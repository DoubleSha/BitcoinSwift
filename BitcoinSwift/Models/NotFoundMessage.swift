//
//  NotFoundMessage.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: NotFoundMessage, right: NotFoundMessage) -> Bool {
  return left.inventoryVectors == right.inventoryVectors
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

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendVarInt(inventoryVectors.count)
    for inventoryVector in inventoryVectors {
      data.appendData(inventoryVector.bitcoinData)
    }
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> NotFoundMessage? {
    let inventoryCount = stream.readVarInt()
    if inventoryCount == nil {
      Logger.warn("Failed to parse count from NotFoundMessage")
      return nil
    }
    if inventoryCount! == 0 {
      Logger.warn("Failed to parse NotFoundMessage. Count is zero")
      return nil
    }
    if inventoryCount! > 50000 {
      Logger.warn("Failed to parse NotFoundMessage. Count is greater than 50000")
      return nil
    }
    var inventoryVectors: [InventoryVector] = []
    for _ in 0..<inventoryCount! {
      let inventoryVector = InventoryVector.fromBitcoinStream(stream)
      if inventoryVector == nil {
        Logger.warn("Failed to parse inventory vector from NotFoundMessage")
        return nil
      }
      inventoryVectors.append(inventoryVector!)
    }
    return NotFoundMessage(inventoryVectors: inventoryVectors)
  }
}
