//
//  PeerConnection.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// Conform to this protocol if you want to be notified of the low-level P2P messages received from
/// the connected peer.
public protocol PeerConnectionDelegate: class {

  /// Called when a connection is successfully established with the remote peer.
  /// peerVersion is the version message received from the peer during the version handshake.
  func peerConnection(peerConnection: PeerConnection,
                      didConnectWithPeerVersion peerVersion: VersionMessage)

  /// Called when the connection to the remote peer is closed for any reason.
  /// If the connection was closed due to an error, then error will be non-nil.
  func peerConnection(peerConnection: PeerConnection, didDisconnectWithError error: NSError?)

  /// Called when a message is received. Switch on message to handle the actual message.
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveMessage message: PeerConnectionMessage)
}

public enum PeerConnectionMessage {
  case PeerAddressMessage(BitcoinSwift.PeerAddressMessage)
  case InventoryMessage(BitcoinSwift.InventoryMessage)
  case GetDataMessage(BitcoinSwift.GetDataMessage)
  case NotFoundMessage(BitcoinSwift.NotFoundMessage)
  case GetBlocksMessage(BitcoinSwift.GetBlocksMessage)
  case GetHeadersMessage(BitcoinSwift.GetHeadersMessage)
  case Transaction(BitcoinSwift.Transaction)
  case Block(BitcoinSwift.Block)
  case HeadersMessage(BitcoinSwift.HeadersMessage)
  case GetPeerAddressMessage(BitcoinSwift.GetPeerAddressMessage)
  case MemPoolMessage(BitcoinSwift.MemPoolMessage)
  case PingMessage(BitcoinSwift.PingMessage)
  case PongMessage(BitcoinSwift.PongMessage)
  case RejectMessage(BitcoinSwift.RejectMessage)
  case FilterLoadMessage(BitcoinSwift.FilterLoadMessage)
  case FilterAddMessage(BitcoinSwift.FilterAddMessage)
  case FilterClearMessage(BitcoinSwift.FilterClearMessage)
  case FilteredBlock(BitcoinSwift.FilteredBlock)
  case AlertMessage(BitcoinSwift.AlertMessage)
}

/// A PeerConnection handles the low-level socket connection to a peer and serializing/deserializing
/// messages to/from the Bitcoin p2p wire format.
///
/// Use PeerConnection to send messages and receive notifications when new messages are received.
/// For higher-level peer state management, such as downloading the blockchain, managing bloom
/// filters, etc, use the PeerController class.
///
/// All message sending, receiving, and serialization is done on a dedicated background thread.
/// By default, delegate methods are dispatched on the main queue. A different queue may be used by
/// passing a delegateQueue to the constructor.
public class PeerConnection: NSObject, NSStreamDelegate, MessageParserDelegate {

  public enum Status { case NotConnected, Connecting, Connected, Disconnecting }

  /// The current status of the connection.
  public var status: Status { return _status }
  private var _status: Status = .NotConnected

  public weak var delegate: PeerConnectionDelegate?
  private var delegateQueue: NSOperationQueue

  private let peerHostname: String?
  private let peerPort: UInt16
  private let network: Message.Network

  // Parses raw data received off the wire into Message objects.
  private let messageParser: MessageParser

  // Streams used to read and write data from the connected peer.
  private var inputStream: NSInputStream!
  private var outputStream: NSOutputStream!

  // Messages that are queued to be sent to the connected peer.
  private var messageSendQueue: [Message] = []
  // Sometimes we aren't able to send the whole message because the buffer is full. When that
  // happens, we must stash the remaining bytes and try again when we receive a
  // NSStreamEvent.HasBytesAvailable event from the outputStream.
  private var pendingSendBytes: [UInt8] = []
  private var readBuffer = [UInt8](count: 1024, repeatedValue: 0)

  private let networkThread = Thread()

  private var connectionTimeoutTimer: NSTimer? = nil

  // The version message received by the peer in response to our version message.
  private var peerVersion: VersionMessage? = nil
  // Indicates if the peer has ack'd our version message yet.
  private var receivedVersionAck = false

