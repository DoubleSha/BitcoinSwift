//
//  BlockHeader.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/28/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: BlockHeader, right: BlockHeader) -> Bool {
  return left.version == right.version &&
      left.previousBlockHash == right.previousBlockHash &&
      left.merkleRoot == right.merkleRoot &&
      left.timestamp == right.timestamp &&
      left.compactDifficulty == right.compactDifficulty &&
      left.nonce == right.nonce
}

public protocol BlockHeaderParameters {

  var blockVersion: UInt32 { get }
}

public struct BlockHeader: Equatable {

  public let version: UInt32
  public let previousBlockHash: SHA256Hash
  public let merkleRoot: SHA256Hash
  public let timestamp: NSDate
  public let compactDifficulty: UInt32
  public let nonce: UInt32

  static private let largestDifficulty = BigInteger(1) << 256
  private var cachedHash: SHA256Hash?

  public init(params: BlockHeaderParameters,
              previousBlockHash: SHA256Hash,
              merkleRoot: SHA256Hash,
              timestamp: NSDate,
              compactDifficulty: UInt32,
              nonce: UInt32) {
    self.init(version: params.blockVersion,
              previousBlockHash: previousBlockHash,
              merkleRoot: merkleRoot,
              timestamp: timestamp,
              compactDifficulty: compactDifficulty,
              nonce: nonce)
  }

  public init(version: UInt32,
              previousBlockHash: SHA256Hash,
              merkleRoot: SHA256Hash,
              timestamp: NSDate,
              compactDifficulty: UInt32,
              nonce: UInt32) {
    self.version = version
    self.previousBlockHash = previousBlockHash
    self.merkleRoot = merkleRoot
    self.timestamp = timestamp
    self.compactDifficulty = compactDifficulty
    self.nonce = nonce
  }

  /// Calculated from the information in the block header. It does not include the transactions.
  /// https://en.bitcoin.it/wiki/Block_hashing_algorithm
  public var hash: SHA256Hash {
    // TODO: Don't recalculate this every time.
    return SHA256Hash(data: bitcoinData.SHA256Hash().SHA256Hash().reversedData)
  }

  /// The difficulty used to create this block. This is the uncompressed form of the
  /// compactDifficulty property.
  public var difficulty: BigInteger {
    let compactDifficultyData = NSMutableData()
    compactDifficultyData.appendUInt32(compactDifficulty, endianness: .BigEndian)
    return BigInteger(compactData: compactDifficultyData)
  }

  /// The work represented by this block.
  /// Work is defined as the number of tries needed to solve a block in the average case.
  /// Consider a difficulty target that covers 5% of all possible hash values. Then the work of the
  /// block will be 20. As the difficulty gets lower, the amount of work goes up.
  public var work: BigInteger {
    return BlockHeader.largestDifficulty / (difficulty + BigInteger(1))
  }
}

extension BlockHeader: BitcoinSerializable {

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendUInt32(version)
    data.appendData(previousBlockHash.bitcoinData)
    data.appendData(merkleRoot.bitcoinData)
    data.appendDateAs32BitUnixTimestamp(timestamp)
    data.appendUInt32(compactDifficulty)
    data.appendUInt32(nonce)
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> BlockHeader? {
    let version = stream.readUInt32()
    if version == nil {
      Logger.warn("Failed to parse version from BlockHeader")
      return nil
    }
    let previousBlockHash = SHA256Hash.fromBitcoinStream(stream)
    if previousBlockHash == nil {
      Logger.warn("Failed to parse previousBlockHash from BlockHeader")
      return nil
    }
    let merkleRoot = SHA256Hash.fromBitcoinStream(stream)
    if merkleRoot == nil {
      Logger.warn("Failed to parse merkleRoot from BlockHeader")
      return nil
    }
    let timestamp = stream.readDateFrom32BitUnixTimestamp()
    if timestamp == nil {
      Logger.warn("Failed to parse timestamp from BlockHeader")
      return nil
    }
    let compactDifficulty = stream.readUInt32()
    if compactDifficulty == nil {
      Logger.warn("Failed to parse compactDifficulty from BlockHeader")
      return nil
    }
    let nonce = stream.readUInt32()
    if nonce == nil {
      Logger.warn("Failed to parse nonce from BlockHeader")
      return nil
    }
    return BlockHeader(version: version!,
                       previousBlockHash: previousBlockHash!,
                       merkleRoot: merkleRoot!,
                       timestamp: timestamp!,
                       compactDifficulty: compactDifficulty!,
                       nonce: nonce!)
  }
}
