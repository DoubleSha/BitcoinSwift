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
  
  public var extendedPublicKeyVersion: NSData {
    let publicKeyVersion: [UInt8] = [0x04, 0x35, 0x87, 0xcf]
    return NSData(bytes: publicKeyVersion, length: publicKeyVersion.count)
  }
  public var extendedPrivateKeyVersion: NSData {
    let privateKeyVersion: [UInt8] = [0x04, 0x35, 0x83, 0x94]
    return NSData(bytes: privateKeyVersion, length: privateKeyVersion.count)
  }
}
