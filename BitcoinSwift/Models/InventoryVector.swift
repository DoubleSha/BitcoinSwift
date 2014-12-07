//
//  InventoryVector.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 14/23/8.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: InventoryVector, rhs: InventoryVector) -> Bool {
  return lhs.type == rhs.type && lhs.hash == rhs.hash
}

/// Inventory vectors are used for notifying other nodes about objects they have or data which is
/// being requested.
/// https://en.bitcoin.it/wiki/Protocol_specification#Inventory_Vectors
public struct InventoryVector: Equatable {

  public enum VectorType: UInt32 {
    case Error = 0, Transaction = 1, Block = 2
  }

  public let type: VectorType
  public let hash: NSData

  public init(type: VectorType, hash: NSData) {
    self.type = type
    self.hash = hash
  }

  public var description: String {
    switch type {
      case .Error:
        return "ERROR \(hash.reversedData.hexString())"
      case .Block:
        return "BLOCK \(hash.reversedData.hexString())"
      case .Transaction:
        return "TRANSACTION \(hash.reversedData.hexString())"
    }
  }
}

extension InventoryVector: BitcoinSerializable {

  public var bitcoinData: NSData {
    var data = NSMutableData()
    data.appendUInt32(type.rawValue)
    data.appendData(hash)
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> InventoryVector? {
    let rawType = stream.readUInt32()
    if rawType == nil {
      Logger.warn("Failed to parse type from InventoryVector")
      return nil
    }
    let type = VectorType(rawValue: rawType!)
    if type == nil {
      Logger.warn("Invalid type \(rawType!) in InventoryVector")
      return nil
    }
    let hash = stream.readData(length: 32)
    if hash == nil {
      Logger.warn("Failed to parse hash from InventoryVector")
      return nil
    }
    return InventoryVector(type: type!, hash: hash!)
  }
}
