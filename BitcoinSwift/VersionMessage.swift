//
//  VersionMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/3/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

struct VersionMessage: MessagePayload {

  let protocolVersion: UInt32
  let services: Message.Services
  let date: NSDate
  let senderAddress: NetworkAddress
  let receiverAddress: NetworkAddress
  let nonce: UInt64
  let userAgent: String
  let blockStartHeight: Int32
  let relayTransactions: Bool

  // MARK: - MessagePayload

  var command: Message.Command {
    return Message.Command.Version
  }

  var data: NSData {
    var data = NSMutableData()
    data.appendUInt32(protocolVersion)
    data.appendUInt64(services.toRaw())
    data.appendInt64(Int64(date.timeIntervalSince1970))
    data.appendNetworkAddress(receiverAddress)
    data.appendNetworkAddress(senderAddress)
    data.appendUInt64(nonce)
    data.appendVarString(userAgent)
    data.appendInt32(blockStartHeight)
    data.appendBool(relayTransactions)
    return data
  }

  static func fromData(data: NSData) -> VersionMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data:data)
    stream.open()
    let protocolVersion = stream.readUInt32()
    if !protocolVersion {
      println("WARN: Failed to parse protocolVersion from VersionMessage \(data)")
      return nil
    }
    let servicesRaw = stream.readUInt64()
    if !servicesRaw {
      println("WARN: Failed to parse servicesRaw from VersionMessage \(data)")
      return nil
    }
    let services = Message.Services.fromMask(servicesRaw!)
    let timestamp = stream.readInt64()
    if !timestamp {
      println("WARN: Failed to parse timestamp from VersionMessage \(data)")
      return nil
    }
    let date = NSDate(timeIntervalSince1970:NSTimeInterval(timestamp!))
    let receiverAddress = stream.readNetworkAddress()
    if !receiverAddress {
      println("WARN: Failed to parse receiverAddress from VersionMessage \(data)")
      return nil
    }
    let senderAddress = stream.readNetworkAddress()
    if !senderAddress {
      println("WARN: Failed to parse senderAddress from VersionMessage \(data)")
      return nil
    }
    let nonce = stream.readUInt64()
    if !nonce {
      println("WARN: Failed to parse nonce from VersionMessage \(data)")
      return nil
    }
    let userAgent = stream.readVarString()
    if !userAgent {
      println("WARN: Failed to parse userAgent from VersionMessage \(data)")
      return nil
    }
    let blockStartHeight = stream.readInt32()
    if !blockStartHeight {
      println("WARN: Failed to parse blockStartHeight from VersionMessage \(data)")
      return nil
    }
    let relayTransactions = stream.readBool()
    if !relayTransactions {
      println("WARN: Failed to parse relayTransactions from VersionMessage \(data)")
      return nil
    }
    return VersionMessage(protocolVersion:protocolVersion!,
                          services:services,
                          date:date,
                          senderAddress:senderAddress!,
                          receiverAddress:receiverAddress!,
                          nonce:nonce!,
                          userAgent:userAgent!,
                          blockStartHeight:blockStartHeight!,
                          relayTransactions:relayTransactions!)
  }
}
