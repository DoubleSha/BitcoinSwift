//
//  InMemorySPVBlockStore.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public class InMemorySPVBlockStore: SPVBlockStore {

  private var blockHeadersByHash = Dictionary<SHA256Hash, BlockHeader>()

  public init() {}

  public var head: BlockHeader? {
    return nil
  }

  public func blockHeaderWithHash(hash: SHA256Hash) -> BlockHeader? {
    return blockHeadersByHash[hash]
  }

  public func addBlockHeader(blockHeader: BlockHeader) {
    blockHeadersByHash[blockHeader.hash] = blockHeader
  }

  public func removeBlockHeader(blockHeader: BlockHeader) {
    blockHeadersByHash[blockHeader.hash] = nil
  }
}
