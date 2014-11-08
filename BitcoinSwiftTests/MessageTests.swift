//
//  MessageTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/3/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class MessageTests: XCTestCase {

  let network = Message.Network.MainNet
  let command = Message.Command.Version

  let payloadBytes: [UInt8] = [
      0x72, 0x11, 0x01, 0x00,                           // 70002 (protocol version 70002)
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // 1 (NODE_NETWORK services)
      0x0e, 0x56, 0x05, 0x54, 0x00, 0x00, 0x00, 0x00,   // Timestamp
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Recipient address info
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xff, 0xff, 0xad, 0x08, 0xa6, 0x69, 0x20, 0x8d, // Sender address info
      0x05, 0x54, 0x51, 0x3e, 0xca, 0x17, 0x9e, 0x5e,   // Node ID
      0x0f, 0x2f, 0x53, 0x61, 0x74, 0x6f, 0x73, 0x68,
      0x69, 0x3a, 0x30, 0x2e, 0x39, 0x2e, 0x31, 0x2f,   // sub-version string
      0x79, 0xa0, 0x02, 0x00,                           // Last block
      0x01]                                             // Relay transactions
  let messageBytes: [UInt8] = [
      0xf9, 0xbe, 0xb4, 0xd9,                           // Main network magic bytes
      0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x00, 0x00, 0x00, 0x00, 0x00, // "version" command
      0x65, 0x00, 0x00, 0x00,                           // Payload is 101 bytes long
      0x2f, 0x80, 0x9b, 0xfa,                           // Payload checksum
      0x72, 0x11, 0x01, 0x00,                           // 70002 (protocol version 70002)
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // 1 (NODE_NETWORK services)
      0x0e, 0x56, 0x05, 0x54, 0x00, 0x00, 0x00, 0x00,   // Timestamp
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Recipient address info
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xff, 0xff, 0xad, 0x08, 0xa6, 0x69, 0x20, 0x8d, // Sender address info
      0x05, 0x54, 0x51, 0x3e, 0xca, 0x17, 0x9e, 0x5e,   // Node ID
      0x0f, 0x2f, 0x53, 0x61, 0x74, 0x6f, 0x73, 0x68,
      0x69, 0x3a, 0x30, 0x2e, 0x39, 0x2e, 0x31, 0x2f,   // sub-version string
      0x79, 0xa0, 0x02, 0x00,                           // Last block
      0x01]                                             // Relay transactions

  var payloadData: NSData!
  var messageData: NSData!
  var message: Message!

  override func setUp() {
    payloadData = NSData(bytes: payloadBytes, length: payloadBytes.count)
    messageData = NSData(bytes: messageBytes, length: messageBytes.count)
    message = Message(network: network, command: command, payloadData: payloadData)
  }

  func testMessageEncoding() {
    XCTAssertEqual(message.bitcoinData, messageData)
  }

  func testMessageDecoding() {
    let stream = NSInputStream(data: messageData)
    stream.open()
    if let testMessage = Message.fromBitcoinStream(stream) {
      XCTAssertEqual(testMessage, message)
    } else {
      XCTFail("\n[FAIL] Failed to parse message")
    }
  }
}
