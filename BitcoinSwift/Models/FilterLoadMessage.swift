//
//  FilterLoadMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/18/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: FilterLoadMessage, rhs: FilterLoadMessage) -> Bool {
  return lhs.filter == rhs.filter &&
      lhs.hashFunctions == rhs.hashFunctions &&
      lhs.tweak == rhs.tweak &&
      lhs.flags == rhs.flags
}

/// Upon receiving a filterload command, the remote peer will immediately restrict the broadcast
/// transactions it announces (in inv messages) to transactions matching the filter.
/// The flags control the update behavior of the matching algorithm.
/// https://en.bitcoin.it/wiki/Protocol_specification#filterload.2C_filteradd.2C_filterclear.2C_merkleblock
public struct FilterLoadMessage: Equatable {

  public static let MaxFilterLength = 36_000
  public static let MaxHashFunctions: UInt32 = 50

  public let filter: NSData
  public let hashFunctions: UInt32
  public let tweak: UInt32
  public let flags: UInt8

  public init(filter: NSData, hashFunctions: UInt32, tweak: UInt32, flags: UInt8) {
    precondition(filter.length <= FilterLoadMessage.MaxFilterLength)
    precondition(hashFunctions <= FilterLoadMessage.MaxHashFunctions)
    self.filter = filter
    self.hashFunctions = hashFunctions
    self.tweak = tweak
    self.flags = flags
  }
}

extension FilterLoadMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.FilterLoad
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendVarInt(filter.length)
    data.appendData(filter)
    data.appendUInt32(hashFunctions)
    data.appendUInt32(tweak)
    data.appendUInt8(flags)
    return data
  }

  public static func fromData(data: NSData) -> FilterLoadMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let filterLength = stream.readVarInt()
    if filterLength == nil {
      Logger.warn("Failed to parse filterLength from FilterLoadMessage \(data)")
      return nil
    }
    if filterLength! <= UInt64(0) || filterLength! > UInt64(FilterLoadMessage.MaxFilterLength) {
      Logger.warn("Invalid filterLength \(filterLength!) in FilterLoadMessage \(data)")
      return nil
    }
    let filter = stream.readData(length: Int(filterLength!))
    if filter == nil {
      Logger.warn("Failed to parse filter from FilterLoadMessage \(data)")
      return nil
    }
    let hashFunctions = stream.readUInt32()
    if hashFunctions == nil {
      Logger.warn("Failed to parse hashFunctions from FilterLoadMessage \(data)")
      return nil
    }
    let tweak = stream.readUInt32()
    if tweak == nil {
      Logger.warn("Failed to parse tweak from FilterLoadMessage \(data)")
      return nil
    }
    let flags = stream.readUInt8()
    if flags == nil {
      Logger.warn("Failed to parse flags from FilterLoadMessage \(data)")
      return nil
    }
    return FilterLoadMessage(filter: filter!,
                             hashFunctions: hashFunctions!,
                             tweak: tweak!,
                             flags: flags!)
  }
}
