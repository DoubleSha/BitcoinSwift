//
//  PeerServices.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/18/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: PeerServices, right: PeerServices) -> Bool {
  return left.value == right.value
}

public func &(left: PeerServices, right: PeerServices) -> PeerServices {
  return PeerServices(rawValue: left.value & right.value)
}

public func |(left: PeerServices, right: PeerServices) -> PeerServices {
  return PeerServices(rawValue: left.value | right.value)
}

public func ^(left: PeerServices, right: PeerServices) -> PeerServices {
  return PeerServices(rawValue: left.value ^ right.value)
}

public prefix func ~(other: PeerServices) -> PeerServices {
  return PeerServices(rawValue: ~other.value)
}

/// Bitfield of features to be enabled for this connection.
/// https://en.bitcoin.it/wiki/Protocol_specification#version
public struct PeerServices : OptionSetType {
  private let value: UInt64

  public init(rawValue value: UInt64) { self.value = value }
  public init(nilLiteral: ()) { value = 0 }
  public var rawValue: UInt64 { return value }

  public static var allZeros: PeerServices { return PeerServices(rawValue: 0) }

  public static var None: PeerServices { return PeerServices(rawValue: 0) }
  // This node can be asked for full blocks instead of just headers.
  public static var NodeNetwork: PeerServices { return PeerServices(rawValue: 1 << 0) }
}
