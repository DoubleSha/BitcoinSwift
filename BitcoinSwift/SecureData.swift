//
//  SecureData.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/30/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: SecureData, right: SecureData) -> Bool {
  return left.mutableData == right.mutableData
}

public class SecureData: Equatable {

  private let mutableData: NSMutableData

  public var mutableBytes: UnsafeMutablePointer<Void> {
    return mutableData.mutableBytes
  }

  public var bytes: UnsafePointer<Void> {
    return mutableData.bytes
  }

  public var length: Int {
    return mutableData.length
  }

  public subscript(subRange: Range<Int>) -> SecureData {
    precondition(mutableData.length > 0)
    precondition(subRange.startIndex >= 0 && subRange.startIndex < mutableData.length)
    precondition(subRange.endIndex > subRange.startIndex &&
        subRange.endIndex <= mutableData.length)
    let length = subRange.endIndex - subRange.startIndex
    let range = NSRange(location: subRange.startIndex, length: length)
    var subData = SecureData(length: length)
    memcpy(subData.mutableBytes, bytes.advancedBy(subRange.startIndex), UInt(length))
    return subData
  }

  public init() {
    mutableData = CFDataCreateMutable(SecureMemoryAllocator.allocator().takeUnretainedValue() , 0)
  }

  public init(length: Int) {
    mutableData =
        CFDataCreateMutable(SecureMemoryAllocator.allocator().takeUnretainedValue(), length)
    mutableData.length = length
  }

  public convenience init(bytes: UnsafePointer<Void>, length: Int) {
    self.init(length: length)
    memcpy(mutableBytes, bytes, UInt(length))
  }
}
