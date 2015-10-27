//
//  HeadersMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/15/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: HeadersMessage, right: HeadersMessage) -> Bool {
  return left.headers == right.headers
}

public struct HeadersMessage: Equatable {

  public let headers: [BlockHeader]

  public init(headers: [BlockHeader]) {
    self.headers = headers
  }
}

/// The headers message returns block headers in response to a getheaders message.
/// https://en.bitcoin.it/wiki/Protocol_specification#headers
extension HeadersMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Headers
  }

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendVarInt(headers.count)
    for header in headers {
      data.appendData(header.bitcoinData)
    }
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> HeadersMessage? {
    let count = stream.readVarInt()
    if count == nil {
      Logger.warn("Failed to parse count from HeadersMessage")
      return nil
    }
    if count! == 0 {
      Logger.warn("Failed to parse HeadersMessage. Count is zero")
      return nil
    }
    var headers: [BlockHeader] = []
    for i in 0..<count! {
      let header = BlockHeader.fromBitcoinStream(stream)
      if header == nil {
        Logger.warn("Failed to parse header \(i) from HeadersMessage")
        return nil
      }
      // There is a transaction count at the end of each header. It should always be 0.
      let transactionCount = stream.readVarInt()
      if transactionCount == nil {
        Logger.warn("Failed to parse transactionCount for header \(i) from HeadersMessage")
        return nil
      }
      if transactionCount! != 0 {
        Logger.warn("Invalid transactionCount \(transactionCount!) for header \(i) from " +
            "HeadersMessage")
        return nil
      }
      headers.append(header!)
    }
    return HeadersMessage(headers: headers)
  }
}
