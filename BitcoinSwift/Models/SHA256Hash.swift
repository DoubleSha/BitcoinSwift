//
//  SHA256Hash.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/6/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: SHA256Hash, right: SHA256Hash) -> Bool {
  return left.data == right.data
}

public struct SHA256Hash: Equatable {

  public let data: NSData

  public init() {
    self.data = NSMutableData(length: 32)!
  }

  public init(data: NSData) {
    precondition(data.length == 32)
    self.data = data
  }

  public init(bytes: [UInt8]) {
    precondition(bytes.count == 32)
    self.data = NSData(bytes: bytes, length: bytes.count)
  }
}

extension SHA256Hash: BitcoinSerializable {

  public var bitcoinData: NSData {
    // Hashes are encoded little-endian on the wire.
    return data.reversedData
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> SHA256Hash? {
    let hashData = stream.readData(32)
    if hashData == nil {
      Logger.warn("Failed to parse hashData from SHA256Hash")
      return nil
    }
    // Hashes are encoded little-endian on the wire.
    return SHA256Hash(data: hashData!.reversedData)
  }
}

extension SHA256Hash: CustomStringConvertible {

  public var description: String {
    return data.hexString
  }
}

extension SHA256Hash: Hashable {

  public var hashValue: Int {
    return data.hashValue
  }
}
