//
//  BlockChainHeader.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// Represents a block header that has been added to a blockchain.
public struct BlockChainHeader {

  let blockHeader: BlockHeader

  /// The height of the block in the blockchain.
  let height: UInt32

  /// The chain work represents the total amount of work that has been done on all blocks in this
  /// chain. It is used to determine the longest chain.
  let chainWork: BigInteger
}
