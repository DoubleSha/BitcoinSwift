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
  let pongMessageNonce: UInt64 = 13361828412632435045
  var nonceData: NSData!

  override func setUp() {
    nonceData = NSData(bytes: pongMessageBytes, length: pongMessageBytes.count)
  }

  func testPongMessageEncoding() {
    let pongMessage = PongMessage(nonce: pongMessageNonce)
    XCTAssertEqual(pongMessage.data, nonceData)
  }

  func testPongMessageDecoding() {
    if let pong1 = PongMessage.fromData(nonceData) {
      XCTAssertEqual(pong1.nonce, pongMessageNonce)
    } else {
      XCTFail("\n[FAIL] Failed to parse PongMessage")
    }
  }
}
