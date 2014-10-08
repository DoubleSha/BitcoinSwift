//
//  MessageHeader.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/24/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: Message.Header, rhs: Message.Header) -> Bool {
  return lhs.network == rhs.network &&
      lhs.command == rhs.command &&
      lhs.payloadLength == rhs.payloadLength &&
      lhs.payloadChecksum == rhs.payloadChecksum
}

extension Message {

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

    public static func fromData(data: NSData) -> Header? {
      return Header.fromStream(NSInputStream(data: data))
    }

    public static func fromStream(stream: NSInputStream) -> Header? {
      if stream.streamStatus != .Open {
        stream.open()
      }
      let networkRaw = stream.readUInt32()
      if networkRaw == nil {
        println("WARN: Failed to parse network magic value in message header")
        return nil
      }
      let network = Network(rawValue: networkRaw!)
      if network == nil {
        println("WARN: Unsupported network \(networkRaw!) in message header")
        return nil
      }
      let commandRaw = stream.readASCIIStringWithLength(Command.encodedLength)
      if commandRaw == nil {
        println("WARN: Failed to parse command in message header")
        return nil
      }
      let command = Command(rawValue: commandRaw!)
      if command == nil {
        println("WARN: Unsupported command \(commandRaw!) in message header")
        return nil
      }
      let payloadLength = stream.readUInt32()
      if payloadLength == nil {
        println("WARN: Failed to parse size in message header")
        return nil
      }
      let payloadChecksum = stream.readUInt32()
      if payloadChecksum == nil {
        println("WARN: Failed to parse payload checksum in message header")
        return nil
      }
      return Header(network: network!,
                    command: command!,
                    payloadLength: payloadLength!,
                    payloadChecksum: payloadChecksum!)
    }

    public var data: NSData {
      var bytes = NSMutableData()
      bytes.appendUInt32(network.rawValue)
      bytes.appendData(command.data)
      bytes.appendUInt32(payloadLength)
      bytes.appendUInt32(payloadChecksum)
      return bytes
    }
  }
}
