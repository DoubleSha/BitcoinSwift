//
//  Block.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/28/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: Block, right: Block) -> Bool {
  return left.header == right.header && left.transactions == right.transactions
}

/// Message payload object corresponding to the Message.Command.Block command. The block message
/// is sent in response to a getdata message which requests transaction information from a
/// block hash.
/// https://en.bitcoin.it/wiki/Protocol_specification#block
public struct Block: Equatable {

  public let header: BlockHeader
  /// If the transactions array is empty, then this is just a block header.
  public let transactions: [Transaction]

  public init(header: BlockHeader, transactions: [Transaction]) {
    self.header = header
    self.transactions = transactions
  }

  public var hash: SHA256Hash {
    return header.hash
  }
}

extension Block: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Block
  }

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendData(header.bitcoinData)
    // Note: the transactions array will be empty if this is just a block header.
    data.appendVarInt(transactions.count)
    for transaction in transactions {
      data.appendData(transaction.bitcoinData)
    }
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> Block? {
    let header = BlockHeader.fromBitcoinStream(stream)
    if header == nil {
      Logger.warn("Failed to parse header from Block")
      return nil
    }
    let transactionsCount = stream.readVarInt()
    if transactionsCount == nil {
      Logger.warn("Failed to parse transactionsCount from Block")
      return nil
    }
    var transactions: [Transaction] = []
    for i in 0..<transactionsCount! {
      let transaction = Transaction.fromBitcoinStream(stream)
      if transaction == nil {
        Logger.warn("Failed to parse transaction at index \(i) from Block")
        return nil
      }
      transactions.append(transaction!)
    }
    return Block(header: header!, transactions: transactions)
  }
}
