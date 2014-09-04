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
    let conn = PeerConnection(hostname:"localhost",
                              port:8333,
                              network:Message.Network.MainNet,
                              delegate:self)
    conn.connectWithVersionMessage(dummyVersionMessage(), timeout:10)
    waitForExpectationsWithTimeout(10, handler:nil)
    conn.disconnect()
  }

  // MARK: - PeerConnectionDelegate

  func peerConnection(peerConnection: PeerConnection, didConnectWithPeerVersion: VersionMessage) {
    connectedExpectation?.fulfill()
    connectedExpectation = nil
  }

  func peerConnection(peerConnection: PeerConnection, didFailWithError error: NSError?) {
    if error != nil {
      XCTFail("Disconnected with error \(error!)")
    }
  }

  // MARK: - Helper methods

  func dummyVersionMessage() -> VersionMessage {
    let emptyPeerAddress = PeerAddress(services:PeerServices.NodeNetwork,
                                       IP:IPAddress.IPV4(0),
                                       port:8333)
    return VersionMessage(protocolVersion:70002,
                          services:PeerServices.NodeNetwork,
                          date: NSDate(),
                          senderAddress:emptyPeerAddress,
                          receiverAddress:emptyPeerAddress,
                          nonce:0,
                          userAgent:"test",
                          blockStartHeight:0,
                          announceRelayedTransactions:true)
  }
}
