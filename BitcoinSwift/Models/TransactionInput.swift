//
//  TransactionInput.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: Transaction.Input, right: Transaction.Input) -> Bool {
  return left.outPoint == right.outPoint &&
      left.scriptSignature == right.scriptSignature &&
      left.sequence == right.sequence
}

public extension Transaction {

  /// An Input represents the bitcoin being sent in a Transaction. It spends an Output from a
  /// previous transaction, referenced by outPoint.
  /// https://en.bitcoin.it/wiki/Protocol_specification#tx
  public struct Input: Equatable {

    /// Reference to the output that this input is spending.
    public let outPoint: OutPoint

    /// Script used to prove that this input is allowed to spend the output referenced by outPoint.
    /// In order to be valid, scriptSignature must meet the requirements in the output's script.
    public let scriptSignature: NSData

    /// Transaction version as defined by the sender. Intended for "replacement" of transactions
    /// when information is updated before inclusion into a block.
    /// This feature is currently disabled in the Bitcoin network.
    /// http://bitcoin.stackexchange.com/questions/2025/what-is-txins-sequence
    public let sequence: UInt32

    public init(outPoint: OutPoint, scriptSignature: NSData, sequence: UInt32) {
      self.outPoint = outPoint
      self.scriptSignature = scriptSignature
      self.sequence = sequence
    }
  }
}

 extension Transaction.Input: BitcoinSerializable {

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendData(outPoint.bitcoinData)
    data.appendVarInt(scriptSignature.length)
    data.appendData(scriptSignature)
    data.appendUInt32(sequence)
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> Transaction.Input? {
    let outPoint = Transaction.OutPoint.fromBitcoinStream(stream)
    if outPoint == nil {
      // Message already logged in OutPoint.fromStream().
      return nil
    }
    let scriptSignatureLength = stream.readVarInt()
    if scriptSignatureLength == nil {
      Logger.warn("Failed to parse scriptSignatureLength in Transaction.Input")
      return nil
    }
    let scriptSignature = stream.readData(Int(scriptSignatureLength!))
    if scriptSignature == nil {
      Logger.warn("Failed to parse scriptSignature in Transaction.Input")
      return nil
    }
    let sequence = stream.readUInt32()
    if sequence == nil {
      Logger.warn("Failed to parse sequence in Transaction.Input")
      return nil
    }
    return Transaction.Input(outPoint: outPoint!,
                             scriptSignature: scriptSignature!,
                             sequence: sequence!)
  }
}
