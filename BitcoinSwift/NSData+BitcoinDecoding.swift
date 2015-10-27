//
//  NSData+BitcoinDecoding.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/18/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public extension NSData {

  public func UInt32AtIndex(index: Int, endianness: Endianness = .LittleEndian) -> UInt32? {
    precondition(index + sizeof(UInt32) <= self.length)
    let subdata = self.subdataWithRange(NSRange(location: index, length: sizeof(UInt32)))
    let stream = NSInputStream(data: subdata)
    stream.open()
    let int: UInt32? = stream.readUInt32(endianness)
    stream.close()
    return int
  }

  public var reversedData: NSData {
    // Copy the data into bytes.
    var bytes = [UInt8](count: self.length, repeatedValue: 0)
    self.getBytes(&bytes, length: bytes.count)
    var tmp: UInt8 = 0
    for i in 0..<(bytes.count / 2) {
      tmp = bytes[i]
      bytes[i] = bytes[bytes.count - i - 1]
      bytes[bytes.count - i - 1] = tmp
    }
    return NSData(bytes: bytes, length: bytes.count)
  }

  public var UInt8Array: [UInt8] {
    var UInt8Array = [UInt8](count: self.length, repeatedValue: 0)
    getBytes(&UInt8Array, length: self.length)
    return UInt8Array
  }
}
