//
//  FilterClearMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/16/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// Clears the bloom filter the peer is using.
/// https://en.bitcoin.it/wiki/Protocol_specification#filterload.2C_filteradd.2C_filterclear.2C_merkleblock
struct FilterClearMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.FilterClear
  }

  public var data: NSData {
    // A filterclear message has no payload.
    return NSData()
  }

  public static func fromData(data: NSData) -> FilterClearMessage? {
    // A filterclear message has no payload.
    if data.length != 0 {
      return nil
    }
    return FilterClearMessage()
  }
}
