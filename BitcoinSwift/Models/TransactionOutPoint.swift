//
//  TransactionInputOutPoint.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: Transaction.OutPoint, right: Transaction.OutPoint) -> Bool {
  return left.transactionHash == right.transactionHash && left.index == right.index
}

public extension Transaction {

  /// Reference to an output in another transaction.
  /// https://en.bitcoin.it/wiki/Protocol_specification#tx
  public struct OutPoint: Equatable {

    /// The hash of the transaction that contains this output.
    public let transactionHash: SHA256Hash

    /// The index of this output within the transaction.
    public let index: UInt32

    public init(transactionHash: SHA256Hash, index: UInt32) {
      self.transactionHash = transactionHash
      self.index = index
    }
  }
}

 extension Transaction.OutPoint: BitcoinSerializable {

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendData(transactionHash.bitcoinData)
    data.appendUInt32(index)
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> Transaction.OutPoint? {
    let transactionHash = SHA256Hash.fromBitcoinStream(stream)
    if transactionHash == nil {
      Logger.warn("Failed to parse transactionHash in Transaction.Input.Outpoint")
      return nil
    }
    let index = stream.readUInt32()
    if index == nil {
      Logger.warn("Failed to parse index in Transaction.Input.Outpoint")
      return nil
    }
    return Transaction.OutPoint(transactionHash: transactionHash!, index: index!)
  }
}
