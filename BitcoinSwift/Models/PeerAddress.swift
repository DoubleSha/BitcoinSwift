//
//  PeerAddress.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/4/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: PeerAddress, right: PeerAddress) -> Bool {
  return left.services == right.services &&
      left.IP == right.IP &&
      left.port == right.port &&
      left.timestamp == right.timestamp
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

extension PeerAddress: BitcoinSerializable {

  public var bitcoinData: NSData {
    return bitcoinDataWithTimestamp(true)
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> PeerAddress? {
    return PeerAddress.fromBitcoinStream(stream, includeTimestamp: true)
  }

  public func bitcoinDataWithTimestamp(includeTimestamp: Bool) -> NSData {
    let data = NSMutableData()
    if includeTimestamp {
      if let timestamp = timestamp {
        data.appendDateAs32BitUnixTimestamp(timestamp)
      } else {
        data.appendDateAs32BitUnixTimestamp(NSDate())
      }
    }
    data.appendUInt64(services.rawValue)
    data.appendData(IP.bitcoinData)
    data.appendUInt16(port, endianness: .BigEndian)  // Network byte order.
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream,
                                       includeTimestamp: Bool) -> PeerAddress? {
    var timestamp: NSDate? = nil
    if includeTimestamp {
      timestamp = stream.readDateFrom32BitUnixTimestamp()
      if timestamp == nil {
        Logger.warn("Failed to parse timestamp from PeerAddress")
        return nil
      }
    }
    let servicesRaw = stream.readUInt64()
    if servicesRaw == nil {
      Logger.warn("Failed to parse servicesRaw from PeerAddress")
      return nil
    }
    let services = PeerServices(rawValue: servicesRaw!)
    let IP = IPAddress.fromBitcoinStream(stream)
    if IP == nil {
      Logger.warn("Failed to parse IP from PeerAddress")
      return nil
    }
    let port = stream.readUInt16(.BigEndian)  // Network byte order.
    if port == nil {
      Logger.warn("Failed to parse port from PeerAddress")
      return nil
    }
    return PeerAddress(services: services, IP: IP!, port: port!, timestamp: timestamp)
  }
}
