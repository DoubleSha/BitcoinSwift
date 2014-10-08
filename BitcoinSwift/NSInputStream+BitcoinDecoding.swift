//
//  NSInputStream+BitcoinDecoding.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public extension NSInputStream {

  // TODO: Read Ints in a generic way instead of copy-pasting.

  public func readUInt8() -> UInt8? {
    var int: UInt8 = 0
    let numberOfBytesRead = self.read(&int, maxLength: sizeof(UInt8))
    if numberOfBytesRead != sizeof(UInt8) {
      return nil
    }
    return int
  }

  public func readUInt16(endianness: Endianness = .LittleEndian) -> UInt16? {
    var readBuffer = [UInt8](count: sizeof(UInt16), repeatedValue: 0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
    if numberOfBytesRead != sizeof(UInt16) {
      return nil
    }
    var int: UInt16 = 0
    for i in 0..<sizeof(UInt16) {
      switch endianness {
        case .LittleEndian: 
          int |= UInt16(readBuffer[i]) << UInt16(i * 8)
        case .BigEndian: 
          int |= UInt16(readBuffer[i]) << UInt16((sizeof(UInt16) - 1 - i) * 8)
      }
    }
    return int
  }

  public func readUInt32(endianness: Endianness = .LittleEndian) -> UInt32? {
    var readBuffer = [UInt8](count: sizeof(UInt32), repeatedValue: 0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
    if numberOfBytesRead != sizeof(UInt32) {
      return nil
    }
    var int: UInt32 = 0
    for i in 0..<sizeof(UInt32) {
      switch endianness {
        case .LittleEndian: 
          int |= UInt32(readBuffer[i]) << UInt32(i * 8)
        case .BigEndian: 
          int |= UInt32(readBuffer[i]) << UInt32((sizeof(UInt32) - 1 - i) * 8)
      }
    }
    return int
  }

  public func readUInt64(endianness: Endianness = .LittleEndian) -> UInt64? {
    var readBuffer = [UInt8](count: sizeof(UInt64), repeatedValue: 0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
    if numberOfBytesRead != sizeof(UInt64) {
      return nil
    }
    var int: UInt64 = 0
    for i in 0..<sizeof(UInt64) {
      switch endianness {
        case .LittleEndian: 
          int |= UInt64(readBuffer[i]) << UInt64(i * 8)
        case .BigEndian: 
          int |= UInt64(readBuffer[i]) << UInt64((sizeof(UInt64) - 1 - i) * 8)
      }
    }
    return int
  }

  public func readInt16(endianness: Endianness = .LittleEndian) -> Int16? {
    var readBuffer = [UInt8](count: sizeof(Int16), repeatedValue: 0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
    if numberOfBytesRead != sizeof(Int16) {
      return nil
    }
    var int: Int16 = 0
    for i in 0..<sizeof(Int16) {
      switch endianness {
        case .LittleEndian: 
          int |= Int16(readBuffer[i]) << Int16(i * 8)
        case .BigEndian: 
          int |= Int16(readBuffer[i]) << Int16((sizeof(Int16) - 1 - i) * 8)
      }
    }
    return int
  }

  public func readInt32(endianness: Endianness = .LittleEndian) -> Int32? {
    var readBuffer = [UInt8](count: sizeof(Int32), repeatedValue: 0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
    if numberOfBytesRead != sizeof(Int32) {
      return nil
    }
    var int: Int32 = 0
    for i in 0..<sizeof(Int32) {
      switch endianness {
        case .LittleEndian: 
          int |= Int32(readBuffer[i]) << Int32(i * 8)
        case .BigEndian: 
          int |= Int32(readBuffer[i]) << Int32((sizeof(Int32) - 1 - i) * 8)
      }
    }
    return int
  }

  public func readInt64(endianness: Endianness = .LittleEndian) -> Int64? {
    var readBuffer = [UInt8](count: sizeof(Int64), repeatedValue: 0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
    if numberOfBytesRead != sizeof(Int64) {
      return nil
    }
    var int: Int64 = 0
    for i in 0..<sizeof(Int64) {
      switch endianness {
        case .LittleEndian: 
          int |= Int64(readBuffer[i]) << Int64(i * 8)
        case .BigEndian: 
          int |= Int64(readBuffer[i]) << Int64((sizeof(Int64) - 1 - i) * 8)
      }
    }
    return int
  }

  public func readBool() -> Bool? {
    if let uint8 = readUInt8() {
      if uint8 > 0 {
        return true
      }
      return false
    }
    return nil
  }

  public func readASCIIStringWithLength(var length: Int) -> String? {
    var readBuffer = [UInt8](count: length, repeatedValue: 0)
    let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
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
    return NSString(bytes: readBuffer, length: length, encoding: NSASCIIStringEncoding)
  }

  // Reads the number of bytes provided by |length|, or the rest of the remaining bytes if length
  // is not provided.
  // Returns nil if there is no data remaining to parse, or if parsing fails for another reason.
  public func readData(var length: Int = 0) -> NSData? {
    let data = NSMutableData()
    var readBuffer = [UInt8](count: 256, repeatedValue: 0)
    if length == 0 {
      while hasBytesAvailable {
        var numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
        if numberOfBytesRead == 0 {
          return nil
        }
        let subarray = [UInt8](readBuffer[0..<numberOfBytesRead])
        data.appendBytes(subarray, length: numberOfBytesRead)
      }
    } else {
      while hasBytesAvailable && length > 0 {
        let numberOfBytesToRead = min(length, readBuffer.count)
        var numberOfBytesRead = self.read(&readBuffer, maxLength: numberOfBytesToRead)
        if numberOfBytesRead != numberOfBytesToRead {
          return nil
        }
        let subarray = [UInt8](readBuffer[0..<numberOfBytesRead])
        data.appendBytes(subarray, length: numberOfBytesRead)
        length -= numberOfBytesRead
      }
    }
    return data
  }

  public func readVarInt() -> UInt64? {
    if let uint8 = readUInt8() {
      switch uint8 {
        case 0..<0xfd: 
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

  public func readVarString() -> String? {
    if let length = readVarInt() {
      return readASCIIStringWithLength(Int(length))
    }
    return nil
  }

  public func readIPAddress() -> IPAddress? {
    // An IPAddress is encoded as 4 32-bit words. IPV4 addresses are encoded as IPV4-in-IPV6
    // (12 bytes 00 00 00 00 00 00 00 00 00 00 FF FF, followed by the 4 bytes of the IPv4 address).
    // Addresses are encoded using network byte order.
    let word0 = readUInt32(endianness: .BigEndian)
    let word1 = readUInt32(endianness: .BigEndian)
    let word2 = readUInt32(endianness: .BigEndian)
    let word3 = readUInt32(endianness: .BigEndian)
    if word0 == nil || word1 == nil || word2 == nil || word3 == nil {
      return nil
    }
    if word0! == 0 && word1! == 0 && word2! == 0xffff {
      return IPAddress.IPV4(word3!)
    }
    return IPAddress.IPV6(word0!, word1!, word2!, word3!)
  }

  public func readDateFromUnixTimestamp(endianness: Endianness = .LittleEndian) -> NSDate? {
    let rawTimestamp = readUInt32(endianness: endianness)
    if rawTimestamp == nil {
      return nil
    }
    return NSDate(timeIntervalSince1970: NSTimeInterval(rawTimestamp!))
  }

  // TODO: The functions below don't belong here. Move them somewhere else.

  public func readPeerAddress(includeTimestamp: Bool = true) -> PeerAddress? {
    var timestamp: NSDate? = nil
    if includeTimestamp {
      let rawTimestamp = readUInt32()
      if rawTimestamp == nil {
        return nil
      }
      timestamp = NSDate(timeIntervalSince1970: NSTimeInterval(rawTimestamp!))
    }
    let servicesRaw = readUInt64()
    if servicesRaw == nil {
      return nil
    }
    let services = PeerServices(rawValue: servicesRaw!)
    let IP = readIPAddress()
    if IP == nil {
      return nil
    }
    let port = readUInt16(endianness: .BigEndian)  // Network byte order.
    if port == nil {
      return nil
    }
    return PeerAddress(services: services, IP: IP!, port: port!, timestamp: timestamp)
  }

  public func readInventoryVector() -> InventoryVector? {
    let rawType = readUInt32()
    if rawType == nil {
      return nil
    }
    let hash = readData(length: 32)
    if hash == nil {
      return nil
    }
    let type = InventoryVector.VectorType(rawValue: rawType!)
    if type == nil {
      return nil
    }
    return InventoryVector(type: type!, hash: hash!)
  }
}
