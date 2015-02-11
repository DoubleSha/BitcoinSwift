//
//  BlockChainStore.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// Persistent storage for blocks in a blockchain.
public protocol BlockChainStore {

  /// The height of the current longest blockchain.
  var height: Int { get }

  /// The head block in the current longest blockchain.
  var head: BlockChainHeader? { get }

  /// Returns the blockChainHeader with the given hash.
  /// If not found, blockChainHeader will be nil and error will be nil.
  /// If an error occurred, blockChainHeader will be nil and error will contain the error.
  func blockChainHeaderWithHash(hash: SHA256Hash)
      -> (blockChainHeader: BlockChainHeader?, error: NSError?)

  /// Saves the blockChainheader in the store.
  /// If already present, then this is just a NOP.
  func addBlockChainHeader(blockChainHeader: BlockChainHeader) -> NSError?

  /// Deletes the blockChainheader with |hash| from the store.
  /// If not present, then this is just a NOP.
  func deleteBlockChainHeaderWithHash(hash: SHA256Hash) -> NSError?
}
