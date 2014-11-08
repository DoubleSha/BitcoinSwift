//
//  IPAddress.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/15/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: IPAddress, rhs: IPAddress) -> Bool {
  switch (lhs, rhs) {
    case (.IPV4(let lhsWord), .IPV4(let rhsWord)): 
      return lhsWord == rhsWord
    case (.IPV6(let lhsWord0, let lhsWord1, let lhsWord2, let lhsWord3),
          .IPV6(let rhsWord0, let rhsWord1, let rhsWord2, let rhsWord3)): 
      return lhsWord0 == rhsWord0 &&
          lhsWord1 == rhsWord1 &&
          lhsWord2 == rhsWord2 &&
          lhsWord3 == rhsWord3
    default: 
      return false
  }
}

public enum IPAddress: Equatable {
  case IPV4(UInt32)
  case IPV6(UInt32, UInt32, UInt32, UInt32)

  // TODO: Make this conform to BitcoinSerializable.
}
