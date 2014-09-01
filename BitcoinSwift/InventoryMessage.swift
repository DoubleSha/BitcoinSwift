//
//  InventoryMessage.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 14/23/8.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//
//  Allows a node to advertise its knowledge of one or more objects. It can be received unsolicited,
//  or in reply to getblocks.
//
//  https://en.bitcoin.it/wiki/Protocol_specification#inv
//

import Foundation

/// Message of type 'inv' (Inventory). Allows a node to advertise its knowledge of one or more
/// objects. It can be received unsolicited, or in reply to getblocks.
public struct InventoryMessage: MessagePayload {

  public let inventoryVectors: [InventoryVector]

  public init(inventoryVectors: [InventoryVector]) {
    assert(inventoryVectors.count > 0 && inventoryVectors.count <= 50000)
    self.inventoryVectors = inventoryVectors
  }

  // MARK: - MessagePayload

  public var command: Message.Command {
    return Message.Command.Inventory
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendVarInt(inventoryVectors.count)
    for inventoryVector in inventoryVectors {
      data.appendInventoryVector(inventoryVector)
    }
    return data
  }

  public static func fromData(data: NSData) -> InventoryMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data:data)
    stream.open()
    let inventoryCount = stream.readVarInt()
    if inventoryCount == nil {
      println("WARN: Failed to parse count from InventoryMessage \(data)")
      return nil
    }
    if inventoryCount! == 0 {
      println("WARN: Failed to parse InventoryMessage. Count is zero \(data)")
      return nil
    }
    if inventoryCount! > 50000 {
      println("WARN: Failed to parse InventoryMessage. Count is greater than 50000 \(data)")
      return nil
    }
    var inventoryVectors: [InventoryVector] = []
    for _ in 0..<inventoryCount! {
      let inventoryVector = stream.readInventoryVector()
      if inventoryVector == nil {
        println("WARN: Failed to parse inventory vector from InventoryMessage \(data)")
        return nil
      }
      inventoryVectors.append(inventoryVector!)
    }
    if stream.hasBytesAvailable {
      println("WARN: Failed to parse InventoryMessage. Too many vectors \(data)")
      return nil
    }
    return InventoryMessage(inventoryVectors:inventoryVectors)
  }
}
