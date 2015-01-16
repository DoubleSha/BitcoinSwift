//
//  Transaction.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: Transaction, right: Transaction) -> Bool {
  return left.version == right.version &&
      left.inputs == right.inputs &&
      left.outputs == right.outputs &&
      left.lockTime == right.lockTime
}

public protocol TransactionParameters {
  var transactionVersion: UInt32 { get }
}

/// Represents a Bitcoin transaction.
/// https://en.bitcoin.it/wiki/Protocol_specification#tx
public struct Transaction: Equatable {

  public let version: UInt32
  public let inputs: [Input]
  public let outputs: [Output]
  public let lockTime: LockTime

  public init(version: UInt32,
              inputs: [Input],
              outputs: [Output],
              lockTime: LockTime = .AlwaysLocked) {
    precondition(outputs.count > 0)
    self.version = version
    self.inputs = inputs
    self.outputs = outputs
    self.lockTime = lockTime
  }

  public init(params: TransactionParameters,
              inputs: [Input],
              outputs: [Output],
              lockTime: LockTime = .AlwaysLocked) {
    self.init(version: params.transactionVersion,
              inputs: inputs,
              outputs: outputs,
              lockTime: lockTime)
  }
}

extension Transaction: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Transaction
  }

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendUInt32(version)
    data.appendVarInt(inputs.count)
    for input in inputs {
      data.appendData(input.bitcoinData)
    }
    data.appendVarInt(outputs.count)
    for output in outputs {
      data.appendData(output.bitcoinData)
    }
    data.appendUInt32(lockTime.rawValue)
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> Transaction? {
    let version = stream.readUInt32()
    if version == nil {
      Logger.warn("Failed to parse version in Transaction")
      return nil
    }
    let inputCount = stream.readVarInt()
    if inputCount == nil {
      Logger.warn("Failed to parse inputCount in Transaction")
      return nil
    }
    var inputs: [Input] = []
    for i in 0..<inputCount! {
      let input = Input.fromBitcoinStream(stream)
      if input == nil {
        Logger.warn("Failed to parse input at index \(i) in Transaction")
        return nil
      }
      inputs.append(input!)
    }
    if inputs.count == 0 {
      Logger.warn("Failed to parse inputs. No inputs found")
      return nil
    }
    let outputCount = stream.readVarInt()
    if outputCount == nil {
      Logger.warn("Failed to parse outputCount in Transaction")
      return nil
    }
    var outputs: [Output] = []
    for i in 0..<outputCount! {
      let output = Output.fromBitcoinStream(stream)
      if output == nil {
        Logger.warn("Failed to parse output at index \(i) in Transaction")
        return nil
      }
      outputs.append(output!)
    }
    if outputs.count == 0 {
      Logger.warn("Failed to parse outputs. No outputs found")
      return nil
    }
    let lockTimeRaw = stream.readUInt32()
    if lockTimeRaw == nil {
      Logger.warn("Failed to parse lockTime in Transaction")
      return nil
    }
    let lockTime = LockTime.fromRaw(lockTimeRaw!)
    if lockTime == nil {
      Logger.warn("Invalid LockTime \(lockTimeRaw) in Transaction")
      return nil
    }
    return Transaction(version: version!, inputs: inputs, outputs: outputs, lockTime: lockTime!)
  }
}
