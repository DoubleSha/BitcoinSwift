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

  // TODO: Make this conform to BitcoinSerializable.
}
