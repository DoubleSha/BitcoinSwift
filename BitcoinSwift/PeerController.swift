//
//  PeerController.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/17/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public class PeerController {

  private let version: VersionMessage
  private let queue: NSOperationQueue
  private let blockStore: SPVBlockStore
  private let peerConnection: PeerConnection

  public init(hostname: String,
              port: UInt16,
              network: Message.Network,
              version: VersionMessage,
              blockStore: SPVBlockStore,
              queue: NSOperationQueue = NSOperationQueue.mainQueue()) {
    self.version = version
    self.queue = queue
    self.blockStore = blockStore
    self.peerConnection = PeerConnection(hostname: hostname,
                                         port: port,
                                         network: network)
  }

  public func downloadHeaders() {

  }
}

extension PeerController: PeerConnectionDelegate {

  public func peerConnection(peerConnection: PeerConnection,
                             didConnectWithPeerVersion peerVersion: VersionMessage) {

  }

  public func peerConnection(peerConnection: PeerConnection,
                             didDisconnectWithError error: NSError?) {

  }

  public func peerConnection(peerConnection: PeerConnection,
                             didReceiveMessage message: PeerConnectionMessage) {

  }
}
