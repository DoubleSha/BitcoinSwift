//
//  RejectMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/4/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: RejectMessage, rhs: RejectMessage) -> Bool {
  return lhs.rejectedCommand == rhs.rejectedCommand &&
      lhs.code == rhs.code &&
      lhs.reason == rhs.reason &&
      lhs.hash == rhs.hash
}

/// The reject message is sent when messages are rejected.
/// https://en.bitcoin.it/wiki/Protocol_specification#reject
public struct RejectMessage: Equatable {

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
  public let hash: NSData?

  public init(rejectedCommand: Message.Command, code: Code, reason: String, hash: NSData? = nil) {
    self.rejectedCommand = rejectedCommand
    self.code = code
    self.reason = reason
    self.hash = hash
  }
}

extension RejectMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Reject
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendVarString(rejectedCommand.rawValue)
    data.appendUInt8(code.rawValue)
    data.appendVarString(reason)
    if let hash = self.hash {
      data.appendData(hash)
    }
    return data
  }

  public static func fromData(data: NSData) -> RejectMessage? {
    if data.length == 0 {
      println("WARN: Empty data passed to RejectMessage \(data)")
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let rawCommand = stream.readVarString()
    if rawCommand == nil {
      println("WARN: Failed to parse rawCommand from RejectMessage \(data)")
      return nil
    }
    let command = Message.Command(rawValue: rawCommand!)
    if command == nil {
      println("WARN: Invalid command \(rawCommand!) from RejectMessage \(data)")
      return nil
    }
    let rawCode = stream.readUInt8()
    if rawCode == nil {
      println("WARN: Failed to parse rawCode from RejectMessage \(data)")
      return nil
    }
    let code = Code(rawValue: rawCode!)
    if code == nil {
      println("WARN: Invalid code \(rawCode!) from RejectMessage \(data)")
      return nil
    }
    let reason = stream.readVarString()
    if reason == nil {
      println("WARN: Failed to parse reason from RejectMessage \(data)")
      return nil
    }
    var hash: NSData? = nil
    if stream.hasBytesAvailable {
      hash = stream.readData(length: 32)
      if hash == nil {
        println("WARN: Failed to parse hash from RejectMessage \(data)")
        return nil
      }
    }
    if stream.hasBytesAvailable {
      println("WARN: Failed to parse RejectMessage. Too much data \(data)")
      return nil
    }
    return RejectMessage(rejectedCommand: command!, code: code!, reason: reason!, hash: hash)
  }
}
