//
//  BitcoinEncodingTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class BitcoinEncodingTests: XCTestCase {

  func testAppendUInt8() {
    let data = NSMutableData()
    data.appendUInt8(0x1)
    let expectedData = NSData(bytes: [0x01] as [UInt8], length: 1)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendUInt16LittleEndian() {
    let data = NSMutableData()
    data.appendUInt16(UInt16(0x0102))
    let expectedData = NSData(bytes: [0x02, 0x01] as [UInt8], length: 2)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendUInt16BigEndian() {
    let data = NSMutableData()
    data.appendUInt16(UInt16(0x0102), endianness: .BigEndian)
    let expectedData = NSData(bytes: [0x01, 0x02] as [UInt8], length: 2)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendUInt32LittleEndian() {
    let data = NSMutableData()
    data.appendUInt32(UInt32(0x01020304))
    let expectedData = NSData(bytes: [0x04, 0x03, 0x02, 0x01] as [UInt8], length: 4)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendUInt32BigEndian() {
    let data = NSMutableData()
    data.appendUInt32(UInt32(0x01020304), endianness: .BigEndian)
    let expectedData = NSData(bytes: [0x01, 0x02, 0x03, 0x04] as [UInt8], length: 4)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendUInt64LittleEndian() {
    let data = NSMutableData()
    data.appendUInt64(UInt64(0x0102030405060708))
    let expectedData = NSData(bytes: [0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01] as [UInt8],
                              length: 8)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendUInt64BigEndian() {
    let data = NSMutableData()
    data.appendUInt64(UInt64(0x0102030405060708), endianness: .BigEndian)
    let expectedData = NSData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08] as [UInt8],
                              length: 8)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendInt16LittleEndian() {
    let data = NSMutableData()
    data.appendInt16(-2)
    let expectedData = NSData(bytes: [0xfe, 0xff] as [UInt8], length: 2)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendInt16BigEndian() {
    let data = NSMutableData()
    data.appendInt16(-2, endianness: .BigEndian)
    let expectedData = NSData(bytes: [0xff, 0xfe] as [UInt8], length: 2)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendInt32LittleEndian() {
    let data = NSMutableData()
    data.appendInt32(-2)
    let expectedData = NSData(bytes: [0xfe, 0xff, 0xff, 0xff] as [UInt8], length: 4)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendInt32BigEndian() {
    let data = NSMutableData()
    data.appendInt32(-2, endianness: .BigEndian)
    let expectedData = NSData(bytes: [0xff, 0xff, 0xff, 0xfe] as [UInt8], length: 4)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendInt64LittleEndian() {
    let data = NSMutableData()
    data.appendInt64(-2)
    let expectedData = NSData(bytes: [0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff] as [UInt8],
                              length: 8)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendInt64BigEndian() {
    let data = NSMutableData()
    data.appendInt64(-2, endianness: .BigEndian)
    let expectedData = NSData(bytes: [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe] as [UInt8],
                              length: 8)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendBool() {
    let data = NSMutableData()
    data.appendBool(true)
    var expectedData = NSData(bytes: [0x01] as [UInt8], length: 1)
    XCTAssertEqual(data, expectedData)
    data.appendBool(false)
    expectedData = NSData(bytes: [0x01, 0x00] as [UInt8], length: 2)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendVarIntUInt8() {
    let data = NSMutableData()
    data.appendVarInt(0xfc)
    let expectedData = NSData(bytes: [0xfc] as [UInt8], length: 1)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendVarIntUInt16() {
    let data = NSMutableData()
    data.appendVarInt(0x00fd)
    let expectedData = NSData(bytes: [0xfd, 0xfd, 0x00] as [UInt8], length: 3)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendVarIntUInt32() {
    let data = NSMutableData()
    data.appendVarInt(0x010000)
    let expectedData = NSData(bytes: [0xfe, 0x00, 0x00, 0x01, 0x00] as [UInt8], length: 5)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendVarIntUInt64() {
    let data = NSMutableData()
    data.appendVarInt(0x0100000000)
    let expectedData =
        NSData(bytes: [0xff, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00] as [UInt8], length: 9)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendVarString() {
    let data = NSMutableData()
    data.appendVarString("abc")
    let expectedData = NSData(bytes: [0x03, 0x61, 0x62, 0x63] as [UInt8], length: 4)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendDateAs32BitUnixTimestamp() {
    let date = NSDate(timeIntervalSince1970: NSTimeInterval(0x4d1015e2))
    let data = NSMutableData()
    data.appendDateAs32BitUnixTimestamp(date)
    let expectedBytes: [UInt8] = [0xe2, 0x15, 0x10, 0x4d]
    let expectedData = NSData(bytes: expectedBytes, length: expectedBytes.count)
    XCTAssertEqual(data, expectedData)
  }

  func testAppendDateAs64BitUnixTimestamp() {
    let date = NSDate(timeIntervalSince1970: NSTimeInterval(0x4d1015e2))
    let data = NSMutableData()
    data.appendDateAs64BitUnixTimestamp(date)
    let expectedBytes: [UInt8] = [0xe2, 0x15, 0x10, 0x4d, 0x00, 0x00, 0x00, 0x00]
    let expectedData = NSData(bytes: expectedBytes, length: expectedBytes.count)
    XCTAssertEqual(data, expectedData)
  }
}
