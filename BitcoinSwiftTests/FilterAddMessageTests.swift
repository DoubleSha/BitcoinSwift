//
//  FilterAddMessageTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/18/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class FilterAddMessageTests: XCTestCase {

  let filterAddMessageBytes: [UInt8] = [0x03, 0x01, 0x02, 0x03]

  var filterAddMessageData: NSData!
  var filterAddMessage: FilterAddMessage!

  override func setUp() {
    filterAddMessageData = NSData(bytes: filterAddMessageBytes,
                                  length: filterAddMessageBytes.count)
    let filterDataBytes: [UInt8] = [0x01, 0x02, 0x03]
    let filterData = NSData(bytes: filterDataBytes, length: filterDataBytes.count)
    filterAddMessage = FilterAddMessage(filterData: filterData)
  }

  func testFilterAddMessageEncoding() {
    XCTAssertEqual(filterAddMessage.bitcoinData, filterAddMessageData)
  }

  func testFilterAddMessageDecoding() {
    let stream = NSInputStream(data: filterAddMessageData)
    stream.open()
    if let testFilterAddMessage = FilterAddMessage.fromBitcoinStream(stream) {
      XCTAssertEqual(testFilterAddMessage, filterAddMessage)
    } else {
      XCTFail("\n[FAIL] Failed to parse FilterAddMessage")
    }
  }
}
