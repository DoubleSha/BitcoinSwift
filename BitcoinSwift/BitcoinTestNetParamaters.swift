//
//  BitcoinTestNetParamaters.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/15/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import Foundation

public class BitcoinTestNetParameters: BitcoinParameters {

  public class func get() -> BitcoinTestNetParameters {
    // TODO: Remove this once Swift supports class vars.
    struct Static {
      static let instance = BitcoinTestNetParameters()
    }
    return Static.instance
  }

  // MARK: - TransactionParameters

  public var transactionVersion: UInt32 {
    return 1
  }

  // MARK: - AddressParameters

  public var supportedAddressHeaders: [UInt8] {
    return [publicKeyAddressHeader, P2SHAddressHeader]
  }

  public var publicKeyAddressHeader: UInt8 {
    return 111
  }

  public var P2SHAddressHeader: UInt8 {
    return 196
  }

  // MARK: - BlockHeaderParameters

  public var blockVersion: UInt32 {
    return 1
  }

  // MARK: - BlockChainStoreParameters

  public var blockChainStoreFileName: String {
    return "blockchain_testnet"
  }
  
  // MARK: - ExtendedKeyVersionParameters
  
  public var addresses: (pub:UInt32, prv: UInt32) {
    return (pub:0x043587CF, prv:0x04358394)
  }
  
  public func addressForKeyType(type:KeyType) -> UInt32 {
    return type == .PublicKey ? self.addresses.pub : self.addresses.prv
  }
}
