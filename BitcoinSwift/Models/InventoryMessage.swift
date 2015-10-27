//
//  InventoryMessage.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 8/23/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: InventoryMessage, right: InventoryMessage) -> Bool {
  return left.inventoryVectors == right.inventoryVectors
}

/// Message payload object corresponding to the Message.Command.Inventory command. Allows a node to
/// advertise its knowledge of one or more objects. It can be received unsolicited, or in reply to
/// getblocks.
/// https://en.bitcoin.it/wiki/Protocol_specification#inv
public struct InventoryMessage: Equatable {

  public let inventoryVectors: [InventoryVector]

  public init(inventoryVectors: [InventoryVector]) {
    precondition(inventoryVectors.count > 0 && inventoryVectors.count <= 50000)
    self.inventoryVectors = inventoryVectors
  }
}

extension InventoryMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Inventory
  }

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendVarInt(inventoryVectors.count)
    for inventoryVector in inventoryVectors {
      data.appendData(inventoryVector.bitcoinData)
    }
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> InventoryMessage? {
    let inventoryCount = stream.readVarInt()
    if inventoryCount == nil {
      Logger.warn("Failed to parse count from InventoryMessage")
      return nil
    }
    if inventoryCount! == 0 {
      Logger.warn("Failed to parse InventoryMessage. Count is zero")
      return nil
    }
    if inventoryCount! > 50000 {
      Logger.warn("Failed to parse InventoryMessage. Count is greater than 50000")
      return nil
    }
    var inventoryVectors: [InventoryVector] = []
    for _ in 0..<inventoryCount! {
      let inventoryVector = InventoryVector.fromBitcoinStream(stream)
      if inventoryVector == nil {
        Logger.warn("Failed to parse inventory vector from InventoryMessage")
        return nil
      }
      inventoryVectors.append(inventoryVector!)
    }
    return InventoryMessage(inventoryVectors: inventoryVectors)
  }
}
