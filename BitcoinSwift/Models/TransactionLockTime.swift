//
//  TransactionLockTime.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: Transaction.LockTime, right: Transaction.LockTime) -> Bool {
  switch (left, right) {
    case (.AlwaysLocked, .AlwaysLocked): 
      return true
    case (.BlockHeight(let leftBlockHeight), .BlockHeight(let rightBlockHeight)): 
      return leftBlockHeight == rightBlockHeight
    case (.Date(let leftDate), .Date(let rightDate)): 
      return leftDate == rightDate
    default: 
      return false
  }
}

public extension Transaction {

  /// The time at which the transaction is locked. After this point, the transaction cannot be
  /// modified and will be mined by the miners.
  /// https://en.bitcoin.it/wiki/Protocol_specification#tx
  public enum LockTime: Equatable {

    /// The transaction will be mined immediately, and cannot be modified after being broadcast.
    case AlwaysLocked

    /// The block height after which the transaction will be locked.
    case BlockHeight(UInt32)

    /// The date after which the transaction will be locked.
    case Date(NSDate)

    public static func fromRaw(raw: UInt32) -> LockTime? {
      switch raw {
        case 0: 
          return .AlwaysLocked
        case 1..<500000000: 
          return .BlockHeight(raw)
        default: 
          return .Date(NSDate(timeIntervalSince1970: NSTimeInterval(raw)))
      }
    }

    public var rawValue: UInt32 {
      switch self {
        case .AlwaysLocked: 
          return 0
        case .BlockHeight(let blockHeight): 
          return blockHeight
        case .Date(let date): 
          return UInt32(date.timeIntervalSince1970)
      }
    }
  }
}
