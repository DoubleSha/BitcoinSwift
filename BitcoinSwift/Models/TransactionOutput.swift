//
//  TransactionOutput.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: Transaction.Output, rhs: Transaction.Output) -> Bool {
  return lhs.value == rhs.value && lhs.script == rhs.script
}

public extension Transaction {

  /// An Output represents the bitcoin being received in a Transaction. It can then later be spent
  /// by an Input in another transaction.
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

public extension Transaction.Output {

  public var data: NSData {
    var data = NSMutableData()
    data.appendInt64(value)
    data.appendVarInt(script.length)
    data.appendData(script)
    return data
  }

  public static func fromData(data: NSData) -> Transaction.Output? {
    return Transaction.Output.fromStream(NSInputStream(data: data))
  }

  public static func fromStream(stream: NSInputStream) -> Transaction.Output? {
    if stream.streamStatus != .Open {
      stream.open()
    }
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
    let script = stream.readData(length: Int(scriptLength!))
    if script == nil {
      Logger.warn("Failed to parse script from Transaction.Output")
      return nil
    }
    // TODO: Validate script.
    return Transaction.Output(value: value!, script: script!)
  }
}
