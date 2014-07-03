//
//  NSData+IntegerEncoding.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

extension NSData {

  func UInt32AtIndex(index: Int, endianness: Endianness = .LittleEndian) -> UInt32 {
    assert(index + sizeof(UInt32) <= self.length)
    let subdata = self.subdataWithRange(NSRange(location:index, length:sizeof(UInt32)))
    let stream = NSInputStream(data:subdata)
    stream.open()
    var int: UInt32 = stream.readUInt32(endianness:endianness)
    stream.close()
    return int
  }
}

extension NSMutableData {

  func appendUInt32(int: UInt32, endianness: Endianness = .LittleEndian) {
    var bytes = UInt8[]()
    for i in 0..sizeof(UInt32) {
      switch endianness {
        case .LittleEndian:
          bytes.append(UInt8(int >> UInt32(i * 8) & UInt32(0xff)))
        case .BigEndian:
          bytes.append(UInt8(int >> UInt32((sizeof(UInt32) - 1 - i) * 8) & UInt32(0xff)))
      }
    }
    self.appendBytes(bytes, length:bytes.count)
  }
}
