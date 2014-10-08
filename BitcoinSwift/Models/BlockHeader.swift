//
//  BlockHeader.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/28/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: Block.Header, rhs: Block.Header) -> Bool {
  return lhs.version == rhs.version &&
      lhs.previousBlockHash == rhs.previousBlockHash &&
      lhs.merkleRoot == rhs.merkleRoot &&
      lhs.timestamp == rhs.timestamp &&
      lhs.difficultyBits == rhs.difficultyBits &&
      lhs.nonce == rhs.nonce
}

extension Block {

  public struct Header: Equatable {

    public let version: UInt32
    public let previousBlockHash: NSData
    public let merkleRoot: NSData
    public let timestamp: NSDate
    public let difficultyBits: UInt32
    public let nonce: UInt32

    /// hash is calculated from the information in the block header. It does not include the
    /// transactions.
    /// https://en.bitcoin.it/wiki/Block_hashing_algorithm
    public var hash: NSData {
      return data.SHA256Hash().SHA256Hash()
    }

    public init(version: UInt32,
                previousBlockHash: NSData,
                merkleRoot: NSData,
                timestamp: NSDate,
                difficultyBits: UInt32,
                nonce: UInt32) {
      self.version = version
      self.previousBlockHash = previousBlockHash
      self.merkleRoot = merkleRoot
      self.timestamp = timestamp
      self.difficultyBits = difficultyBits
      self.nonce = nonce
    }
  }
}

extension Block.Header {

  public var data: NSData {
    var data = NSMutableData()
    data.appendUInt32(version)
    data.appendData(previousBlockHash)
    data.appendData(merkleRoot)
    data.appendDateAsUnixTimestamp(timestamp)
    data.appendUInt32(difficultyBits)
    data.appendUInt32(nonce)
    return data
  }

  public static func fromStream(stream: NSInputStream) -> Block.Header? {
    if stream.streamStatus != .Open {
      stream.open()
    }
    let version = stream.readUInt32()
    if version == nil {
      println("WARN: Failed to parse version from Block.Header")
      return nil
    }
    let previousBlockHash = stream.readData(length: 32)
    if previousBlockHash == nil {
      println("WARN: Failed to parse previousBlockHash from Block.Header")
      return nil
    }
    let merkleRoot = stream.readData(length: 32)
    if merkleRoot == nil {
      println("WARN: Failed to parse merkleRoot from Block.Header")
      return nil
    }
    let timestamp = stream.readDateFromUnixTimestamp()
    if timestamp == nil {
      println("WARN: Failed to parse timestamp from Block.Header")
      return nil
    }
    let difficultyBits = stream.readUInt32()
    if difficultyBits == nil {
      println("WARN: Failed to parse difficultyBits from Block.Header")
      return nil
    }
    let nonce = stream.readUInt32()
    if nonce == nil {
      println("WARN: Failed to parse nonce from Block.Header")
      return nil
    }
    return Block.Header(version: version!,
                        previousBlockHash: previousBlockHash!,
                        merkleRoot: merkleRoot!,
                        timestamp: timestamp!,
                        difficultyBits: difficultyBits!,
                        nonce: nonce!)
  }
}
