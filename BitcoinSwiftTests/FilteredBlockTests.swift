//
//  FilteredBlockTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/26/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class FilteredBlockTests: XCTestCase {

  func testFilteredBlockEncoding() {
    XCTAssertEqual(DummyMessage.filteredBlock.bitcoinData, DummyMessage.filteredBlockData)
  }

  func testFilteredBlockDecoding() {
    let stream = NSInputStream(data: DummyMessage.filteredBlockData)
    stream.open()
    if let testFilteredBlock = FilteredBlock.fromBitcoinStream(stream) {
      XCTAssertEqual(testFilteredBlock, DummyMessage.filteredBlock)
    } else {
      XCTFail("Failed to parse FilteredBlock")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
