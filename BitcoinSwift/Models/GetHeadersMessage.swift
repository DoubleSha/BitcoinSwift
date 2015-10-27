//
//  GetHeadersMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: GetHeadersMessage, right: GetHeadersMessage) -> Bool {
  return left.protocolVersion == right.protocolVersion &&
      left.blockLocatorHashes == right.blockLocatorHashes &&
      left.blockHashStop == right.blockHashStop
}

/// Message payload object corresponding to the Message.Command.GetHeaders command. Return a headers
/// packet containing the headers of blocks starting right after the last known hash in the block
/// locator object, up to blockHashStop or 2000 blocks, whichever comes first.
/// https://en.bitcoin.it/wiki/Protocol_specification#getheaders
public struct GetHeadersMessage: Equatable {

  public let protocolVersion: UInt32
  public let blockLocatorHashes: [SHA256Hash]
  public let blockHashStop: SHA256Hash?

  public init(protocolVersion: UInt32,
              blockLocatorHashes: [SHA256Hash],
              blockHashStop: SHA256Hash? = nil) {
    precondition(blockLocatorHashes.count > 0, "Must include at least one blockHash")
    self.protocolVersion = protocolVersion
    self.blockLocatorHashes = blockLocatorHashes
    self.blockHashStop = blockHashStop
  }
}

extension GetHeadersMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.GetHeaders
  }

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendUInt32(protocolVersion)
    data.appendVarInt(blockLocatorHashes.count)
    for blockLocatorHash in blockLocatorHashes {
      data.appendData(blockLocatorHash.bitcoinData)
    }
    if let hashStop = blockHashStop {
      data.appendData(hashStop.bitcoinData)
    } else {
      data.appendData(SHA256Hash().bitcoinData)
    }
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> GetHeadersMessage? {
    let protocolVersion = stream.readUInt32()
    if protocolVersion == nil {
      Logger.warn("Failed to parse protocolVersion from GetHeadersMessage")
      return nil
    }
    let hashCount = stream.readVarInt()
    if hashCount == nil {
      Logger.warn("Failed to parse hashCount from GetHeadersMessage")
      return nil
    }
    var blockLocatorHashes: [SHA256Hash] = []
    for _ in 0..<hashCount! {
      let blockLocatorHash = SHA256Hash.fromBitcoinStream(stream)
      if blockLocatorHash == nil {
        Logger.warn("Failed to parse blockLocatorHash from GetHeadersMessage")
        return nil
      }
      blockLocatorHashes.append(blockLocatorHash!)
    }
    var blockHashStop = SHA256Hash.fromBitcoinStream(stream)
    if blockHashStop == nil {
      Logger.warn("Failed to parse blockHashStop from GetHeadersMessage")
      return nil
    }
    if blockHashStop == SHA256Hash() {
      // blockHashStop will be 0 to get as many blocks as possible (max 2000 blocks).
      blockHashStop = nil
    }
    return GetHeadersMessage(protocolVersion: protocolVersion!,
                             blockLocatorHashes: blockLocatorHashes,
                             blockHashStop: blockHashStop)
  }
}
