//
//  MessageHeaderTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/24/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class MessageHeaderTests: XCTestCase {

  let network = Message.Network.MainNet
  let command = Message.Command.Version
  let headerBytes: [UInt8] = [
      0xf9, 0xbe, 0xb4, 0xd9, // network (little-endian)
      0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x00, 0x00, 0x00, 0x00, 0x00, // "version" command
      0x02, 0x00, 0x00, 0x00, // payload size (little-endian)
      0xf1, 0x58, 0x13, 0xfa] // payload checksum

  var headerData: NSData!
  var header: Message.Header!

  override func setUp() {
    super.setUp()
    headerData = NSData(bytes: headerBytes, length: headerBytes.count)
    header = Message.Header(network: network.rawValue,
                            command: command,
                            payloadLength: 2,
                            payloadChecksum: 0xfa1358f1)
  }

  func testMessageHeaderEncoding() {
    XCTAssertEqual(header.bitcoinData, headerData)
  }

  func testMessageHeaderDecoding() {
    let stream = NSInputStream(data: headerData)
    stream.open()
    if let testHeader = Message.Header.fromBitcoinStream(stream) {
      XCTAssertEqual(testHeader, header)
    } else {
      XCTFail("Failed to parse message header")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
