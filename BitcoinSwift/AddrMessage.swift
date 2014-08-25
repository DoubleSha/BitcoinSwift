//
//  AddrMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/14/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public struct AddrMessage: MessagePayload {

  public let peerAddresses: [PeerAddress]

  public init(peerAddresses: [PeerAddress]) {
    assert(peerAddresses.count > 0 && peerAddresses.count <= 1000)
    self.peerAddresses = peerAddresses
  }

  // MARK: - MessagePayload

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

  public static func fromData(data: NSData) -> AddrMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data:data)
    stream.open()
    let count = stream.readVarInt()
    if count == nil {
      println("WARN: Failed to parse count from AddrMessage \(data)")
      return nil
    }
    if count! == 0 {
      println("WARN: Failed to parse AddrMessage. count is zero \(data)")
      return nil
    }
    if count! > 1000 {
      println("WARN: Failed to parse AddrMessage. count is greater than 1000 \(data)")
      return nil
    }
    var peerAddresses: [PeerAddress] = []
    for _ in 0..<count! {
      let peerAddress = stream.readPeerAddress()
      if peerAddress == nil {
        println("WARN: Failed to parse peer address from AddrMessage \(data)")
        return nil
      }
      peerAddresses.append(peerAddress!)
    }
    if stream.hasBytesAvailable {
      println("WARN: Failed to parse AddrMessage. Too many addresses \(data)")
      return nil
    }
    return AddrMessage(peerAddresses:peerAddresses)
  }
}