  public init(hostname: String,
              port: UInt16,
              network: Message.Network,
              delegate: PeerConnectionDelegate? = nil,
              delegateQueue: NSOperationQueue = NSOperationQueue.mainQueue()) {
    self.delegate = delegate
    self.peerHostname = hostname
    self.peerPort = port
    self.network = network
    self.delegateQueue = delegateQueue
    self.messageParser = MessageParser(network: network)
    super.init()
    self.messageParser.delegate = self
  }

  /// Attempts to open a connection to the remote peer.
  /// Once the socket is successfully opened, versionMessage is sent to the remote peer.
  /// The connection is considered "open" after the peer responds to the versionMessage with its
  /// own VersionMessage and a VersionAck confirming it is compatible.
  public func connectWithVersionMessage(versionMessage: VersionMessage,
                                        timeout: NSTimeInterval = 5) {
    precondition(status == .NotConnected)
    precondition(!networkThread.executing)
    precondition(!receivedVersionAck)
    precondition(connectionTimeoutTimer == nil)
    setStatus(.Connecting)
    Logger.info("Attempting to connect to peer \(peerHostname!):\(peerPort)")
    connectionTimeoutTimer =
        NSTimer.scheduledTimerWithTimeInterval(timeout,
                                               target: self,
                                               selector: "connectionTimerDidTimeout:",
                                               userInfo: nil,
                                               repeats: false)
    networkThread.startWithCompletion {
      self.networkThread.addOperationWithBlock {
        if let (inputStream, outputStream) =
            self.streamsToPeerWithHostname(self.peerHostname!, port: self.peerPort) {
          self.inputStream = inputStream
          self.outputStream = outputStream
          self.inputStream.delegate = self
          self.outputStream.delegate = self
          self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(),
                                             forMode: NSDefaultRunLoopMode)
          self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(),
                                              forMode: NSDefaultRunLoopMode)
          self.inputStream.open()
          self.outputStream.open()
          self.sendMessageWithPayload(versionMessage)
        }
      }
    }
  }

  /// Closes the connection with the remote peer. Should only be called if status is .Connected.
  public func disconnect() {
    disconnectWithError(nil)
  }

  /// Queues the provided message to be sent to the connected peer.
  /// If status is not yet Connected, the message will be queued and sent once the connection is
  /// established.
  /// This method is thread-safe. It can be called from any thread. Messages are sent on a
  /// dedicated background thread.
  public func sendMessageWithPayload(payload: MessagePayload) {
    let message = Message(network: network, payload: payload)
    networkThread.addOperationWithBlock {
      self.messageSendQueue.append(message)
      self.send()
    }
  }

  // MARK: - NSStreamDelegate

  public func stream(stream: NSStream, handleEvent event: NSStreamEvent) {
    precondition(NSThread.currentThread() == networkThread)
    switch event {
      case NSStreamEvent.None: 
        break
      case NSStreamEvent.OpenCompleted: 
        break
      case NSStreamEvent.HasBytesAvailable: 
        self.receive()
      case NSStreamEvent.HasSpaceAvailable: 
        self.send()
      case NSStreamEvent.ErrorOccurred: 
        disconnectWithError(errorWithCode(.StreamError))
      case NSStreamEvent.EndEncountered: 
        disconnectWithError(errorWithCode(.StreamEndEncountered))
      default: 
        Logger.error("Invalid NSStreamEvent \(event)")
        assert(false, "Invalid NSStreamEvent")
    }
  }

  // MARK: - MessageParserDelegate

  // Parses the payload from payloadData given the provided header, and notifies the delegate if
  // parsing was successful. For some message types (e.g. VersionAck), payloadData is expected to
  // have a length of 0.
  public func didParseMessage(message: Message) {
    Logger.debug("Received \(message.header.command.rawValue) message")
    let payloadStream = NSInputStream(data: message.payload)
    payloadStream.open()
    switch message.header.command {
      case .Version: 
        if peerVersion != nil {
          Logger.warn("Received extraneous VersionMessage. Ignoring")
          break
        }
        assert(status == .Connecting)
        let versionMessage = VersionMessage.fromBitcoinStream(payloadStream)
        if versionMessage == nil {
          disconnectWithError(errorWithCode(.Unknown))
          break
        }
        if !isPeerVersionSupported(versionMessage!) {
          disconnectWithError(errorWithCode(.UnsupportedPeerVersion))
          break
        }
        peerVersion = versionMessage!
        sendVersionAck()
        if receivedVersionAck {
          didConnect()
        }
      case .VersionAck: 
        if status != .Connecting {
          // The connection might have been cancelled, or it might have failed. For example,
          // the connection can fail if we received an invalid VersionMessage from the peer.
          Logger.warn("Ignoring VersionAck message because not in Connecting state")
          break
        }
        receivedVersionAck = true
        if peerVersion != nil {
          didConnect()
        }
      case .Address:
        if let peerAddressMessage = PeerAddressMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.PeerAddressMessage(peerAddressMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .Inventory:
        if let inventoryMessage = InventoryMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.InventoryMessage(inventoryMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .GetData:
        if let getDataMessage = GetDataMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.GetDataMessage(getDataMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .NotFound:
        if let notFoundMessage = NotFoundMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.NotFoundMessage(notFoundMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .GetBlocks:
        if let getBlocksMessage = GetBlocksMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.GetBlocksMessage(getBlocksMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .GetHeaders:
        if let getHeadersMessage = GetHeadersMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.GetHeadersMessage(getHeadersMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .Transaction:
        if let transaction = Transaction.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.Transaction(transaction)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .Block:
        if let block = Block.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.Block(block)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .Headers:
        if let headersMessage = HeadersMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.HeadersMessage(headersMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .GetAddress:
        if let getPeerAddressMessage = GetPeerAddressMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.GetPeerAddressMessage(getPeerAddressMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .MemPool:
        if let memPoolMessage = MemPoolMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.MemPoolMessage(memPoolMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .Ping:
        if let pingMessage = PingMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.PingMessage(pingMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .Pong:
        if let pongMessage = PongMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.PongMessage(pongMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .Reject:
        if let rejectMessage = RejectMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.RejectMessage(rejectMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .FilterLoad:
        if let filterLoadMessage = FilterLoadMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.FilterLoadMessage(filterLoadMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .FilterAdd:
        if let filterAddMessage = FilterAddMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.FilterAddMessage(filterAddMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .FilterClear:
        if let filterClearMessage = FilterClearMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.FilterClearMessage(filterClearMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .FilteredBlock:
        if let filteredBlock = FilteredBlock.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.FilteredBlock(filteredBlock)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      case .Alert:
        if let alertMessage = AlertMessage.fromBitcoinStream(payloadStream) {
          let message = PeerConnectionMessage.AlertMessage(alertMessage)
          delegate?.peerConnection(self, didReceiveMessage: message)
        }
      default: 
        Logger.warn("Received unknown command \(message.header.command.rawValue). Ignoring")
    }
    payloadStream.close()
  }

  // MARK: - Private Methods

  // Exposed for testing. Override this method to mock out the streams.
  // Initializes the socket connection and returns an NSInputStream and NSOutputStream for
  // sending and receiving raw data.
  public func streamsToPeerWithHostname(hostname: String, port: UInt16) ->
      (inputStream: NSInputStream, outputStream: NSOutputStream)? {
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?
    CFStreamCreatePairWithSocketToHost(nil,
                                       hostname as NSString,
                                       UInt32(port),
                                       &readStream,
                                       &writeStream);
    if readStream == nil || writeStream == nil {
      Logger.info("Connection failed to peer \(self.peerHostname!):\(self.peerPort)")
      self.setStatus(.NotConnected)
      return nil
    }
    return (readStream!.takeUnretainedValue(), writeStream!.takeUnretainedValue())
  }

  // Dequeues a message from the messageSendQueue and tries to send it. This should be called
  // whenever a new message is added to messageSendQueue, or while there are still bytes left
  // to send in pendingSendBytes.
  private func send() {
    precondition(NSThread.currentThread() == networkThread)
    if let outputStream = outputStream {
      sendWithStream(outputStream)
    }
  }

  // Helper method for send(). Do not call directly.
  private func sendWithStream(outputStream: NSOutputStream) {
    if !outputStream.hasSpaceAvailable {
      return
    }
    if messageSendQueue.count > 0 && pendingSendBytes.count == 0 {
      let message = messageSendQueue.removeAtIndex(0)
      Logger.debug("Sending \(message.header.command.rawValue) message")
      pendingSendBytes += message.bitcoinData.UInt8Array
    }
    if pendingSendBytes.count > 0 {
      let bytesWritten = outputStream.write(pendingSendBytes, maxLength: pendingSendBytes.count)
      if bytesWritten > 0 {
        pendingSendBytes.removeRange(0..<bytesWritten)
      }
      if messageSendQueue.count > 0 || pendingSendBytes.count > 0 {
        networkThread.addOperationWithBlock {
          self.send()
        }
      }
    }
  }

  // Reads from the inputStream until it no longer has bytes available and parses as much as it can.
  // This should be called whenever inputStream has new bytes available.
  // Notifies the delegate for messages that are parsed.
  private func receive() {
    precondition(NSThread.currentThread() == networkThread)
    if let inputStream = inputStream {
      receiveWithStream(inputStream)
    }
  }

  // Helper method for receive(). Do not call directly.
  private func receiveWithStream(inputStream: NSInputStream) {
    if !inputStream.hasBytesAvailable {
      return
    }
    let bytesRead = inputStream.read(&readBuffer, maxLength: readBuffer.count)
    if bytesRead > 0 {
      messageParser.parseBytes([UInt8](readBuffer[0..<bytesRead]))
      if inputStream.hasBytesAvailable {
        networkThread.addOperationWithBlock {
          self.receive()
        }
      }
    }
  }

  private func disconnectWithError(error: NSError?) {
    if status == .Disconnecting || status == .NotConnected {
      return
    }
    if let error = error {
      Logger.warn("Socket error \(error)")
    }
    setStatus(.Disconnecting)
    connectionTimeoutTimer?.invalidate()
    connectionTimeoutTimer = nil
    networkThread.addOperationWithBlock {
      self.inputStream?.close()
      self.outputStream?.close()
      self.inputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(),
                                          forMode: NSDefaultRunLoopMode)
      self.outputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(),
                                           forMode: NSDefaultRunLoopMode)
      self.peerVersion = nil
      self.receivedVersionAck = false
      self.setStatus(.NotConnected)
      self.delegateQueue.addOperationWithBlock {
        // For some reason, using self.delegate? within a block doesn't compile... Xcode bug?
        if let delegate = self.delegate {
          delegate.peerConnection(self, didDisconnectWithError: error)
        }
      }
      self.networkThread.cancel()
    }
  }

  private func didConnect() {
    precondition(status == .Connecting)
    precondition(self.peerVersion != nil)
    precondition(receivedVersionAck)
    Logger.info("Connected to peer \(peerHostname!):\(peerPort)")
    connectionTimeoutTimer?.invalidate()
    connectionTimeoutTimer = nil
    setStatus(.Connected)
    let peerVersion = self.peerVersion!
    self.delegateQueue.addOperationWithBlock {
      // For some reason, using self.delegate? within a block doesn't compile... Xcode bug?
      if let delegate = self.delegate {
        delegate.peerConnection(self, didConnectWithPeerVersion: peerVersion)
      }
    }
  }

  private func sendVersionAck() {
    sendMessageWithPayload(VersionAckMessage())
  }

  private func errorWithCode(code: ErrorCode) -> NSError {
    return NSError(domain: ErrorDomain, code: code.rawValue, userInfo: nil)
  }

  private func isPeerVersionSupported(versionMessage: VersionMessage) -> Bool {
    // TODO: Make this a real check.
    return true
  }

  private func setStatus(newStatus: Status) {
    _status = newStatus
  }

  func connectionTimerDidTimeout(timer: NSTimer) {
    connectionTimeoutTimer?.invalidate()
    connectionTimeoutTimer = nil
    if status == .Connecting {
      disconnectWithError(errorWithCode(.ConnectionTimeout))
    }
  }
}

extension PeerConnection {

  public var ErrorDomain: String { return "BitcoinSwift.PeerConnection" }

  public enum ErrorCode: Int {
    case Unknown = 0,
        ConnectionTimeout,
        UnsupportedPeerVersion,
        StreamError,
        StreamEndEncountered
  }
}
