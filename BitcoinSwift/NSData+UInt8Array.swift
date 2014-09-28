//
//  NSData+UInt8Array.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/19/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public extension NSData {

  public func UInt8Array() -> [UInt8] {
    var UInt8Array = [UInt8](count: self.length, repeatedValue: 0)
    getBytes(&UInt8Array, length: self.length)
    return UInt8Array
  }
}
