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

  private var blockChainHeadersByHash = Dictionary<SHA256Hash, BlockChainHeader>()

  public var height: Int {
    return 0
  }

  public var head: BlockChainHeader? {
    return nil
  }

  public func blockChainHeaderWithHash(hash: SHA256Hash)
      -> (blockChainHeader: BlockChainHeader?, error: NSError?) {
    return (blockChainHeader: blockChainHeadersByHash[hash], error: nil)
  }

  public func addBlockChainHeader(blockChainHeader: BlockChainHeader) -> NSError? {
    blockChainHeadersByHash[blockChainHeader.blockHeader.hash] = blockChainHeader
    return nil
  }

  public func deleteBlockChainHeaderWithHash(hash: SHA256Hash) -> NSError? {
    blockChainHeadersByHash[hash] = nil
    return nil
  }
}
