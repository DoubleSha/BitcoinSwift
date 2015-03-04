//
//  CoreDataBlockChainStoreTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 2/24/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class CoreDataBlockChainStoreTests: XCTestCase {

  let blockChainStore = CoreDataBlockChainStore()

  override func setUp() {
    super.setUp()
    blockChainStore.setUpWithParams(BitcoinUnitTestParameters.get())
  }

  override func tearDown() {
    blockChainStore.deletePersistentStore()
  }

  func DISABLED_testSaveBlockChainHeader() {
    var error: NSError?
    XCTAssertTrue(blockChainStore.height(&error) == nil)
    XCTAssertTrue(error == nil)
    let blockChainHeader = blockChainStore.blockChainHeaderWithHash(SHA256Hash(), error: &error)
    XCTAssertTrue(blockChainHeader == nil)
    XCTAssertTrue(error == nil)
  }
}
