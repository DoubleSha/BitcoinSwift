//
//  InventoryVector.swift
//  BitcoinSwift
//
//  Created by James MacWhyte on 14/23/8.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: InventoryVector, right: InventoryVector) -> Bool {
  return left.type == right.type && left.hash == right.hash
}

/// Inventory vectors are used for notifying other nodes about objects they have or data which is
/// being requested.
/// https://en.bitcoin.it/wiki/Protocol_specification#Inventory_Vectors
public struct InventoryVector: Equatable {

  public enum VectorType: UInt32 {
    case Error = 0, Transaction = 1, Block = 2
  }

  public let type: VectorType
  public let hash: SHA256Hash

  public init(type: VectorType, hash: SHA256Hash) {
    self.type = type
    self.hash = hash
  }
}

extension InventoryVector: BitcoinSerializable {

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendUInt32(type.rawValue)
    data.appendData(hash.bitcoinData)
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
    let hash = SHA256Hash.fromBitcoinStream(stream)
    if hash == nil {
      Logger.warn("Failed to parse hash from InventoryVector")
      return nil
    }
    return InventoryVector(type: type!, hash: hash!)
  }
}

extension InventoryVector: CustomStringConvertible {

  public var description: String {
    switch type {
      case .Error:
        return "ERROR \(hash)"
      case .Block:
        return "BLOCK \(hash)"
      case .Transaction:
        return "TRANSACTION \(hash)"
    }
  }
}
