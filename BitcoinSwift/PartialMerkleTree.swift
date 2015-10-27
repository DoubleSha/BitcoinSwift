//
//  PartialMerkleTree.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/16/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: PartialMerkleTree, right: PartialMerkleTree) -> Bool {
  return left.totalLeafNodes == right.totalLeafNodes &&
      left.hashes == right.hashes &&
      left.flags == right.flags &&
      left.rootHash == right.rootHash &&
      left.matchingHashes == right.matchingHashes
}

public struct PartialMerkleTree {

  /// The number of leaf nodes that would be present if this were a full merkle tree.
  public let totalLeafNodes: UInt32
  /// The hashes used to build the partial merkle tree, in depth-first order.
  public let hashes: [SHA256Hash]
  /// Flag bits used to build the partial merkle tree, packed per 8 in a byte, least significant
  /// bit first.
  public let flags: [UInt8]
  /// The merkle root hash is calculated by building the merkle tree from the hashes and flags.
  public let rootHash: SHA256Hash
  /// The list of leaf hashes that were marked as matching the filter.
  public let matchingHashes: [SHA256Hash]

  /// Returns nil if a partial
  public init?(totalLeafNodes: UInt32, hashes: [SHA256Hash], flags: [UInt8]) {
    self.totalLeafNodes = totalLeafNodes
    self.hashes = hashes
    self.flags = flags
    let height = PartialMerkleTree.treeHeightWithtotalLeafNodes(totalLeafNodes)
    var matchingHashes: [SHA256Hash] = []
    var flagBitIndex = 0
    var hashIndex = 0
    if let merkleRoot =
        PartialMerkleTree.merkleTreeNodeWithHeight(height,
                                                   hashes: hashes,
                                                   flags: flags,
                                                   matchingHashes: &matchingHashes,
                                                   flagBitIndex: &flagBitIndex,
                                                   hashIndex: &hashIndex) {
      self.rootHash = merkleRoot.hash
      self.matchingHashes = matchingHashes
      // Fail if there are any unused hashes.
      if hashIndex < hashes.count {
        return nil
      }
      // Fail if there are unused flag bits, except for the minimum number of bits necessary to
      // pad up to the next full byte.
      if (flagBitIndex / 8 != flags.count - 1) && (flagBitIndex != flags.count * 8) {
        return nil
      }
      // Fail if there are any non-zero bits in the padding section.
      while flagBitIndex < flags.count * 8 {
        let flag = PartialMerkleTree.flagBitAtIndex(flagBitIndex++, flags: flags)
        if flag == 1 {
          return nil
        }
      }
    } else {
      self.rootHash = SHA256Hash()
      self.matchingHashes = []
      return nil
    }
  }

  // MARK: - Private Methods

  private static func treeHeightWithtotalLeafNodes(totalLeafNodes: UInt32) -> Int {
    return Int(ceil(log2(Double(totalLeafNodes))))
  }

  private static func merkleTreeNodeWithHeight(height: Int,
                                               hashes: [SHA256Hash],
                                               flags: [UInt8],
                                               inout matchingHashes: [SHA256Hash],
                                               inout flagBitIndex: Int,
                                               inout hashIndex: Int) -> MerkleTreeNode? {
    if hashIndex >= hashes.count {
      // We have run out of hashes without successfully building the tree.
      return nil
    }
    if flagBitIndex >= flags.count * 8 {
      // We have run out of flags without sucessfully building the tree.
      return nil
    }
    let flag = flagBitAtIndex(flagBitIndex++, flags: flags)
    let nodeHash: SHA256Hash
    var leftNode: MerkleTreeNode! = nil
    var rightNode: MerkleTreeNode! = nil
    if height == 0 {
      // This is a leaf node.
      nodeHash = hashes[hashIndex++]
      if flag == 1 {
        matchingHashes.append(nodeHash)
      }
    } else {
      // This is not a leaf node.
      if flag == 0 {
        nodeHash = hashes[hashIndex++]
      } else {
        leftNode = merkleTreeNodeWithHeight(height - 1,
                                            hashes: hashes,
                                            flags: flags,
                                            matchingHashes: &matchingHashes,
                                            flagBitIndex: &flagBitIndex,
                                            hashIndex: &hashIndex)
        rightNode = merkleTreeNodeWithHeight(height - 1,
                                             hashes: hashes,
                                             flags: flags,
                                             matchingHashes: &matchingHashes,
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

  private static func flagBitAtIndex(index: Int, flags: [UInt8]) -> UInt8 {
    precondition(index < flags.count * 8)
    let flagByte = flags[flags.count - Int(index / 8) - 1]
    return (flagByte >> UInt8(index % 8)) & 1
  }
}

extension PartialMerkleTree: BitcoinSerializable {

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendUInt32(totalLeafNodes)
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

  public static func fromBitcoinStream(stream: NSInputStream) -> PartialMerkleTree? {
    let totalLeafNodes = stream.readUInt32()
    if totalLeafNodes == nil {
      Logger.warn("Failed to parse totalLeafNodes from PartialMerkleTree")
      return nil
    }
    let hashesCount = stream.readVarInt()
    if hashesCount == nil {
      Logger.warn("Failed to parse hashesCount from PartialMerkleTree")
      return nil
    }
    var hashes: [SHA256Hash] = []
    for i in 0..<hashesCount! {
      let hash = SHA256Hash.fromBitcoinStream(stream)
      if hash == nil {
        Logger.warn("Failed to parse hash \(i) from PartialMerkleTree")
        return nil
      }
      hashes.append(hash!)
    }
    let flagBytesCount = stream.readVarInt()
    if flagBytesCount == nil {
      Logger.warn("Failed to parse flagBytesCount from PartialMerkleTree")
      return nil
    }
    var flags: [UInt8] = []
    for i in 0..<flagBytesCount! {
      let flagByte = stream.readUInt8()
      if flagByte == nil {
        Logger.warn("Failed to parse flagByte \(i) from PartialMerkleTree")
        return nil
      }
      flags.append(flagByte!)
    }
    return PartialMerkleTree(totalLeafNodes: totalLeafNodes!, hashes: hashes, flags: flags)
  }
}
