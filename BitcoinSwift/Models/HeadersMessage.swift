//
//  HeadersMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/15/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: HeadersMessage, rhs: HeadersMessage) -> Bool {
  return lhs.headers == rhs.headers
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

  public var data: NSData {
    var data = NSMutableData()
    data.appendVarInt(headers.count)
    for header in headers {
      data.appendData(header.data)
    }
    return data
  }

  public static func fromData(data: NSData) -> HeadersMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let count = stream.readVarInt()
    if count == nil {
      Logger.warn("Failed to parse count from HeadersMessage \(data)")
      return nil
    }
    if count! == 0 {
      Logger.warn("Failed to parse HeadersMessage. Count is zero \(data)")
      return nil
    }
    var headers: [BlockHeader] = []
    for i in 0..<count! {
      let header = BlockHeader.fromStream(stream)
      if header == nil {
        Logger.warn("Failed to parse header \(i) from HeadersMessage \(data)")
        return nil
      }
      headers.append(header!)
    }
    if stream.hasBytesAvailable {
      Logger.warn("Failed to parse HeadersMessage. Too much data \(data)")
      return nil
    }
    return HeadersMessage(headers: headers)
  }
}
