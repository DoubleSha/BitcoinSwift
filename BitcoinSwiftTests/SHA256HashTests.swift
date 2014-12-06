//
//  SHA256HashTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/6/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class SHA256HashTests: XCTestCase {

  // Hash is encoded little-endian.
  let hashBytes: [UInt8] = [
      0x6d, 0xbd, 0xdb, 0x08, 0x5b, 0x1d, 0x8a, 0xf7,
      0x51, 0x84, 0xf0, 0xbc, 0x01, 0xfa, 0xd5, 0x8d,
      0x12, 0x66, 0xe9, 0xb6, 0x3b, 0x50, 0x88, 0x19,
      0x90, 0xe4, 0xb4, 0x0d, 0x6a, 0xee, 0x36, 0x29]

  var hashData: NSData!
  var sha256Hash: SHA256Hash!

  override func setUp() {
    hashData = NSData(bytes: hashBytes, length: hashBytes.count)
    sha256Hash = SHA256Hash(data: hashData.reversedData)
  }

  func testSHA256HashEncoding() {
    XCTAssertEqual(sha256Hash.bitcoinData, hashData)
  }

  func testSHA256HashDecoding() {
    let stream = NSInputStream(data: hashData)
    stream.open()
    if let testSHA256Hash = SHA256Hash.fromBitcoinStream(stream) {
      XCTAssertEqual(testSHA256Hash, sha256Hash)
    } else {
      XCTFail("Failed to parse SHA256Hash")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
