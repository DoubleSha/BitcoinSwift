//
//  PongMessage.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: PongMessage, rhs: PongMessage) -> Bool {
  return lhs.nonce == rhs.nonce
}

/// The pong message is sent in response to a ping message, generated using a nonce included in the 
/// ping.
/// https://en.bitcoin.it/wiki/Protocol_specification#pong
public struct PongMessage: Equatable {

  public var nonce: UInt64

  public init(nonce: UInt64) {
    self.nonce = nonce
  }
}

extension PongMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Pong
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendUInt64(nonce)
    return data
  }

  public static func fromData(data: NSData) -> PongMessage? {
    if data.length == 0 {
      Logger.warn("No data passed to PongMessage \(data)")
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let nonce = stream.readUInt64()
    if nonce == nil {
      Logger.warn("Failed to parse nonce from PingMessage \(data)")
      return nil
    }
    if stream.hasBytesAvailable {
      Logger.warn("Failed to parse PingMessage. Too much data \(data)")
      return nil
    }
    return PongMessage(nonce: nonce!)
  }
}
