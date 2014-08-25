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
  let mainNetPort: UInt16 = 8333
  let testNetPort: UInt16 = 18333

  override func setUp() {
    connectedExpectation = expectationWithDescription("connected")
  }

  func testConnect() {
    // Try to connect to either MainNet or TestNet on localhost. If either succeeds, we're golden.
    let connMainNet = PeerConnection(hostname:"localhost",
                                     port:mainNetPort,
                                     networkMagicValue:Message.NetworkMagicValue.MainNet,
                                     delegate:self)
    connMainNet.connectWithVersionMessage(dummyVersionMessageWithPort(mainNetPort))
    let connTestNet = PeerConnection(hostname:"localhost",
                                     port:testNetPort,
                                     networkMagicValue:Message.NetworkMagicValue.TestNet3,
                                     delegate:self)
    connTestNet.connectWithVersionMessage(dummyVersionMessageWithPort(testNetPort))
    waitForExpectationsWithTimeout(10, handler:nil)
    connMainNet.disconnect()
    connTestNet.disconnect()
  }

  // MARK: - PeerConnectionDelegate

  func peerConnectionDidConnect(peerConnection: PeerConnection) {
    connectedExpectation?.fulfill()
    connectedExpectation = nil
  }

  // MARK: - Helper methods

  func dummyVersionMessageWithPort(port: UInt16) -> VersionMessage {
    let emptyPeerAddress = PeerAddress(services:PeerServices.NodeNetwork,
                                       IP:IPAddress.IPV4(0),
                                       port:port)
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
