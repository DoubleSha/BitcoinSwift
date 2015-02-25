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

  // MARK: - BlockChainStore

  public func height() -> (height: UInt32?, error: NSError?) {
    return (height: _head?.height, error: nil)
  }

  public func head() -> (head: BlockChainHeader?, error: NSError?) {
    return (head: _head, error: nil)
  }

  public func addBlockChainHeaderAsNewHead(blockChainHeader: BlockChainHeader) -> NSError? {
    blockChainHeadersByHash[blockChainHeader.blockHeader.hash] = blockChainHeader
    _head = blockChainHeader
    return nil
  }

  public func deleteBlockChainHeaderWithHash(hash: SHA256Hash) -> NSError? {
    blockChainHeadersByHash[hash] = nil
    return nil
  }

  public func blockChainHeaderWithHash(hash: SHA256Hash)
      -> (blockChainHeader: BlockChainHeader?, error: NSError?) {
    return (blockChainHeader: blockChainHeadersByHash[hash], error: nil)
  }
}
