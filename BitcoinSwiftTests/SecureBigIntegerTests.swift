//
//  SecureBigIntegerTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/11/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class SecureBigIntegerTests: XCTestCase {

  var secureFive: SecureBigInteger!
  var secureSix: SecureBigInteger!
  var secureThirtyFive: SecureBigInteger!

  override func setUp() {
    let thirtyFiveBytes: [UInt8] = [0x23]
    let thirtyFiveSecureData = SecureData(bytes: thirtyFiveBytes,
                                          length: UInt(thirtyFiveBytes.count))
    secureThirtyFive = SecureBigInteger(secureData: thirtyFiveSecureData)
    let fiveBytes: [UInt8] = [0x05]
    let fiveSecureData = SecureData(bytes: fiveBytes, length: UInt(fiveBytes.count))
    secureFive = SecureBigInteger(secureData: fiveSecureData)
    let sixBytes: [UInt8] = [0x06]
    let sixSecureData = SecureData(bytes: sixBytes, length: UInt(sixBytes.count))
    secureSix = SecureBigInteger(secureData: sixSecureData)
  }

  func testZero() {
    XCTAssertTrue(SecureBigInteger().isEqual(BigInteger(0)))
  }

  func testEqual() {
    XCTAssertTrue(secureThirtyFive.isEqual(BigInteger(35)))
    XCTAssertFalse(secureThirtyFive.isEqual(BigInteger(36)))
  }

  func testGreaterThan() {
    XCTAssertTrue(secureThirtyFive.greaterThan(BigInteger(34)))
    XCTAssertFalse(secureThirtyFive.greaterThan(BigInteger(35)))
    XCTAssertFalse(secureThirtyFive.greaterThan(BigInteger(36)))
  }

  func testGreaterThanOrEqual() {
    XCTAssertTrue(secureThirtyFive.greaterThanOrEqual(BigInteger(34)))
    XCTAssertTrue(secureThirtyFive.greaterThanOrEqual(BigInteger(35)))
    XCTAssertFalse(secureThirtyFive.greaterThanOrEqual(BigInteger(36)))
  }

  func testLessThan() {
    XCTAssertTrue(secureThirtyFive.lessThan(BigInteger(36)))
    XCTAssertFalse(secureThirtyFive.lessThan(BigInteger(35)))
    XCTAssertFalse(secureThirtyFive.lessThan(BigInteger(34)))
  }

  func testLessThanOrEqual() {
    XCTAssertTrue(secureThirtyFive.lessThanOrEqual(BigInteger(36)))
    XCTAssertTrue(secureThirtyFive.lessThanOrEqual(BigInteger(35)))
    XCTAssertFalse(secureThirtyFive.lessThanOrEqual(BigInteger(34)))
  }

  func testAddModulo() {
    let zero = secureThirtyFive.add(secureFive, modulo:BigInteger(10))
    XCTAssertTrue(zero.isEqual(BigInteger(0)))
    let one = secureThirtyFive.add(secureSix, modulo:BigInteger(10))
    XCTAssertTrue(one.isEqual(BigInteger(1)))
  }
}
