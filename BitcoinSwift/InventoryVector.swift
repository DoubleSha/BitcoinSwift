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
}
