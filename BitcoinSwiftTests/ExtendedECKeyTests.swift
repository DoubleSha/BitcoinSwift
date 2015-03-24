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
      0xff, 0xfc, 0xf9, 0xf6, 0xf3, 0xf0, 0xed, 0xea,
      0xe7, 0xe4, 0xe1, 0xde, 0xdb, 0xd8, 0xd5, 0xd2,
      0xcf, 0xcc, 0xc9, 0xc6, 0xc3, 0xc0, 0xbd, 0xba,
      0xb7, 0xb4, 0xb1, 0xae, 0xab, 0xa8, 0xa5, 0xa2,
      0x9f, 0x9c, 0x99, 0x96, 0x93, 0x90, 0x8d, 0x8a,
      0x87, 0x84, 0x81, 0x7e, 0x7b, 0x78, 0x75, 0x72,
      0x6f, 0x6c, 0x69, 0x66, 0x63, 0x60, 0x5d, 0x5a,
      0x57, 0x54, 0x51, 0x4e, 0x4b, 0x48, 0x45, 0x42]

  var masterKey0: ExtendedECKey!
  var masterKey1: ExtendedECKey!

  override func setUp() {
    super.setUp()
    let masterKey0Seed = SecureData(bytes: masterKey0SeedBytes,
                                    length: UInt(masterKey0SeedBytes.count))
    masterKey0 = ExtendedECKey.masterKeyWithSeed(masterKey0Seed)
    let masterKey1Seed = SecureData(bytes: masterKey1SeedBytes,
                                    length: UInt(masterKey1SeedBytes.count))
    masterKey1 = ExtendedECKey.masterKeyWithSeed(masterKey1Seed)
  }

  func testMasterKey0() {
    let publicKeyBytes: [UInt8] = [
        0x03, 0x39, 0xa3, 0x60, 0x13, 0x30, 0x15, 0x97,
        0xda, 0xef, 0x41, 0xfb, 0xe5, 0x93, 0xa0, 0x2c,
        0xc5, 0x13, 0xd0, 0xb5, 0x55, 0x27, 0xec, 0x2d,
        0xf1, 0x05, 0x0e, 0x2e, 0x8f, 0xf4, 0x9c, 0x85, 0xc2]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0xe8, 0xf3, 0x2e, 0x72, 0x3d, 0xec, 0xf4, 0x05,
        0x1a, 0xef, 0xac, 0x8e, 0x2c, 0x93, 0xc9, 0xc5,
        0xb2, 0x14, 0x31, 0x38, 0x17, 0xcd, 0xb0, 0x1a,
        0x14, 0x94, 0xb9, 0x17, 0xc8, 0x43, 0x6b, 0x35]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    XCTAssertEqual(masterKey0.publicKey, publicKey)
    XCTAssertEqual(masterKey0.privateKey, privateKey)
  }

  func testMasterKey0Child0h() {
    let publicKeyBytes: [UInt8] = [
        0x03, 0x5a, 0x78, 0x46, 0x62, 0xa4, 0xa2, 0x0a,
        0x65, 0xbf, 0x6a, 0xab, 0x9a, 0xe9, 0x8a, 0x6c,
        0x06, 0x8a, 0x81, 0xc5, 0x2e, 0x4b, 0x03, 0x2c,
        0x0f, 0xb5, 0x40, 0x0c, 0x70, 0x6c, 0xfc, 0xcc, 0x56]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0xed, 0xb2, 0xe1, 0x4f, 0x9e, 0xe7, 0x7d, 0x26,
        0xdd, 0x93, 0xb4, 0xec, 0xed, 0xe8, 0xd1, 0x6e,
        0xd4, 0x08, 0xce, 0x14, 0x9b, 0x6c, 0xd8, 0x0b,
        0x07, 0x15, 0xa2, 0xd9, 0x11, 0xa0, 0xaf, 0xea]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    if let key = masterKey0.childKeyWithHardenedIndex(0) {
      XCTAssertEqual(key.publicKey, publicKey)
      XCTAssertEqual(key.privateKey, privateKey)
    } else {
      XCTFail("Failed to create child key.")
    }
  }

  func testMasterKey0Child0hChild1() {
    let publicKeyBytes: [UInt8] = [
        0x03, 0x50, 0x1e, 0x45, 0x4b, 0xf0, 0x07, 0x51,
        0xf2, 0x4b, 0x1b, 0x48, 0x9a, 0xa9, 0x25, 0x21,
        0x5d, 0x66, 0xaf, 0x22, 0x34, 0xe3, 0x89, 0x1c,
        0x3b, 0x21, 0xa5, 0x2b, 0xed, 0xb3, 0xcd, 0x71, 0x1c]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0x3c, 0x6c, 0xb8, 0xd0, 0xf6, 0xa2, 0x64, 0xc9,
        0x1e, 0xa8, 0xb5, 0x03, 0x0f, 0xad, 0xaa, 0x8e,
        0x53, 0x8b, 0x02, 0x0f, 0x0a, 0x38, 0x74, 0x21,
        0xa1, 0x2d, 0xe9, 0x31, 0x9d, 0xc9, 0x33, 0x68]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    if let key = masterKey0.childKeyWithHardenedIndex(0)?.childKeyWithIndex(1) {
      XCTAssertEqual(key.publicKey, publicKey)
      XCTAssertEqual(key.privateKey, privateKey)
    } else {
      XCTFail("Failed to create child key.")
    }
  }

  func testMasterKey0Child0hChild1Child2h() {
    let publicKeyBytes: [UInt8] = [
        0x03, 0x57, 0xbf, 0xe1, 0xe3, 0x41, 0xd0, 0x1c,
        0x69, 0xfe, 0x56, 0x54, 0x30, 0x99, 0x56, 0xcb,
        0xea, 0x51, 0x68, 0x22, 0xfb, 0xa8, 0xa6, 0x01,
        0x74, 0x3a, 0x01, 0x2a, 0x78, 0x96, 0xee, 0x8d, 0xc2]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0xcb, 0xce, 0x0d, 0x71, 0x9e, 0xcf, 0x74, 0x31,
        0xd8, 0x8e, 0x6a, 0x89, 0xfa, 0x14, 0x83, 0xe0,
        0x2e, 0x35, 0x09, 0x2a, 0xf6, 0x0c, 0x04, 0x2b,
        0x1d, 0xf2, 0xff, 0x59, 0xfa, 0x42, 0x4d, 0xca]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    if let key = masterKey0.childKeyWithHardenedIndex(0)?.childKeyWithIndex(1)?
        .childKeyWithHardenedIndex(2) {
      XCTAssertEqual(key.publicKey, publicKey)
      XCTAssertEqual(key.privateKey, privateKey)
    } else {
      XCTFail("Failed to create child key.")
    }
  }

  func testMasterKey0Child0hChild1Child2hChild2() {
    let publicKeyBytes: [UInt8] = [
        0x02, 0xe8, 0x44, 0x50, 0x82, 0xa7, 0x2f, 0x29,
        0xb7, 0x5c, 0xa4, 0x87, 0x48, 0xa9, 0x14, 0xdf,
        0x60, 0x62, 0x2a, 0x60, 0x9c, 0xac, 0xfc, 0xe8,
        0xed, 0x0e, 0x35, 0x80, 0x45, 0x60, 0x74, 0x1d, 0x29]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0x0f, 0x47, 0x92, 0x45, 0xfb, 0x19, 0xa3, 0x8a,
        0x19, 0x54, 0xc5, 0xc7, 0xc0, 0xeb, 0xab, 0x2f,
        0x9b, 0xdf, 0xd9, 0x6a, 0x17, 0x56, 0x3e, 0xf2,
        0x8a, 0x6a, 0x4b, 0x1a, 0x2a, 0x76, 0x4e, 0xf4]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    if let key = masterKey0.childKeyWithHardenedIndex(0)?.childKeyWithIndex(1)?
        .childKeyWithHardenedIndex(2)?.childKeyWithIndex(2) {
      XCTAssertEqual(key.publicKey, publicKey)
      XCTAssertEqual(key.privateKey, privateKey)
    } else {
      XCTFail("Failed to create child key.")
    }
  }

  func testMasterKey0Child0hChild1Child2hChild2Child1000000000() {
    let publicKeyBytes: [UInt8] = [
        0x02, 0x2a, 0x47, 0x14, 0x24, 0xda, 0x5e, 0x65,
        0x74, 0x99, 0xd1, 0xff, 0x51, 0xcb, 0x43, 0xc4,
        0x74, 0x81, 0xa0, 0x3b, 0x1e, 0x77, 0xf9, 0x51,
        0xfe, 0x64, 0xce, 0xc9, 0xf5, 0xa4, 0x8f, 0x70, 0x11]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0x47, 0x1b, 0x76, 0xe3, 0x89, 0xe5, 0x28, 0xd6,
        0xde, 0x6d, 0x81, 0x68, 0x57, 0xe0, 0x12, 0xc5,
        0x45, 0x50, 0x51, 0xca, 0xd6, 0x66, 0x08, 0x50,
        0xe5, 0x83, 0x72, 0xa6, 0xc3, 0xe6, 0xe7, 0xc8]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    if let key = masterKey0.childKeyWithHardenedIndex(0)?.childKeyWithIndex(1)?
        .childKeyWithHardenedIndex(2)?.childKeyWithIndex(2)?.childKeyWithIndex(1000000000) {
      XCTAssertEqual(key.publicKey, publicKey)
      XCTAssertEqual(key.privateKey, privateKey)
    } else {
      XCTFail("Failed to create child key.")
    }
  }

  func testMasterKey1() {
    let publicKeyBytes: [UInt8] = [
        0x03, 0xcb, 0xca, 0xa9, 0xc9, 0x8c, 0x87, 0x7a,
        0x26, 0x97, 0x7d, 0x00, 0x82, 0x5c, 0x95, 0x6a,
        0x23, 0x8e, 0x8d, 0xdd, 0xfb, 0xd3, 0x22, 0xcc,
        0xe4, 0xf7, 0x4b, 0x0b, 0x5b, 0xd6, 0xac, 0xe4, 0xa7]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0x4b, 0x03, 0xd6, 0xfc, 0x34, 0x04, 0x55, 0xb3,
        0x63, 0xf5, 0x10, 0x20, 0xad, 0x3e, 0xcc, 0xa4,
        0xf0, 0x85, 0x02, 0x80, 0xcf, 0x43, 0x6c, 0x70,
        0xc7, 0x27, 0x92, 0x3f, 0x6d, 0xb4, 0x6c, 0x3e]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    XCTAssertEqual(masterKey1.publicKey, publicKey)
    XCTAssertEqual(masterKey1.privateKey, privateKey)
  }

  func testMasterKey1Child0() {
    let publicKeyBytes: [UInt8] = [
        0x02, 0xfc, 0x9e, 0x5a, 0xf0, 0xac, 0x8d, 0x9b,
        0x3c, 0xec, 0xfe, 0x2a, 0x88, 0x8e, 0x21, 0x17,
        0xba, 0x3d, 0x08, 0x9d, 0x85, 0x85, 0x88, 0x6c,
        0x9c, 0x82, 0x6b, 0x6b, 0x22, 0xa9, 0x8d, 0x12, 0xea]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0xab, 0xe7, 0x4a, 0x98, 0xf6, 0xc7, 0xea, 0xbe,
        0xe0, 0x42, 0x8f, 0x53, 0x79, 0x8f, 0x0a, 0xb8,
        0xaa, 0x1b, 0xd3, 0x78, 0x73, 0x99, 0x90, 0x41,
        0x70, 0x3c, 0x74, 0x2f, 0x15, 0xac, 0x7e, 0x1e]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    if let key = masterKey1.childKeyWithIndex(0) {
      XCTAssertEqual(key.publicKey, publicKey)
      XCTAssertEqual(key.privateKey, privateKey)
    } else {
      XCTFail("Failed to create child key.")
    }
  }

  func testMasterKey1Child0Child2147483647h() {
    let publicKeyBytes: [UInt8] = [
        0x03, 0xc0, 0x1e, 0x74, 0x25, 0x64, 0x7b, 0xde,
        0xfa, 0x82, 0xb1, 0x2d, 0x9b, 0xad, 0x5e, 0x3e,
        0x68, 0x65, 0xbe, 0xe0, 0x50, 0x26, 0x94, 0xb9,
        0x4c, 0xa5, 0x8b, 0x66, 0x6a, 0xbc, 0x0a, 0x5c, 0x3b]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0x87, 0x7c, 0x77, 0x9a, 0xd9, 0x68, 0x71, 0x64,
        0xe9, 0xc2, 0xf4, 0xf0, 0xf4, 0xff, 0x03, 0x40,
        0x81, 0x43, 0x92, 0x33, 0x06, 0x93, 0xce, 0x95,
        0xa5, 0x8f, 0xe1, 0x8f, 0xd5, 0x2e, 0x6e, 0x93]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    if let key = masterKey1.childKeyWithIndex(0)?.childKeyWithHardenedIndex(2147483647) {
      XCTAssertEqual(key.publicKey, publicKey)
      XCTAssertEqual(key.privateKey, privateKey)
    } else {
      XCTFail("Failed to create child key.")
    }
  }

  func testMasterKey1Child0Child2147483647hChild1() {
    let publicKeyBytes: [UInt8] = [
        0x03, 0xa7, 0xd1, 0xd8, 0x56, 0xde, 0xb7, 0x4c,
        0x50, 0x8e, 0x05, 0x03, 0x1f, 0x98, 0x95, 0xda,
        0xb5, 0x46, 0x26, 0x25, 0x1b, 0x38, 0x06, 0xe1,
        0x6b, 0x4b, 0xd1, 0x2e, 0x78, 0x1a, 0x7d, 0xf5, 0xb9]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0x70, 0x4a, 0xdd, 0xf5, 0x44, 0xa0, 0x6e, 0x5e,
        0xe4, 0xbe, 0xa3, 0x70, 0x98, 0x46, 0x3c, 0x23,
        0x61, 0x3d, 0xa3, 0x20, 0x20, 0xd6, 0x04, 0x50,
        0x6d, 0xa8, 0xc0, 0x51, 0x8e, 0x1d, 0xa4, 0xb7]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    if let key = masterKey1.childKeyWithIndex(0)?.childKeyWithHardenedIndex(2147483647)?
        .childKeyWithIndex(1) {
      XCTAssertEqual(key.publicKey, publicKey)
      XCTAssertEqual(key.privateKey, privateKey)
    } else {
      XCTFail("Failed to create child key.")
    }
  }

  func testMasterKey1Child0Child2147483647hChild1Child2147483646h() {
    let publicKeyBytes: [UInt8] = [
        0x02, 0xd2, 0xb3, 0x69, 0x00, 0x39, 0x6c, 0x92,
        0x82, 0xfa, 0x14, 0x62, 0x85, 0x66, 0x58, 0x2f,
        0x20, 0x6a, 0x5d, 0xd0, 0xbc, 0xc8, 0xd5, 0xe8,
        0x92, 0x61, 0x18, 0x06, 0xca, 0xfb, 0x03, 0x01, 0xf0]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0xf1, 0xc7, 0xc8, 0x71, 0xa5, 0x4a, 0x80, 0x4a,
        0xfe, 0x32, 0x8b, 0x4c, 0x83, 0xa1, 0xc3, 0x3b,
        0x8e, 0x5f, 0xf4, 0x8f, 0x50, 0x87, 0x27, 0x3f,
        0x04, 0xef, 0xa8, 0x3b, 0x24, 0x7d, 0x6a, 0x2d]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    if let key = masterKey1.childKeyWithIndex(0)?.childKeyWithHardenedIndex(2147483647)?
        .childKeyWithIndex(1)?.childKeyWithHardenedIndex(2147483646) {
      XCTAssertEqual(key.publicKey, publicKey)
      XCTAssertEqual(key.privateKey, privateKey)
    } else {
      XCTFail("Failed to create child key.")
    }
  }

  func testMasterKey1Child0Child2147483647hChild1Child2147483646hChild2() {
    let publicKeyBytes: [UInt8] = [
        0x02, 0x4d, 0x90, 0x2e, 0x1a, 0x2f, 0xc7, 0xa8,
        0x75, 0x5a, 0xb5, 0xb6, 0x94, 0xc5, 0x75, 0xfc,
        0xe7, 0x42, 0xc4, 0x8d, 0x9f, 0xf1, 0x92, 0xe6,
        0x3d, 0xf5, 0x19, 0x3e, 0x4c, 0x7a, 0xfe, 0x1f, 0x9c]
    let publicKey = NSData(bytes: publicKeyBytes, length: publicKeyBytes.count)
    let privateKeyBytes: [UInt8] = [
        0xbb, 0x7d, 0x39, 0xbd, 0xb8, 0x3e, 0xcf, 0x58,
        0xf2, 0xfd, 0x82, 0xb6, 0xd9, 0x18, 0x34, 0x1c,
        0xbe, 0xf4, 0x28, 0x66, 0x1e, 0xf0, 0x1a, 0xb9,
        0x7c, 0x28, 0xa4, 0x84, 0x21, 0x25, 0xac, 0x23]
    let privateKey = SecureData(bytes: privateKeyBytes, length: UInt(privateKeyBytes.count))
    if let key = masterKey1.childKeyWithIndex(0)?.childKeyWithHardenedIndex(2147483647)?
        .childKeyWithIndex(1)?.childKeyWithHardenedIndex(2147483646)?.childKeyWithIndex(2) {
      XCTAssertEqual(key.publicKey, publicKey)
      XCTAssertEqual(key.privateKey, privateKey)
    } else {
      XCTFail("Failed to create child key.")
    }
  }
    
  func testParentPointer() {
    let child = masterKey0.childKeyWithIndex(0)
    let grandchild = child!.childKeyWithHardenedIndex(0)
    
    XCTAssertNil(masterKey0.parent)
    XCTAssertEqual(child!.parent!, masterKey0)
    XCTAssertEqual(grandchild!.parent!, child!)
  }
  
  func testDefaultVersion() {
    XCTAssert(masterKey0.version === BitcoinMainNetParameters.get())
  }
  
  func testExplicitVersionOverwrite() {
    let mainnetKey = ExtendedECKey.masterKey(version: BitcoinMainNetParameters.get()).key
    let testnetKey = ExtendedECKey.masterKey(version: BitcoinTestNetParameters.get()).key
    
    XCTAssert(mainnetKey.version === BitcoinMainNetParameters.get())
    XCTAssert(testnetKey.version === BitcoinTestNetParameters.get())
  }
  
  func testVersionPropagation() {
    let seed = SecureData(bytes: masterKey0SeedBytes,
        length: UInt(masterKey0SeedBytes.count))
    
    let mMaster = ExtendedECKey.masterKeyWithSeed(seed, version: BitcoinMainNetParameters.get())!
    let tMaster = ExtendedECKey.masterKeyWithSeed(seed, version: BitcoinTestNetParameters.get())!
    let mGrandChild = mMaster.childKeyWithIndex(0)!.childKeyWithHardenedIndex(0)!
    let tGrandChild = tMaster.childKeyWithHardenedIndex(0)!.childKeyWithIndex(0)!
    
    XCTAssert(mGrandChild.version === BitcoinMainNetParameters.get())
    XCTAssert(tGrandChild.version === BitcoinTestNetParameters.get())
  }
  
  func testExtendedKeySerilization_TestVector1() {
    
    var key = masterKey0
    
    // chain - m
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi")
    
    // chain - m/0ʜ
    key = key.childKeyWithHardenedIndex(0)
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7")
    
    // chain - m/0ʜ/1
    key = key?.childKeyWithIndex(1)
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs")
    
    // chain - m/0ʜ/1/2ʜ
    key = key?.childKeyWithHardenedIndex(2)
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM")
    
    // chain - m/0ʜ/1/2ʜ/2
    key = key?.childKeyWithIndex(2)
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334")
    
    // chain - m/0ʜ/1/2ʜ/2/1000000000
    key = key?.childKeyWithIndex(1000000000)
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76")
  }
  
  func testExtendedKeySerilization_TestVector2() {
    
    var key = masterKey1
    
    // chain - m
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U")
    
    // chain - m/0
    key = key.childKeyWithIndex(0)
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt")
    
    // chain - m/0/2147483647ʜ
    key = key?.childKeyWithHardenedIndex(2147483647)
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9")
    
    // chain - m/0/2147483647ʜ/1
    key = key?.childKeyWithIndex(1)
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef")
    
    // chain - m/0/2147483647ʜ/1/2147483646ʜ
    key = key?.childKeyWithHardenedIndex(2147483646)
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc")
    
    // chain - m/0/2147483647ʜ/1/2147483646ʜ/2
    key = key?.childKeyWithIndex(2)
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PublicKey),  "xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt")
    XCTAssertEqual(key.encodeExtendedKey(ofType: .PrivateKey), "xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j")
  }
  
  func testDeriviation() {
    let key01 = masterKey0.childKeyWithIndex(1)?.childKeyWithHardenedIndex(2)?.childKeyWithIndex(2147483647)
    let key02 = key01?.childKeyWithIndex(1)
    let derivedKey01 = masterKey0.derive("m\\1\\2'\\2147483647")
    let derivedKey02 = derivedKey01?.derive("\\1")
    XCTAssertEqual(key01!.publicKey, derivedKey01!.publicKey)
    XCTAssertEqual(key02!.publicKey, derivedKey02!.publicKey)
    
    let badKey01 = masterKey0.derive("\\3000000000'")
    let badKey02 = masterKey0.derive("m\\1\\m\\1")
    let badKey03 = masterKey0.childKeyWithIndex(15)?.derive("m\\1", isAbsolute:false)
    XCTAssertNil(badKey01)
    XCTAssertNil(badKey02)
    XCTAssertNil(badKey03)
  }
  
  func testPath() {
    let key = masterKey0.childKeyWithIndex(1)?.childKeyWithIndex(2)?.childKeyWithIndex(3)
    let keyPath = key!.path
    XCTAssertEqual(keyPath, "m\\1\\2\\3")
    
    let keyFromPath = key!.derive(keyPath)
    XCTAssertEqual(key!.publicKey, keyFromPath!.publicKey)
  }
}
