//
//  FilterLoadMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/18/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: FilterLoadMessage, right: FilterLoadMessage) -> Bool {
  return left.filter == right.filter &&
      left.numHashFunctions == right.numHashFunctions &&
      left.tweak == right.tweak &&
      left.flags == right.flags
}

/// Upon receiving a filterload command, the remote peer will immediately restrict the broadcast
/// transactions it announces (in inv messages) to transactions matching the filter.
/// The flags control the update behavior of the matching algorithm.
/// https://en.bitcoin.it/wiki/Protocol_specification#filterload.2C_filteradd.2C_filterclear.2C_merkleblock
public struct FilterLoadMessage: Equatable {

  public static let MaxFilterLength = 36_000
  public static let MaxNumHashFunctions: UInt32 = 50

  public let filter: NSData
  public let numHashFunctions: UInt32
  public let tweak: UInt32
  public let flags: UInt8

  public init(filter: NSData, numHashFunctions: UInt32, tweak: UInt32, flags: UInt8) {
    precondition(filter.length <= FilterLoadMessage.MaxFilterLength)
    self.filter = filter
    self.numHashFunctions = numHashFunctions
    self.tweak = tweak
    self.flags = flags
  }
}

extension FilterLoadMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.FilterLoad
  }

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendVarInt(filter.length)
    data.appendData(filter)
    data.appendUInt32(numHashFunctions)
    data.appendUInt32(tweak)
    data.appendUInt8(flags)
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> FilterLoadMessage? {
    let filterLength = stream.readVarInt()
    if filterLength == nil {
      Logger.warn("Failed to parse filterLength from FilterLoadMessage")
      return nil
    }
    if filterLength! <= UInt64(0) || filterLength! > UInt64(FilterLoadMessage.MaxFilterLength) {
      Logger.warn("Invalid filterLength \(filterLength!) in FilterLoadMessage")
      return nil
    }
    let filter = stream.readData(Int(filterLength!))
    if filter == nil {
      Logger.warn("Failed to parse filter from FilterLoadMessage")
      return nil
    }
    let numHashFunctions = stream.readUInt32()
    if numHashFunctions == nil {
      Logger.warn("Failed to parse numHashFunctions from FilterLoadMessage")
      return nil
    }
    let tweak = stream.readUInt32()
    if tweak == nil {
      Logger.warn("Failed to parse tweak from FilterLoadMessage")
      return nil
    }
    let flags = stream.readUInt8()
    if flags == nil {
      Logger.warn("Failed to parse flags from FilterLoadMessage")
      return nil
    }
    return FilterLoadMessage(filter: filter!,
                             numHashFunctions: numHashFunctions!,
                             tweak: tweak!,
                             flags: flags!)
  }
}
