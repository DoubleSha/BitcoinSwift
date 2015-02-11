//
//  BlockChainHeaderEntity.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 2/10/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import CoreData
import Foundation

class BlockChainHeaderEntity: NSManagedObject {

  @NSManaged var height: NSNumber
  @NSManaged var chainWork: NSData
  @NSManaged var blockHash: NSData
  @NSManaged var version: NSNumber
  @NSManaged var previousBlockHash: NSData
  @NSManaged var merkleRoot: NSData
  @NSManaged var timestamp: NSDate
  @NSManaged var compactDifficulty: NSNumber
  @NSManaged var nonce: NSNumber

  func setBlockChainHeader(blockChainHeader: BlockChainHeader) {
    height = NSNumber(unsignedInt: blockChainHeader.height)
    chainWork = blockChainHeader.chainWork.data
    let blockHeader = blockChainHeader.blockHeader
    blockHash = blockHeader.hash.data
    version = NSNumber(unsignedInt: blockHeader.version)
    previousBlockHash = blockHeader.previousBlockHash.data
    merkleRoot = blockHeader.merkleRoot.data
    timestamp = blockHeader.timestamp
    compactDifficulty = NSNumber(unsignedInt: blockHeader.compactDifficulty)
    nonce = NSNumber(unsignedInt: blockHeader.nonce)
  }

  var blockChainHeader: BlockChainHeader {
    let blockHeader = BlockHeader(version: version.unsignedIntValue,
                                  previousBlockHash: SHA256Hash(data: previousBlockHash),
                                  merkleRoot: SHA256Hash(data: merkleRoot),
                                  timestamp: timestamp,
                                  compactDifficulty: compactDifficulty.unsignedIntValue,
                                  nonce: nonce.unsignedIntValue)
    return BlockChainHeader(blockHeader: blockHeader,
                            height: height.unsignedIntValue,
                            chainWork: BigInteger(data: chainWork))
  }
}
