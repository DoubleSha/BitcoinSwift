//
//  NSData+BitcoinEncoding.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public extension NSData {

  public func UInt32AtIndex(index: Int, endianness: Endianness = .LittleEndian) -> UInt32? {
    precondition(index + sizeof(UInt32) <= self.length)
    let subdata = self.subdataWithRange(NSRange(location: index, length: sizeof(UInt32)))
    let stream = NSInputStream(data: subdata)
    stream.open()
    var int: UInt32? = stream.readUInt32(endianness: endianness)
    stream.close()
    return int
  }
}

public extension NSMutableData {

  // TODO: Append Ints in a generic way instead of copy-pasting.

  public func appendUInt8(value: UInt8) {
    self.appendBytes([value] as [UInt8], length: 1)
  }

  public func appendUInt16(value: UInt16, endianness: Endianness = .LittleEndian) {
    var bytes: [UInt8] = []
    for i in 0..<sizeof(UInt16) {
      switch endianness {
        case .LittleEndian: 
          bytes.append(UInt8(value >> UInt16(i * 8) & UInt16(0xff)))
        case .BigEndian: 
          bytes.append(UInt8(value >> UInt16((sizeof(UInt16) - 1 - i) * 8) & UInt16(0xff)))
      }
    }
    self.appendBytes(bytes, length: bytes.count)
  }

  public func appendUInt32(value: UInt32, endianness: Endianness = .LittleEndian) {
    var bytes: [UInt8] = []
    for i in 0..<sizeof(UInt32) {
      switch endianness {
        case .LittleEndian: 
          bytes.append(UInt8(value >> UInt32(i * 8) & UInt32(0xff)))
        case .BigEndian: 
          bytes.append(UInt8(value >> UInt32((sizeof(UInt32) - 1 - i) * 8) & UInt32(0xff)))
      }
    }
    self.appendBytes(bytes, length: bytes.count)
  }

  public func appendUInt64(value: UInt64, endianness: Endianness = .LittleEndian) {
    var bytes: [UInt8] = []
    for i in 0..<sizeof(UInt64) {
      switch endianness {
        case .LittleEndian: 
          bytes.append(UInt8(value >> UInt64(i * 8) & UInt64(0xff)))
        case .BigEndian: 
          bytes.append(UInt8(value >> UInt64((sizeof(UInt64) - 1 - i) * 8) & UInt64(0xff)))
      }
    }
    self.appendBytes(bytes, length: bytes.count)
  }

  public func appendInt16(value: Int16, endianness: Endianness = .LittleEndian) {
    var bytes: [UInt8] = []
    for i in 0..<sizeof(Int16) {
      switch endianness {
        case .LittleEndian: 
          bytes.append(UInt8(value >> Int16(i * 8) & Int16(0xff)))
        case .BigEndian: 
          bytes.append(UInt8(value >> Int16((sizeof(Int16) - 1 - i) * 8) & Int16(0xff)))
      }
    }
    self.appendBytes(bytes, length: bytes.count)
  }

  public func appendInt32(value: Int32, endianness: Endianness = .LittleEndian) {
    var bytes: [UInt8] = []
    for i in 0..<sizeof(Int32) {
      switch endianness {
        case .LittleEndian: 
          bytes.append(UInt8(value >> Int32(i * 8) & Int32(0xff)))
        case .BigEndian: 
          bytes.append(UInt8(value >> Int32((sizeof(Int32) - 1 - i) * 8) & Int32(0xff)))
      }
    }
    self.appendBytes(bytes, length: bytes.count)
  }

  public func appendInt64(value: Int64, endianness: Endianness = .LittleEndian) {
    var bytes: [UInt8] = []
    for i in 0..<sizeof(Int64) {
      switch endianness {
        case .LittleEndian: 
          bytes.append(UInt8(value >> Int64(i * 8) & Int64(0xff)))
        case .BigEndian: 
          bytes.append(UInt8(value >> Int64((sizeof(Int64) - 1 - i) * 8) & Int64(0xff)))
      }
    }
    self.appendBytes(bytes, length: bytes.count)
  }

  public func appendVarInt(value: UInt64, endianness: Endianness = .LittleEndian) {
    switch value {
      case 0..<0xfd: 
        appendUInt8(UInt8(value))
      case 0xfd...0xffff: 
        appendUInt8(0xfd)
        appendUInt16(UInt16(value), endianness: endianness)
      case 0x010000...0xffffffff: 
        appendUInt8(0xfe)
        appendUInt32(UInt32(value), endianness: endianness)
      default: 
        appendUInt8(0xff)
        appendUInt64(value, endianness: endianness)
    }
  }

  public func appendVarInt(value: Int, endianness: Endianness = .LittleEndian) {
    precondition(value >= 0)
    appendVarInt(UInt64(value), endianness: endianness)
  }

  public func appendBool(value: Bool) {
    value ? appendUInt8(1) : appendUInt8(0)
  }

  public func appendVarString(string: String) {
    let length = string.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)
    appendVarInt(length)
    if length > 0 {
      appendBytes(string.dataUsingEncoding(NSASCIIStringEncoding)!.bytes, length: length)
    }
  }

  public func appendPeerAddress(peerAddress: PeerAddress, includeTimestamp: Bool = true) {
    if includeTimestamp {
      if let timestamp = peerAddress.timestamp {
        appendUInt32(UInt32(timestamp.timeIntervalSince1970))
      } else {
        appendUInt32(UInt32(NSDate().timeIntervalSince1970))
      }
    }
    appendUInt64(peerAddress.services.toRaw())
    appendIPAddress(peerAddress.IP)
    appendUInt16(peerAddress.port, endianness: .BigEndian)  // Network byte order.
  }

  public func appendIPAddress(IP: IPAddress) {
    // An IPAddress is encoded as 4 32-bit words. IPV4 addresses are encoded as IPV4-in-IPV6
    // (12 bytes 00 00 00 00 00 00 00 00 00 00 FF FF, followed by the 4 bytes of the IPv4 address).
    // Addresses are encoded using network byte order (big endian).
    switch IP {
      case .IPV4(let word): 
        appendUInt32(0, endianness: .BigEndian)
        appendUInt32(0, endianness: .BigEndian)
        appendUInt32(0xffff, endianness: .BigEndian)
        appendUInt32(word, endianness: .BigEndian)
      case .IPV6(let word0, let word1, let word2, let word3): 
        appendUInt32(word0, endianness: .BigEndian)
        appendUInt32(word1, endianness: .BigEndian)
        appendUInt32(word2, endianness: .BigEndian)
        appendUInt32(word3, endianness: .BigEndian)
    }
  }

  public func appendInventoryVector(inventoryVector: InventoryVector) {
    appendUInt32(inventoryVector.type.toRaw())
    self.appendData(inventoryVector.hash)
  }
}
