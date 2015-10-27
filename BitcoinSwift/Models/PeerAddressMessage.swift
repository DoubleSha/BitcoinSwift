//
//  PeerAddressMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/14/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: PeerAddressMessage, right: PeerAddressMessage) -> Bool {
  return left.peerAddresses == right.peerAddresses
}

/// Message payload object corresponding to the Message.Command.Address command.
/// Provides information on known nodes of the network.
/// https://en.bitcoin.it/wiki/Protocol_specification#addr
public struct PeerAddressMessage: Equatable {

  public let peerAddresses: [PeerAddress]

  public init(peerAddresses: [PeerAddress]) {
    assert(peerAddresses.count > 0 && peerAddresses.count <= 1000)
    self.peerAddresses = peerAddresses
  }
}

extension PeerAddressMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Address
  }

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendVarInt(peerAddresses.count)
    for peerAddress in peerAddresses {
      data.appendData(peerAddress.bitcoinData)
    }
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> PeerAddressMessage? {
    let count = stream.readVarInt()
    if count == nil {
      Logger.warn("Failed to parse count from PeerAddressMessage")
      return nil
    }
    if count! == 0 {
      Logger.warn("Failed to parse PeerAddressMessage. count is zero")
      return nil
    }
    if count! > 1000 {
      Logger.warn("Failed to parse PeerAddressMessage. count is greater than 1000")
      return nil
    }
    var peerAddresses: [PeerAddress] = []
    for _ in 0..<count! {
      let peerAddress = PeerAddress.fromBitcoinStream(stream)
      if peerAddress == nil {
        Logger.warn("Failed to parse peer address from PeerAddressMessage")
        return nil
      }
      peerAddresses.append(peerAddress!)
    }
    return PeerAddressMessage(peerAddresses: peerAddresses)
  }
}
