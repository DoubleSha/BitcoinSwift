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

  let networkMagicValue = Message.NetworkMagicValue.MainNet
  let command = Message.Command.Version
  let payloadBytes: [UInt8] = [0xaa, 0xbb]
  let messageBytes: [UInt8] = [
      0xf9, 0xbe, 0xb4, 0xd9, // networkMagicValue (little-endian)
      0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x00, 0x00, 0x00, 0x00, 0x00, // "version" command
      0x02, 0x00, 0x00, 0x00, // payload size (little-endian)
      0xf1, 0x58, 0x13, 0xfa, // payload checksum
      0xaa, 0xbb]             // payload bytes

  func testMessageEncoding() {
    let payloadData = NSData(bytes:payloadBytes, length:payloadBytes.count)
    let message = Message(networkMagicValue:networkMagicValue,
                          command:command,
                          payloadData:payloadData)
    let encodedMessage = message.data
    let messageData = NSData(bytes:messageBytes, length:messageBytes.count)
    XCTAssertEqual(encodedMessage, messageData,
                   "\n[FAIL] Invalid encoded message \(encodedMessage)")
  }

  func testMessageDecoding() {
    let payloadData = NSData(bytes:payloadBytes, length:payloadBytes.count)
    let messageData = NSData(bytes:messageBytes, length:messageBytes.count)
    if let message = Message.fromData(messageData) {
      XCTAssertEqual(networkMagicValue, message.networkMagicValue,
                     "\n[FAIL] Invalid networkMagicValue \(message.networkMagicValue)")
      XCTAssertEqual(command, message.command,
                     "\n[FAIL] Invalid command \(message.command)")
      XCTAssertEqual(command, message.command,
                     "\n[FAIL] Invalid command \(message.command)")
      XCTAssertEqual(payloadData, message.payload,
                     "\n[FAIL] Invalid payload \(message.payload.hexString())")
    } else {
      XCTFail("\n[FAIL] Failed to parse message")
    }
  }

  func testEmptyData() {
    if let message = Message.fromData(NSData()) {
      XCTFail("\n[FAIL] Message should be nil")
    }
  }
}
