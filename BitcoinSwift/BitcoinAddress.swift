//
//  BitcoinAddress.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/19/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

// TODO: Decide if/how this is needed.
protocol BitcoinAddressParameters {
  var publicKeyVersionHeader: UInt8 { get }
  var P2SHVersionHeader: UInt8 { get }
}

public struct BitcoinAddress {

  public let address: String

  public init(versionHeader: UInt8, payload: NSData) {
    var addressBytes = NSMutableData(bytes:[versionHeader] as [UInt8], length:1)
    addressBytes.appendData(payload.SHA256Hash().RIPEMD160Hash())
    var checksum = addressBytes.SHA256Hash().SHA256Hash()
        .subdataWithRange(NSRange(location:0, length:4))
    addressBytes.appendData(checksum)
    address = addressBytes.base58String()
  }
}
