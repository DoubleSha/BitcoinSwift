//
//  VersionAckMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/3/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

struct VersionAckMessage: MessagePayload {

  // MARK: - MessagePayload

  var command: Message.Command {
    return Message.Command.VersionAck
  }

  var data: NSData {
    return NSData(bytes:[0] as UInt8[], length:1)
  }
}
