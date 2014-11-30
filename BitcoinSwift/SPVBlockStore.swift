//
//  SPVBlockStore.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public protocol SPVBlockStore {

  func blockHeaderWithHash(hash: NSData) -> BlockHeader?
  func addBlockHeader(blockHeader: BlockHeader)
  func removeBlockHeader(blockHeader: BlockHeader)
}
