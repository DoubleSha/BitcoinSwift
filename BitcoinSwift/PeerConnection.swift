//
//  PeerConnection.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

// Delegate methods may be called from a background thread.
public protocol PeerConnectionDelegate : class {
  func peerConnection(peerConnection: PeerConnection,
                      didConnectWithPeerVersion peerVersion: VersionMessage)
  func peerConnection(peerConnection: PeerConnection, didDisconnectWithError error: NSError?)
}

public class PeerConnection: NSObject, NSStreamDelegate {

  public var delegate: PeerConnectionDelegate?
  public enum Status { case NotConnected, Connecting, Connected, Disconnecting }
  public var status: Status { return _status }
  private var _status: Status = .NotConnected

  // Depending on the constructor used, either the hostname or the IP will be non-nil.
  private let peerHostname: String?
  private let peerIP: IPAddress?
  private let peerPort: UInt16
  private let network: Message.Network

  private var inputStream: NSInputStream!
  private var outputStream: NSOutputStream!

  // Messages that are queued to be sent to the connected peer.
  private var messageSendQueue: [Message] = []
  // Sometimes we aren't able to send the whole message because the buffer is full. When that
  // happens, we must stash the remaining bytes and try again when we receive a
  // NSStreamEvent.HasBytesAvailable event from the outputStream.
  private var pendingSendBytes: [UInt8] = []
  // We receive a message in chunks. When we have received only part of a message, but not the
  // whole thing, receivedBytes stores the pending bytes, and add onto it the next time
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
              delegate: PeerConnectionDelegate? = nil) {
    self.delegate = delegate
    self.peerIP = nil
    self.peerHostname = hostname
    self.peerPort = port
    self.network = network
  }

  public init(IP: IPAddress,
              port: UInt16,
              network: Message.Network,
              delegate: PeerConnectionDelegate? = nil) {
    self.delegate = delegate
    self.peerIP = IP
    self.peerHostname = nil
    self.peerPort = port
    self.network = network
  }

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

  public func disconnect() {
    disconnectWithError(nil)
  }

  public func sendMessageWithPayload(payload: MessagePayload) {
    let message = Message(network:network, payload:payload)
    networkThread.addOperationWithBlock {
      self.messageSendQueue.append(message)
      self.send()
    }
  }

  // MARK: - NSStreamDelegate

  public func stream(stream: NSStream!, handleEvent event: NSStreamEvent) {
    assert(NSThread.currentThread() == networkThread)
    switch event {
      case NSStreamEvent.None:
        println("none")
      case NSStreamEvent.OpenCompleted:
        println("open completed")
      case NSStreamEvent.HasBytesAvailable:
        self.receive()
      case NSStreamEvent.HasSpaceAvailable:
        self.send()
      case NSStreamEvent.ErrorOccurred:
        println("error occurred")
      case NSStreamEvent.EndEncountered:
        println("end encountered")
      default:
        println("ERROR Invalid NSStreamEvent \(event)")
        assert(false, "Invalid NSStreamEvent")
    }
  }

  // MARK: - Private Methods

  private func send() {
    assert(NSThread.currentThread() == networkThread)
    if outputStream == nil {
      return
    }
    if !outputStream.hasSpaceAvailable {
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

  private func receive() {
    assert(NSThread.currentThread() == networkThread)
    if inputStream == nil {
      return
    }
    if !inputStream.hasBytesAvailable {
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

  private func processMessageWithHeader(header: Message.Header, payloadData: NSData) {
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
          disconnectWithError(errorWithCode(ErrorCode.ConnectionFailed))
          break
        }
        if !isPeerVersionSupported(versionMessage!) {
          disconnectWithError(errorWithCode(ErrorCode.UnsupportedPeerVersion))
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
        println("WARN: Unknown command \(header.command.toRaw())")
    }
  }

  private func disconnectWithError(error: NSError?) {
    setStatus(.Disconnecting)
    networkThread.addOperationWithBlock {
      self.inputStream?.close()
      self.outputStream?.close()
      self.inputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode:NSDefaultRunLoopMode)
      self.outputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode:NSDefaultRunLoopMode)
      self.peerVersion = nil
      self.receivedVersionAck = false
      self.setStatus(.NotConnected)
      self.delegate?.peerConnection(self, didDisconnectWithError:error)
      NSThread.exit()
    }
  }

  // Returns -1 if the header start was not found. Otherwise returns the index in the bytes.
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
    assert(status == .Connecting && peerVersion != nil && receivedVersionAck)
    _status = .Connected
    delegate?.peerConnection(self, didConnectWithPeerVersion:peerVersion!)
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
    case Unknown = 0, ConnectionFailed, UnsupportedPeerVersion, StreamError, StreamEnded
  }
}
