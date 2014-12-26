//
//  DeterministicECKey.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/20/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

/// An ExtendedECKey represents a key that is part of a DeterministicECKeyChain. It is just an
/// ECKey except an additional chainCode parameter and an index are used to derive the key.
/// Extended keys can be used to derive child keys.
/// BIP 32: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
public class ExtendedECKey : ECKey {

  public let chainCode: NSData
  public let index: UInt32

  /// Creates a new master extended key (both private and public).
  /// Can return nil in the unlikely case the randomly generated private key is invalid. If nil is
  /// returned, retry.
  public class func masterKey() -> ExtendedECKey? {
    let randomData = NSMutableData(length: 32)!
    let result = SecRandomCopyBytes(kSecRandomDefault,
                                    UInt(randomData.length),
                                    UnsafeMutablePointer<UInt8>(randomData.mutableBytes))
    assert(result == 0)
    return ExtendedECKey.masterKeyWithSeed(randomData)
  }

  public class func masterKeyWithSeed(seed: NSData) -> ExtendedECKey? {
    // TODO: Use securely allocated data here.
    let indexHash = seed.HMACSHA512WithKey(ExtendedECKey.masterKeySeed())
    let privateKey = indexHash.subdataWithRange(NSRange(location: 0, length: 32))
    let chainCode = indexHash.subdataWithRange(NSRange(location: 32, length: 32))
    let privateKeyInt = BigInteger(secureData: privateKey)
    if privateKeyInt == BigInteger(0) || privateKeyInt >= ECKey.curveOrder() {
      return nil
    }
    return ExtendedECKey(privateKey: privateKey, chainCode: chainCode)
  }

  /// Creates a new child key derived from self with index.
  public func childKeyWithIndex(index: UInt32) -> ExtendedECKey? {
    var data = NSMutableData()
    if indexIsHardened(index) {
      data.appendBytes([0] as [UInt8], length: 1)
      data.appendData(privateKey)
      data.appendUInt32(index, endianness: .BigEndian)
    } else {
      data.appendData(publicKey)
      data.appendUInt32(index, endianness: .BigEndian)
    }
    // TODO: Use securely allocated data here.
    let indexHash = data.HMACSHA512WithKey(chainCode)
    let indexHashLInt =
        BigInteger(secureData: indexHash.subdataWithRange(NSRange(location: 0, length: 32)))
    let curveOrder = ECKey.curveOrder()
    if indexHashLInt >= curveOrder {
      return nil
    }
    let childPrivateKeyInt = indexHashLInt.add(BigInteger(secureData: privateKey),
                                               modulo:curveOrder)
    if childPrivateKeyInt == BigInteger(0) {
      return nil
    }
    let childPrivateKey = childPrivateKeyInt.data
    assert(childPrivateKey.length == 32)
    let childChainCode = indexHash.subdataWithRange(NSRange(location: 32, length: 32))
    return ExtendedECKey(privateKey: childPrivateKey, chainCode: childChainCode, index: index)
  }

  public func childKeyWithHardenedIndex(index: UInt32) -> ExtendedECKey? {
    return childKeyWithIndex(index + ExtendedECKey.hardenedIndexOffset())
  }

  /// Returns whether or not this key is hardened. A hardened key has more secure properties.
  /// In general, you should always use a hardened key as the master key when deriving a
  /// deterministic key chain where the keys in that chain will be published to the blockchain.
  public var hardened: Bool {
    return indexIsHardened(index)
  }

  /// Returns nil if the index is not hardened.
  public var hardenedIndex: UInt32? {
    return hardened ? index - ExtendedECKey.hardenedIndexOffset() : nil
  }

  // MARK: - Private Methods.

  // TODO: Make this a class var instead of a func once Swift adds support for that.
  private class func masterKeySeed() -> NSData {
    return ("Bitcoin seed" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
  }

  // TODO: Make this a class var instead of a func once Swift adds support for that.
  private class func hardenedIndexOffset() -> UInt32 {
    return 0x80000000
  }

  private init(privateKey: NSData, chainCode: NSData, index: UInt32 = 0) {
    self.chainCode = chainCode
    self.index = index
    super.init(privateKey: privateKey)
  }

  private init(publicKey: NSData, chainCode: NSData, index: UInt32 = 0) {
    self.chainCode = chainCode
    self.index = index
    super.init(publicKey: publicKey)
  }

  private convenience init(privateKey: NSData, chainCode: NSData, hardenedIndex: UInt32) {
    let index = hardenedIndex + ExtendedECKey.hardenedIndexOffset()
    self.init(privateKey: privateKey, chainCode: chainCode, index: index)
  }

  private convenience init(publicKey: NSData, chainCode: NSData, hardenedIndex: UInt32) {
    let index = hardenedIndex + ExtendedECKey.hardenedIndexOffset()
    self.init(publicKey: publicKey, chainCode: chainCode, index: hardenedIndex)
  }

  private func indexIsHardened(index: UInt32) -> Bool {
    return index >= ExtendedECKey.hardenedIndexOffset()
  }
}
