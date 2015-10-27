//
//  RejectMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/4/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: RejectMessage, right: RejectMessage) -> Bool {
  return left.rejectedCommand == right.rejectedCommand &&
      left.code == right.code &&
      left.reason == right.reason &&
      left.hash == right.hash
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
  public let hash: SHA256Hash?

  public init(rejectedCommand: Message.Command,
              code: Code,
              reason: String,
              hash: SHA256Hash? = nil) {
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

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendVarString(rejectedCommand.rawValue)
    data.appendUInt8(code.rawValue)
    data.appendVarString(reason)
    if let hash = self.hash {
      data.appendData(hash.bitcoinData)
    }
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> RejectMessage? {
    let rawCommand = stream.readVarString()
    if rawCommand == nil {
      print("WARN: Failed to parse rawCommand from RejectMessage")
      return nil
    }
    let command = Message.Command(rawValue: rawCommand!)
    if command == nil {
      print("WARN: Invalid command \(rawCommand!) from RejectMessage")
      return nil
    }
    let rawCode = stream.readUInt8()
    if rawCode == nil {
      print("WARN: Failed to parse rawCode from RejectMessage")
      return nil
    }
    let code = Code(rawValue: rawCode!)
    if code == nil {
      print("WARN: Invalid code \(rawCode!) from RejectMessage")
      return nil
    }
    let reason = stream.readVarString()
    if reason == nil {
      print("WARN: Failed to parse reason from RejectMessage")
      return nil
    }
    var hash: SHA256Hash? = nil
    if stream.hasBytesAvailable {
      hash = SHA256Hash.fromBitcoinStream(stream)
      if hash == nil {
        print("WARN: Failed to parse hash from RejectMessage")
        return nil
      }
    }
    return RejectMessage(rejectedCommand: command!, code: code!, reason: reason!, hash: hash)
  }
}
