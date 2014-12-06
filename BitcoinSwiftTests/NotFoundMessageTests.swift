//
//  NotFoundMessageTests.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class NotFoundMessageTests: XCTestCase {

  let notFoundMessageBytes: [UInt8] = [
      0x01,                                             // Number of inventory vectors (1)
      0x02, 0x00, 0x00, 0x00,                           // First vector type (2: Block)
      0x71, 0x40, 0x03, 0x91, 0x50, 0x8c, 0xae, 0x45,
      0x35, 0x86, 0x4f, 0x74, 0x91, 0x76, 0xab, 0x7f,
      0xa3, 0xa2, 0x51, 0xc2, 0x13, 0x40, 0x21, 0x1e,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]   // Block hash
  let vector0HashBytes: [UInt8] = [
      0x71, 0x40, 0x03, 0x91, 0x50, 0x8c, 0xae, 0x45,
      0x35, 0x86, 0x4f, 0x74, 0x91, 0x76, 0xab, 0x7f,
      0xa3, 0xa2, 0x51, 0xc2, 0x13, 0x40, 0x21, 0x1e,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]   // Block hash

  var notFoundMessageData: NSData!
  var notFoundMessage: NotFoundMessage!

  override func setUp() {
    notFoundMessageData = NSData(bytes: notFoundMessageBytes, length: notFoundMessageBytes.count)
    let vector0Hash = NSData(bytes: vector0HashBytes, length: vector0HashBytes.count)
    let inventoryVectors = [
        InventoryVector(type: InventoryVector.VectorType.Block, hash: vector0Hash)]
    notFoundMessage = NotFoundMessage(inventoryVectors: inventoryVectors)
  }

  // TODO: Add edge test cases: Too many vectors, empty data, etc.

  func testNotFoundMessageEncoding() {
    XCTAssertEqual(notFoundMessage.bitcoinData, notFoundMessageData)
  }

  func testNotFoundMessageDecoding() {
    let stream = NSInputStream(data: notFoundMessageData)
    stream.open()
    if let testNotFoundMessage = NotFoundMessage.fromBitcoinStream(stream) {
      XCTAssertEqual(testNotFoundMessage, notFoundMessage)
    } else {
      XCTFail("Failed to parse NotFoundMessage")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
