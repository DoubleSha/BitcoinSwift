//
//  IPAddress.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/15/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: IPAddress, rhs: IPAddress) -> Bool {
  switch (lhs, rhs) {
    case (.IPV4(let lhsWord), .IPV4(let rhsWord)): 
      return lhsWord == rhsWord
    case (.IPV6(let lhsWord0, let lhsWord1, let lhsWord2, let lhsWord3),
          .IPV6(let rhsWord0, let rhsWord1, let rhsWord2, let rhsWord3)): 
      return lhsWord0 == rhsWord0 &&
          lhsWord1 == rhsWord1 &&
          lhsWord2 == rhsWord2 &&
          lhsWord3 == rhsWord3
    default: 
      return false
  }
}

public enum IPAddress: Equatable {

  case IPV4(UInt32)
  case IPV6(UInt32, UInt32, UInt32, UInt32)
}

extension IPAddress: BitcoinSerializable {

  public var bitcoinData: NSData {
    var data = NSMutableData()
    // An IPAddress is encoded as 4 32-bit words. IPV4 addresses are encoded as IPV4-in-IPV6
    // (12 bytes 00 00 00 00 00 00 00 00 00 00 FF FF, followed by the 4 bytes of the IPv4 address).
    // Addresses are encoded using network byte order (big endian).
    switch self {
      case .IPV4(let word):
        data.appendUInt32(0, endianness: .BigEndian)
        data.appendUInt32(0, endianness: .BigEndian)
        data.appendUInt32(0xffff, endianness: .BigEndian)
        data.appendUInt32(word, endianness: .BigEndian)
      case .IPV6(let word0, let word1, let word2, let word3):
        data.appendUInt32(word0, endianness: .BigEndian)
        data.appendUInt32(word1, endianness: .BigEndian)
        data.appendUInt32(word2, endianness: .BigEndian)
        data.appendUInt32(word3, endianness: .BigEndian)
    }
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> IPAddress? {
    // An IPAddress is encoded as 4 32-bit words. IPV4 addresses are encoded as IPV4-in-IPV6
    // (12 bytes 00 00 00 00 00 00 00 00 00 00 FF FF, followed by the 4 bytes of the IPv4 address).
    // Addresses are encoded using network byte order.
    let word0 = stream.readUInt32(endianness: .BigEndian)
    if word0 == nil {
      Logger.warn("Failed to parse word0 from IPAddress")
      return nil
    }
    let word1 = stream.readUInt32(endianness: .BigEndian)
    if word1 == nil {
      Logger.warn("Failed to parse word1 from IPAddress")
      return nil
    }
    let word2 = stream.readUInt32(endianness: .BigEndian)
    if word2 == nil {
      Logger.warn("Failed to parse word2 from IPAddress")
      return nil
    }
    let word3 = stream.readUInt32(endianness: .BigEndian)
    if word3 == nil {
      Logger.warn("Failed to parse word3 from IPAddress")
      return nil
    }
    if word0! == 0 && word1! == 0 && word2! == 0xffff {
      return IPAddress.IPV4(word3!)
    }
    return IPAddress.IPV6(word0!, word1!, word2!, word3!)
  }
}
