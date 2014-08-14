//
//  Base58Tests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/19/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class Base58Tests: XCTestCase {

  func testBase58WithValidAddress() {
    let expectedBase58String = "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM";
    let bytes: [UInt8] = [0x00, 0x01, 0x09, 0x66, 0x77, 0x60, 0x06, 0x95,
                          0x3D, 0x55, 0x67, 0x43, 0x9E, 0x5E, 0x39, 0xF8,
                          0x6A, 0x0D, 0x27, 0x3B, 0xEE, 0xD6, 0x19, 0x67, 0xF6]
    let base58String = NSData(bytes:bytes, length:25).base58String()
    XCTAssertEqual(base58String, expectedBase58String,
                   "\n[FAIL] Incorrect base58String:\n  " +
                   "Expected \(expectedBase58String)\n  " +
                   "Actual   \(base58String)")
  }

  func testBase58WithEmptyData() {
    XCTAssertEqual(NSData().base58String()!, "",
                   "\n[FAIL] base58String should be an empty string for empty data")
  }

  func testBase58WithLeadingZeros() {
    let expectedBase58String = "111111Cy3N8mvNoTsRECfT9Ywzm3EDs4";
    let bytes: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x5D,
                          0x23, 0x8C, 0x7F, 0x7C, 0xB6, 0x23, 0xD0, 0x3C,
                          0x47, 0xA1, 0xE8, 0x31, 0x84, 0x38, 0x44, 0x20, 0xEF]
    let base58String = NSData(bytes:bytes, length:25).base58String()
    XCTAssertEqual(base58String, expectedBase58String,
                   "\n[FAIL] Incorrect base58String:\n  " +
                   "Expected \(expectedBase58String)\n  " +
                   "Actual   \(base58String)")
  }
}
