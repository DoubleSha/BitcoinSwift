//
//  Block.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/28/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: Block, rhs: Block) -> Bool {
  return lhs.header == rhs.header && lhs.transactions == rhs.transactions
}

/// Message payload object corresponding to the Message.Command.Block command. The block message
/// is sent in response to a getdata message which requests transaction information from a
/// block hash.
/// https://en.bitcoin.it/wiki/Protocol_specification#block
public struct Block: Equatable {

  public let header: Header
  /// If the transactions array is empty, then this is just a block header.
  public let transactions: [Transaction]

  public init(header: Header, transactions: [Transaction]) {
    self.header = header
    self.transactions = transactions
  }
}

extension Block: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Block
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendData(header.data)
    // Note: the transactions array will be empty if this is just a block header.
    data.appendVarInt(transactions.count)
    for transaction in transactions {
      data.appendData(transaction.data)
    }
    return data
  }

  public static func fromData(data: NSData) -> Block? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let header = Header.fromStream(stream)
    if header == nil {
      Logger.warn("Failed to parse header from BlockMessage \(data)")
      return nil
    }
    let transactionsCount = stream.readVarInt()
    if transactionsCount == nil {
      Logger.warn("Failed to parse transactionsCount from BlockMessage \(data)")
      return nil
    }
    var transactions: [Transaction] = []
    for i in 0..<transactionsCount! {
      let transaction = Transaction.fromStream(stream)
      if transaction == nil {
        Logger.warn("Failed to parse transaction at index \(i) from BlockMessage \(data)")
        return nil
      }
      transactions.append(transaction!)
    }
    return Block(header: header!, transactions: transactions)
  }
}
