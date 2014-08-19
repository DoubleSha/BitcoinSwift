//
//  PeerConnection.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

// Delegate methods may be called from a background thread.
@objc public protocol PeerConnectionDelegate : class {
  optional func peerConnectionDidConnect(peerConnection: PeerConnection)
}

public class PeerConnection: NSObject, NSStreamDelegate {

  public var delegate: PeerConnectionDelegate?
  public enum Status { case NotConnected, Connecting, Connected }

  private let queue = NSOperationQueue()

  // Depending on the constructor used, either the hostname or the IP will be non-nil.
  private let peerHostname: String?
  private let peerIP: IPAddress?
  private let peerPort: UInt16
  private let networkMagicValue: Message.NetworkMagicValue

  private var inputStream: NSInputStream?
  private var outputStream: NSOutputStream?

  // Messages that are queued to be sent to the connected peer.
  private var messageSendQueue = [Message]()
  // Sometimes we aren't able to send the whole message because the buffer is full. When that
  // happens, we must stash the remaining bytes and try again when we receive a
  // NSStreamEvent.HasBytesAvailable event from the outputStream.
  private var pendingSendBytes = [UInt8]()

  public init(hostname: String,
              port: UInt16,
              networkMagicValue: Message.NetworkMagicValue,
              delegate: PeerConnectionDelegate? = nil) {
    self.delegate = delegate
    self.peerIP = nil
    self.peerHostname = hostname
    self.peerPort = port
    self.networkMagicValue = networkMagicValue
  }

  public init(IP: IPAddress,
              port: UInt16,
              networkMagicValue: Message.NetworkMagicValue,
              delegate: PeerConnectionDelegate? = nil) {
    self.delegate = delegate
    self.peerIP = IP
    self.peerHostname = nil
    self.peerPort = port
    self.networkMagicValue = networkMagicValue
  }

  public func connectWithVersionMessage(versionMessage: VersionMessage) {
    queue.addOperationWithBlock() {
      self.inputStream = nil
      self.outputStream = nil
      NSStream.getStreamsToHostWithName(self.peerHostname!,
                                        port:Int(self.peerPort),
                                        inputStream:&self.inputStream,
                                        outputStream:&self.outputStream)
      assert(self.inputStream != nil)
      assert(self.outputStream != nil)
      self.inputStream!.delegate = self
      self.outputStream!.delegate = self
      // TODO: Do we need to create a separate RunLoop for this to run in the background?
      self.inputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode:NSDefaultRunLoopMode)
      self.outputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode:NSDefaultRunLoopMode)
      self.inputStream!.open()
      self.outputStream!.open()
      self.sendMessageWithPayload(versionMessage)
    }
  }

  public func disconnect() {
    queue.cancelAllOperations()
    if self.inputStream != nil {
      self.inputStream!.close()
    }
    if self.outputStream != nil {
      self.outputStream!.close()
    }
  }

  public func sendMessageWithPayload(payload: MessagePayload) {
    let message = Message(networkMagicValue:networkMagicValue, payload:payload)
    queue.addOperationWithBlock() {
      self.messageSendQueue.append(message)
      self.maybeSend()
    }
  }

  // MARK: - NSStreamDelegate

  public func stream(stream: NSStream!, handleEvent event: NSStreamEvent) {
    switch event {
      case NSStreamEvent.None:
        println("none")
      case NSStreamEvent.OpenCompleted:
        println("open completed")
      case NSStreamEvent.HasBytesAvailable:
        println("has bytes available")
      case NSStreamEvent.HasSpaceAvailable:
        println("has space available")
        queue.addOperationWithBlock() {
          self.maybeSend()
        }
      case NSStreamEvent.ErrorOccurred:
        println("error occurred")
      case NSStreamEvent.EndEncountered:
        println("end encountered")
      default:
        println("ERROR Invalid NSStreamEvent \(event)")
        assert(false, "Invalid NSStreamEvent")
    }
  }

  private func maybeSend() {
    assert(NSOperationQueue.currentQueue() == queue)
    if outputStream == nil {
      return
    }
    if !outputStream!.hasSpaceAvailable {
      return
    }
    if messageSendQueue.count > 0 && pendingSendBytes.count == 0 {
      pendingSendBytes += messageSendQueue.removeAtIndex(0).data.UInt8Array()
    }
    if pendingSendBytes.count > 0 {
      let bytesWritten = outputStream!.write(pendingSendBytes, maxLength:pendingSendBytes.count)
      if bytesWritten > 0 {
        pendingSendBytes.removeRange(0..<bytesWritten)
      }
      if messageSendQueue.count > 0 || pendingSendBytes.count > 0 {
        queue.addOperationWithBlock() {
          self.maybeSend()
        }
      }
    }
  }
}
