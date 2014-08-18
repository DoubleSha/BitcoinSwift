//
//  PeerServices.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/18/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: PeerServices, rhs: PeerServices) -> Bool {
  return lhs.value == rhs.value
}

// Bitfield of features to be enabled for this connection.
public struct PeerServices : RawOptionSetType {
  private var value: UInt64 = 0
  init(_ value: UInt64) { self.value = value }
  public var boolValue: Bool { return self.value != 0 }
  public func toRaw() -> UInt64 { return self.value }
  public static func fromRaw(raw: UInt64) -> PeerServices? { return PeerServices(raw) }
  public static func fromMask(raw: UInt64) -> PeerServices { return PeerServices(raw) }
  public static func convertFromNilLiteral() -> PeerServices { return self(0) }

  public static var None: PeerServices { return PeerServices(0) }
  // This node can be asked for full blocks instead of just headers.
  public static var NodeNetwork: PeerServices { return PeerServices(1 << 0) }
}
