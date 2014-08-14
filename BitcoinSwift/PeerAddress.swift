//
//  PeerAddress.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/4/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: PeerAddress, rhs: PeerAddress) -> Bool {
  return lhs.services == rhs.services &&
      lhs.IP == rhs.IP &&
      lhs.port == rhs.port
}

public struct PeerAddress: Equatable {

  public let services: Message.Services
  public let IP: IPAddress
  public let port: UInt16

  public init(services: Message.Services, IP: IPAddress, port: UInt16) {
    self.services = services
    self.IP = IP
    self.port = port
  }
}
