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

  let base58Bytes: [UInt8] = [
      0x00, 0x01, 0x09, 0x66, 0x77, 0x60, 0x06, 0x95,
      0x3D, 0x55, 0x67, 0x43, 0x9E, 0x5E, 0x39, 0xF8,
      0x6A, 0x0D, 0x27, 0x3B, 0xEE, 0xD6, 0x19, 0x67, 0xF6]

  let base58BytesWithLeadingZeros: [UInt8] = [
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x5D,
      0x23, 0x8C, 0x7F, 0x7C, 0xB6, 0x23, 0xD0, 0x3C,
      0x47, 0xA1, 0xE8, 0x31, 0x84, 0x38, 0x44, 0x20, 0xEF]

  var base58Data: NSData!
  var base58DataWithLeadingZeros: NSData!

  let base58String = "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM"
  let base58StringWithLeadingZeros = "111111Cy3N8mvNoTsRECfT9Ywzm3EDs4"
  let invalidBase58Strings = ["3N8mvN034", "3N8mvNI34", "3N8mvNO34",
                              "3N8mvNl34", "3N8mvN+34", "3N8mvN-34"]

  override func setUp() {
    base58Data = NSData(bytes: base58Bytes, length: base58Bytes.count)
    base58DataWithLeadingZeros = NSData(bytes: base58BytesWithLeadingZeros,
                                        length: base58BytesWithLeadingZeros.count)
  }

  func testBase58Encoding() {
    XCTAssertEqual(base58Data.base58String, base58String)
  }

  func testBase58EncodingWithLeadingZeros() {
    XCTAssertEqual(base58DataWithLeadingZeros.base58String, base58StringWithLeadingZeros)
  }

  func testBase58EncodingWithEmptyData() {
    XCTAssertEqual(NSData().base58String, "")
  }

  func testBase58Decoding() {
    if let testBase58Data = NSData.fromBase58String(base58String) {
      XCTAssertEqual(testBase58Data, base58Data)
    } else {
      XCTFail("Failed to parse base58Data")
    }
  }

  func testBase58DecodingWithLeadingZeros() {
    if let testBase58Data = NSData.fromBase58String(base58StringWithLeadingZeros) {
      XCTAssertEqual(testBase58Data, base58DataWithLeadingZeros)
    } else {
      XCTFail("Failed to parse base58DataWithLeadingZeros")
    }
  }

  func testBase58DecodingWithInvalidBase58String() {
    for invalidBase58String in invalidBase58Strings {
      XCTAssertNil(NSData.fromBase58String(invalidBase58String))
    }
  }

  func testBase58DecodingWithEmptyData() {
    if let testBase58Data = NSData.fromBase58String("") {
      XCTAssertEqual(testBase58Data, NSData())
    } else {
      XCTFail("Failed to parse empty base58Data")
    }
  }
}
