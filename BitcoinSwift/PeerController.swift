//
//  PeerController.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/17/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public protocol PeerControllerDelegate: class {
  func blockChainSyncComplete()
}

// TODO: Clean this up. This is ugly and hacked right now. I just threw something together to
// demo header sync'ing with the dlheader.swift script.

public class PeerController {

  private let hostname: String
  private let port: UInt16
  private let network: NetworkMagicNumber
  private let queue: NSOperationQueue
  private let blockChainStore: BlockChainStore
  private var connection: PeerConnection?
  private weak var delegate: PeerControllerDelegate?
  private var peerVersion: VersionMessage?
  private var headersDownloaded = 0

  public init(hostname: String,
              port: UInt16,
              network: NetworkMagicNumber,
              blockChainStore: BlockChainStore,
              queue: NSOperationQueue = NSOperationQueue.mainQueue(),
              delegate: PeerControllerDelegate? = nil) {
    self.hostname = hostname
    self.port = port
    self.network = network
    self.blockChainStore = blockChainStore
    self.queue = queue
    self.delegate = delegate
  }

  public func start() {
    precondition(connection == nil)
    queue.addOperationWithBlock {
      self.headersDownloaded = 0
      self.connection = PeerConnection(hostname: self.hostname,
                                       port: self.port,
                                       network: self.network,
                                       delegate: self,
                                       delegateQueue: self.queue)
      self.connection!.connectWithVersionMessage(self.createVersion())
    }
  }

  private func createVersion() -> VersionMessage {
    let senderPeerAddress = PeerAddress(services: PeerServices.NodeNetwork,
                                        IP: IPAddress.IPV4(0x00000000),
                                        port: 0)
    let receiverPeerAddress = PeerAddress(services: PeerServices.NodeNetwork,
                                          IP: IPAddress.IPV4(0x00000000),
                                          port: 0)
    return VersionMessage(protocolVersion: 70002,
                          services: PeerServices.NodeNetwork,
                          date: NSDate(),
                          senderAddress: senderPeerAddress,
                          receiverAddress: receiverPeerAddress,
                          nonce: 0x5e9e17ca3e515405,
                          userAgent: "/BitcoinSwift:0.0.1/",
                          blockStartHeight: 0,
                          announceRelayedTransactions: false)
  }

  private var genesisBlockHash: SHA256Hash {
    let bytes: [UInt8] = [
        0x00, 0x00, 0x00, 0x00, 0x00, 0x19, 0xd6, 0x68,
        0x9c, 0x08, 0x5a, 0xe1, 0x65, 0x83, 0x1e, 0x93,
        0x4f, 0xf7, 0x63, 0xae, 0x46, 0xa2, 0xa6, 0xc1,
        0x72, 0xb3, 0xf1, 0xb6, 0x0a, 0x8c, 0xe2, 0x6f]
    return SHA256Hash(bytes: bytes)
  }
}

extension PeerController: PeerConnectionDelegate {

  public func peerConnection(peerConnection: PeerConnection,
                             didConnectWithPeerVersion peerVersion: VersionMessage) {
    queue.addOperationWithBlock {
      self.peerVersion = peerVersion
      let getHeadersMessage = GetHeadersMessage(protocolVersion: 70002,
                                                blockLocatorHashes: [self.genesisBlockHash])
      self.connection?.sendMessageWithPayload(getHeadersMessage)
    }
  }

  public func peerConnection(peerConnection: PeerConnection,
                             didDisconnectWithError error: NSError?) {
    Logger.info("Connection failed")
  }

  public func peerConnection(peerConnection: PeerConnection,
                             didReceiveMessage message: PeerConnectionMessage) {
    switch message {
      case .InventoryMessage(let inventoryMessage):
        Logger.info("Inventory Message")
        for inventoryVector in inventoryMessage.inventoryVectors {
          Logger.info("  " + inventoryVector.description)
        }
      case .HeadersMessage(let headersMessage):
        queue.addOperationWithBlock {
          self.headersDownloaded += headersMessage.headers.count
          // If there are still more headers to sync, request more.
          if headersMessage.headers.count == 2000 {
            let percentComplete = Double(self.headersDownloaded) /
                Double(self.peerVersion!.blockStartHeight) * 100
            Logger.info("Received \(headersMessage.headers.count) block headers - " +
                "\(Int(percentComplete))% complete")
            let lastHeaderHash = headersMessage.headers.last!.hash
            let getHeadersMessage = GetHeadersMessage(protocolVersion: 70002,
                                                      blockLocatorHashes: [lastHeaderHash])
            self.connection?.sendMessageWithPayload(getHeadersMessage)
          } else {
            Logger.info("Header sync complete")
            if let delegate = self.delegate {
              delegate.blockChainSyncComplete()
            }
          }
        }
      default:
        break
    }
  }
}
