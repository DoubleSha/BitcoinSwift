//
//  AddressTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/20/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class AddressTests: XCTestCase {

  func testAddressFromECKey() {
    let publicKeyBytes: [UInt8] = [
        0x03, 0x36, 0xff, 0xdd, 0x88, 0xa9, 0x55, 0x93,
        0xe1, 0x4d, 0x8b, 0x90, 0x2b, 0xc0, 0x8c, 0xee,
        0xa8, 0x81, 0x1c, 0xa4, 0x4f, 0x47, 0x9a, 0xc7,
        0x68, 0x75, 0x3e, 0xd2, 0xde, 0x14, 0xa3, 0x4b, 0x2a]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let key = ECKey(publicKey: publicKey)
    let address = Address(params: BitcoinMainNetParameters.get(), key: key)
    XCTAssertEqual(address.stringValue, "1XxXTQbNTVfGvSaLpWYkHUeN3BqHWm7mZ")
  }

  func testAddressFromStringValue() {
    let hash160Bytes: [UInt8] = [
        0x05, 0xda, 0xd4, 0x30, 0x89, 0xc9, 0x90, 0x14,
        0x2e, 0x65, 0x09, 0xeb, 0x42, 0xd9, 0x0b, 0xa0,
        0x36, 0xf0, 0x85, 0xf1]
    let hash160 = NSData(bytes: hash160Bytes, length: hash160Bytes.count)
    let address = Address(params: BitcoinMainNetParameters.get(),
                          stringValue: "1XxXTQbNTVfGvSaLpWYkHUeN3BqHWm7mZ")!
    XCTAssertEqual(address.hash160, hash160)
  }

  func testInvalidAddresses() {
    // Left a character off the end.
    var address = Address(params: BitcoinMainNetParameters.get(),
                          stringValue: "1XxXTQbNTVfGvSaLpWYkHUeN3BqHWm7m")
    XCTAssertTrue(address == nil)

    // Too long to be valid.
    address = Address(params: BitcoinMainNetParameters.get(),
                      stringValue: "1XxXTQbNTVfGvSaLpWYkHUeN3BqHWm7mfjfjfjfj")
    XCTAssertTrue(address == nil)

    // Invalid params.
    address = Address(params: BitcoinTestNetParameters.get(),
                      stringValue: "1XxXTQbNTVfGvSaLpWYkHUeN3BqHWm7mZ")
    XCTAssertTrue(address == nil)
  }
}
