//
//  RejectMessage.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 9/28/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// The reject message is sent when messages are rejected.
/// https://en.bitcoin.it/wiki/Protocol_specification#reject
public struct RejectMessage: MessagePayload {

  public enum Code: UInt8 {
    case Malformed = 0x01
    case Invalid = 0x10
    case Obsolete = 0x11
    case Duplicate = 0x12
    case NonStandard = 0x40
    case Dust = 0x41
    case InsufficientFee = 0x42
    case Checkpoint = 0x43
  }

  public let rejectedCommand: Message.Command
  public let code: Code
  public let reason: String

  public init(rejectedCommand: Message.Command, code: Code, reason: String) {
    self.rejectedCommand = rejectedCommand
    self.code = code
    self.reason = reason
  }

  // MARK: - MessagePayload

  public var command: Message.Command {
    return Message.Command.Reject
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendVarString(rejectedCommand.toRaw())
    data.appendUInt8(code.toRaw())
    data.appendVarString(reason)
    return data
  }

  public static func fromData(data: NSData) -> RejectMessage? {
    if data.length == 0 {
      println("WARN: No data passed to RejectMessage \(data)")
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let rawCommand = stream.readVarString()
    if rawCommand == nil {
      println("WARN: Failed to parse rawCommand from RejectMessage \(data)")
      return nil
    }
    let command = Message.Command.fromRaw(rawCommand!)
    if command == nil {
      println("WARN: Invalid command \(rawCommand!) from RejectMessage \(data)")
      return nil
    }
    let rawCode = stream.readUInt8()
    if rawCode == nil {
      println("WARN: Failed to parse rawCode from RejectMessage \(data)")
      return nil
    }
    let code = Code.fromRaw(rawCode!)
    if code == nil {
      println("WARN: Invalid code \(rawCommand!) from RejectMessage \(data)")
      return nil
    }
    let reason = stream.readVarString()
    if stream.hasBytesAvailable {
      println("WARN: Failed to parse RejectMessage. Too much data \(data)")
      return nil
    }
    return RejectMessage(rejectedCommand: command!, code: code!, reason: reason)
  }
}
