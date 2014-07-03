//
//  NSInputStream+IntegerDecoding.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

extension NSInputStream {

  func readUInt32(endianness: Endianness = .LittleEndian) -> UInt32? {
    var readBuffer = Array<UInt8>(count:sizeof(UInt32), repeatedValue:0)
    var numberOfBytesRead = self.read(&readBuffer, maxLength:readBuffer.count)
    if numberOfBytesRead != sizeof(UInt32) {
      return nil
    }
    var int: UInt32 = 0
    for i in 0..sizeof(UInt32) {
      switch endianness {
        case .LittleEndian:
          int |= UInt32(readBuffer[i]) << UInt32(i * 8)
        case .BigEndian:
          int |= UInt32(readBuffer[i]) << UInt32((sizeof(UInt32) - 1 - i) * 8)
      }
    }
    return int
  }

  func readASCIIStringWithLength(length:Int) -> String? {
    var readBuffer = Array<UInt8>(count:length, repeatedValue:0)
    var numberOfBytesRead = self.read(&readBuffer, maxLength:readBuffer.count)
    if numberOfBytesRead != length {
      return nil
    }
    return NSString(bytes:readBuffer, length:readBuffer.count, encoding:NSASCIIStringEncoding)
  }

  func readRemainingBytes() -> NSData {
    var data = NSMutableData()
    var readBuffer = Array<UInt8>(count:256, repeatedValue:0)
    while hasBytesAvailable {
      var numberOfBytesRead = self.read(&readBuffer, maxLength:readBuffer.count)
      data.appendBytes(readBuffer[0..numberOfBytesRead], length:numberOfBytesRead)
    }
    return data
  }
}
