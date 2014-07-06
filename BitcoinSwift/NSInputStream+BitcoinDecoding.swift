//
//  NSInputStream+BitcoinDecoding.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

extension NSInputStream {

  // TODO: Read UInt's in a generic way instead of copy-pasting.

  func readUInt8() -> UInt8? {
    var int: UInt8 = 0
    let numberOfBytesRead = self.read(&int, maxLength:sizeof(UInt8))
    if numberOfBytesRead != sizeof(UInt8) {
      return nil
    }
    return int
  }

  func readUInt16(endianness: Endianness = .LittleEndian) -> UInt16? {
    var readBuffer = Array<UInt8>(count:sizeof(UInt16), repeatedValue:0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength:readBuffer.count)
    if numberOfBytesRead != sizeof(UInt16) {
      return nil
    }
    var int: UInt16 = 0
    for i in 0..sizeof(UInt16) {
      switch endianness {
        case .LittleEndian:
          int |= UInt16(readBuffer[i]) << UInt16(i * 8)
        case .BigEndian:
          int |= UInt16(readBuffer[i]) << UInt16((sizeof(UInt16) - 1 - i) * 8)
      }
    }
    return int
  }

  func readUInt32(endianness: Endianness = .LittleEndian) -> UInt32? {
    var readBuffer = Array<UInt8>(count:sizeof(UInt32), repeatedValue:0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength:readBuffer.count)
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

  func readUInt64(endianness: Endianness = .LittleEndian) -> UInt64? {
    var readBuffer = Array<UInt8>(count:sizeof(UInt64), repeatedValue:0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength:readBuffer.count)
    if numberOfBytesRead != sizeof(UInt64) {
      return nil
    }
    var int: UInt64 = 0
    for i in 0..sizeof(UInt64) {
      switch endianness {
        case .LittleEndian:
          int |= UInt64(readBuffer[i]) << UInt64(i * 8)
        case .BigEndian:
          int |= UInt64(readBuffer[i]) << UInt64((sizeof(UInt64) - 1 - i) * 8)
      }
    }
    return int
  }

  func readASCIIStringWithLength(var length:Int) -> String? {
    var readBuffer = Array<UInt8>(count:length, repeatedValue:0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength:readBuffer.count)
    if numberOfBytesRead != length {
      return nil
    }
    // Remove the trailing 0's or else the string has a bunch of garbage at the end of it.
    for var i = numberOfBytesRead - 1; i >= 0; --i {
      if readBuffer[i] != 0 {
        break
      }
      --length
    }
    return NSString(bytes:readBuffer, length:length, encoding:NSASCIIStringEncoding)
  }

  // Reads the number of bytes provided by |length|, or the rest of the remaining bytes if length
  // is not provided.
  // Returns nil if there is no data remaining to parse, or if parsing fails for another reason.
  func readData(var length: Int = 0) -> NSData? {
    let data = NSMutableData()
    var readBuffer = Array<UInt8>(count:256, repeatedValue:0)
    if length == 0 {
      while hasBytesAvailable {
        var numberOfBytesRead = self.read(&readBuffer, maxLength:readBuffer.count)
        if numberOfBytesRead == 0 {
          return nil
        }
        data.appendBytes(readBuffer[0..numberOfBytesRead], length:numberOfBytesRead)
      }
    } else {
      while hasBytesAvailable && length > 0 {
        let numberOfBytesToRead = min(length, readBuffer.count)
        var numberOfBytesRead = self.read(&readBuffer, maxLength:numberOfBytesToRead)
        if numberOfBytesRead != numberOfBytesToRead {
          return nil
        }
        data.appendBytes(readBuffer[0..numberOfBytesRead], length:numberOfBytesRead)
        length -= numberOfBytesRead
      }
    }
    return data
  }

  func readVarInt() -> UInt64? {
    if let uint8 = readUInt8() {
      switch uint8 {
        case 0..0xfd:
          return UInt64(uint8)
        case 0xfd:
          if let uint16 = readUInt16() {
            return UInt64(uint16)
          }
        case 0xfe:
          if let uint32 = readUInt32() {
            return UInt64(uint32)
          }
        case 0xff:
          return readUInt64()
        default:
          return nil
      }
    }
    return nil
  }

  // The dummy bool is needed because of a compiler bug.
  // TODO: Remove the dummy bool when Apple fixes the bug.
  func readVarString(dummy: Bool = false) -> String? {
    if let length = readVarInt() {
      return readASCIIStringWithLength(Int(length))
    }
    return nil
  }

  func readNetworkAddress() -> NetworkAddress? {
    let timestamp = readUInt32()
    if !timestamp {
      return nil
    }
    let date = NSDate(timeIntervalSince1970:NSTimeInterval(timestamp!))
    let servicesRaw = readUInt64()
    if !servicesRaw {
      return nil
    }
    let services = Message.Services.fromMask(servicesRaw!)
    let IP = readIPAddress()
    if !IP {
      return nil
    }
    let port = readUInt16(endianness:.BigEndian)  // Network byte order.
    if !port {
      return nil
    }
    return NetworkAddress(date:date, services:services, IP:IP!, port:port!)
  }

  func readIPAddress() -> NetworkAddress.IPAddress? {
    // An IPAddress is encoded as 4 32-bit words. IPV4 addresses are encoded as IPV4-in-IPV6
    // (12 bytes 00 00 00 00 00 00 00 00 00 00 FF FF, followed by the 4 bytes of the IPv4 address).
    // Addresses are encoded using network byte order.
    let word0 = readUInt32(endianness:.BigEndian)
    let word1 = readUInt32(endianness:.BigEndian)
    let word2 = readUInt32(endianness:.BigEndian)
    let word3 = readUInt32(endianness:.BigEndian)
    if !word0 || !word1 || !word2 || !word3 {
      return nil
    }
    if word0! == 0 && word1! == 0 && word2! == 0xffff {
      return NetworkAddress.IPAddress.IPV4(word3!)
    }
    return NetworkAddress.IPAddress.IPV6(word0!, word1!, word2!, word3!)
  }
}
