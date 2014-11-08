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
  let vector0HashBytes: [UInt8] = [
      0x71, 0x40, 0x03, 0x91, 0x50, 0x8c, 0xae, 0x45,
      0x35, 0x86, 0x4f, 0x74, 0x91, 0x76, 0xab, 0x7f,
      0xa3, 0xa2, 0x51, 0xc2, 0x13, 0x40, 0x21, 0x1e,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]   // Block hash

  var inventoryMessageData: NSData!
  var vector0Hash: NSData!

  override func setUp() {
    vector0Hash = NSData(bytes: vector0HashBytes, length: vector0HashBytes.count)
    inventoryMessageData = NSData(bytes: inventoryMessageBytes, length: inventoryMessageBytes.count)
  }

  // TODO: Add edge test cases: Too many vectors, empty data, etc.

  func testInventoryMessageEncoding() {
    let inventoryVectors = [
        InventoryVector(type: InventoryVector.VectorType.Block, hash: vector0Hash)]
    let inventoryMessage = InventoryMessage(inventoryVectors: inventoryVectors)
    let expectedData = NSData(bytes: inventoryMessageBytes, length: inventoryMessageBytes.count)
    XCTAssertEqual(inventoryMessage.bitcoinData, expectedData)
  }

  func testInventoryMessageDecoding() {
    let stream = NSInputStream(data: inventoryMessageData)
    stream.open()
    if let inventoryMessage = InventoryMessage.fromBitcoinStream(stream) {
      let expectedInventoryVectors = [
          InventoryVector(type: InventoryVector.VectorType.Block, hash: vector0Hash)]
      let expectedInventoryMessage = InventoryMessage(inventoryVectors: expectedInventoryVectors)
      XCTAssertEqual(inventoryMessage, expectedInventoryMessage)
    } else {
      XCTFail("\n[FAIL] Failed to parse InventoryMessage")
    }
  }
}
