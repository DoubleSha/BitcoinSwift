#!/usr/bin/swift -F /Library/Frameworks

import BitcoinSwift
import Foundation

class DataFetcher: PeerConnectionDelegate {

  let queue = NSOperationQueue()
  let semaphore = dispatch_semaphore_create(0)
  var getDataMessage: GetDataMessage?
  var transactionResponse: Transaction?
  var blockResponse: Block?

  func fetchTransactionWithHash(hash: NSData) -> Transaction? {
    let inventoryVector = InventoryVector(type: .Transaction, hash: hash)
    getDataMessage = GetDataMessage(inventoryVectors: [inventoryVector])
    let connection = connect()
    waitWithTimeout(30)
    connection.disconnect()
    return transactionResponse
  }

  func fetchBlockWithHash(hash: NSData) -> Block? {
    let inventoryVector = InventoryVector(type: .Block, hash: hash)
    getDataMessage = GetDataMessage(inventoryVectors: [inventoryVector])
    let connection = connect()
    waitWithTimeout(30)
    connection.disconnect()
    return blockResponse
  }

  // MARK: - PeerConnectionDelegate

  func peerConnection(peerConnection: PeerConnection,
                      didConnectWithPeerVersion peerVersion: VersionMessage) {
    if let message = getDataMessage {
      peerConnection.sendMessageWithPayload(message)
    }
  }

  func peerConnection(peerConnection: PeerConnection, didDisconnectWithError error: NSError?) {
    dispatch_semaphore_signal(semaphore)
  }

  func peerConnection(peerConnection: PeerConnection,
                      didReceiveMessage message: PeerConnectionMessage) {
    switch message {
      case .Transaction(let transaction):
        transactionResponse = transaction
        dispatch_semaphore_signal(semaphore)
      case .Block(let block):
        blockResponse = block
        dispatch_semaphore_signal(semaphore)
      case .NotFoundMessage(let notFoundMessage):
        println("Not Found")
        dispatch_semaphore_signal(semaphore)
      default:
        break
    }
  }

  // MARK: - Private Methods

  func connect() -> PeerConnection {
    let connection = PeerConnection(hostname: "localhost",
                                    port: 8333,
                                    network: Message.Network.MainNet,
                                    delegate: self,
                                    delegateQueue: queue)
    let senderPeerAddress = PeerAddress(services: PeerServices.NodeNetwork,
                                        IP: IPAddress.IPV4(0x00000000),
                                        port: 0)
    let receiverPeerAddress = PeerAddress(services: PeerServices.NodeNetwork,
                                          IP: IPAddress.IPV4(0x00000000),
                                          port: 0)
    let versionMessage = VersionMessage(protocolVersion: 70002,
                                        services: PeerServices.NodeNetwork,
                                        date: NSDate(),
                                        senderAddress: senderPeerAddress,
                                        receiverAddress: receiverPeerAddress,
                                        nonce: 0x5e9e17ca3e515405,
                                        userAgent: "/BitcoinSwift:0.0.1/",
                                        blockStartHeight: 0,
                                        announceRelayedTransactions: false)
    connection.connectWithVersionMessage(versionMessage)
    return connection
  }

  func waitWithTimeout(seconds: Int) {
    let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds) * Int64(NSEC_PER_SEC))
    dispatch_semaphore_wait(semaphore, timeout)
  }
}

let blockHashBytes: [UInt8] = [
    0x00, 0x00, 0x00, 0x00, 0x00, 0x19, 0xd6, 0x68,
    0x9c, 0x08, 0x5a, 0xe1, 0x65, 0x83, 0x1e, 0x93,
    0x4f, 0xf7, 0x63, 0xae, 0x46, 0xa2, 0xa6, 0xc1,
    0x72, 0xb3, 0xf1, 0xb6, 0x0a, 0x8c, 0xe2, 0x6f]
let blockHash = NSData(bytes: blockHashBytes, length: blockHashBytes.count)
let blockDataFetcher = DataFetcher()
if let block = blockDataFetcher.fetchBlockWithHash(blockHash) {
  println("Success! Block \(block.hash)")
}
println("Failed to fetch block")

let transactionHashBytes: [UInt8] = [
    0x6d, 0xbd, 0xdb, 0x08, 0x5b, 0x1d, 0x8a, 0xf7,
    0x51, 0x84, 0xf0, 0xbc, 0x01, 0xfa, 0xd5, 0x8d,
    0x12, 0x66, 0xe9, 0xb6, 0x3b, 0x50, 0x88, 0x19,
    0x90, 0xe4, 0xb4, 0x0d, 0x6a, 0xee, 0x36, 0x29]
let transactionHash = NSData(bytes: transactionHashBytes, length: transactionHashBytes.count)
let transactionDataFetcher = DataFetcher()
if let transaction = transactionDataFetcher.fetchTransactionWithHash(transactionHash) {
  println("Success! Transaction \(transactionHash)")
}
println("Failed to fetch transaction")
