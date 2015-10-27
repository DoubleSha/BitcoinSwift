//
//  FilteredBlock.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/26/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: FilteredBlock, right: FilteredBlock) -> Bool {
  return left.header == right.header && left.partialMerkleTree == right.partialMerkleTree
}

/// Blocks served from a peer with a bloom filter loaded. Only includes merkle branches for
/// transactions that are relevant to the current bloom filter.
/// https://en.bitcoin.it/wiki/Protocol_specification#filterload.2C_filteradd.2C_filterclear.2C_merkleblock
public struct FilteredBlock: Equatable {

  public let header: BlockHeader
  public let partialMerkleTree: PartialMerkleTree

  public init(header: BlockHeader,
              partialMerkleTree: PartialMerkleTree) {
    self.header = header
    self.partialMerkleTree = partialMerkleTree
  }

  public var merkleProofIsValid: Bool {
    return header.merkleRoot == partialMerkleTree.rootHash
  }
}

extension FilteredBlock: MessagePayload {

  public var command: Message.Command {
    return Message.Command.FilteredBlock
  }

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendData(header.bitcoinData)
    data.appendData(partialMerkleTree.bitcoinData)
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> FilteredBlock? {
    let header = BlockHeader.fromBitcoinStream(stream)
    if header == nil {
      Logger.warn("Failed to parse header from FilteredBlock")
      return nil
    }
    let partialMerkleTree = PartialMerkleTree.fromBitcoinStream(stream)
    if partialMerkleTree == nil {
      Logger.warn("Failed to parse partialMerkleTree from FilteredBlock")
      return nil
    }
    let filteredBlock = FilteredBlock(header: header!, partialMerkleTree: partialMerkleTree!)
    if !filteredBlock.merkleProofIsValid {
      Logger.warn("Failed to parse FilteredBlock, invalid merkle proof")
      return nil
    }
    return filteredBlock
  }
}
