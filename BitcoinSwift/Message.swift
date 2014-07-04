//
//  Message.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/23/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

protocol MessagePayload {
  var command: Message.Command { get }
  var bytes: NSData { get }
}

struct Message {

  // Magic value indicating message origin network, and used to seek to next message when stream
  // state is unknown.
  enum NetworkMagicValue: UInt32 {
    case MainNet = 0xd9b4Bef9, TestNet = 0xdab5bffa, TestNet3 = 0x0709110b
  }

  enum Command: String {

    case Version = "version", VersionAck = "verack"

    static let encodedLength = 12

    // The command string encoded into 12 bytes, null padded.
    var bytes: NSData {
      var bytes = NSMutableData(length:Command.encodedLength)
      let ASCIIStringData = self.toRaw().dataUsingEncoding(NSASCIIStringEncoding)
      bytes.replaceBytesInRange(NSRange(location:0, length:ASCIIStringData.length),
                                withBytes:ASCIIStringData.bytes)
      return bytes
    }
  }

  let networkMagicValue: NetworkMagicValue
  let command: Command
  let payload: NSData
  let payloadChecksum: UInt32

  init(networkMagicValue: NetworkMagicValue, command: Command, payloadBytes: NSData) {
    self.networkMagicValue = networkMagicValue
    self.command = command
    self.payload = payloadBytes
    self.payloadChecksum = Message.checksumForPayload(payload)
  }

  init(networkMagicValue: NetworkMagicValue, payload: MessagePayload) {
    self.networkMagicValue = networkMagicValue
    command = payload.command
    self.payload = payload.bytes
    self.payloadChecksum = Message.checksumForPayload(self.payload)
  }

  static func fromData(data: NSData) -> Message? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data:data)
    stream.open()
    let networkMagicValueRaw = stream.readUInt32()
    if !networkMagicValueRaw {
      println("WARN: Failed to parse network magic value")
      return nil
    }
    let networkMagicValue = NetworkMagicValue.fromRaw(networkMagicValueRaw!)
    if !networkMagicValue {
      println("WARN: Unsupported networkMagicValue \(networkMagicValueRaw)")
      return nil
    }
    let commandRaw = stream.readASCIIStringWithLength(Command.encodedLength)
    if !commandRaw {
      println("WARN: Failed to parse command")
      return nil
    }
    let command = Command.fromRaw(commandRaw!)
    if !command {
      println("WARN: Unsupported command \(commandRaw!)")
      return nil
    }
    let length = stream.readUInt32()
    if !length {
      println("WARN: Failed to parse length")
      return nil
    }
    let checksum = stream.readUInt32()
    if !checksum {
      println("WARN: Failed to parse checksum")
      return nil
    }
    let payloadBytes = stream.readData()
    if !payloadBytes || payloadBytes!.length == 0 {
      println("WARN: Failed to parse payload")
      return nil
    }
    stream.close()
    return Message(networkMagicValue:networkMagicValue!,
                   command:command!,
                   payloadBytes:payloadBytes!)
  }

  var bytes: NSData {
    var bytes = NSMutableData()
    bytes.appendUInt32(networkMagicValue.toRaw())
    bytes.appendData(command.bytes)
    bytes.appendUInt32(UInt32(payload.length))
    bytes.appendUInt32(payloadChecksum)
    bytes.appendData(payload)
    return bytes
  }

  static func checksumForPayload(payload: NSData) -> UInt32 {
    return payload.SHA256Hash().SHA256Hash().UInt32AtIndex(0)!
  }
}
