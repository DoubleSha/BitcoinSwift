//
//  TransactionOutput.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: Transaction.Output, right: Transaction.Output) -> Bool {
  return left.value == right.value && left.script == right.script
}

public extension Transaction {

  /// An Output represents the bitcoin being received in a Transaction. It can then later be spent
  /// by an Input in another transaction.
  /// https://en.bitcoin.it/wiki/Protocol_specification#tx
  public struct Output: Equatable {

    /// The value being sent in this output, in satoshi.
    public let value: Int64

    /// The script defines the conditions that must be met in order to spend the output.
    /// https://en.bitcoin.it/wiki/Script
    public let script: NSData

    public init(value: Int64, script: NSData) {
      // TODO: Validate script.
      self.value = value
      self.script = script
    }
  }
}

 extension Transaction.Output: BitcoinSerializable {

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendInt64(value)
    data.appendVarInt(script.length)
    data.appendData(script)
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> Transaction.Output? {
    let value = stream.readInt64()
    if value == nil {
      Logger.warn("Failed to parse value from Transaction.Output")
      return nil
    }
    let scriptLength = stream.readVarInt()
    if scriptLength == nil {
      Logger.warn("Failed to parse scriptLength from Transaction.Output")
      return nil
    }
    let script = stream.readData(Int(scriptLength!))
    if script == nil {
      Logger.warn("Failed to parse script from Transaction.Output")
      return nil
    }
    // TODO: Validate script.
    return Transaction.Output(value: value!, script: script!)
  }
}
