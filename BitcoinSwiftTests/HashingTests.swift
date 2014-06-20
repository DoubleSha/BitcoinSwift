//
//  HashingTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/19/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class HashingTests: XCTestCase {

  let data = NSData(bytes:"abc".cStringUsingEncoding(NSASCIIStringEncoding)!, length:3)

  // SHA256 Tests.

  func testSHA256() {
    let expectedSHA256HashBytes: UInt8[] = [0xba, 0x78, 0x16, 0xbf, 0x8f, 0x01, 0xcf, 0xea,
                                            0x41, 0x41, 0x40, 0xde, 0x5d, 0xae, 0x22, 0x23,
                                            0xb0, 0x03, 0x61, 0xa3, 0x96, 0x17, 0x7a, 0x9c,
                                            0xb4, 0x10, 0xff, 0x61, 0xf2, 0x00, 0x15, 0xad]
    let expectedSHA256Hash = NSData(bytes:expectedSHA256HashBytes, length:32)
    let SHA256Hash = data.SHA256Hash()
    XCTAssertNotNil(SHA256Hash, "\nSHA256Hash is nil")
    XCTAssertEqualObjects(SHA256Hash, expectedSHA256Hash, "\n[FAIL] Incorrect SHA256Hash:\n  " +
                          "Expected \(expectedSHA256Hash.hexString())\n  " +
                          "Actual   \(SHA256Hash.hexString())")
  }

  func testSHA256EmptyData() {
    XCTAssertNil(NSData().SHA256Hash(), "\n[FAIL] SHA256Hash should be nil for empty data")
  }

  // RIPEMD160 Tests.

  func testRIPEMD160() {
    let expectedRIPEMD160HashBytes: UInt8[] = [0x8e, 0xb2, 0x08, 0xf7, 0xe0, 0x5d, 0x98, 0x7a,
                                               0x9b, 0x04, 0x4a, 0x8e, 0x98, 0xc6, 0xb0, 0x87,
                                               0xf1, 0x5a, 0x0b, 0xfc]
    let expectedRIPEMD160Hash = NSData(bytes:expectedRIPEMD160HashBytes, length:20)
    let RIPEMD160Hash = data.RIPEMD160Hash()
    XCTAssertNotNil(RIPEMD160Hash, "\nRIPEMD160Hash is nil");
    XCTAssertEqualObjects(RIPEMD160Hash, expectedRIPEMD160Hash,
                          "\n[FAIL] Incorrect RIPEMD160Hash:\n  " +
                          "Expected \(expectedRIPEMD160Hash.hexString())\n  " +
                          "Actual   \(RIPEMD160Hash.hexString())")
  }

  func testRIPEMD160EmptyData() {
    XCTAssertNil(NSData().RIPEMD160Hash(), "\n[FAIL] RIPEMD160Hash should be nil for empty data")
  }
}
