//
//  Message.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/23/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// A MessagePayload can be any of the supported message types defined in the Message.Command enum.
/// Implement the data and fromData methods to serialize/deserialize the payload from the Bitcoin
/// P2P wire format.
public protocol MessagePayload: BitcoinSerializable {
  var command: Message.Command { get }
}

public func ==(left: Message, right: Message) -> Bool {
  return left.header == right.header && left.payload == right.payload
}

/// Wrapper struct that contains the header and payload for sending a message.
/// Use this to serialize/deserialize messages to/from the Bitcoin P2P wire format.
/// https://en.bitcoin.it/wiki/Protocol_specification#Message_structure
public struct Message: Equatable {

  /// Magic value indicating message origin network, and used to seek to next message when stream
  /// state is unknown.
  public enum Network: UInt32 {
    case MainNet = 0xd9b4Bef9, TestNet = 0xdab5bffa, TestNet3 = 0x0709110b

    public var magicBytes: [UInt8] {
      let data = NSMutableData()
      data.appendUInt32(rawValue)
      return data.UInt8Array
    }
  }

  /// Indicates what command this message corresponds to.
  /// Available commands are defined in the spec here: 
  /// https://en.bitcoin.it/wiki/Protocol_specification#Message_types
  public enum Command: String {

    case Version = "version"
    case VersionAck = "verack"
    case Address = "addr"
    case Inventory = "inv"
    case GetData = "getdata"
    case NotFound = "notfound"
    case GetBlocks = "getblocks"
    case GetHeaders = "getheaders"
    case Transaction = "tx"
    case Block = "block"
    case Headers = "headers"
    case GetAddress = "getaddr"
    case MemPool = "mempool"
    case Ping = "ping"
    case Pong = "pong"
    case Reject = "reject"
    case FilterLoad = "filterload"
    case FilterAdd = "filteradd"
    case FilterClear = "filterclear"
    case FilteredBlock = "merkleblock"
    case Alert = "alert"

    /// The length of the command string when encoded into ascii format for wire-transmission.
    /// It is padded with 0's if shorter than this length.
    public static let encodedLength = 12

    /// The command string encoded into 12 bytes, null padded.
    public var data: NSData {
      let data = NSMutableData(length: Command.encodedLength)!
      let ASCIIStringData = rawValue.dataUsingEncoding(NSASCIIStringEncoding)!
      data.replaceBytesInRange(NSRange(location: 0, length: ASCIIStringData.length),
                               withBytes: ASCIIStringData.bytes)
      return data
    }
  }

  public let header: Header
  public let payload: NSData

  public var network: Network {
    return header.network
  }
  public var command: Command {
    return header.command
  }
  public var payloadChecksum: UInt32 {
    return header.payloadChecksum
  }

  public init(network: Network, command: Command, payloadData: NSData) {
    self.header = Header(network: network,
                         command: command,
                         payloadLength: UInt32(payloadData.length),
                         payloadChecksum: Message.checksumForPayload(payloadData))
    self.payload = payloadData
  }

  public init(network: Network, payload: MessagePayload) {
    self.header = Header(network: network,
                         command: payload.command,
                         payloadLength: UInt32(payload.bitcoinData.length),
                         payloadChecksum: Message.checksumForPayload(payload.bitcoinData))
    self.payload = payload.bitcoinData
  }

  public init(header: Header, payloadData: NSData) {
    self.header = header
    self.payload = payloadData
  }

  public func isChecksumValid() -> Bool {
    return payloadChecksum == Message.checksumForPayload(payload)
  }

  // MARK: - Private Methods

  private static func checksumForPayload(payload: NSData) -> UInt32 {
    return payload.SHA256Hash().SHA256Hash().UInt32AtIndex(0)!
  }
}

extension Message: BitcoinSerializable {

  public var bitcoinData: NSData {
    let bytes = NSMutableData(data: header.bitcoinData)
    bytes.appendData(payload)
    return bytes
  }

  /// Does not parse the payload data into its corresponding payload type. Use the corresponding
  /// struct that conforms to the MessagePayload protocol to parse the payload.
  public static func fromBitcoinStream(stream: NSInputStream) -> Message? {
    let header = Header.fromBitcoinStream(stream)
    if header == nil {
      // Header.fromBitcoinStream() has already logged a warning for us.
      return nil
    }
    let payloadData = stream.readData()
    if payloadData == nil || payloadData!.length == 0 {
      Logger.warn("Failed to parse payload in message")
      return nil
    }
    return Message(header: header!, payloadData: payloadData!)
  }
}
