//
//  FilteredBlock.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/26/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: FilteredBlock, right: FilteredBlock) -> Bool {
  return left.header == right.header &&
      left.totalNumTransactions == right.totalNumTransactions &&
      left.hashes == right.hashes &&
      left.flags == right.flags
}

/// Blocks served from a peer with a bloom filter loaded. Only includes merkle branches for
/// transactions that are relevant to the current bloom filter.
/// https://en.bitcoin.it/wiki/Protocol_specification#filterload.2C_filteradd.2C_filterclear.2C_merkleblock
public struct FilteredBlock: Equatable {

  public let header: BlockHeader
  /// Number of transactions in the block (including unmatched ones).
  public let totalNumTransactions: UInt32
  /// Hashes in depth-first order.
  public let hashes: [SHA256Hash]
  /// Flag bits, packed per 8 in a byte, least significant bit first.
  public let flags: [UInt8]

  public init(header: BlockHeader,
              totalNumTransactions: UInt32,
              hashes: [SHA256Hash],
              flags: [UInt8]) {
    self.header = header
    self.totalNumTransactions = totalNumTransactions
    self.hashes = hashes
    self.flags = flags
  }

  public func merkleProofIsValid() -> Bool {
    var flagBitIndex = 0
    var hashIndex = 0
    if let root = merkleTreeNodeWithHeight(transactionMerkleTreeHeight,
                                           flagBitIndex: &flagBitIndex,
                                           hashIndex: &hashIndex) {
      return root.hash == header.merkleRoot
    }
    return false
  }

  // MARK: - Private Methods

  private var transactionMerkleTreeHeight: Int {
    return Int(ceil(log2(Double(totalNumTransactions))))
  }

  private func merkleTreeNodeWithHeight(height: Int,
                                        inout flagBitIndex: Int,
                                        inout hashIndex: Int) -> MerkleTreeNode? {
    let flagByte = flags[flags.count - Int(flagBitIndex / 8) - 1]
    let flag = (flagByte >> UInt8(flagBitIndex % 8)) & 1
    ++flagBitIndex
    let nodeHash: SHA256Hash
    var leftNode: MerkleTreeNode! = nil
    var rightNode: MerkleTreeNode! = nil
    if (height == 0) {
      // This is a leaf node.
      nodeHash = hashes[hashIndex++]
      // TODO: Mark the transaction as part of the filter based on the flag.
    } else {
      // This is not a leaf node.
      if (flag == 0) {
        nodeHash = hashes[hashIndex++]
      } else {
        leftNode = merkleTreeNodeWithHeight(height - 1,
                                            flagBitIndex: &flagBitIndex,
                                            hashIndex: &hashIndex)
        rightNode = merkleTreeNodeWithHeight(height - 1,
                                             flagBitIndex: &flagBitIndex,
                                             hashIndex: &hashIndex)
        if leftNode == nil || rightNode == nil {
          return nil
        }
        let hashData = NSMutableData()
        hashData.appendData(leftNode.hash.data.reversedData)
        hashData.appendData(rightNode.hash.data.reversedData)
        nodeHash = SHA256Hash(data: hashData.SHA256Hash().SHA256Hash().reversedData)
      }
    }
    return MerkleTreeNode(hash: nodeHash, left: leftNode, right: rightNode)
  }
}

extension FilteredBlock: MessagePayload {

  public var command: Message.Command {
    return Message.Command.FilteredBlock
  }

  public var bitcoinData: NSData {
    var data = NSMutableData()
    data.appendData(header.bitcoinData)
    data.appendUInt32(totalNumTransactions)
    data.appendVarInt(hashes.count)
    for hash in hashes {
      data.appendData(hash.bitcoinData)
    }
    data.appendVarInt(flags.count)
    for flag in flags {
      data.appendUInt8(flag)
    }
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> FilteredBlock? {
    let header = BlockHeader.fromBitcoinStream(stream)
    if header == nil {
      Logger.warn("Failed to parse header from FilteredBlock")
      return nil
    }
    let totalNumTransactions = stream.readUInt32()
    if totalNumTransactions == nil {
      Logger.warn("Failed to parse totalNumTransactions from FilteredBlock")
      return nil
    }
    let hashesCount = stream.readVarInt()
    if hashesCount == nil {
      Logger.warn("Failed to parse hashesCount from FilteredBlock")
      return nil
    }
    var hashes: [SHA256Hash] = []
    for i in 0..<hashesCount! {
      let hash = SHA256Hash.fromBitcoinStream(stream)
      if hash == nil {
        Logger.warn("Failed to parse hash \(i) from FilteredBlock")
        return nil
      }
      hashes.append(hash!)
    }
    let flagBytesCount = stream.readVarInt()
    if flagBytesCount == nil {
      Logger.warn("Failed to parse flagBytesCount from FilteredBlock")
      return nil
    }
    var flags: [UInt8] = []
    for i in 0..<flagBytesCount! {
      let flagByte = stream.readUInt8()
      if flagByte == nil {
        Logger.warn("Failed to parse flagByte \(i) from FilteredBlock")
        return nil
      }
      flags.append(flagByte!)
    }
    let filteredBlock = FilteredBlock(header: header!,
                                      totalNumTransactions: totalNumTransactions!,
                                      hashes: hashes,
                                      flags: flags)
    if filteredBlock.merkleProofIsValid() {
      return filteredBlock
    }
    Logger.warn("Invalid merkle proof in FilteredBlock")
    return nil
  }
}
