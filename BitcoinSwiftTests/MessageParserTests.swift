//
//  MessageParserTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/13/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class MessageParserTests: XCTestCase, MessageParserDelegate {

  var messageParser: MessageParser!
  var parsedMessages: [Message] = []

  // Random, invalid bytes.
  private let junkBytes: [UInt8] = [0x87, 0x64, 0x12, 0x67, 0x32]

  override func setUp() {
    super.setUp()
    messageParser = MessageParser(network: Message.Network.MainNet.rawValue)
    messageParser.delegate = self
  }

  func testSimpleParse() {
    messageParser.parseBytes(DummyMessage.versionMessageBytes)
    XCTAssertEqual(parsedMessages, [DummyMessage.versionMessage])
  }

  func testParseWithJunkPrefix() {
    messageParser.parseBytes(junkBytes + DummyMessage.versionMessageBytes)
    XCTAssertEqual(parsedMessages, [DummyMessage.versionMessage])
  }

  func testParseWithJunkSuffix() {
    messageParser.parseBytes(DummyMessage.versionMessageBytes + junkBytes)
    XCTAssertEqual(parsedMessages, [DummyMessage.versionMessage])
  }

  func testParseTwoMessages() {
    messageParser.parseBytes(DummyMessage.versionMessageBytes)
    messageParser.parseBytes(DummyMessage.versionMessageBytes)
    XCTAssertEqual(parsedMessages, [DummyMessage.versionMessage, DummyMessage.versionMessage])
  }

  func testParseTwoMessagesWithJunkInBetween() {
    messageParser.parseBytes(DummyMessage.versionMessageBytes)
    messageParser.parseBytes(junkBytes)
    messageParser.parseBytes(DummyMessage.versionMessageBytes)
    XCTAssertEqual(parsedMessages, [DummyMessage.versionMessage, DummyMessage.versionMessage])
  }

  func testIgnoreMessageWithInvalidChecksum() {
    messageParser.parseBytes(DummyMessage.versionMessageBytesWithInvalidChecksum)
    XCTAssertEqual(parsedMessages, [])
  }

  func testIgnoreMessageWherePayloadLengthTooBig() {
    // TODO: Make sure we ignore messages that are too long, or we are vulnerable to a DOS attack.
  }

  // TODO: Add some more tests here for exotic edge cases.

  // MARK: - MessageParserDelegate

  func didParseMessage(message: Message) {
    parsedMessages.append(message)
  }
}
