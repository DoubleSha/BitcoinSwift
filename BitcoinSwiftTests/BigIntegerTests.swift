//
//  BigIntegerTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class BigIntegerTests: XCTestCase {

  func testZero() {
    XCTAssertEqual(BigInteger(), BigInteger(0))
  }

  func testAdd() {
    XCTAssertEqual(BigInteger(25) + BigInteger(5), BigInteger(30))
  }

  func testSubtract() {
    XCTAssertEqual(BigInteger(25) - BigInteger(5), BigInteger(20))
  }

  func testMultiply() {
    XCTAssertEqual(BigInteger(25) * BigInteger(5), BigInteger(125))
  }

  func testDivide() {
    XCTAssertEqual(BigInteger(25) / BigInteger(5), BigInteger(5))
  }

  func testModulo() {
    XCTAssertEqual(BigInteger(25) % BigInteger(6), BigInteger(1))
  }

  func testAddModulo() {
    XCTAssertEqual(BigInteger(25).add(BigInteger(5), modulo:BigInteger(10)), BigInteger(0))
    XCTAssertEqual(BigInteger(25).add(BigInteger(6), modulo:BigInteger(10)), BigInteger(1))
  }

  func testLeftShift() {
    XCTAssertEqual(BigInteger(1) << 2, BigInteger(4))
  }

  func testRightShift() {
    XCTAssertEqual(BigInteger(4) >> 2, BigInteger(1))
  }

  func testEqual() {
    XCTAssertEqual(BigInteger(25), BigInteger(25))
    XCTAssertNotEqual(BigInteger(26), BigInteger(25))
  }

  func testGreaterThan() {
    XCTAssertGreaterThan(BigInteger(26), BigInteger(25))
    XCTAssertFalse(BigInteger(25) > BigInteger(25))
    XCTAssertFalse(BigInteger(25) > BigInteger(26))
  }

  func testGreaterThanOrEqual() {
    XCTAssertGreaterThanOrEqual(BigInteger(26), BigInteger(25))
    XCTAssertGreaterThanOrEqual(BigInteger(25), BigInteger(25))
    XCTAssertFalse(BigInteger(25) >= BigInteger(26))
  }

  func testLessThan() {
    XCTAssertLessThan(BigInteger(25), BigInteger(26))
    XCTAssertFalse(BigInteger(25) < BigInteger(25))
    XCTAssertFalse(BigInteger(26) < BigInteger(25))
  }

  func testLessThanOrEqual() {
    XCTAssertLessThanOrEqual(BigInteger(25), BigInteger(26))
    XCTAssertLessThanOrEqual(BigInteger(25), BigInteger(25))
    XCTAssertFalse(BigInteger(26) <= BigInteger(25))
  }

  func testDataWithLargeValue() {
    let bigInt: BigInteger = BigInteger(1) << 256
    let expectedBytes: [UInt8] = [
        0x01,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    let expectedData = NSData(bytes: expectedBytes, length: expectedBytes.count)
    XCTAssertEqual(bigInt.data, expectedData)
  }

  func testCreateFromData() {
    let bytes: [UInt8] = [0x01, 0x00]
    let data = NSData(bytes: bytes, length: bytes.count)
    XCTAssertEqual(BigInteger(data: data), BigInteger(256))
  }

  func testCreateFromLargeData() {
    let bytes: [UInt8] = [
        0x01,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    let data = NSData(bytes: bytes, length: bytes.count)
    let bigInt = BigInteger(data: data)
    XCTAssertEqual(bigInt.data, data)
  }
}
