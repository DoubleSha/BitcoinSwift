//
//  BlockChainHeader.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: BlockChainHeader, right: BlockChainHeader) -> Bool {
  return left.blockHeader == right.blockHeader &&
      left.height == right.height &&
      left.chainWork == right.chainWork
}

/// Represents a block header that has been added to a blockchain.
public struct BlockChainHeader: Equatable {

  public let blockHeader: BlockHeader

  /// The height of the block in the blockchain.
  public let height: UInt32

  /// The chain work represents the total amount of work that has been done on all blocks in this
  /// chain. It is used to determine the longest chain.
  public let chainWork: BigInteger

  public init(blockHeader: BlockHeader, height: UInt32, chainWork: BigInteger) {
    self.blockHeader = blockHeader
    self.height = height
    self.chainWork = chainWork
  }
}
