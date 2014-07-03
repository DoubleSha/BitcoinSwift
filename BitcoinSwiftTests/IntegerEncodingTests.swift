//
//  IntegerEncodingTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import XCTest

class IntegerEncodingTests: XCTestCase {

  func testAppendUInt32LittleEndian() {
    var data = NSMutableData()
    data.appendUInt32(UInt32(0x01020304))
    let expectedData = NSData(bytes:[0x04, 0x03, 0x02, 0x01] as UInt8[], length:4)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendUInt32BigEndian() {
    var data = NSMutableData()
    data.appendUInt32(UInt32(0x01020304), endianness:.BigEndian)
    let expectedData = NSData(bytes:[0x01, 0x02, 0x03, 0x04] as UInt8[], length:4)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testReadUInt32LittleEndian() {
    let data = NSData(bytes:[0x01, 0x02, 0x03, 0x04] as UInt8[], length:4)
    let expectedInt: UInt32 = 0x04030201
    let int: UInt32 = data.UInt32AtIndex(0)
    XCTAssertEqual(int, expectedInt, "\n[FAIL] Invalid int \(int)")
  }

  func testReadUInt32BigEndian() {
    let data = NSData(bytes:[0x01, 0x02, 0x03, 0x04] as UInt8[], length:4)
    let expectedInt: UInt32 = 0x01020304
    let int: UInt32 = data.UInt32AtIndex(0, endianness:.BigEndian)
    XCTAssertEqual(int, expectedInt, "\n[FAIL] Invalid int \(int)")
  }
}
