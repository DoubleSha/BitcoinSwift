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
      lhs.port == rhs.port &&
      lhs.timestamp == rhs.timestamp
}

/// Used to represent networks addresses of peers over the wire.
/// https://en.bitcoin.it/wiki/Protocol_specification#Network_address
public struct PeerAddress: Equatable {

  public let services: PeerServices
  public let IP: IPAddress
  public let port: UInt16
  public var timestamp: NSDate?

  public init(services: PeerServices, IP: IPAddress, port: UInt16, timestamp: NSDate? = nil) {
    self.services = services
    self.IP = IP
    self.port = port
    self.timestamp = timestamp
  }
}
