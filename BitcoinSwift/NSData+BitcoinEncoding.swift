//
//  NSData+BitcoinEncoding.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

extension NSData {

  func UInt32AtIndex(index: Int, endianness: Endianness = .LittleEndian) -> UInt32? {
    assert(index + sizeof(UInt32) <= self.length)
    let subdata = self.subdataWithRange(NSRange(location:index, length:sizeof(UInt32)))
    let stream = NSInputStream(data:subdata)
    stream.open()
    var int: UInt32? = stream.readUInt32(endianness:endianness)
    stream.close()
    return int
  }
}

extension NSMutableData {

  // TODO: Do this in a generic way instaed of copy-pasting.

  // ZOMGWTF Apple. The dummy Bool is needed because of an Apple bug. It doesn't compile
  // without that.
  // TODO: Remove this when the bug is fixed.
  func appendUInt8(myInt: UInt8, dummy: Bool = false) {
    self.appendBytes([myInt], length:1)
  }

  func appendUInt16(myInt: UInt16, endianness: Endianness = .LittleEndian) {
    var bytes = UInt8[]()
    for i in 0..sizeof(UInt16) {
      switch endianness {
        case .LittleEndian:
          bytes.append(UInt8(myInt >> UInt16(i * 8) & UInt16(0xff)))
        case .BigEndian:
          bytes.append(UInt8(myInt >> UInt16((sizeof(UInt16) - 1 - i) * 8) & UInt16(0xff)))
      }
    }
    self.appendBytes(bytes, length:bytes.count)
  }

  func appendUInt32(myInt: UInt32, endianness: Endianness = .LittleEndian) {
    var bytes = UInt8[]()
    for i in 0..sizeof(UInt32) {
      switch endianness {
        case .LittleEndian:
          bytes.append(UInt8(myInt >> UInt32(i * 8) & UInt32(0xff)))
        case .BigEndian:
          bytes.append(UInt8(myInt >> UInt32((sizeof(UInt32) - 1 - i) * 8) & UInt32(0xff)))
      }
    }
    self.appendBytes(bytes, length:bytes.count)
  }

  func appendUInt64(myInt: UInt64, endianness: Endianness = .LittleEndian) {
    var bytes = UInt8[]()
    for i in 0..sizeof(UInt64) {
      switch endianness {
        case .LittleEndian:
          bytes.append(UInt8(myInt >> UInt64(i * 8) & UInt64(0xff)))
        case .BigEndian:
          bytes.append(UInt8(myInt >> UInt64((sizeof(UInt64) - 1 - i) * 8) & UInt64(0xff)))
      }
    }
    self.appendBytes(bytes, length:bytes.count)
  }
}
