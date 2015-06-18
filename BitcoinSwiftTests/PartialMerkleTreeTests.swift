//
//  PartialMerkleTreeTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/17/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class PartialMerkleTreeTests: XCTestCase {

  func testValidPartialMerkleTree() {
    XCTAssertTrue(PartialMerkleTree(totalLeafNodes: 7,
                                    hashes: DummyMessage.partialMerkleTreeHashes,
                                    flags: [0x1d]) != nil)
  }

  func testPartialMerkleTreeWithInvalidFlagPadding() {
    XCTAssertTrue(PartialMerkleTree(totalLeafNodes: 7,
                                    hashes: DummyMessage.partialMerkleTreeHashes,
                                    flags: [0x00, 0x1d]) == nil)
  }

  func testPartialMerkleTreeWithUnusedFlagBits() {
    XCTAssertTrue(PartialMerkleTree(totalLeafNodes: 7,
                                    hashes: DummyMessage.partialMerkleTreeHashes,
                                    flags: [0x9d]) == nil)
  }

  func testPartialMerkleTreeWithUnusedHashes() {
    var hashes = DummyMessage.partialMerkleTreeHashes
    hashes.append(hashes[hashes.endIndex - 1])
    XCTAssertTrue(PartialMerkleTree(totalLeafNodes: 7,
                                    hashes: hashes,
                                    flags: [0x1d]) == nil)
  }
}
