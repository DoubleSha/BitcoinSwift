//
//  TransactionInputOutPoint.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: Transaction.OutPoint, rhs: Transaction.OutPoint) -> Bool {
  return lhs.transactionHash.isEqualToData(rhs.transactionHash) &&
      lhs.index == rhs.index
}

public extension Transaction {

  /// Reference to an output in another transaction.
  public struct OutPoint: Equatable {

    /// The hash of the transaction that contains this output.
    public let transactionHash: NSData

    /// The index of this output within the transaction.
    public let index: UInt32

    public init(transactionHash: NSData, index: UInt32) {
      precondition(transactionHash.length == 32)
      self.transactionHash = transactionHash
      self.index = index
    }
  }
}

public extension Transaction.OutPoint {

  public var data: NSData {
    var data = NSMutableData()
    data.appendData(transactionHash)
    data.appendUInt32(index)
    return data
  }

  public static func fromData(data: NSData) -> Transaction.OutPoint? {
    return Transaction.OutPoint.fromStream(NSInputStream(data:data))
  }

  public static func fromStream(stream: NSInputStream) -> Transaction.OutPoint? {
    if stream.streamStatus != .Open {
      stream.open()
    }
    let transactionHash = stream.readData(length:32)
    if transactionHash == nil {
      println("WARN: Failed to parse transactionHash in Transaction.Input.Outpoint")
      return nil
    }
    let index = stream.readUInt32()
    if index == nil {
      println("WARN: Failed to parse index in Transaction.Input.Outpoint")
      return nil
    }
    return Transaction.OutPoint(transactionHash:transactionHash!, index:index!)
  }
}
