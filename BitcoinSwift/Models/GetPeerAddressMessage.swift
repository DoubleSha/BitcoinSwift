//
//  GetPeerAddressMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/12/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// The getaddr message sends a request to a node asking for information about known active peers to
/// help with finding potential nodes in the network. The response to receiving this message is to
/// transmit one or more addr messages with one or more peers from a database of known active peers.
/// https://en.bitcoin.it/wiki/Protocol_specification#getaddr
public struct GetPeerAddressMessage: MessagePayload {

  // Swift's default struct initializers are marked as internal
  // See: http://stackoverflow.com/a/27635674/1470317
  public init()
  {}
  
  public var command: Message.Command {
    return Message.Command.GetAddress
  }

  public var bitcoinData: NSData {
    // A getaddr message has no payload.
    return NSData()
  }

  public static func fromBitcoinStream(stream: NSInputStream) ->GetPeerAddressMessage? {
    // A getaddr message has no payload.
    return GetPeerAddressMessage()
  }
}
