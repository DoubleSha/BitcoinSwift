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
  public enum State { case NotConnected, Connecting, Connected }

  private let queue = NSOperationQueue()

  // Depending on the constructor used, either the hostname or the IP will be non-nil.
  private let peerHostname: String?
  private let peerIP: IPAddress?
  private let peerPort: UInt16

  private var inputStream: NSInputStream?
  private var outputStream: NSOutputStream?

  public init(hostname: String, port: UInt16, delegate: PeerConnectionDelegate? = nil) {
    self.delegate = delegate
    self.peerIP = nil
    self.peerHostname = hostname
    self.peerPort = port
  }

  public init(IP: IPAddress, port: UInt16, delegate: PeerConnectionDelegate? = nil) {
    self.delegate = delegate
    self.peerIP = IP
    self.peerHostname = nil
    self.peerPort = port
  }

  public func connect() {
    queue.addOperationWithBlock() {
      NSStream.getStreamsToHostWithName(self.peerHostname!,
                                        port:Int(self.peerPort),
                                        inputStream:&self.inputStream,
                                        outputStream:&self.outputStream)
      assert(self.inputStream != nil)
      assert(self.outputStream != nil)
      self.inputStream!.delegate = self
      self.outputStream!.delegate = self
      self.inputStream!.open()
      self.outputStream!.open()
    }
  }

  public func disconnect() {
    // TODO
  }

  public func sendMessageWithPayload(payload: MessagePayload) {
    // TODO
  }

  // MARK: - NSStreamDelegate

  public func stream(aStream: NSStream!, handleEvent eventCode: NSStreamEvent) {
    switch eventCode {
      case NSStreamEvent.None:
        println("none")
      case NSStreamEvent.OpenCompleted:
        println("open completed")
      case NSStreamEvent.HasBytesAvailable:
        println("has bytes available")
      case NSStreamEvent.HasSpaceAvailable:
        println("has space available")
      case NSStreamEvent.ErrorOccurred:
        println("error occurred")
      case NSStreamEvent.EndEncountered:
        println("end encountered")
      default:
        println("ERROR Invalid NSStreamEvent code \(eventCode)")
        assert(false, "Invalid NSStreamEvent code")
    }
  }
}
