//
//  NSData+StringEncoding.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/23/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

let base58CharToValueMap: [Character: Int] = [
    "1": 0, "2": 1, "3": 2, "4": 3, "5": 4, "6": 5, "7": 6, "8": 7,
    "9": 8, "A": 9, "B": 10, "C": 11, "D": 12, "E": 13, "F": 14, "G": 15,
    "H": 16, "J": 17, "K": 18, "L": 19, "M": 20, "N": 21, "P": 22, "Q": 23,
    "R": 24, "S": 25, "T": 26, "U": 27, "V": 28, "W": 29, "X": 30, "Y": 31,
    "Z": 32, "a": 33, "b": 34, "c": 35, "d": 36, "e": 37, "f": 38, "g": 39,
    "h": 40, "i": 41, "j": 42, "k": 43, "m": 44, "n": 45, "o": 46, "p": 47,
    "q": 48, "r": 49, "s": 50, "t": 51, "u": 52, "v": 53, "w": 54, "x": 55,
    "y": 56, "z": 57]

let base58ValueToCharMap: [Int: Character] = [
    0: "1", 1: "2", 2: "3", 3: "4", 4: "5", 5: "6", 6: "7", 7: "8",
    8: "9", 9: "A", 10: "B", 11: "C", 12: "D", 13: "E", 14: "F", 15: "G",
    16: "H", 17: "J", 18: "K", 19: "L", 20: "M", 21: "N", 22: "P", 23: "Q",
    24: "R", 25: "S", 26: "T", 27: "U", 28: "V", 29: "W", 30: "X", 31: "Y",
    32: "Z", 33: "a", 34: "b", 35: "c", 36: "d", 37: "e", 38: "f", 39: "g",
    40: "h", 41: "i", 42: "j", 43: "k", 44: "m", 45: "n", 46: "o", 47: "p",
    48: "q", 49: "r", 50: "s", 51: "t", 52: "u", 53: "v", 54: "w", 55: "x",
    56: "y", 57: "z"]

extension NSData {

  /// Converts base58String into binary data. Returns nil if base58String is not a valid base58
  /// string.
  public class func fromBase58String(base58String: String) -> NSData? {
    let big58 = BigInteger(58)
    var multiplier = BigInteger(1)
    var value = BigInteger(0)
    for char in reverse(base58String) {
      if let charValue = base58CharToValueMap[char] {
        value = value + (BigInteger(Int32(charValue)) * multiplier)
      } else {
        // The string is not a valid base58 string.
        return nil
      }
      multiplier = multiplier * big58
    }
    var prefixBytes: [UInt8] = []
    for char in base58String {
      // For each leading '1', append a 0 to the base58 result.
      if char != "1" {
        break
      }
      prefixBytes.append(0)
    }
    let result = NSMutableData(bytes: prefixBytes, length: prefixBytes.count)
    result.appendData(value.data)
    return result
  }

  /// Returns base58 string representation of NSData. Leading 0's in the data are preserved as '1'
  /// in base58 encoding.
  /// If the NSData object is empty or has 0 length, returns an empty string.
  /// https://en.bitcoin.it/wiki/Base58Check_encoding
  public var base58String: String {
    let big58 = BigInteger(58)
    var value = BigInteger(data: self)
    var base58String = String()
    while value > BigInteger(0) {
      let remainder = value % big58
      value = value / big58
      if let char = base58ValueToCharMap[Int(remainder.UIntValue)] {
        base58String.append(char)
      }
    }
    for byte in self.UInt8Array {
      // For each leading 0, append a '1' to the base58 string.
      if byte != 0 {
        break
      }
      base58String.append(base58ValueToCharMap[0]!)
    }
    // Reverse the string because we have been building it backwards. It's more efficient to reverse
    // the string after we are finished, rather than appending to the front as we go.
    return base58String.reversedString
  }
  
  ///Converts hexadecimal string into binary data.
  public class func fromHexString(hexString: String) -> NSData? {
    let hexCharToValueMap: [Character: UInt8] = [
      "0":  0, "1":  1, "2":  2, "3":  3,
      "4":  4, "5":  5, "6":  6, "7":  7,
      "8":  8, "9":  9, "a": 10, "b": 11,
      "c": 12, "d": 13, "e": 14, "f": 15
    ]
    let hexChars = Array(hexString.lowercaseString)
    var byte: UInt8 = 0
    var bytes: [UInt8] = []
    for (index, char) in enumerate(hexChars) {
      if let hex = hexCharToValueMap[char] {
        byte = 16 * byte + hex
        if index % 2 == 1 {
          bytes.append(byte)
          byte = 0
        }
      } else {
        return nil
      }
    }
    return NSData(bytes: bytes, length: bytes.count)
  }
  
  /// Returns hexadecimal string representation of NSData. Empty string if data is empty.
  /// There is no leading '0x'.
  public var hexString: String {
    var hexString = String()
    for byte in self.UInt8Array {
      hexString += String(format: "%02lx", byte)
    }
    return hexString
  }
}
