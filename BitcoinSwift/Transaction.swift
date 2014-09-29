//
//  Transaction.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: Transaction, rhs: Transaction) -> Bool {
  return lhs.version == rhs.version &&
      lhs.inputs == rhs.inputs &&
      lhs.outputs == rhs.outputs &&
      lhs.lockTime == rhs.lockTime
}

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
}

extension Transaction: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Transaction
  }

  public var data: NSData {
    let data = NSMutableData()
    data.appendUInt32(version)
    data.appendVarInt(inputs.count)
    for input in inputs {
      data.appendData(input.data)
    }
    data.appendVarInt(outputs.count)
    for output in outputs {
      data.appendData(output.data)
    }
    data.appendUInt32(lockTime.toRaw())
    return data
  }

  public static func fromData(data: NSData) -> Transaction? {
    return Transaction.fromStream(NSInputStream(data: data))
  }

  public static func fromStream(stream: NSInputStream) -> Transaction? {
    if stream.streamStatus != .Open {
      stream.open()
    }
    let version = stream.readUInt32()
    if version == nil {
      println("WARN: Failed to parse version in Transaction")
      return nil
    }
    let inputCount = stream.readVarInt()
    if inputCount == nil {
      println("WARN: Failed to parse inputCount in Transaction")
      return nil
    }
    var inputs: [Input] = []
    for i in 0..<inputCount! {
      let input = Input.fromStream(stream)
      if input == nil {
        println("WARN: Failed to parse input at index \(i) in Transaction")
        return nil
      }
      inputs.append(input!)
    }
    let outputCount = stream.readVarInt()
    if outputCount == nil {
      println("WARN: Failed to parse outputCount in Transaction")
      return nil
    }
    var outputs: [Output] = []
    for i in 0..<outputCount! {
      let output = Output.fromStream(stream)
      if output == nil {
        println("WARN: Failed to parse output at index \(i) in Transaction")
        return nil
      }
      outputs.append(output!)
    }
    let lockTimeRaw = stream.readUInt32()
    if lockTimeRaw == nil {
      println("WARN: Failed to parse lockTime in Transaction")
      return nil
    }
    let lockTime = LockTime.fromRaw(lockTimeRaw!)
    if lockTime == nil {
      println("WARN: Invalid LockTime \(lockTimeRaw) in Transaction")
      return nil
    }
    return Transaction(version: version!, inputs: inputs, outputs: outputs, lockTime: lockTime!)
  }
}
