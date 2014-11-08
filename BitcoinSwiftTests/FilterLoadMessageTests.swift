//
//  FilterLoadMessageTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/18/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class FilterLoadMessageTests: XCTestCase {

  let filterLoadMessageBytes: [UInt8] = [
      0x03,                     // filter length
      0x01, 0x02, 0x03,         // filter bytes
      0x01, 0x00, 0x00, 0x00,   // num hash functions
      0x04, 0x03, 0x02, 0x01,   // tweak
      0x00]                     // flags

  var filterLoadMessageData: NSData!
  var filterLoadMessage: FilterLoadMessage!

  override func setUp() {
    filterLoadMessageData = NSData(bytes: filterLoadMessageBytes,
                                   length: filterLoadMessageBytes.count)
    let filterBytes: [UInt8] = [0x01, 0x02, 0x03]
    let filter = NSData(bytes: filterBytes, length: filterBytes.count)
    filterLoadMessage = FilterLoadMessage(filter: filter,
                                          numHashFunctions: 1,
                                          tweak: 0x01020304,
                                          flags: 0)
  }

  func testFilterLoadMessageEncoding() {
    XCTAssertEqual(filterLoadMessage.bitcoinData, filterLoadMessageData)
  }

  func testFilterLoadMessageDecoding() {
    let stream = NSInputStream(data: filterLoadMessageData)
    stream.open()
    if let testFilterLoadMessage = FilterLoadMessage.fromBitcoinStream(stream) {
      XCTAssertEqual(testFilterLoadMessage, filterLoadMessage)
    } else {
      XCTFail("\n[FAIL] Failed to parse FilterLoadMessage")
    }
  }
}
