//
//  VersionMessageTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/7/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class VersionMessageTests: XCTestCase {

  func testVersionMessageDecoding() {
    let bytes: [UInt8] = [
        0x71, 0x11, 0x01, 0x00,                           // 70001 (protocol version 70001)
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // 1 (NODE_NETWORK services)
        0x11, 0xb2, 0xd0, 0x50, 0x00, 0x00, 0x00, 0x00,   // Tue Dec 18 10:12:33 PST 2012
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Receiver address info
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Sender address info
        0x3b, 0x2e, 0xb3, 0x5d, 0x8c, 0xe6, 0x17, 0x65,   // nonce: "Node ID"
        0x0f, 0x2f, 0x53, 0x61, 0x74, 0x6f, 0x73, 0x68,
        0x69, 0x3a, 0x30, 0x2e, 0x37, 0x2e, 0x32, 0x2f,   // "/Satoshi:0.7.2/" sub-version string
        0xc0, 0x3e, 0x03, 0x00,                   // Last block sending node has is block #212672
        0x01]                                             // Announce relayed transactions (true)
    let data = NSData(bytes:bytes, length:bytes.count)
    if let versionMessage = VersionMessage.fromData(data) {
      XCTAssertEqual(versionMessage.protocolVersion, 70001)
      XCTAssertEqual(versionMessage.services, Message.Services.NodeNetwork)
      XCTAssertEqual(versionMessage.date, NSDate(timeIntervalSince1970:1355854353))
      let emptyPeerAddress = PeerAddress(services:Message.Services.NodeNetwork,
                                         IP:IPAddress.IPV4(0),
                                         port:0)
      XCTAssertEqual(versionMessage.receiverAddress, emptyPeerAddress)
      XCTAssertEqual(versionMessage.senderAddress, emptyPeerAddress)
      XCTAssertEqual(versionMessage.userAgent, "/Satoshi:0.7.2/")
      XCTAssertEqual(versionMessage.blockStartHeight, 212672)
      XCTAssertTrue(versionMessage.announceRelayedTransactions)
    } else {
      XCTFail("\n[FAIL] Failed to parse VersionMessage")
    }
  }

  func testVersionMessageEncoding() {
    // TODO
  }
}
