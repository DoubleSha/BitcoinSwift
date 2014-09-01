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
public protocol PeerConnectionDelegate : class {

  /// Called when a connection is successfully established with the remote peer.
  /// peerVersion is the version message received from the peer during the version handshake.
  func peerConnection(peerConnection: PeerConnection,
                      didConnectWithPeerVersion peerVersion: VersionMessage)

  /// Called when the connection to the remote peer is closed for any reason.
  /// If the connection was closed due to an error, then error will be non-nil.
  func peerConnection(peerConnection: PeerConnection, didDisconnectWithError error: NSError?)
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
public class PeerConnection: NSObject, NSStreamDelegate {

  public enum Status { case NotConnected, Connecting, Connected, Disconnecting }

  /// The current status of the connection.
  public var status: Status { return _status }
  private var _status: Status = .NotConnected

  private var delegate: PeerConnectionDelegate?
  private var delegateQueue: dispatch_queue_t

  // Depending on the constructor used, either the hostname or the IP will be non-nil.
  private let peerHostname: String?
  private let peerIP: IPAddress?
  private let peerPort: UInt16
  private let network: Message.Network

  // Streams used to read & write data from the connected peer.
  private var inputStream: NSInputStream!
  private var outputStream: NSOutputStream!

  // Messages that are queued to be sent to the connected peer.
  private var messageSendQueue: [Message] = []
  // Sometimes we aren't able to send the whole message because the buffer is full. When that
  // happens, we must stash the remaining bytes and try again when we receive a
  // NSStreamEvent.HasBytesAvailable event from the outputStream.
  private var pendingSendBytes: [UInt8] = []
  // We receive a message in chunks. When we have received only part of a message, but not the
  // whole thing, receivedBytes stores the pending bytes, and adds onto it the next time
  // we receive a NSStreamEvent.HasBytesAvailable event.
  private var receivedBytes: [UInt8] = []
  // The header for the message we are about to receive. This is non-nil when we have received
  // enough bytes to parse the header, but haven't received the full message yet.
  private var receivedHeader: Message.Header? = nil
  private var readBuffer = [UInt8](count:1024, repeatedValue:0)

  private let networkThread = Thread()

  // The version message received by the peer in response to our version message.
  private var peerVersion: VersionMessage? = nil
  // Indicates if the peer has ack'd our version message yet.
  private var receivedVersionAck = false

  public init(hostname: String,
              port: UInt16,
              network: Message.Network,
              delegate: PeerConnectionDelegate? = nil,
              delegateQueue: dispatch_queue_t = dispatch_get_main_queue()) {
    self.delegate = delegate
    self.peerIP = nil
    self.peerHostname = hostname
    self.peerPort = port
    self.network = network
    self.delegateQueue = delegateQueue
  }

  public init(IP: IPAddress,
              port: UInt16,
              network: Message.Network,
              delegate: PeerConnectionDelegate? = nil,
              delegateQueue: dispatch_queue_t = dispatch_get_main_queue()) {
    self.delegate = delegate
    self.peerIP = IP
    self.peerHostname = nil
    self.peerPort = port
    self.network = network
    self.delegateQueue = delegateQueue
  }

  /// Attempts to open a connection to the remote peer.
  /// Once the socket is successfully opened, versionMessage is sent to the remote peer.
  /// The connection is considered "open" after the peer responds to the versionMessage with its
  /// own VersionMessage and a VersionAck confirming it is compatible.
  public func connectWithVersionMessage(versionMessage: VersionMessage) {
    assert(status == .NotConnected)
    assert(!networkThread.executing)
    assert(!receivedVersionAck)
    setStatus(.Connecting)
    println("Attempting to connect to peer \(peerHostname!):\(peerPort)")
    networkThread.startWithCompletion {
      self.networkThread.addOperationWithBlock {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        // TODO: Support peerIP here instead of just peerHostname.
        CFStreamCreatePairWithSocketToHost(nil,
                                           self.peerHostname! as NSString,
                                           UInt32(self.peerPort),
                                           &readStream,
                                           &writeStream);
        if readStream == nil || writeStream == nil {
          println("Connection failed to peer \(self.peerHostname!):\(self.peerPort)")
          self.setStatus(.NotConnected)
          return
        }
        self.inputStream = readStream!.takeUnretainedValue()
        self.outputStream = writeStream!.takeUnretainedValue()
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode:NSDefaultRunLoopMode)
        self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(),
                                            forMode:NSDefaultRunLoopMode)
        self.inputStream.open()
        self.outputStream.open()
        self.sendMessageWithPayload(versionMessage)
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
    let message = Message(network:network, payload:payload)
    networkThread.addOperationWithBlock {
      self.messageSendQueue.append(message)
      self.send()
    }
  }

