//
//  BitcoinEncodingTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import XCTest

class BitcoinEncodingTests: XCTestCase {

  func testAppendUInt8() {
    var data = NSMutableData()
    data.appendUInt8(0x1)
    let expectedData = NSData(bytes:[0x01] as UInt8[], length:1)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendUInt16LittleEndian() {
    var data = NSMutableData()
    data.appendUInt16(UInt16(0x0102))
    let expectedData = NSData(bytes:[0x02, 0x01] as UInt8[], length:2)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendUInt16BigEndian() {
    var data = NSMutableData()
    data.appendUInt16(UInt16(0x0102), endianness:.BigEndian)
    let expectedData = NSData(bytes:[0x01, 0x02] as UInt8[], length:2)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

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

  func testAppendUInt64LittleEndian() {
    var data = NSMutableData()
    data.appendUInt64(UInt64(0x0102030405060708))
    let expectedData = NSData(bytes:[0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01] as UInt8[],
                              length:8)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendUInt64BigEndian() {
    var data = NSMutableData()
    data.appendUInt64(UInt64(0x0102030405060708), endianness:.BigEndian)
    let expectedData = NSData(bytes:[0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08] as UInt8[],
                              length:8)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testReadUInt32LittleEndian() {
    let data = NSData(bytes:[0x01, 0x02, 0x03, 0x04] as UInt8[], length:4)
    let expectedInt: UInt32 = 0x04030201
    let int: UInt32 = data.UInt32AtIndex(0)!
    XCTAssertEqual(int, expectedInt, "\n[FAIL] Invalid int \(int)")
  }

  func testReadUInt32BigEndian() {
    let data = NSData(bytes:[0x01, 0x02, 0x03, 0x04] as UInt8[], length:4)
    let expectedInt: UInt32 = 0x01020304
    let int: UInt32 = data.UInt32AtIndex(0, endianness:.BigEndian)!
    XCTAssertEqual(int, expectedInt, "\n[FAIL] Invalid int \(int)")
  }

  func testReadUInt8FromStream() {
    let bytes: UInt8[] = [0x01, 0x02]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()

    // Test reading a little-endian UInt8.
    if let int = inputStream.readUInt8() {
      XCTAssertEqual(int, 0x01, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // Test reading a big-endian UInt8.
    if let int = inputStream.readUInt8() {
      XCTAssertEqual(int, 0x02, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadUInt16FromStream() {
    let bytes: UInt8[] = [0x01, 0x02, 0x03, 0x04, 0x05]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()

    // Test reading a little-endian UInt16.
    if let int = inputStream.readUInt16() {
      XCTAssertEqual(int, 0x0201, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // Test reading a big-endian UInt16.
    if let int = inputStream.readUInt16(endianness:.BigEndian) {
      XCTAssertEqual(int, 0x0304, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let int = inputStream.readUInt16() {
      XCTFail("\n[FAIL] Expected to fail")
    }

    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadUInt32FromStream() {
    let bytes: UInt8[] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()

    // Test reading a little-endian UInt32.
    if let int = inputStream.readUInt32() {
      XCTAssertEqual(int, 0x04030201, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // Test reading a big-endian UInt32.
    if let int = inputStream.readUInt32(endianness:.BigEndian) {
      XCTAssertEqual(int, 0x05060708, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let int = inputStream.readUInt32() {
      XCTFail("\n[FAIL] Expected to fail")
    }

    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadUInt64FromStream() {
    let bytes: UInt8[] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
                          0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()

    // Test reading a little-endian UInt64.
    if let int = inputStream.readUInt64() {
      XCTAssertEqual(int, 0x0807060504030201, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // Test reading a big-endian UInt64.
    if let int = inputStream.readUInt64(endianness:.BigEndian) {
      XCTAssertEqual(int, 0x090a0b0c0d0e0f10, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let int = inputStream.readUInt64() {
      XCTFail("\n[FAIL] Expected to fail")
    }

    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadASCIIString() {
    let bytes: UInt8[] = [0x61, 0x62, 0x63] // "abc"
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()
    if let string = inputStream.readASCIIStringWithLength(3) {
      XCTAssertEqual(string, "abc", "\n[FAIL] Unexpected string \(string)")
    } else {
      XCTFail("\n[FAIL] Failed to parse string")
    }
    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadASCIIStringWithTrailingZeros() {
    let bytes: UInt8[] = [0x61, 0x62, 0x63, 0x00, 0x00, 0x00, 0x00] // "abc" with trailing 0's
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()
    if let string = inputStream.readASCIIStringWithLength(7) {
      XCTAssertEqual(string, "abc", "\n[FAIL] Unexpected string \(string)")
    } else {
      XCTFail("\n[FAIL] Failed to parse string")
    }
    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadBytes() {
    let bytes: UInt8[] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()

    // Test reading data of a fixed length.
    if let data = inputStream.readData(length:4) {
      let expectedBytes: UInt8[] = [0x01, 0x02, 0x03, 0x04]
      let expectedData = NSData(bytes:expectedBytes, length:expectedBytes.count)
      XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data \(data)")
    } else {
      XCTFail("\n[FAIL] Failed to read data")
    }

    // Test reading the remaining data.
    if let data = inputStream.readData() {
      let expectedBytes: UInt8[] = [0x05, 0x06, 0x07, 0x08, 0x09]
      let expectedData = NSData(bytes:expectedBytes, length:expectedBytes.count)
      XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data \(data)")
    } else {
      XCTFail("\n[FAIL] Failed to read data")
    }

    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }
}
