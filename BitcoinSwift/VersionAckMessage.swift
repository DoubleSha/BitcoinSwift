//
//  VersionAckMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/31/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

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
