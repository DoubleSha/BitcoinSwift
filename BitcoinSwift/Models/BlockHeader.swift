//
//  BlockHeader.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/28/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: BlockHeader, rhs: BlockHeader) -> Bool {
  return lhs.version == rhs.version &&
      lhs.previousBlockHash == rhs.previousBlockHash &&
      lhs.merkleRoot == rhs.merkleRoot &&
      lhs.timestamp == rhs.timestamp &&
      lhs.compactDifficulty == rhs.compactDifficulty &&
      lhs.nonce == rhs.nonce
}

public struct BlockHeader: Equatable {

  public let version: UInt32
  public let previousBlockHash: NSData
  public let merkleRoot: NSData
  public let timestamp: NSDate
  public let compactDifficulty: UInt32
  public let nonce: UInt32

  /// hash is calculated from the information in the block header. It does not include the
  /// transactions.
  /// https://en.bitcoin.it/wiki/Block_hashing_algorithm
  public var hash: NSData {
    return bitcoinData.SHA256Hash().SHA256Hash().reversedData
  }

  /// The difficulty used to create this block. This is the uncompressed form of the
  /// compactDifficulty property.
  public var difficulty: BigInteger {
    var compactDifficultyData = NSMutableData()
    compactDifficultyData.appendUInt32(compactDifficulty, endianness: .BigEndian)
    return BigInteger(compactData: compactDifficultyData)
  }

  public init(version: UInt32,
              previousBlockHash: NSData,
              merkleRoot: NSData,
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
}

extension BlockHeader: BitcoinSerializable {

  public var bitcoinData: NSData {
    var data = NSMutableData()
    data.appendUInt32(version)
    data.appendData(previousBlockHash)
    data.appendData(merkleRoot)
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
    let previousBlockHash = stream.readData(length: 32)
    if previousBlockHash == nil {
      Logger.warn("Failed to parse previousBlockHash from BlockHeader")
      return nil
    }
    let merkleRoot = stream.readData(length: 32)
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
