//
//  NSDataToUInt8ArrayTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/19/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class NSDataToUInt8ArrayTests: XCTestCase {

  func testConvertNSDataToUInt8Array() {
    let data = NSData(bytes: [0, 1, 2, 3] as [UInt8], length: 4)
    let expectedBytes: [UInt8] = [0, 1, 2, 3]
    XCTAssertEqual(data.UInt8Array(), expectedBytes)
  }
}
