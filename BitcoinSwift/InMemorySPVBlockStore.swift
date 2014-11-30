//
//  InMemorySPVBlockStore.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public class InMemorySPVBlockStore: SPVBlockStore {

  private var blockHeadersByHash = Dictionary<NSData, BlockHeader>()

  public func blockHeaderWithHash(hash: NSData) -> BlockHeader? {
    return blockHeadersByHash[hash]
  }

  public func addBlockHeader(blockHeader: BlockHeader) {
    blockHeadersByHash[blockHeader.hash] = blockHeader
  }

  public func removeBlockHeader(blockHeader: BlockHeader) {
    blockHeadersByHash[blockHeader.hash] = nil
  }
}
