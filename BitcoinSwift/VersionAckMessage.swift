//
//  VersionAckMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/31/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//
//  The verack message is sent in reply to version. This message consists of only a message header 
//  with the command string "verack".
//
//  https://en.bitcoin.it/wiki/Protocol_specification#verack
//

import Foundation

/// Message of type 'verack' (VersionAck). This message is sent in reply to 'version' (Version).
/// This message consists of only a message header with the command string "verack".
public struct VersionAckMessage: MessagePayload {

  // MARK: - MessagePayload

  public var command: Message.Command {
    return Message.Command.VersionAck
  }

  public var data: NSData {
    // A verack message has no payload.
    return NSData()
  }

  public static func fromData(data: NSData) -> VersionAckMessage? {
    // A verack message has no payload.
    if data.length != 0 {
      return nil
    }
    return VersionAckMessage()
  }
}
