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
public struct FilterClearMessage: MessagePayload {

  // Swift's default struct initializers are marked as internal
  // See: http://stackoverflow.com/a/27635674/1470317
  public init() {}
  
  public var command: Message.Command {
    return Message.Command.FilterClear
  }

  public var bitcoinData: NSData {
    // A filterclear message has no payload.
    return NSData()
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> FilterClearMessage? {
    // A filterclear message has no payload.
    return FilterClearMessage()
  }
}
