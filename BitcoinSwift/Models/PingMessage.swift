//
//  PingMessage.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: PingMessage, right: PingMessage) -> Bool {
  return left.nonce == right.nonce
}

/// The ping message is sent primarily to confirm that the TCP/IP connection is still valid. An
/// error in transmission is presumed to be a closed connection and the address is removed as a
/// current peer.
/// https://en.bitcoin.it/wiki/Protocol_specification#ping
public struct PingMessage: Equatable {

  public var nonce: UInt64

  public init(nonce: UInt64? = nil) {
    if let nonce = nonce {
      self.nonce = nonce
    } else {
      self.nonce = UInt64(arc4random()) | (UInt64(arc4random()) << 32)
    }
  }
}

extension PingMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Ping
  }

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendUInt64(nonce)
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> PingMessage? {
    let nonce = stream.readUInt64()
    if nonce == nil {
      Logger.warn("Failed to parse nonce from PingMessage")
      return nil
    }
    return PingMessage(nonce: nonce)
  }
}
