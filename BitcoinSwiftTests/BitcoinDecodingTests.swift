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
    let data = NSData(bytes:[0x01, 0x02, 0x03, 0x04] as [UInt8], length:4)
    let expectedInt: UInt32 = 0x04030201
    let int: UInt32 = data.UInt32AtIndex(0)!
    XCTAssertEqual(int, expectedInt, "\n[FAIL] Invalid int \(int)")
  }

  func testReadUInt32BigEndian() {
    let data = NSData(bytes:[0x01, 0x02, 0x03, 0x04] as [UInt8], length:4)
    let expectedInt: UInt32 = 0x01020304
    let int: UInt32 = data.UInt32AtIndex(0, endianness:.BigEndian)!
    XCTAssertEqual(int, expectedInt, "\n[FAIL] Invalid int \(int)")
  }

  func testReadUInt8FromStream() {
    let bytes: [UInt8] = [0x01, 0x02]
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
    let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05]
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
    let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09]
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
    let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
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

  func testReadInt16FromStream() {
    let bytes: [UInt8] = [0xfe, 0xff, 0xff, 0xfe, 0x05]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()

    // Test reading a little-endian Int16.
    if let int = inputStream.readInt16() {
      XCTAssertEqual(int, -2, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // Test reading a big-endian Int16.
    if let int = inputStream.readInt16(endianness:.BigEndian) {
      XCTAssertEqual(int, -2, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let int = inputStream.readInt16() {
      XCTFail("\n[FAIL] Expected to fail")
    }

    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadInt32FromStream() {
    let bytes: [UInt8] = [0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x09]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()

    // Test reading a little-endian Int32.
    if let int = inputStream.readInt32() {
      XCTAssertEqual(int, -2, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // Test reading a big-endian Int32.
    if let int = inputStream.readInt32(endianness:.BigEndian) {
      XCTAssertEqual(int, -2, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let int = inputStream.readInt32() {
      XCTFail("\n[FAIL] Expected to fail")
    }

    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadInt64FromStream() {
    let bytes: [UInt8] = [0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
                          0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x11]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()

    // Test reading a little-endian Int64.
    if let int = inputStream.readInt64() {
      XCTAssertEqual(int, -2, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // Test reading a big-endian Int64.
    if let int = inputStream.readInt64(endianness:.BigEndian) {
      XCTAssertEqual(int, -2, "\n[FAIL] Unexpected int \(int)")
    } else {
      XCTFail("\n[FAIL] Failed to read int")
    }

    // There is only one byte left, which is not long enough.
    if let int = inputStream.readInt64() {
      XCTFail("\n[FAIL] Expected to fail")
    }

    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadASCIIString() {
    let bytes: [UInt8] = [0x61, 0x62, 0x63] // "abc"
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
    let bytes: [UInt8] = [0x61, 0x62, 0x63, 0x00, 0x00, 0x00, 0x00] // "abc" with trailing 0's
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
    let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()

    // Test reading data of a fixed length.
    if let data = inputStream.readData(length:4) {
      let expectedBytes: [UInt8] = [0x01, 0x02, 0x03, 0x04]
      let expectedData = NSData(bytes:expectedBytes, length:expectedBytes.count)
      XCTAssertEqual(data, expectedData, "\n[FAIL] Invalid data \(data)")
    } else {
      XCTFail("\n[FAIL] Failed to read data")
    }

    // Test reading the remaining data.
    if let data = inputStream.readData() {
      let expectedBytes: [UInt8] = [0x05, 0x06, 0x07, 0x08, 0x09]
      let expectedData = NSData(bytes:expectedBytes, length:expectedBytes.count)
      XCTAssertEqual(data, expectedData, "\n[FAIL] Invalid data \(data)")
    } else {
      XCTFail("\n[FAIL] Failed to read data")
    }

    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadVarIntUInt8() {
    let bytes: [UInt8] = [0xfc]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()
    if let uint8 = inputStream.readVarInt() {
      XCTAssertEqual(uint8, 0xfc, "\n[FAIL] Invalid int \(uint8)")
    } else {
      XCTFail("\n[FAIL] Failed to read varint")
    }
    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadVarIntUInt16() {
    let bytes: [UInt8] = [0xfd, 0x02, 0x01]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()
    if let uint16 = inputStream.readVarInt() {
      XCTAssertEqual(uint16, 0x0102, "\n[FAIL] Invalid int \(uint16)")
    } else {
      XCTFail("\n[FAIL] Failed to read varint")
    }
    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadVarIntUInt32() {
    let bytes: [UInt8] = [0xfe, 0x04, 0x03, 0x02, 0x01]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()
    if let uint32 = inputStream.readVarInt() {
      XCTAssertEqual(uint32, 0x01020304, "\n[FAIL] Invalid int \(uint32)")
    } else {
      XCTFail("\n[FAIL] Failed to read varint")
    }
    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadVarIntUInt64() {
    let bytes: [UInt8] = [0xff, 0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()
    if let uint64 = inputStream.readVarInt() {
      XCTAssertEqual(uint64, 0x0102030405060708, "\n[FAIL] Invalid int \(uint64)")
    } else {
      XCTFail("\n[FAIL] Failed to read varint")
    }
    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadBool() {
    let bytes: [UInt8] = [0x01, 0x00]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()
    if let bool = inputStream.readBool() {
      XCTAssertTrue(bool, "\n[FAIL] Invalid bool \(bool)")
    } else {
      XCTFail("\n[FAIL] Failed to read varint")
    }
    if let bool = inputStream.readBool() {
      XCTAssertFalse(bool, "\n[FAIL] Invalid bool \(bool)")
    } else {
      XCTFail("\n[FAIL] Failed to read varint")
    }
    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadVarString() {
    let bytes: [UInt8] = [0x03, 0x61, 0x62, 0x63] // "abc"
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()
    if let string = inputStream.readVarString() {
      XCTAssertEqual(string, "abc", "\n[FAIL] Unexpected string \(string)")
    } else {
      XCTFail("\n[FAIL] Failed to parse string")
    }
    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadIPV4Address() {
    let bytes: [UInt8] = [0x00, 0x00, 0x00, 0x00,
                          0x00, 0x00, 0x00, 0x00,
                          0x00, 0x00, 0xff, 0xff,
                          0x01, 0x02, 0x03, 0x04]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()
    if let IP = inputStream.readIPAddress() {
      let expectedIP = IPAddress.IPV4(0x01020304)
      XCTAssertEqual(IP, expectedIP, "\n[FAIL] Invalid IP")
    } else {
      XCTFail("\n[FAIL] Failed to parse IP")
    }
    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadIPV6Address() {
    let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04,
                          0x11, 0x12, 0x13, 0x14,
                          0x21, 0x22, 0x23, 0x24,
                          0x31, 0x32, 0x33, 0x34]
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()
    if let IP = inputStream.readIPAddress() {
      let expectedIP = IPAddress.IPV6(0x01020304,
                                      0x11121314,
                                      0x21222324,
                                      0x31323334)
      XCTAssertEqual(IP, expectedIP, "\n[FAIL] Invalid IP")
    } else {
      XCTFail("\n[FAIL] Failed to parse IP")
    }
    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }

  func testReadPeerAddress() {
    let bytes: [UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services
                          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // IP
                          0x00, 0x00, 0xff, 0xff, 0x01, 0x02, 0x03, 0x04, // IP
                          0x20, 0x8D]                                     // port
    let data = NSData(bytes:bytes, length:bytes.count)
    let inputStream = NSInputStream(data:data)
    inputStream.open()
    if let peerAddress = inputStream.readPeerAddress() {
      let services = Message.Services.NodeNetwork
      let IP = IPAddress.IPV4(0x01020304)
      let port: UInt16 = 8333
      let expectedPeerAddress = PeerAddress(services:services, IP:IP, port:port)
      XCTAssertEqual(peerAddress, expectedPeerAddress, "\n[FAIL] Invalid PeerAddress")
    } else {
      XCTFail("\n[FAIL] Failed to parse PeerAddress")
    }
    XCTAssertFalse(inputStream.hasBytesAvailable, "\n[FAIL] inputStream should be exhausted")
    inputStream.close()
  }
}
