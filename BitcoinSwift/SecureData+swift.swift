//
//  SecureData+swift.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/30/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

extension SecureData {

  public subscript(subRange: Range<Int>) -> SecureData {
    precondition(subRange.startIndex >= 0 && subRange.startIndex < mutableData.length)
    precondition(subRange.endIndex > subRange.startIndex &&
        subRange.endIndex <= mutableData.length)
    let length = subRange.endIndex - subRange.startIndex
    let subData = SecureData(length: UInt(length))
    memcpy(subData.mutableBytes, mutableBytes.advancedBy(subRange.startIndex), length)
    return subData
  }
}

extension SecureData {

  public func appendUInt32(value: UInt32, endianness: Endianness = .LittleEndian) {
    mutableData.appendUInt32(value, endianness: endianness)
  }
}

extension SecureData {

  public func HMACSHA512WithKey(key: SecureData) -> SecureData {
    return HMACSHA512WithKeyData(key.mutableData)
  }

  public func HMACSHA512WithKeyData(key: NSData) -> SecureData {
    let digest = SecureData(length: 64)
    mutableData.HMACSHA512WithKey(key, digest: digest.mutableData)
    return digest
  }
}
