//
//  NotFoundMessage.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: NotFoundMessage, rhs: NotFoundMessage) -> Bool {
  return lhs.inventoryVectors == rhs.inventoryVectors
}

/// Message payload object corresponding to the Message.Command.NotFound command. Is a response to 
/// getdata, sent if any requested data items could not be relayed. For example, the requested
/// transaction may not be in the memory pool or relay set.
/// https://en.bitcoin.it/wiki/Protocol_specification#notfound
public struct NotFoundMessage: Equatable {

  public let inventoryVectors: [InventoryVector]

  public init(inventoryVectors: [InventoryVector]) {
    precondition(inventoryVectors.count > 0 && inventoryVectors.count <= 50000)
    self.inventoryVectors = inventoryVectors
  }
}

extension NotFoundMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.NotFound
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendVarInt(inventoryVectors.count)
    for inventoryVector in inventoryVectors {
      data.appendInventoryVector(inventoryVector)
    }
    return data
  }

  public static func fromData(data: NSData) -> NotFoundMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let inventoryCount = stream.readVarInt()
    if inventoryCount == nil {
      Logger.warn("Failed to parse count from NotFoundMessage \(data)")
      return nil
    }
    if inventoryCount! == 0 {
      Logger.warn("Failed to parse NotFoundMessage. Count is zero \(data)")
      return nil
    }
    if inventoryCount! > 50000 {
      Logger.warn("Failed to parse NotFoundMessage. Count is greater than 50000 \(data)")
      return nil
    }
    var inventoryVectors: [InventoryVector] = []
    for _ in 0..<inventoryCount! {
      let inventoryVector = stream.readInventoryVector()
      if inventoryVector == nil {
        Logger.warn("Failed to parse inventory vector from NotFoundMessage \(data)")
        return nil
      }
      inventoryVectors.append(inventoryVector!)
    }
    if stream.hasBytesAvailable {
      Logger.warn("Failed to parse NotFoundMessage. Too many vectors \(data)")
      return nil
    }
    return NotFoundMessage(inventoryVectors: inventoryVectors)
  }
}
