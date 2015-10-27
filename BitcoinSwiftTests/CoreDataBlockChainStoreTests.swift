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
    do {
      try blockChainStore.setUpInMemory()
    } catch {
      XCTFail()
    }
    XCTAssertTrue(blockChainStore.isSetUp)
  }

  func testEmpty() {
    let height: UInt32?
    do {
      try height = blockChainStore.height()
    } catch {
      height = nil
      XCTFail()
    }
    XCTAssertTrue(height == nil)

    let head: BlockChainHeader?
    do {
      try head = blockChainStore.head()
    } catch {
      head = nil
      XCTFail()
    }
    XCTAssertTrue(head == nil)

    let blockChainHeader: BlockChainHeader?
    do {
      try blockChainHeader = blockChainStore.blockChainHeaderWithHash(SHA256Hash())
    } catch {
    blockChainHeader = nil
      XCTFail()
    }
    XCTAssertTrue(blockChainHeader == nil)
  }

  func testSaveAndReadAndDelete() {
    let blockChainHeader = dummyBlockChainHeader()
    do {
      try blockChainStore.addBlockChainHeaderAsNewHead(blockChainHeader)
    } catch {
      XCTFail()
    }

    let height: UInt32?
    do {
      try height = blockChainStore.height()
    } catch {
      height = nil
      XCTFail()
    }
    XCTAssertTrue(height != nil)
    XCTAssertEqual(height!, blockChainHeader.height)

    let head: BlockChainHeader?
    do {
      try head = blockChainStore.head()
    } catch {
      head = nil
      XCTFail()
    }
    XCTAssertTrue(head != nil)
    XCTAssertEqual(head!, blockChainHeader)

    let readBlockChainHeader: BlockChainHeader?
    do {
      try readBlockChainHeader =
          blockChainStore.blockChainHeaderWithHash(blockChainHeader.blockHeader.hash)
    } catch {
      readBlockChainHeader = nil
      XCTFail()
    }
    XCTAssertTrue(readBlockChainHeader != nil)
    XCTAssertEqual(readBlockChainHeader!, blockChainHeader)

    do {
      try blockChainStore.deleteBlockChainHeaderWithHash(blockChainHeader.blockHeader.hash)
    } catch {
      XCTFail()
    }

    let deletedBlockChainHeader: BlockChainHeader?
    do {
      try deletedBlockChainHeader =
          blockChainStore.blockChainHeaderWithHash(blockChainHeader.blockHeader.hash)
    } catch {
      deletedBlockChainHeader = nil
      XCTFail()
    }
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
