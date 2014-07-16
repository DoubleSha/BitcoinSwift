//
//  IPAddress.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/15/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

func ==(lhs: IPAddress, rhs: IPAddress) -> Bool {
  switch lhs {
    case .IPV4(let lword):
      switch rhs {
        case .IPV4(let rword):
          return lword == rword
        case .IPV6:
          return false
      }
    case .IPV6(let lword0, let lword1, let lword2, let lword3):
      switch rhs {
        case .IPV4:
          return false
        case .IPV6(let rword0, let rword1, let rword2, let rword3):
          return lword0 == rword0 && lword1 == rword1 && lword2 == rword2 && lword3 == rword3
      }
  }
}

enum IPAddress: Equatable {
  case IPV4(UInt32)
  case IPV6(UInt32, UInt32, UInt32, UInt32)
}
