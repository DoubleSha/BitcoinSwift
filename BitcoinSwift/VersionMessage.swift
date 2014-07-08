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
  let myAddress: NetworkAddress
  let theirAddress: NetworkAddress
  let nonce: UInt64
  let userAgent = "/BitcoinSwift:0.1.0/"
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
    data.appendUInt64(UInt64(date.timeIntervalSince1970))
    data.appendNetworkAddress(theirAddress)
    data.appendNetworkAddress(myAddress)
    data.appendUInt64(nonce)
    data.appendVarString(userAgent)
    data.appendInt32(blockStartHeight)
    data.appendBool(relayTransactions)
    return data
  }
}
