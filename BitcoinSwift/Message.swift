//
//  Message.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/23/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

struct VersionMessage: MessagePayload {

  // MARK: - MessagePayload

  var command: Message.Command {
    return Message.Command.Version
  }

  var bytes: NSData {
    return NSData(bytes:[0] as UInt8[], length:1)
  }
}

struct VersionAckMessage: MessagePayload {

  // MARK: - MessagePayload

  var command: Message.Command {
    return Message.Command.VersionAck
  }

  var bytes: NSData {
    return NSData(bytes:[0] as UInt8[], length:1)
  }
}

protocol MessagePayload {
  var command: Message.Command { get }
  var bytes: NSData { get }
}

struct Message {

  enum Command: String {

    case Version = "ver", VersionAck = "verack"

    static let encodedLength = 12

    var bytes: NSData {
      var bytes = NSMutableData(length:Command.encodedLength)
      let ASCIIString = self.toRaw().dataUsingEncoding(NSASCIIStringEncoding)
      bytes.replaceBytesInRange(NSRange(location:0, length:ASCIIString.length),
                                withBytes:ASCIIString.bytes)
      return bytes
    }

    static func fromString(string: String) -> Command? {
      switch string {
        case Command.Version.toRaw():
          return Command.Version
        case Command.VersionAck.toRaw():
          return Command.VersionAck
        default:
          return nil
      }
    }
  }

  // Magic value indicating message origin network, and used to seek to next message when stream
  // state is unknown.
  let networkMagicValue: UInt32
  let command: Command
  let payload: NSData
  var payloadChecksum: UInt32 {
    return payload.SHA256Hash().SHA256Hash().UInt32AtIndex(0)
  }

  init(networkMagicValue: UInt32, command: Command, payload: NSData) {
    self.networkMagicValue = networkMagicValue
    self.command = command
    self.payload = payload
  }

  init(networkMagicValue: UInt32, payload: MessagePayload) {
    self.networkMagicValue = networkMagicValue
    command = payload.command
    self.payload = payload.bytes
  }

  func parseFromData(data: NSData) -> Message? {
    let stream = NSInputStream(data:bytes)
    let networkMagicValue = stream.readUInt32()
    if !networkMagicValue {
      println("WARN: Failed to parse network magic value")
      return nil
    }
    let commandString = stream.readASCIIStringWithLength(Command.encodedLength)
    if !commandString {
      println("WARN: Failed to parse command")
      return nil
    }
    let command = Command.fromRaw(commandString!)
    if !command {
      println("WARN: Unsupported command \(commandString!)")
      return nil
    }
    let payload = stream.readRemainingBytes()
    return Message(networkMagicValue:networkMagicValue!,
                   command:command!,
                   payload:payload)
  }

  var bytes: NSData {
    var bytes = NSMutableData()
    bytes.appendUInt32(networkMagicValue)
    bytes.appendData(command.bytes)
    bytes.appendUInt32(UInt32(payload.length))
    bytes.appendUInt32(payloadChecksum)
    bytes.appendData(payload)
    return bytes
  }
}
