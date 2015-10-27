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

  public let chainCode: SecureData
  public let index: UInt32

  /// Creates a new master extended key (both private and public).
  /// Returns the key and the randomly-generated seed used to create the key.
  public class func masterKey() -> (key: ExtendedECKey, seed: SecureData) {
    var masterKey: ExtendedECKey? = nil
    let randomData = SecureData(length: UInt(ECKey.privateKeyLength()))
    var tries = 0
    while masterKey == nil {
      let result = SecRandomCopyBytes(kSecRandomDefault,
                                      size_t(randomData.length),
                                      UnsafeMutablePointer<UInt8>(randomData.mutableBytes))
      assert(result == 0)
      masterKey = ExtendedECKey.masterKeyWithSeed(randomData)
      assert(++tries < 5)
    }
    return (masterKey!, randomData)
  }

  /// Can return nil in the (very very very very) unlikely case the randomly generated private key
  /// is invalid. If nil is returned, retry.
  public class func masterKeyWithSeed(seed: SecureData) -> ExtendedECKey? {
    let indexHash = seed.HMACSHA512WithKeyData(ExtendedECKey.masterKeySeed())
    let privateKey = indexHash[0..<32]
    let chainCode = indexHash[32..<64]
    let privateKeyInt = SecureBigInteger(secureData: privateKey)
    if privateKeyInt.isEqual(BigInteger(0)) ||
        privateKeyInt.greaterThanOrEqual(ECKey.curveOrder()) {
      return nil
    }
    return ExtendedECKey(privateKey: privateKey, chainCode: chainCode)
  }

  /// Creates a new child key derived from self with index.
  public func childKeyWithIndex(index: UInt32) -> ExtendedECKey? {
    let data = SecureData()
    if indexIsHardened(index) {
      data.appendBytes([0] as [UInt8], length: 1)
      data.appendSecureData(privateKey)
      data.appendUInt32(index, endianness: .BigEndian)
    } else {
      data.appendData(publicKey)
      data.appendUInt32(index, endianness: .BigEndian)
    }
    let indexHash = data.HMACSHA512WithKey(chainCode)
    let indexHashLInt = SecureBigInteger(secureData: indexHash[0..<32])
    let curveOrder = ECKey.curveOrder()
    if indexHashLInt.greaterThanOrEqual(curveOrder) {
      return nil
    }
    let childPrivateKeyInt = indexHashLInt.add(SecureBigInteger(secureData: privateKey),
                                               modulo:curveOrder)
    if childPrivateKeyInt.isEqual(BigInteger(0)) {
      return nil
    }
    // The BigInteger might result in data whose length is less than expected, so we pad with 0's.
    let childPrivateKey = SecureData()
    let offset = ECKey.privateKeyLength() - Int32(childPrivateKeyInt.secureData.length)
    assert(offset >= 0)
    if offset > 0 {
      let offsetBytes = [UInt8](count: Int(offset), repeatedValue: 0)
      childPrivateKey.appendBytes(offsetBytes, length: UInt(offsetBytes.count))
    }
    childPrivateKey.appendSecureData(childPrivateKeyInt.secureData)
    assert(Int32(childPrivateKey.length) == ECKey.privateKeyLength())
    let childChainCode = indexHash[32..<64]
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

  private init(privateKey: SecureData, chainCode: SecureData, index: UInt32 = 0) {
    self.chainCode = chainCode
    self.index = index
    super.init(privateKey: privateKey)
  }

  private func indexIsHardened(index: UInt32) -> Bool {
    return index >= ExtendedECKey.hardenedIndexOffset()
  }
}
