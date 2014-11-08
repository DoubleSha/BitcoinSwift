//
//  MemPoolMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/14/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// The mempool message sends a request to a node asking for information about transactions it has
/// verified but which have not yet confirmed. The response to receiving this message is an inv
/// message containing the transaction hashes for all the transactions in the node's mempool.
/// https://en.bitcoin.it/wiki/Protocol_specification#mempool
public struct MemPoolMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.MemPool
  }

  public var bitcoinData: NSData {
    // A mempool message has no payload.
    return NSData()
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> MemPoolMessage? {
    // A mempool message has no payload.
    return MemPoolMessage()
  }
}
