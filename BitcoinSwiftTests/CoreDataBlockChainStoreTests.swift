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
    blockChainStore.setUpInMemory()
    XCTAssertTrue(blockChainStore.isSetUp)
  }

  func testEmpty() {
    var error: NSError?
    let height = blockChainStore.height(&error)
    XCTAssertNil(error)
    XCTAssertTrue(height == nil)

    let head = blockChainStore.head(&error)
    XCTAssertNil(error)
    XCTAssertTrue(head == nil)

    let blockChainHeader = blockChainStore.blockChainHeaderWithHash(SHA256Hash(), error: &error)
    XCTAssertNil(error)
    XCTAssertTrue(blockChainHeader == nil)
  }

  func testSaveAndReadAndDelete() {
    var error: NSError?
    let blockChainHeader = dummyBlockChainHeader()
    blockChainStore.addBlockChainHeaderAsNewHead(blockChainHeader, error: &error)
    XCTAssertNil(error)

    let height = blockChainStore.height(&error)
    XCTAssertNil(error)
    XCTAssertTrue(height != nil)
    XCTAssertEqual(height!, blockChainHeader.height)

    let head = blockChainStore.head(&error)
    XCTAssertNil(error)
    XCTAssertTrue(head != nil)
    XCTAssertEqual(head!, blockChainHeader)

    let readBlockChainHeader =
        blockChainStore.blockChainHeaderWithHash(blockChainHeader.blockHeader.hash, error: &error)
    XCTAssertNil(error)
    XCTAssertTrue(readBlockChainHeader != nil)
    XCTAssertEqual(readBlockChainHeader!, blockChainHeader)

    blockChainStore.deleteBlockChainHeaderWithHash(blockChainHeader.blockHeader.hash, error: &error)
    XCTAssertNil(error)

    let deletedBlockChainHeader =
        blockChainStore.blockChainHeaderWithHash(blockChainHeader.blockHeader.hash, error: &error)
    XCTAssertNil(error)
    XCTAssertTrue(deletedBlockChainHeader == nil)
  }

  // MARK: - Private Methods

  func dummyBlockChainHeader() -> BlockChainHeader {
    let blockHeader = BlockHeader(params: BitcoinUnitTestParameters.get(),
                                  previousBlockHash: SHA256Hash(),
                                  merkleRoot: SHA256Hash(),
                                  timestamp: NSDate(),
                                  compactDifficulty: 0,
                                  nonce: 0)
    return BlockChainHeader(blockHeader: blockHeader, height: 1, chainWork: BigInteger(0))
  }
}
