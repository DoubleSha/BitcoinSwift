//
//  PeerAddressTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/6/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class PeerAddressTests: XCTestCase {

  let peerAddressBytesWithTimestamp: [UInt8] = [
        0xe2, 0x15, 0x10, 0x4d,                         // timestamp
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // IP
        0x00, 0x00, 0xff, 0xff, 0x01, 0x02, 0x03, 0x04, // IP
        0x20, 0x8d]                                     // port

  let peerAddressBytesWithoutTimestamp: [UInt8] = [
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // services
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // IP
        0x00, 0x00, 0xff, 0xff, 0x01, 0x02, 0x03, 0x04, // IP
        0x20, 0x8d]                                     // port

  var peerAddressDataWithTimestamp: NSData!
  var peerAddressDataWithoutTimestamp: NSData!
  var peerAddressWithTimestamp: PeerAddress!
  var peerAddressWithoutTimestamp: PeerAddress!

  override func setUp() {
    peerAddressDataWithTimestamp = NSData(bytes: peerAddressBytesWithTimestamp,
                                          length: peerAddressBytesWithTimestamp.count)
    peerAddressDataWithoutTimestamp = NSData(bytes: peerAddressBytesWithoutTimestamp,
                                             length: peerAddressBytesWithoutTimestamp.count)
    let timestamp = NSDate(timeIntervalSince1970: NSTimeInterval(0x4d1015e2))
    let services = PeerServices.NodeNetwork
    let IP = IPAddress.IPV4(0x01020304)
    let port: UInt16 = 8333
    peerAddressWithTimestamp = PeerAddress(services: services,
                                           IP: IP,
                                           port: port,
                                           timestamp: timestamp)
    peerAddressWithoutTimestamp = PeerAddress(services: services, IP: IP, port: port)
  }

  func testPeerAddressEncodingWithTimestamp() {
    XCTAssertEqual(peerAddressWithTimestamp.bitcoinData, peerAddressDataWithTimestamp)
  }

  func testPeerAddressEncodingWithoutTimestamp() {
    XCTAssertEqual(peerAddressWithTimestamp.bitcoinDataWithTimestamp(false),
                   peerAddressDataWithoutTimestamp)
  }

  func testPeerAddressDecodingWithTimestamp() {
    let stream = NSInputStream(data: peerAddressDataWithTimestamp)
    stream.open()
    if let testPeerAddress = PeerAddress.fromBitcoinStream(stream) {
      XCTAssertEqual(testPeerAddress, peerAddressWithTimestamp)
    } else {
      XCTFail("Failed to parse PeerAddress")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testPeerAddressDecodingWithoutTimestamp() {
    let stream = NSInputStream(data: peerAddressDataWithoutTimestamp)
    stream.open()
    if let testPeerAddress = PeerAddress.fromBitcoinStream(stream, includeTimestamp: false) {
      XCTAssertEqual(testPeerAddress, peerAddressWithoutTimestamp)
    } else {
      XCTFail("Failed to parse PeerAddress")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
