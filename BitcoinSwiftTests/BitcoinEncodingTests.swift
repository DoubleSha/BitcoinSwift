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

  func testAppendInt16LittleEndian() {
    var data = NSMutableData()
    data.appendInt16(-2)
    let expectedData = NSData(bytes:[0xfe, 0xff] as UInt8[], length:2)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendInt16BigEndian() {
    var data = NSMutableData()
    data.appendInt16(-2, endianness:.BigEndian)
    let expectedData = NSData(bytes:[0xff, 0xfe] as UInt8[], length:2)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendInt32LittleEndian() {
    var data = NSMutableData()
    data.appendInt32(-2)
    let expectedData = NSData(bytes:[0xfe, 0xff, 0xff, 0xff] as UInt8[], length:4)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendInt32BigEndian() {
    var data = NSMutableData()
    data.appendInt32(-2, endianness:.BigEndian)
    let expectedData = NSData(bytes:[0xff, 0xff, 0xff, 0xfe] as UInt8[], length:4)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendInt64LittleEndian() {
    var data = NSMutableData()
    data.appendInt64(-2)
    let expectedData = NSData(bytes:[0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff] as UInt8[],
                              length:8)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendInt64BigEndian() {
    var data = NSMutableData()
    data.appendInt64(-2, endianness:.BigEndian)
    let expectedData = NSData(bytes:[0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe] as UInt8[],
                              length:8)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendVarIntUInt8() {
    var data = NSMutableData()
    data.appendVarInt(0xfc)
    let expectedData = NSData(bytes:[0xfc] as UInt8[], length:1)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendVarIntUInt16() {
    var data = NSMutableData()
    data.appendVarInt(0x00fd)
    let expectedData = NSData(bytes:[0xfd, 0xfd, 0x00] as UInt8[], length:3)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendVarIntUInt32() {
    var data = NSMutableData()
    data.appendVarInt(0x010000)
    let expectedData = NSData(bytes:[0xfe, 0x00, 0x00, 0x01, 0x00] as UInt8[], length:5)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendVarIntUInt64() {
    var data = NSMutableData()
    data.appendVarInt(0x0100000000)
    let expectedData =
        NSData(bytes:[0xff, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00] as UInt8[], length:9)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendBool() {
    var data = NSMutableData()
    data.appendBool(true)
    var expectedData = NSData(bytes:[0x01] as UInt8[], length:1)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
    data.appendBool(false)
    expectedData = NSData(bytes:[0x01, 0x00] as UInt8[], length:2)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendVarString() {
    var data = NSMutableData()
    data.appendVarString("abc")
    let expectedData = NSData(bytes:[0x03, 0x61, 0x62, 0x63] as UInt8[], length:4)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendIPV4Address() {
    var data = NSMutableData()
    data.appendIPAddress(NetworkAddress.IPAddress.IPV4(0x01020304))
    let IPBytes: UInt8[] = [0x00, 0x00, 0x00, 0x00,
                            0x00, 0x00, 0x00, 0x00,
                            0x00, 0x00, 0xff, 0xff,
                            0x01, 0x02, 0x03, 0x04]
    let expectedData = NSData(bytes:IPBytes, length:IPBytes.count)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendIPV6Address() {
    var data = NSMutableData()
    data.appendIPAddress(NetworkAddress.IPAddress.IPV6(0x01020304,
                                                       0x11121314,
                                                       0x21222324,
                                                       0x31323334))
    let IPBytes: UInt8[] = [0x01, 0x02, 0x03, 0x04,
                            0x11, 0x12, 0x13, 0x14,
                            0x21, 0x22, 0x23, 0x24,
                            0x31, 0x32, 0x33, 0x34]
    let expectedData = NSData(bytes:IPBytes, length:IPBytes.count)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }

  func testAppendNetworkAddress() {
    let date = NSDate(timeIntervalSince1970:1)
    let services = Message.Services.NodeNetwork
    let IP = NetworkAddress.IPAddress.IPV4(0x01020304)
    let port: UInt16 = 8333
    let networkAddress = NetworkAddress(date:date, services:services, IP:IP, port:port)
    var data = NSMutableData()
    data.appendNetworkAddress(networkAddress)
    let expectedBytes: UInt8[] = [0x01, 0x00, 0x00, 0x00,                         // timestamp
                                  0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services
                                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // IP
                                  0x00, 0x00, 0xff, 0xff, 0x01, 0x02, 0x03, 0x04, // IP
                                  0x20, 0x8D]                                     // port
    let expectedData = NSData(bytes:expectedBytes, length:expectedBytes.count)
    XCTAssertEqualObjects(data, expectedData, "\n[FAIL] Invalid data " + data.hexString())
  }
}
