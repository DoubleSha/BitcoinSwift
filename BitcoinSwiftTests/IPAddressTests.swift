//
//  IPAddressTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/6/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class IPAddressTests: XCTestCase {

  let IPV4Bytes: [UInt8] = [
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xff, 0xff, 0x01, 0x02, 0x03, 0x04]

  let IPV6Bytes: [UInt8] = [
      0x01, 0x02, 0x03, 0x04, 0x11, 0x12, 0x13, 0x14,
      0x21, 0x22, 0x23, 0x24, 0x31, 0x32, 0x33, 0x34]

  var IPV4Data: NSData!
  var IPV6Data: NSData!

  let IPV4 = IPAddress.IPV4(0x01020304)
  let IPV6 = IPAddress.IPV6(0x01020304, 0x11121314, 0x21222324, 0x31323334)

  override func setUp() {
    super.setUp()
    IPV4Data = NSData(bytes: IPV4Bytes, length: IPV4Bytes.count)
    IPV6Data = NSData(bytes: IPV6Bytes, length: IPV6Bytes.count)
  }

  func testIPV4AddressEncoding() {
    XCTAssertEqual(IPV4.bitcoinData, IPV4Data)
  }

  func testIPV6AddressEncoding() {
    XCTAssertEqual(IPV6.bitcoinData, IPV6Data)
  }

  func testIPV4AddressDecoding() {
    let stream = NSInputStream(data: IPV4Data)
    stream.open()
    if let testIP = IPAddress.fromBitcoinStream(stream) {
      XCTAssertEqual(testIP, IPV4)
    } else {
      XCTFail("Failed to parse IP")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testIPV6AddressDecoding() {
    let stream = NSInputStream(data: IPV6Data)
    stream.open()
    if let testIP = IPAddress.fromBitcoinStream(stream) {
      XCTAssertEqual(testIP, IPV6)
    } else {
      XCTFail("Failed to parse IP")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
