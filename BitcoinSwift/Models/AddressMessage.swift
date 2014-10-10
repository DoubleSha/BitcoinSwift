//
//  AddressMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/14/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: AddressMessage, rhs: AddressMessage) -> Bool {
  return lhs.peerAddresses == rhs.peerAddresses
}

/// Message payload object corresponding to the Message.Command.Addr command. Provides information
/// on known nodes of the network.
/// https://en.bitcoin.it/wiki/Protocol_specification#addr
public struct AddressMessage: Equatable {

  public let peerAddresses: [PeerAddress]

  public init(peerAddresses: [PeerAddress]) {
    assert(peerAddresses.count > 0 && peerAddresses.count <= 1000)
    self.peerAddresses = peerAddresses
  }
}

extension AddressMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Addr
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendVarInt(peerAddresses.count)
    for peerAddress in peerAddresses {
      data.appendPeerAddress(peerAddress)
    }
    return data
  }

  public static func fromData(data: NSData) -> AddressMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let count = stream.readVarInt()
    if count == nil {
      Logger.warn("Failed to parse count from AddressMessage \(data)")
      return nil
    }
    if count! == 0 {
      Logger.warn("Failed to parse AddressMessage. count is zero \(data)")
      return nil
    }
    if count! > 1000 {
      Logger.warn("Failed to parse AddressMessage. count is greater than 1000 \(data)")
      return nil
    }
    var peerAddresses: [PeerAddress] = []
    for _ in 0..<count! {
      let peerAddress = stream.readPeerAddress()
      if peerAddress == nil {
        Logger.warn("Failed to parse peer address from AddressMessage \(data)")
        return nil
      }
      peerAddresses.append(peerAddress!)
    }
    if stream.hasBytesAvailable {
      Logger.warn("Failed to parse AddressMessage. Too many addresses \(data)")
      return nil
    }
    return AddressMessage(peerAddresses: peerAddresses)
  }
}
