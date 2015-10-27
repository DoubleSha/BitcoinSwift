//
//  BitcoinDecodingTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/6/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class BitcoinDecodingTests: XCTestCase {

  func testReadUInt32LittleEndian() {
    let data = NSData(bytes: [0x01, 0x02, 0x03, 0x04] as [UInt8], length: 4)
    let expectedInt: UInt32 = 0x04030201
    let int: UInt32 = data.UInt32AtIndex(0)!
    XCTAssertEqual(int, expectedInt)
  }

  func testReadUInt32BigEndian() {
    let data = NSData(bytes: [0x01, 0x02, 0x03, 0x04] as [UInt8], length: 4)
    let expectedInt: UInt32 = 0x01020304
    let int: UInt32 = data.UInt32AtIndex(0, endianness: .BigEndian)!
    XCTAssertEqual(int, expectedInt)
  }

  func testReversedDataWithOddBytes() {
    let data = NSData(bytes: [0x01, 0x02, 0x03] as [UInt8], length: 3)
    let expectedData = NSData(bytes: [0x03, 0x02, 0x01] as [UInt8], length: 3)
    XCTAssertEqual(data.reversedData, expectedData)
  }

  func testReversedDataWithEvenBytes() {
    let data = NSData(bytes: [0x01, 0x02, 0x03, 0x04] as [UInt8], length: 4)
    let expectedData = NSData(bytes: [0x04, 0x03, 0x02, 0x01] as [UInt8], length: 4)
    XCTAssertEqual(data.reversedData, expectedData)
  }

  func testReadUInt8FromStream() {
    let bytes: [UInt8] = [0x01, 0x02]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()

    // Test reading a little-endian UInt8.
    if let int = stream.readUInt8() {
      XCTAssertEqual(int, UInt8(0x01))
    } else {
      XCTFail("Failed to read int")
    }

    // Test reading a big-endian UInt8.
    if let int = stream.readUInt8() {
      XCTAssertEqual(int, UInt8(0x02))
    } else {
      XCTFail("Failed to read int")
    }

    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadUInt16FromStream() {
    let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()

    // Test reading a little-endian UInt16.
    if let int = stream.readUInt16() {
      XCTAssertEqual(int, UInt16(0x0201))
    } else {
      XCTFail("Failed to read int")
    }

    // Test reading a big-endian UInt16.
    if let int = stream.readUInt16(.BigEndian) {
      XCTAssertEqual(int, UInt16(0x0304))
    } else {
      XCTFail("Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let _ = stream.readUInt16() {
      XCTFail("Expected to fail")
    }

    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadUInt32FromStream() {
    let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()

    // Test reading a little-endian UInt32.
    if let int = stream.readUInt32() {
      XCTAssertEqual(int, UInt32(0x04030201))
    } else {
      XCTFail("Failed to read int")
    }

    // Test reading a big-endian UInt32.
    if let int = stream.readUInt32(.BigEndian) {
      XCTAssertEqual(int, UInt32(0x05060708))
    } else {
      XCTFail("Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let _ = stream.readUInt32() {
      XCTFail("Expected to fail")
    }

    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadUInt64FromStream() {
    let bytes: [UInt8] = [
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()

    // Test reading a little-endian UInt64.
    if let int = stream.readUInt64() {
      XCTAssertEqual(int, UInt64(0x0807060504030201))
    } else {
      XCTFail("Failed to read int")
    }

    // Test reading a big-endian UInt64.
    if let int = stream.readUInt64(.BigEndian) {
      XCTAssertEqual(int, UInt64(0x090a0b0c0d0e0f10))
    } else {
      XCTFail("Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let _ = stream.readUInt64() {
      XCTFail("Expected to fail")
    }

    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadInt16FromStream() {
    let bytes: [UInt8] = [0xfe, 0xff, 0xff, 0xfe, 0x05]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()

    // Test reading a little-endian Int16.
    if let int = stream.readInt16() {
      XCTAssertEqual(int, Int16(-2))
    } else {
      XCTFail("Failed to read int")
    }

    // Test reading a big-endian Int16.
    if let int = stream.readInt16(.BigEndian) {
      XCTAssertEqual(int, Int16(-2))
    } else {
      XCTFail("Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let _ = stream.readInt16() {
      XCTFail("Expected to fail")
    }

    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadInt32FromStream() {
    let bytes: [UInt8] = [0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x09]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()

    // Test reading a little-endian Int32.
    if let int = stream.readInt32() {
      XCTAssertEqual(int, Int32(-2))
    } else {
      XCTFail("Failed to read int")
    }

    // Test reading a big-endian Int32.
    if let int = stream.readInt32(.BigEndian) {
      XCTAssertEqual(int, Int32(-2))
    } else {
      XCTFail("Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let _ = stream.readInt32() {
      XCTFail("Expected to fail")
    }

    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadInt64FromStream() {
    let bytes: [UInt8] = [
        0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x11]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()

    // Test reading a little-endian Int64.
    if let int = stream.readInt64() {
      XCTAssertEqual(int, Int64(-2))
    } else {
      XCTFail("Failed to read int")
    }

    // Test reading a big-endian Int64.
    if let int = stream.readInt64(.BigEndian) {
      XCTAssertEqual(int, Int64(-2))
    } else {
      XCTFail("Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let _ = stream.readInt64() {
      XCTFail("Expected to fail")
    }

    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadBool() {
    let bytes: [UInt8] = [0x01, 0x00]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()
    if let bool = stream.readBool() {
      XCTAssertTrue(bool)
    } else {
      XCTFail("Failed to read varint")
    }
    if let bool = stream.readBool() {
      XCTAssertFalse(bool)
    } else {
      XCTFail("Failed to read varint")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadASCIIString() {
    let bytes: [UInt8] = [0x61, 0x62, 0x63] // "abc"
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()
    if let string = stream.readASCIIStringWithLength(3) {
      XCTAssertEqual(string, "abc")
    } else {
      XCTFail("Failed to parse string")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadASCIIStringWithTrailingZeros() {
    let bytes: [UInt8] = [0x61, 0x62, 0x63, 0x00, 0x00, 0x00, 0x00] // "abc" with trailing 0's
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()
    if let string = stream.readASCIIStringWithLength(7) {
      XCTAssertEqual(string, "abc")
    } else {
      XCTFail("Failed to parse string")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadBytes() {
    let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()

    // Test reading data of a fixed length.
    if let data = stream.readData(4) {
      let expectedBytes: [UInt8] = [0x01, 0x02, 0x03, 0x04]
      let expectedData = NSData(bytes: expectedBytes, length: expectedBytes.count)
      XCTAssertEqual(data, expectedData)
    } else {
      XCTFail("Failed to read data")
    }

    // Test reading the remaining data.
    if let data = stream.readData() {
      let expectedBytes: [UInt8] = [0x05, 0x06, 0x07, 0x08, 0x09]
      let expectedData = NSData(bytes: expectedBytes, length: expectedBytes.count)
      XCTAssertEqual(data, expectedData)
    } else {
      XCTFail("Failed to read data")
    }

    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadVarIntUInt8() {
    let bytes: [UInt8] = [0xfc]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()
    if let uint8 = stream.readVarInt() {
      XCTAssertEqual(uint8, UInt64(0xfc))
    } else {
      XCTFail("Failed to read varint")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadVarIntUInt16() {
    let bytes: [UInt8] = [0xfd, 0x02, 0x01]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()
    if let uint16 = stream.readVarInt() {
      XCTAssertEqual(uint16, UInt64(0x0102))
    } else {
      XCTFail("Failed to read varint")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadVarIntUInt32() {
    let bytes: [UInt8] = [0xfe, 0x04, 0x03, 0x02, 0x01]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()
    if let uint32 = stream.readVarInt() {
      XCTAssertEqual(uint32, UInt64(0x01020304))
    } else {
      XCTFail("Failed to read varint")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadVarIntUInt64() {
    let bytes: [UInt8] = [0xff, 0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()
    if let uint64 = stream.readVarInt() {
      XCTAssertEqual(uint64, UInt64(0x0102030405060708))
    } else {
      XCTFail("Failed to read varint")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadVarString() {
    let bytes: [UInt8] = [0x03, 0x61, 0x62, 0x63] // "abc"
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()
    if let string = stream.readVarString() {
      XCTAssertEqual(string, "abc")
    } else {
      XCTFail("Failed to parse string")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testReadDateFrom32BitUnixTimestamp() {
    let bytes: [UInt8] = [0xe2, 0x15, 0x10, 0x4d]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()
    if let date = stream.readDateFrom32BitUnixTimestamp() {
      let expectedDate = NSDate(timeIntervalSince1970: NSTimeInterval(0x4d1015e2))
      XCTAssertEqual(date, expectedDate)
    } else {
      XCTFail("Failed to parse Date")
    }
  }

  func testReadDateFrom64BitUnixTimestamp() {
    let bytes: [UInt8] = [0xe2, 0x15, 0x10, 0x4d, 0x00, 0x00, 0x00, 0x00]
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()
    if let date = stream.readDateFrom64BitUnixTimestamp() {
      let expectedDate = NSDate(timeIntervalSince1970: NSTimeInterval(0x4d1015e2))
      XCTAssertEqual(date, expectedDate)
    } else {
      XCTFail("Failed to parse Date")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
