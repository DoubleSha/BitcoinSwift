//
//  VersionAckMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/3/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public struct VersionAckMessage: MessagePayload {

  // MARK: - MessagePayload

  public var command: Message.Command {
    return Message.Command.VersionAck
  }

  public var data: NSData {
    return NSData(bytes:[0] as [UInt8], length:1)
  }

  public static func fromData(data: NSData) -> VersionAckMessage?  {
    return nil
  }
}
