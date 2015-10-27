//
//  GetDataMessage.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 8/31/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: GetDataMessage, right: GetDataMessage) -> Bool {
  return left.inventoryVectors == right.inventoryVectors
}

/// Message payload object corresponding to the Message.Command.GetData command. Used in response
/// to an 'inv' message to retrieve the content of a specific object. It can be used to retrieve
/// transactions, but only if they are in the memory pool or relay set. Arbitrary access to
/// transactions in the chain is not allowed.
/// https://en.bitcoin.it/wiki/Protocol_specification#getdata
public struct GetDataMessage: Equatable {

  public let inventoryVectors: [InventoryVector]

  public init(inventoryVectors: [InventoryVector]) {
    assert(inventoryVectors.count > 0 && inventoryVectors.count <= 50000)
    self.inventoryVectors = inventoryVectors
  }
}

extension GetDataMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.GetData
  }

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendVarInt(inventoryVectors.count)
    for inventoryVector in inventoryVectors {
      data.appendData(inventoryVector.bitcoinData)
    }
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> GetDataMessage? {
    let inventoryCount = stream.readVarInt()
    if inventoryCount == nil {
      Logger.warn("Failed to parse count from GetDataMessage")
      return nil
    }
    if inventoryCount! == 0 {
      Logger.warn("Failed to parse GetDataMessage. Count is zero")
      return nil
    }
    if inventoryCount! > 50000 {
      Logger.warn("Failed to parse GetDataMessage. Count is greater than 50000")
      return nil
    }
    var inventoryVectors: [InventoryVector] = []
    for i in 0..<inventoryCount! {
      let inventoryVector = InventoryVector.fromBitcoinStream(stream)
      if inventoryVector == nil {
        Logger.warn("Failed to parse inventory vector \(i) from GetDataMessage")
        return nil
      }
      inventoryVectors.append(inventoryVector!)
    }
    return GetDataMessage(inventoryVectors: inventoryVectors)
  }
}
