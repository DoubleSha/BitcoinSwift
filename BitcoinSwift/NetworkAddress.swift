//
//  NetworkAddress.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/4/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

func ==(lhs: NetworkAddress, rhs: NetworkAddress) -> Bool {
  return lhs.services == rhs.services &&
      lhs.IP == rhs.IP &&
      lhs.port == rhs.port
}

func ==(lhs: NetworkAddress.IPAddress, rhs: NetworkAddress.IPAddress) -> Bool {
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

struct NetworkAddress: Equatable {

  enum IPAddress: Equatable {
    case IPV4(UInt32)
    case IPV6(UInt32, UInt32, UInt32, UInt32)
  }

  let services: Message.Services
  let IP: IPAddress
  let port: UInt16
}
