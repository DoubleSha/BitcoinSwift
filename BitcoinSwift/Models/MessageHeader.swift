//
//  MessageHeader.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/24/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: Message.Header, right: Message.Header) -> Bool {
  return left.network == right.network &&
      left.command == right.command &&
      left.payloadLength == right.payloadLength &&
      left.payloadChecksum == right.payloadChecksum
}

extension Message {

  /// Metadata about the message.
  /// https://en.bitcoin.it/wiki/Protocol_specification#Message_structure
  public struct Header: Equatable {

    public let network: Network
    public let command: Command
    public let payloadLength: UInt32
    public let payloadChecksum: UInt32

    // Network (4 bytes) + Command (12 bytes) + payloadLength (4 bytes) + payloadChecksum (4 bytes).
    public static let length = 24

    public init(network: Network,
                command: Command,
                payloadLength: UInt32,
                payloadChecksum: UInt32) {
      self.network = network
      self.command = command
      self.payloadLength = payloadLength
      self.payloadChecksum = payloadChecksum
    }
  }
}

extension Message.Header: BitcoinSerializable {

  public var bitcoinData: NSData {
    let bytes = NSMutableData()
    bytes.appendUInt32(network.rawValue)
    bytes.appendData(command.data)
    bytes.appendUInt32(payloadLength)
    bytes.appendUInt32(payloadChecksum)
    return bytes
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> Message.Header? {
    let networkRaw = stream.readUInt32()
    if networkRaw == nil {
      Logger.warn("Failed to parse network magic value in message header")
      return nil
    }
    let network = Message.Network(rawValue: networkRaw!)
    if network == nil {
      Logger.warn("Unsupported network \(networkRaw!) in message header")
      return nil
    }
    let commandRaw = stream.readASCIIStringWithLength(Message.Command.encodedLength)
    if commandRaw == nil {
      Logger.warn("Failed to parse command in message header")
      return nil
    }
    let command = Message.Command(rawValue: commandRaw!)
    if command == nil {
      Logger.warn("Unsupported command \(commandRaw!) in message header")
      return nil
    }
    let payloadLength = stream.readUInt32()
    if payloadLength == nil {
      Logger.warn("Failed to parse size in message header")
      return nil
    }
    let payloadChecksum = stream.readUInt32()
    if payloadChecksum == nil {
      Logger.warn("Failed to parse payload checksum in message header")
      return nil
    }
    return Message.Header(network: network!,
      command: command!,
      payloadLength: payloadLength!,
      payloadChecksum: payloadChecksum!)
  }
}

