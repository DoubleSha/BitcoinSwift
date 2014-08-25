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
  public enum Network: UInt32 {
    case MainNet = 0xd9b4Bef9, TestNet = 0xdab5bffa, TestNet3 = 0x0709110b
  }

  public enum Command: String {
    case Version = "version"
    case VersionAck = "verack"
    case Addr = "addr"
    case Inventory = "inv"
    // TODO: Define message structs for each of these message types.
    // In progress.
    case GetData = "getdata"
    // Not started.
    case NotFound = "notfound"
    case GetBlocks = "getblocks"
    case GetHeaders = "getheaders"
    case Transaction = "tx"
    case Block = "block"
    case Headers = "headers"
    case GetAddr = "getaddr"
    case MemPool = "mempool"
    case Ping = "ping"
    case Pong = "pong"
    case Reject = "reject"
    case FilterLoad = "filterload"
    case FilterAdd = "filteradd"
    case FilterClear = "filterclear"
    case MerkleBlock = "merkleblock"
    case Alert = "alert"

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
    self.header = Header(network:network,
                         command:command,
                         payloadLength:UInt32(payloadData.length),
                         payloadChecksum:Message.checksumForPayload(payloadData))
    self.payload = payloadData
  }

  public init(network: Network, payload: MessagePayload) {
    self.header = Header(network:network,
                         command:payload.command,
                         payloadLength:UInt32(payload.data.length),
                         payloadChecksum:Message.checksumForPayload(payload.data))
    self.payload = payload.data
  }

  public init(header: Header, payloadData: NSData) {
    self.header = header
    self.payload = payloadData
  }

  public static func fromData(data: NSData) -> Message? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data:data)
    stream.open()
    let header = Header.fromStream(stream)
    if header == nil {
      // Header.fromData() has already logged a warning for us.
      return nil
    }
    let payloadData = stream.readData()
    if payloadData == nil || payloadData!.length == 0 {
      println("WARN: Failed to parse payload in message")
      return nil
    }
    stream.close()
    return Message(header:header!, payloadData:payloadData!)
  }

  public var data: NSData {
    var bytes = NSMutableData(data:header.data)
    bytes.appendData(payload)
    return bytes
  }

  // MARK: - Private Methods

  private static func checksumForPayload(payload: NSData) -> UInt32 {
    return payload.SHA256Hash().SHA256Hash().UInt32AtIndex(0)!
  }
}
