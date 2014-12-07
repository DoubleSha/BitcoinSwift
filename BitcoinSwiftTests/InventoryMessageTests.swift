//
//  InventoryMessageTests.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 8/23/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class InventoryMessageTests: XCTestCase {

  let inventoryMessageBytes: [UInt8] = [
      0x01,                                             // Number of inventory vectors (1)
      0x02, 0x00, 0x00, 0x00,                           // First vector type (2: Block)
      0x71, 0x40, 0x03, 0x91, 0x50, 0x8c, 0xae, 0x45,
      0x35, 0x86, 0x4f, 0x74, 0x91, 0x76, 0xab, 0x7f,
      0xa3, 0xa2, 0x51, 0xc2, 0x13, 0x40, 0x21, 0x1e,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]   // Block hash

  var inventoryMessageData: NSData!
  var inventoryMessage: InventoryMessage!

  override func setUp() {
    let vector0HashBytes: [UInt8] = [
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x1e, 0x21, 0x40, 0x13, 0xc2, 0x51, 0xa2, 0xa3,
        0x7f, 0xab, 0x76, 0x91, 0x74, 0x4f, 0x86, 0x35,
        0x45, 0xae, 0x8c, 0x50, 0x91, 0x03, 0x40, 0x71]   // Block hash
    let vector0Hash = SHA256Hash(bytes: vector0HashBytes)
    let inventoryVectors = [InventoryVector(type: .Block, hash: vector0Hash)]
    inventoryMessage = InventoryMessage(inventoryVectors: inventoryVectors)
    inventoryMessageData = NSData(bytes: inventoryMessageBytes, length: inventoryMessageBytes.count)
  }

  // TODO: Add edge test cases: Too many vectors, empty data, etc.

  func testInventoryMessageEncoding() {
    XCTAssertEqual(inventoryMessage.bitcoinData, inventoryMessageData)
  }

  func testInventoryMessageDecoding() {
    let stream = NSInputStream(data: inventoryMessageData)
    stream.open()
    if let testInventoryMessage = InventoryMessage.fromBitcoinStream(stream) {
      XCTAssertEqual(testInventoryMessage, inventoryMessage)
    } else {
      XCTFail("Failed to parse InventoryMessage")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
