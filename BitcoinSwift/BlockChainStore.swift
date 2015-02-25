//
//  BlockChainStore.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public protocol BlockChainStoreParameters {

  /// The filename to use for the persistent blockchain store.
  /// This filename should NOT have an extension. The BlockChainStore will append an appropriate
  /// extension based on the type of file (e.g. CoreDataBlockChainStore will append ".sqlite").
  var blockChainStoreFileName: String { get }
}

/// Persistent storage for blocks in a blockchain. Calls to all methods should be thread-safe.
public protocol BlockChainStore {

  /// The height of the current longest blockchain. If there is no head block, returns nil. If an
  /// error occurs, it will be stored in error.
  func height() -> (height: UInt32?, error: NSError?)

  /// The head block in the current longest blockchain. If there is no head block, returns nil.
  /// If an error occurs, it will be stored in error.
  func head() -> (head: BlockChainHeader?, error: NSError?)

  /// Adds blockChainHeader to the store and sets it as the head of the current longest chain.
  /// Returns the error if an error occurred.
  func addBlockChainHeaderAsNewHead(blockChainHeader: BlockChainHeader) -> NSError?

  /// Deletes the blockChainheader with |hash| from the store.
  /// If not present, then this is just a NOP.
  func deleteBlockChainHeaderWithHash(hash: SHA256Hash) -> NSError?

  /// Returns the blockChainHeader with the given hash. If there is no block matching the given
  /// hash, returns nil. If an error occurs, it will be stored in error.
  func blockChainHeaderWithHash(hash: SHA256Hash)
      -> (blockChainHeader: BlockChainHeader?, error: NSError?)
}
