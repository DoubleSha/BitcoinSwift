//
//  ExtendedECKeyTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/23/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class ExtendedECKeyTests: XCTestCase {

  let masterKey0SeedBytes: [UInt8] = [
      0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
      0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f]

  let masterKey1SeedBytes: [UInt8] = [
      0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
      0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f]

  var masterKey0: ExtendedECKey!
  var masterKey1: ExtendedECKey!

  override func setUp() {
    let masterKey0Seed = NSData(bytes: masterKey0SeedBytes, length: masterKey0SeedBytes.count)
    masterKey0 = ExtendedECKey.masterKeyWithSeed(masterKey0Seed)
    let masterKey1Seed = NSData(bytes: masterKey1SeedBytes, length: masterKey1SeedBytes.count)
    masterKey1 = ExtendedECKey.masterKeyWithSeed(masterKey1Seed)
  }

  func testMasterKey0() {

  }
}
