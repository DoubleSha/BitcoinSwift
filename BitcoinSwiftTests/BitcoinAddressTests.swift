//
//  BitcoinAddressTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/20/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class BitcoinAddressTests: XCTestCase {

  func testBitcoinAddress() {
    let publicKey: UInt8[] = [0x04, 0x74, 0xD1, 0x73, 0x77, 0xAC, 0x32, 0x62,
                              0x08, 0x8D, 0x8D, 0x20, 0xEE, 0x4F, 0x86, 0xC6,
                              0x13, 0x8E, 0x87, 0x9B, 0x6B, 0x23, 0xA5, 0x89,
                              0x57, 0x76, 0x43, 0xF1, 0xAC, 0x1F, 0x4C, 0x7A,
                              0xA6, 0xA9, 0x48, 0xFB, 0xD7, 0xAA, 0xA7, 0x45,
                              0x6E, 0x6C, 0x5F, 0x1A, 0x67, 0x0B, 0x83, 0x46,
                              0x02, 0xFE, 0x50, 0x4D, 0x53, 0xD5, 0x4A, 0x1C,
                              0x18, 0x42, 0x59, 0x9F, 0xBC, 0x4B, 0x76, 0xEB, 0x9A]
    let expectedBitcoinAddr = "1BdadBJNye9Ex8N67KNwedtmqwNk38Xcw9"
    let bitcoinAddr = BitcoinAddress(versionHeader:0 , payload:NSData(bytes:publicKey, length:65))
    XCTAssertEqualObjects(bitcoinAddr.address, expectedBitcoinAddr,
                          "\n[FAIL] Incorrect bitcoinAddr:\n  " +
                          "Expected \(expectedBitcoinAddr)\n  " +
                          "Actual   \(bitcoinAddr.address)\n")
  }
}
