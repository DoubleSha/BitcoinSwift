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
}

public class PeerConnection {
  public var delegate: PeerConnectionDelegate?
  public enum State { case NotConnected, Connecting, Connected }

  private let queue = NSOperationQueue()

  // Depending on the constructor used, either the hostname or the IP will be non-nil.
  private let peerHostname: String?
  private let peerIP: IPAddress?
  private let peerPort: UInt16

  private var inputStream: NSInputStream?
  private var outputStream: NSOutputStream?

  init(hostname: String, port: UInt16, delegate: PeerConnectionDelegate? = nil) {
    self.delegate = delegate
    self.peerIP = nil
    self.peerHostname = hostname
    self.peerPort = port
  }

  init(IP: IPAddress, port: UInt16, delegate: PeerConnectionDelegate? = nil) {
    self.delegate = delegate
    self.peerIP = IP
    self.peerHostname = nil
    self.peerPort = port
  }

  func connect() {
    NSLog("Connecting");
    queue.addOperationWithBlock() {
      NSStream.getStreamsToHostWithName(self.peerHostname!,
                                        port:Int(self.peerPort),
                                        inputStream:&self.inputStream,
                                        outputStream:&self.outputStream)
      assert(self.inputStream != nil)
      assert(self.outputStream != nil)
      self.inputStream!.open()
      self.outputStream!.open()
    }
  }

  func disconnect() {

  }
}
