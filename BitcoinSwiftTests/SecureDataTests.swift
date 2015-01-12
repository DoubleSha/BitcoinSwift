//
//  SecureDataTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/3/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class SecureDataTests: XCTestCase {

  func testSubRange() {
    let bytes: [UInt8] = [0x1, 0x2, 0x3, 0x4]
    let leftBytes: [UInt8] = [0x1, 0x2]
    let rightBytes: [UInt8] = [0x3, 0x4]
    let data = SecureData(bytes: bytes, length: UInt(bytes.count))
    let leftData = SecureData(bytes: leftBytes, length: UInt(leftBytes.count))
    let rightData = SecureData(bytes: rightBytes, length: UInt(rightBytes.count))
    XCTAssertEqual(data[0..<2], leftData)
    XCTAssertEqual(data[2..<4], rightData)
    XCTAssertEqual(data[0..<4], data)
  }
}
