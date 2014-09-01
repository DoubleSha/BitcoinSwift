//
//  GetDataMessage.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 14/31/8.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// Message of type 'getdata' (GetData). Used in response to inv (Inventory), to retrieve the 
/// content of a specific object.  It can be used to retrieve transactions, but only if they are 
/// in the memory pool or relay set. Arbitrary access to transactions in the chain is not allowed.
public struct GetDataMessage: MessagePayload {

  public let inventoryVectors: [InventoryVector]

  public init(inventoryVectors: [InventoryVector]) {
    assert(inventoryVectors.count > 0 && inventoryVectors.count <= 50000)
    self.inventoryVectors = inventoryVectors
  }

  // MARK: - MessagePayload

  public var command: Message.Command {
    return Message.Command.GetData
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendVarInt(inventoryVectors.count)
    for inventoryVector in inventoryVectors {
      data.appendInventoryVector(inventoryVector)
    }
    return data
  }

  public static func fromData(data: NSData) -> GetDataMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data:data)
    stream.open()
    let inventoryCount = stream.readVarInt()
    if inventoryCount == nil {
      println("WARN: Failed to parse count from GetDataMessage \(data)")
      return nil
    }
    if inventoryCount! == 0 {
      println("WARN: Failed to parse GetDataMessage. Count is zero \(data)")
      return nil
    }
    if inventoryCount! > 50000 {
      println("WARN: Failed to parse GetDaraMessage. Count is greater than 50000 \(data)")
      return nil
    }
    var inventoryVectors: [InventoryVector] = []
    for _ in 0..<inventoryCount! {
      let inventoryVector = stream.readInventoryVector()
      if inventoryVector == nil {
        println("WARN: Failed to parse inventory vector from GetDataMessage \(data)")
        return nil
      }
      inventoryVectors.append(inventoryVector!)
    }
    if stream.hasBytesAvailable {
      println("WARN: Failed to parse InventoryMessage. Too many vectors \(data)")
      return nil
    }
    return GetDataMessage(inventoryVectors: inventoryVectors)
  }
}
