//
//  PongMessage.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// The pong message is sent in response to a ping message, generated using a nonce included in the 
/// ping.
/// https://en.bitcoin.it/wiki/Protocol_specification#pong
public struct PongMessage: MessagePayload {

  public var nonce: UInt64

  public init(nonce: UInt64) {
    self.nonce = nonce
  }

  // MARK: - MessagePayload

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
      println("WARN: No data passed to PongMessage \(data)")
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let nonce = stream.readUInt64()
    if nonce == nil {
      println("WARN: Failed to parse nonce from PingMessage \(data)")
      return nil
    }
    if stream.hasBytesAvailable {
      println("WARN: Failed to parse PingMessage. Too much data \(data)")
      return nil
    }
    return PongMessage(nonce: nonce!)
  }
}
