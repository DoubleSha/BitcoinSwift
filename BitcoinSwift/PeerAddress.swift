//
//  PeerAddress.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/4/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

func ==(lhs: PeerAddress, rhs: PeerAddress) -> Bool {
  return lhs.services == rhs.services &&
      lhs.IP == rhs.IP &&
      lhs.port == rhs.port
}

struct PeerAddress: Equatable {
  let services: Message.Services
  let IP: IPAddress
  let port: UInt16
}
