//
//  Message.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/23/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public protocol MessagePayload {
  var command: Message.Command { get }
  var data: NSData { get }
  class func fromData(data: NSData) -> Self?
}

public struct Message {

  // Magic value indicating message origin network, and used to seek to next message when stream
  // state is unknown.
  public enum NetworkMagicValue: UInt32 {
    case MainNet = 0xd9b4Bef9, TestNet = 0xdab5bffa, TestNet3 = 0x0709110b
  }

  public enum Command: String {
    case Version = "version", VersionAck = "verack", Addr = "addr"

    public static let encodedLength = 12

    // The command string encoded into 12 bytes, null padded.
    public var data: NSData {
      var data = NSMutableData(length:Command.encodedLength)
      let ASCIIStringData = self.toRaw().dataUsingEncoding(NSASCIIStringEncoding)!
      data.replaceBytesInRange(NSRange(location:0, length:ASCIIStringData.length),
                               withBytes:ASCIIStringData.bytes)
      return data
    }
  }

  public let networkMagicValue: NetworkMagicValue
  public let command: Command
  public let payload: NSData
  public let payloadChecksum: UInt32

  public init(networkMagicValue: NetworkMagicValue, command: Command, payloadData: NSData) {
    self.networkMagicValue = networkMagicValue
    self.command = command
    self.payload = payloadData
    self.payloadChecksum = Message.checksumForPayload(payload)
  }

  public init(networkMagicValue: NetworkMagicValue, payload: MessagePayload) {
    self.networkMagicValue = networkMagicValue
    command = payload.command
    self.payload = payload.data
    self.payloadChecksum = Message.checksumForPayload(self.payload)
  }

  public static func fromData(data: NSData) -> Message? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data:data)
    stream.open()
    let networkMagicValueRaw = stream.readUInt32()
    if networkMagicValueRaw == nil {
      println("WARN: Failed to parse network magic value")
      return nil
    }
    let networkMagicValue = NetworkMagicValue.fromRaw(networkMagicValueRaw!)
    if networkMagicValue == nil {
      println("WARN: Unsupported networkMagicValue \(networkMagicValueRaw)")
      return nil
    }
    let commandRaw = stream.readASCIIStringWithLength(Command.encodedLength)
    if commandRaw == nil {
      println("WARN: Failed to parse command")
      return nil
    }
    let command = Command.fromRaw(commandRaw!)
    if command == nil {
      println("WARN: Unsupported command \(commandRaw!)")
      return nil
    }
    let length = stream.readUInt32()
    if length == nil {
      println("WARN: Failed to parse length")
      return nil
    }
    let checksum = stream.readUInt32()
    if checksum == nil {
      println("WARN: Failed to parse checksum")
      return nil
    }
    let payloadData = stream.readData()
    if payloadData == nil || payloadData!.length == 0 {
      println("WARN: Failed to parse payload")
      return nil
    }
    stream.close()
    return Message(networkMagicValue:networkMagicValue!,
                   command:command!,
                   payloadData:payloadData!)
  }

  public var data: NSData {
    var bytes = NSMutableData()
    bytes.appendUInt32(networkMagicValue.toRaw())
    bytes.appendData(command.data)
    bytes.appendUInt32(UInt32(payload.length))
    bytes.appendUInt32(payloadChecksum)
    bytes.appendData(payload)
    return bytes
  }

  // MARK: - Private Methods

  private static func checksumForPayload(payload: NSData) -> UInt32 {
    return payload.SHA256Hash().SHA256Hash().UInt32AtIndex(0)!
  }
}
