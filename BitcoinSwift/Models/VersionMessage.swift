//
//  VersionMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/3/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: VersionMessage, right: VersionMessage) -> Bool {
  return left.protocolVersion == right.protocolVersion &&
      left.services == right.services &&
      left.date == right.date &&
      left.senderAddress == right.senderAddress &&
      left.receiverAddress == right.receiverAddress &&
      left.nonce == right.nonce &&
      left.userAgent == right.userAgent &&
      left.blockStartHeight == right.blockStartHeight &&
      left.announceRelayedTransactions == right.announceRelayedTransactions
}

/// Message payload object corresponding to the Message.Command.Version command. When a node creates
/// an outgoing connection, it will immediately advertise its version with this message and the
/// remote node will respond with its version. No further communication is possible until both peers
/// have exchanged their version.
/// https://en.bitcoin.it/wiki/Protocol_specification#version
public struct VersionMessage: Equatable {

  public let protocolVersion: UInt32
  public let services: PeerServices
  public let date: NSDate
  public let senderAddress: PeerAddress
  public let receiverAddress: PeerAddress
  public let nonce: UInt64
  public let userAgent: String
  public let blockStartHeight: Int32
  public let announceRelayedTransactions: Bool

  public init(protocolVersion: UInt32,
              services: PeerServices,
              date: NSDate,
              senderAddress: PeerAddress,
              receiverAddress: PeerAddress,
              nonce: UInt64,
              userAgent: String,
              blockStartHeight: Int32,
              announceRelayedTransactions: Bool) {
    self.protocolVersion = protocolVersion
    self.services = services
    self.date = date
    self.senderAddress = senderAddress
    self.receiverAddress = receiverAddress
    self.nonce = nonce
    self.userAgent = userAgent
    self.blockStartHeight = blockStartHeight
    self.announceRelayedTransactions = announceRelayedTransactions
  }
}

extension VersionMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Version
  }

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendUInt32(protocolVersion)
    data.appendUInt64(services.rawValue)
    data.appendDateAs64BitUnixTimestamp(date)
    data.appendData(receiverAddress.bitcoinDataWithTimestamp(false))
    data.appendData(senderAddress.bitcoinDataWithTimestamp(false))
    data.appendUInt64(nonce)
    data.appendVarString(userAgent)
    data.appendInt32(blockStartHeight)
    data.appendBool(announceRelayedTransactions)
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> VersionMessage? {
    let protocolVersion = stream.readUInt32()
    if protocolVersion == nil {
      Logger.warn("Failed to parse protocolVersion from VersionMessage")
      return nil
    }
    let servicesRaw = stream.readUInt64()
    if servicesRaw == nil {
      Logger.warn("Failed to parse servicesRaw from VersionMessage")
      return nil
    }
    let services = PeerServices(rawValue: servicesRaw!)
    let timestamp = stream.readInt64()
    if timestamp == nil {
      Logger.warn("Failed to parse timestamp from VersionMessage")
      return nil
    }
    let date = NSDate(timeIntervalSince1970: NSTimeInterval(timestamp!))
    let receiverAddress = PeerAddress.fromBitcoinStream(stream, includeTimestamp: false)
    if receiverAddress == nil {
      Logger.warn("Failed to parse receiverAddress from VersionMessage")
      return nil
    }
    let senderAddress = PeerAddress.fromBitcoinStream(stream, includeTimestamp: false)
    if senderAddress == nil {
      Logger.warn("Failed to parse senderAddress from VersionMessage")
      return nil
    }
    let nonce = stream.readUInt64()
    if nonce == nil {
      Logger.warn("Failed to parse nonce from VersionMessage")
      return nil
    }
    let userAgent = stream.readVarString()
    if userAgent == nil {
      Logger.warn("Failed to parse userAgent from VersionMessage")
      return nil
    }
    let blockStartHeight = stream.readInt32()
    if blockStartHeight == nil {
      Logger.warn("Failed to parse blockStartHeight from VersionMessage")
      return nil
    }
    let announceRelayedTransactions = stream.readBool()
    if announceRelayedTransactions == nil {
      Logger.warn("Failed to parse announceRelayedTransactions from VersionMessage")
      return nil
    }
    return VersionMessage(protocolVersion: protocolVersion!,
                          services: services,
                          date: date,
                          senderAddress: senderAddress!,
                          receiverAddress: receiverAddress!,
                          nonce: nonce!,
                          userAgent: userAgent!,
                          blockStartHeight: blockStartHeight!,
                          announceRelayedTransactions: announceRelayedTransactions!)
  }
}
