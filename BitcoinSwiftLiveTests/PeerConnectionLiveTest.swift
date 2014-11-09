//
//  PeerConnectionLiveTest.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/18/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class PeerConnectionLiveTest: XCTestCase, PeerConnectionDelegate {
  var connectedExpectation: XCTestExpectation!

  override func setUp() {
    connectedExpectation = expectationWithDescription("connected")
  }

  func testConnect() {
    let conn = PeerConnection(hostname: "localhost",
                              port: 8333,
                              network: Message.Network.MainNet,
                              delegate: self)
    conn.connectWithVersionMessage(dummyVersionMessage(), timeout: 10)
    waitForExpectationsWithTimeout(10, handler: nil)
    conn.disconnect()
  }

  // MARK: - PeerConnectionDelegate

  func peerConnection(peerConnection: PeerConnection, didConnectWithPeerVersion: VersionMessage) {
    connectedExpectation?.fulfill()
    connectedExpectation = nil
  }

  func peerConnection(peerConnection: PeerConnection, didDisconnectWithError error: NSError?) {
    if error != nil {
      XCTFail("Disconnected with error \(error!)")
    }
  }

  // MARK: - Helper methods

  func dummyVersionMessage() -> VersionMessage {
    let emptyPeerAddress = PeerAddress(services: PeerServices.NodeNetwork,
                                       IP: IPAddress.IPV4(0),
                                       port: 8333)
    return VersionMessage(protocolVersion: 70002,
                          services: PeerServices.NodeNetwork,
                          date: NSDate(),
                          senderAddress: emptyPeerAddress,
                          receiverAddress: emptyPeerAddress,
                          nonce: 0,
                          userAgent: "test",
                          blockStartHeight: 0,
                          announceRelayedTransactions: true)
  }

  // TODO: Make these optional once Swift supports pure-Swift optional methods.

  func peerConnection(peerConnection: PeerConnection,
                      didReceiveAddressMessage addressMessage: AddressMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveInventoryMessage inventoryMessage: InventoryMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveGetDataMessage getDataMessage: GetDataMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveNotFoundMessage notFoundMessage: NotFoundMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveGetBlocksMessage getBlocksMessage: GetBlocksMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveGetHeadersMessage getHeadersMessage: GetHeadersMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveTransaction transaction: Transaction) {}
  func peerConnection(peerConnection: PeerConnection, didReceiveBlock block: Block) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveHeadersMessage headersMessage: HeadersMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveGetAddressMessage getAddressMessage: GetAddressMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveMemPoolMessage memPoolMessage: MemPoolMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceivePingMessage pingMessage: PingMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceivePongMessage pongMessage: PongMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveRejectMessage rejectMessage: RejectMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveFilterLoadMessage filterLoadMessage: FilterLoadMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveFilterAddMessage filterAddMessage: FilterAddMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveFilterClearMessage filterClearMessage: FilterClearMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveFilteredBlock filteredBlock: FilteredBlock) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveAlertMessage alertMessage: AlertMessage) {}
}
