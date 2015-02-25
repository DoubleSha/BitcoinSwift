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

  let versionMessageBytes: [UInt8] = [
      0x71, 0x11, 0x01, 0x00,                           // 70001 (protocol version 70001)
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // 1 (NODE_NETWORK services)
      0x11, 0xb2, 0xd0, 0x50, 0x00, 0x00, 0x00, 0x00,   // Tue Dec 18 10: 12: 33 PST 2012
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xff, 0xff, 0x0a, 0x00, 0x00, 0x01, 0x20, 0x8d, // Receiver address info
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xff, 0xff, 0x0a, 0x00, 0x00, 0x02, 0x20, 0x8d, // Sender address info
      0x3b, 0x2e, 0xb3, 0x5d, 0x8c, 0xe6, 0x17, 0x65,   // nonce: "Node ID"
      0x0f, 0x2f, 0x53, 0x61, 0x74, 0x6f, 0x73, 0x68,
      0x69, 0x3a, 0x30, 0x2e, 0x37, 0x2e, 0x32, 0x2f,   // "/Satoshi:0.7.2/" sub-version string
      0xc0, 0x3e, 0x03, 0x00,                   // Last block sending node has is block #212672
      0x01]                                             // Announce relayed transactions (true)

  var versionMessageData: NSData!
  var versionMessage: VersionMessage!

  override func setUp() {
    super.setUp()
    versionMessageData = NSData(bytes: versionMessageBytes, length: versionMessageBytes.count)
    let senderPeerAddress = PeerAddress(services: PeerServices.NodeNetwork,
                                        IP: IPAddress.IPV4(0x0a000002),
                                        port: 8333)
    let receiverPeerAddress = PeerAddress(services: PeerServices.NodeNetwork,
                                          IP: IPAddress.IPV4(0x0a000001),
                                          port: 8333)
    versionMessage = VersionMessage(protocolVersion: 70001,
                                            services: PeerServices.NodeNetwork,
                                            date: NSDate(timeIntervalSince1970: 1355854353),
                                            senderAddress: senderPeerAddress,
                                            receiverAddress: receiverPeerAddress,
                                            nonce: 0x6517e68c5db32e3b,
                                            userAgent: "/Satoshi:0.7.2/",
                                            blockStartHeight: 212672,
                                            announceRelayedTransactions: true)
  }

  func testVersionMessageEncoding() {
    XCTAssertEqual(versionMessage.bitcoinData, versionMessageData)
  }

  func testVersionMessageDecoding() {
    let stream = NSInputStream(data: versionMessageData)
    stream.open()
    if let testVersionMessage = VersionMessage.fromBitcoinStream(stream) {
      XCTAssertEqual(testVersionMessage, versionMessage)
    } else {
      XCTFail("Failed to parse VersionMessage")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
