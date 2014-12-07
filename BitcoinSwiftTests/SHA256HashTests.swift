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

  let hashBytes: [UInt8] = [
      0x29, 0x36, 0xee, 0x6a, 0x0d, 0xb4, 0xe4, 0x90,
      0x19, 0x88, 0x50, 0x3b, 0xb6, 0xe9, 0x66, 0x12,
      0x8d, 0xd5, 0xfa, 0x01, 0xbc, 0xf0, 0x84, 0x51,
      0xf7, 0x8a, 0x1d, 0x5b, 0x08, 0xdb, 0xbd, 0x6d]

  var hashData: NSData!
  var sha256Hash: SHA256Hash!

  override func setUp() {
    hashData = NSData(bytes: hashBytes, length: hashBytes.count)
    sha256Hash = SHA256Hash(bytes: hashBytes)
  }

  func testSHA256HashEncoding() {
    // Bitcoin encodes hashes as little-endian on the wire.
    XCTAssertEqual(sha256Hash.bitcoinData, hashData.reversedData)
  }

  func testSHA256HashDecoding() {
    // Bitcoin encodes hashes as little-endian on the wire.
    let stream = NSInputStream(data: hashData.reversedData)
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