  // MARK: - NSStreamDelegate

  func stream(stream: NSStream!, handleEvent event: NSStreamEvent) {
    assert(NSThread.currentThread() == networkThread)
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
        println("ERROR: Invalid NSStreamEvent \(event)")
        assert(false, "Invalid NSStreamEvent")
    }
  }

  // MARK: - Private Methods

  // Dequeues a message from the messageSendQueue and tries to send it. This should be called
  // whenever a new message is added to messageSendQueue, or while there are still bytes left
  // to send in pendingSendBytes.
  private func send() {
    assert(NSThread.currentThread() == networkThread)
    if outputStream == nil || !outputStream.hasSpaceAvailable {
      return
    }
    if messageSendQueue.count > 0 && pendingSendBytes.count == 0 {
      let message = messageSendQueue.removeAtIndex(0)
      println("Sending \(message.header.command.toRaw()) message")
      pendingSendBytes += message.data.UInt8Array()
    }
    if pendingSendBytes.count > 0 {
      let bytesWritten = outputStream!.write(pendingSendBytes, maxLength:pendingSendBytes.count)
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
    assert(NSThread.currentThread() == networkThread)
    if inputStream == nil || !inputStream.hasBytesAvailable {
      return
    }
    let bytesRead = inputStream.read(&readBuffer, maxLength:readBuffer.count)
    if bytesRead > 0 {
      receivedBytes += readBuffer[0..<bytesRead]
      processReceivedBytes()
      if inputStream.hasBytesAvailable {
        networkThread.addOperationWithBlock {
          self.receive()
        }
      }
    }
  }

  // Helper method for receive().
  // Consumes the data in receivedBytes by parsing it into Messages, or discarding invalid data.
  // Doesn't return until all data in receivedBytes has been consumed, or until more data must be
  // received to parse a valid message.
  private func processReceivedBytes() {
    while true {
      if receivedHeader == nil {
        let headerStartIndex = headerStartIndexInBytes(receivedBytes)
        if headerStartIndex < 0 {
          // We did not find the message start, so we must wait for more bytes.
          // Throw away the bytes we have since we couldn't figure out how to handle them.
          // We might have all but the last byte of the networkMagicBytes for the next message,
          // so keep the last 3 bytes.
          let end = receivedBytes.count - network.magicBytes.count + 1
          if end > 0 {
            receivedBytes.removeRange(0..<end)
          }
          return
        }
        // Remove the bytes before startIndex since we don't know what they are.
        receivedBytes.removeRange(0..<headerStartIndex)
        if receivedBytes.count < Message.Header.length {
          // We're expecting a header, but there aren't enough bytes yet to parse one.
          // Wait for more bytes to be received.
          return
        }
        let data = NSData(bytes:receivedBytes, length:receivedBytes.count)
        receivedHeader = Message.Header.fromData(data)
        if receivedHeader == nil {
          // Failed to parse the header for some reason. It's possible that the networkMagicBytes
          // coincidentally appeared in the byte data, or the header was invalid for some reason.
          // Strip the networkMagicBytes so we can advance and try to parse again.
          receivedBytes.removeRange(0..<network.magicBytes.count)
          continue
        }
        // receivedHeader is guaranteed to be non-nil at this point.
        // We successfully parsed the header from receivedBytes, so remove those bytes.
        receivedBytes.removeRange(0..<Message.Header.length)
      }
      assert(Message.Header.length == 24)
      // NOTE: payloadLength can be 0 for some message types, e.g. VersionAck.
      let payloadLength = Int(receivedHeader!.payloadLength)
      // TODO: Need to figure out a maximum length to allow here, or somebody could DOS us by
      // providing a huge value for payloadLength.
      if receivedBytes.count < payloadLength {
        // Haven't received the whole message yet. Wait for more bytes.
        return
      }
      let payloadData = NSData(bytes:receivedBytes, length:payloadLength)
      processMessageWithHeader(receivedHeader!, payloadData:payloadData)
      receivedBytes.removeRange(0..<payloadLength)
      receivedHeader = nil
    }
  }

  // Parses the payload from payloadData given the provided header, and notifies the delegate if
  // parsing was successful. For some message types (e.g. VersionAck), payloadData is expected to
  // have a length of 0.
  private func processMessageWithHeader(header: Message.Header, payloadData: NSData) {
    // TODO: Add the rest of the messages.
    println("Received \(header.command.toRaw()) message")
    switch header.command {
      case .Version:
        if peerVersion != nil {
          println("WARN: Received extraneous VersionMessage. Ignoring")
          break
        }
        assert(status == .Connecting)
        let versionMessage = VersionMessage.fromData(payloadData)
        if versionMessage == nil {
          disconnectWithError(errorWithCode(.ConnectionFailed))
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
          println("WARN: Ignoring VersionAck message because not in Connecting state")
          return
        }
        receivedVersionAck = true
        if peerVersion != nil {
          didConnect()
        }
      default:
        println("WARN: Received unknown command \(header.command.toRaw()). Ignoring")
    }
  }

  private func disconnectWithError(error: NSError?) {
    setStatus(.Disconnecting)
    let peerConnection: PeerConnection = self
    networkThread.addOperationWithBlock {
      self.inputStream?.close()
      self.outputStream?.close()
      self.inputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode:NSDefaultRunLoopMode)
      self.outputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode:NSDefaultRunLoopMode)
      self.peerVersion = nil
      self.receivedVersionAck = false
      self.setStatus(.NotConnected)
      dispatch_async(self.delegateQueue) {
        // For some reason, using self.delegate? within a block doesn't compile... Xcode bug?
        if let delegate = self.delegate {
          delegate.peerConnection(self, didDisconnectWithError:error)
        }
      }
      NSThread.exit()
    }
  }

  // Returns -1 if the header start (the position of network.magicBytes) was not found.
  // Otherwise returns the position where the message header begins.
  private func headerStartIndexInBytes(bytes: [UInt8]) -> Int {
    let networkMagicBytes = network.magicBytes
    if bytes.count < networkMagicBytes.count {
      return -1
    }
    for i in 0...(bytes.count - networkMagicBytes.count) {
      var found = true
      for j in 0..<networkMagicBytes.count {
        if bytes[i + j] != networkMagicBytes[j] {
          found = false
          break
        }
      }
      if found {
        return i
      }
    }
    return -1
  }

  private func didConnect() {
    assert(status == .Connecting && self.peerVersion != nil && receivedVersionAck)
    _status = .Connected
    let peerVersion = self.peerVersion!
    dispatch_async(delegateQueue) {
      // For some reason, using self.delegate? within a block doesn't compile... Xcode bug?
      if let delegate = self.delegate {
        delegate.peerConnection(self, didConnectWithPeerVersion:peerVersion)
      }
    }
  }

  private func sendVersionAck() {
    sendMessageWithPayload(VersionAckMessage())
  }

  private func errorWithCode(code: ErrorCode) -> NSError {
    return NSError(domain:ErrorDomain, code:ErrorCode.ConnectionFailed.toRaw(), userInfo:nil)
  }

  private func isPeerVersionSupported(versionMessage: VersionMessage) -> Bool {
    // TODO: Make this a real check.
    return true
  }

  private func setStatus(newStatus: Status) {
    _status = newStatus
  }
}

extension PeerConnection {

  public var ErrorDomain: String { return "BitcoinSwift.PeerConnection" }

  public enum ErrorCode: Int {
    case Unknown = 0, ConnectionFailed, UnsupportedPeerVersion, StreamError, StreamEndEncountered
  }
}
