//
//  GetHeadersMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// Message payload object corresponding to the Message.Command.GetHeaders command. Return a headers
/// packet containing the headers of blocks starting right after the last known hash in the block
/// locator object, up to blockHashStop or 2000 blocks, whichever comes first.
/// https://en.bitcoin.it/wiki/Protocol_specification#getheaders
public struct GetHeadersMessage: MessagePayload {

  public let protocolVersion: UInt32
  public let blockLocatorHashes: [NSData]
  public let blockHashStop: NSData?

  public init(protocolVersion: UInt32, blockLocatorHashes: [NSData], blockHashStop: NSData? = nil) {
    precondition(blockLocatorHashes.count > 0, "Must include at least one blockHash")
    self.protocolVersion = protocolVersion
    self.blockLocatorHashes = blockLocatorHashes
    self.blockHashStop = blockHashStop
  }

  public var command: Message.Command {
    return Message.Command.GetBlocks
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendUInt32(protocolVersion)
    data.appendVarInt(blockLocatorHashes.count)
    for blockLocatorHash in blockLocatorHashes {
      data.appendData(blockLocatorHash)
    }
    if let hashStop = blockHashStop {
      data.appendData(hashStop)
    } else {
      data.appendData(NSMutableData(length:32))
    }
    return data
  }

  public static func fromData(data: NSData) -> GetHeadersMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data:data)
    stream.open()
    let protocolVersion = stream.readUInt32()
    if protocolVersion == nil {
      println("WARN: Failed to parse protocolVersion from GetHeadersMessage \(data)")
      return nil
    }
    let hashCount = stream.readVarInt()
    if hashCount == nil {
      println("WARN: Failed to parse hashCount from GetHeadersMessage \(data)")
      return nil
    }
    var blockLocatorHashes: [NSData] = []
    for _ in 0..<hashCount! {
      let blockLocatorHash = stream.readData(length:32)
      if blockLocatorHash == nil {
        println("WARN: Failed to parse blockLocatorHash from GetHeadersMessage \(data)")
        return nil
      }
      blockLocatorHashes.append(blockLocatorHash!)
    }
    var blockHashStop = stream.readData(length:32)
    if blockHashStop == nil {
      println("WARN: Failed to parse blockHashStop from GetHeadersMessage \(data)")
      return nil
    }
    let zeroHash = NSMutableData(length:32)
    if blockHashStop == zeroHash {
      // blockHashStop will be 0 to get as many blocks as possible (max 2000 blocks).
      blockHashStop = nil
    }
    return GetHeadersMessage(protocolVersion:protocolVersion!,
                             blockLocatorHashes:blockLocatorHashes,
                             blockHashStop:blockHashStop)
  }
}
