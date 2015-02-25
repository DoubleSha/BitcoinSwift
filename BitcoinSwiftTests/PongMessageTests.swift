//
//  PongMessageTests.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class PongMessageTests: XCTestCase {

  let pongMessageBytes: [UInt8] = [0x65, 0x89, 0xad, 0xb4, 0x25, 0xc0, 0x6e, 0xb9]

  var pongMessageData: NSData!
  var pongMessage: PongMessage!

  override func setUp() {
    super.setUp()
    pongMessageData = NSData(bytes: pongMessageBytes, length: pongMessageBytes.count)
    pongMessage = PongMessage(nonce: 13361828412632435045)
  }

  func testPongMessageEncoding() {
    XCTAssertEqual(pongMessage.bitcoinData, pongMessageData)
  }

  func testPongMessageDecoding() {
    let stream = NSInputStream(data: pongMessageData)
    stream.open()
    if let testPongMessage = PongMessage.fromBitcoinStream(stream) {
      XCTAssertEqual(testPongMessage, pongMessage)
    } else {
      XCTFail("Failed to parse PongMessage")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
