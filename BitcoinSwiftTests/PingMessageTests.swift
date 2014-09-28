//
//  PingMessageTests.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class PingMessageTests: XCTestCase {

  let pingMessageBytes: [UInt8] = [0x65, 0x89, 0xad, 0xb4, 0x25, 0xc0, 0x6e, 0xb9]
  let pingMessageNonce: UInt64 = 13361828412632435045
  var nonceData: NSData!

  override func setUp() {
    nonceData = NSData(bytes: pingMessageBytes, length: pingMessageBytes.count)
  }

  /// Test to check the random nonce generation if no nonce is supplied.
  func testPingMessageNoNonce() {
    let ping1 = PingMessage()
    let ping2 = PingMessage()
    XCTAssert(ping1.nonce != ping2.nonce)
  }

  /// Test Ping encoding
  func testPingMessageEncoding() {
    let pingMessage = PingMessage(nonce: pingMessageNonce)
    XCTAssertEqual(pingMessage.data, nonceData)
  }

  /// Test Ping decoding
  func testPingMessageDecoding() {
    if let ping1 = PingMessage.fromData(nonceData) {
      XCTAssertEqual(ping1.nonce, pingMessageNonce)
    } else {
      XCTFail("\n[FAIL] Failed to parse PingMessage")
    }
  }
}
