//
//  InMemoryBlockChainStore.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// Stores the blockchain in memory.
public class InMemoryBlockChainStore: BlockChainStore {

  private var _head: BlockChainHeader? = nil
  private var blockChainHeadersByHash = Dictionary<SHA256Hash, BlockChainHeader>()

  public init() {}

  // MARK: - BlockChainStore

  public func height(error: NSErrorPointer) -> UInt32? {
    return _head?.height
  }

  public func head(error: NSErrorPointer) -> BlockChainHeader? {
    return _head
  }

  public func addBlockChainHeaderAsNewHead(blockChainHeader: BlockChainHeader,
                                           error: NSErrorPointer) {
    blockChainHeadersByHash[blockChainHeader.blockHeader.hash] = blockChainHeader
    _head = blockChainHeader
  }

  public func deleteBlockChainHeaderWithHash(hash: SHA256Hash, error: NSErrorPointer) {
    blockChainHeadersByHash[hash] = nil
  }

  public func blockChainHeaderWithHash(hash: SHA256Hash, error: NSErrorPointer)
      -> BlockChainHeader? {
    return blockChainHeadersByHash[hash]
  }
}
