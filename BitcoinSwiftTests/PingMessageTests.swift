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

  var pingMessageData: NSData!
  var pingMessage: PingMessage!

  override func setUp() {
    pingMessageData = NSData(bytes: pingMessageBytes, length: pingMessageBytes.count)
    pingMessage = PingMessage(nonce: 13361828412632435045)
  }

  func testPingMessageEncoding() {
    XCTAssertEqual(pingMessage.bitcoinData, pingMessageData)
  }

  func testPingMessageDecoding() {
    let stream = NSInputStream(data: pingMessageData)
    stream.open()
    if let testPingMessage = PingMessage.fromBitcoinStream(stream) {
      XCTAssertEqual(testPingMessage, pingMessage)
    } else {
      XCTFail("Failed to parse PingMessage")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
