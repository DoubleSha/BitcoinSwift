//
//  Address.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/19/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public protocol AddressParameters {

  /// Returns an array of all supported headers. Used to validate addresses when created from a
  /// string value.
  var supportedAddressHeaders: [UInt8] { get }

  /// Header to use for an address created from a public key.
  var publicKeyAddressHeader: UInt8 { get }

  /// Header to use for an address created from a P2SH hash.
  var P2SHAddressHeader: UInt8 { get }
}

public func ==(left: Address, right: Address) -> Bool {
  return left.hash160 == right.hash160
}

public struct Address: Equatable {

  public let header: UInt8
  public let hash160: NSData

  public var stringValue: String {
    var data = NSMutableData()
    data.appendUInt8(header)
    data.appendData(hash160)
    data.appendData(checksumForData(data))
    return data.base58String
  }

  public var checksum: NSData {
    var data = NSMutableData()
    data.appendUInt8(header)
    data.appendData(hash160)
    return checksumForData(data)
  }

  public init(params: AddressParameters, key: ECKey) {
    self.init(header: params.publicKeyAddressHeader,
              hash160: key.publicKey.SHA256Hash().RIPEMD160Hash())
  }

  public init(params: AddressParameters, scriptHash: NSData) {
    self.init(header: params.P2SHAddressHeader, hash160: scriptHash)
  }

  /// Creates an address from a base 58 encoded string. Returns nil if the address is not valid.
  /// If params is nil, the header will not be verified.
  /// If params is not nil, returns nil if the header does not match a known value.
  public init?(params: AddressParameters?, stringValue: String) {
    let stringLength = count(stringValue)
    if stringLength > 35 || stringLength < 26 {
      Logger.debug("Invalid Address \(stringValue)")
      return nil
    }
    let data: NSData! = NSMutableData.fromBase58String(stringValue)
    if data == nil {
      Logger.debug("Invalid Address \(stringValue) base58 decoding failed")
      return nil
    }
    // Data is comprised of: header (1 byte) + hash160 (20 bytes) + checksum (4 bytes).
    if data.length != 25 {
      Logger.debug("Invalid Address: \(stringValue)")
      return nil
    }
    let inputStream = NSInputStream(data: data)
    inputStream.open()
    header = inputStream.readUInt8()!
    hash160 = inputStream.readData(length: 20)!
    let checksum = inputStream.readData(length: 4)!
    inputStream.close()
    if self.checksum != checksum {
      Logger.debug("Invalid Address \(stringValue) checksum failed")
      return nil
    }
    if let supportedAddressHeaders = params?.supportedAddressHeaders {
      if find(supportedAddressHeaders, header) == nil {
        Logger.debug("Invalid Address \(stringValue) unsupported header")
        return nil
      }
    }
  }

  public init(header: UInt8, hash160: NSData) {
    precondition(hash160.length == 20)
    self.header = header
    self.hash160 = hash160
  }

  // MARK: - Private Methods

  private func checksumForData(data: NSData) -> NSData {
    return data.SHA256Hash().SHA256Hash().subdataWithRange(NSRange(location: 0, length: 4))
  }
}
