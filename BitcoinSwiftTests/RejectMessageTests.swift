//
//  RejectMessageTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/4/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class RejectMessageTests: XCTestCase {

  let rejectMessageWithoutHashBytes: [UInt8] = [
      0x07,                                             // command string length: 7
      0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e,         // command string: "version"
      0x01,                                             // code: Malformed
      0x06,                                             // reason string length: 6
      0x72, 0x65, 0x61, 0x73, 0x6f, 0x6e]               // reason: "reason"

  let rejectMessageWithHashBytes: [UInt8] = [
      0x07,                                             // command string length: 7
      0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e,         // command string: "version"
      0x41,                                             // code: Dust
      0x06,                                             // reason string length: 6
      0x72, 0x65, 0x61, 0x73, 0x6f, 0x6e,               // reason: "reason"
      0xb5, 0x0c, 0xc0, 0x69, 0xd6, 0xa3, 0xe3, 0x3e,
      0x3f, 0xf8, 0x4a, 0x5c, 0x41, 0xd9, 0xd3, 0xfe,
      0xbe, 0x7c, 0x77, 0x0f, 0xdc, 0xc9, 0x6b, 0x2c,
      0x3f, 0xf6, 0x0a, 0xbe, 0x18, 0x4f, 0x19, 0x63]   // transaction hash

  let transactionHashBytes: [UInt8] = [
      0xb5, 0x0c, 0xc0, 0x69, 0xd6, 0xa3, 0xe3, 0x3e,
      0x3f, 0xf8, 0x4a, 0x5c, 0x41, 0xd9, 0xd3, 0xfe,
      0xbe, 0x7c, 0x77, 0x0f, 0xdc, 0xc9, 0x6b, 0x2c,
      0x3f, 0xf6, 0x0a, 0xbe, 0x18, 0x4f, 0x19, 0x63]

  var rejectMessageWithoutHashData: NSData!
  var rejectMessageWithoutHash: RejectMessage!

  var rejectMessageWithHashData: NSData!
  var rejectMessageWithHash: RejectMessage!

  override func setUp() {
    rejectMessageWithoutHashData = NSData(bytes: rejectMessageWithoutHashBytes,
                                          length: rejectMessageWithoutHashBytes.count)
    rejectMessageWithoutHash = RejectMessage(rejectedCommand: .Version,
                                             code: .Malformed,
                                             reason: "reason")

    rejectMessageWithHashData = NSData(bytes: rejectMessageWithHashBytes,
                                       length: rejectMessageWithHashBytes.count)
    let transactionHash = NSData(bytes: transactionHashBytes, length: transactionHashBytes.count)
    rejectMessageWithHash = RejectMessage(rejectedCommand: .Version,
                                          code: .Dust,
                                          reason: "reason",
                                          hash: transactionHash)
  }

  func testRejectMessageWithHashEncoding() {
    XCTAssertEqual(rejectMessageWithHash.bitcoinData, rejectMessageWithHashData)
  }

  func testRejectMessageWithHashDecoding() {
    let stream = NSInputStream(data: rejectMessageWithHashData)
    stream.open()
    if let testRejectMessageWithHash = RejectMessage.fromBitcoinStream(stream) {
      XCTAssertEqual(testRejectMessageWithHash, rejectMessageWithHash)
    } else {
      XCTFail("Failed to parse RejectMessage")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testRejectMessageWithoutHashEncoding() {
    XCTAssertEqual(rejectMessageWithoutHash.bitcoinData, rejectMessageWithoutHashData)
  }

  func testRejectMessageWithoutHashDecoding() {
    let stream = NSInputStream(data: rejectMessageWithoutHashData)
    stream.open()
    if let testRejectMessageWithoutHash = RejectMessage.fromBitcoinStream(stream) {
      XCTAssertEqual(testRejectMessageWithoutHash, rejectMessageWithoutHash)
    } else {
      XCTFail("Failed to parse RejectMessage")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
