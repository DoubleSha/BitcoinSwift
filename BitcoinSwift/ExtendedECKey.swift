//
//  DeterministicECKey.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/20/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public protocol ExtendedKeyVersionParameters: class {
  
  var extendedPublicKeyVersion: NSData { get }
  var extendedPrivateKeyVersion: NSData { get }
}


/// An ExtendedECKey represents a key that is part of a DeterministicECKeyChain. It is just an
/// ECKey except an additional chainCode parameter and an index are used to derive the key.
/// Extended keys can be used to derive child keys.
/// BIP 32: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
public class ExtendedECKey : ECKey {
  
  public let chainCode: SecureData
  public let index: UInt32
  public let params: ExtendedKeyVersionParameters
  public let parent: ExtendedECKey?
  
  /// Returns the key's identifier (this corresponds exactly to a traditional bitcoin address).
  public var identifier: NSData {
    return publicKey.SHA256Hash().RIPEMD160Hash()
  }
  
  /// Returns this key's fingerprint.
  public var fingerprint: NSData {
    return self.identifier.subdataWithRange(NSMakeRange(0, 4))
  }
  
  private class func masterParentFingerprint() -> NSData {
    // TODO: Remove this once Swift supports class vars.
    struct Static {
      static let masterParentFingerprint: [UInt8] = [0x00, 0x00, 0x00, 0x00]
    }
    return NSData(bytes: Static.masterParentFingerprint,
                 length: Static.masterParentFingerprint.count)
  }
  
  private class func pathSeporator() -> Character {
    // TODO: Remove this once Swift supports class vars.
    struct Static {
      static let pathSeporator: Character = "/"
    }
    return Static.pathSeporator
  }
  
  /// Returns the parent's fingerprint. 0x0000000 if master.
  public var parentFingerprint: NSData {
    if let parent = parent {
      return parent.fingerprint
    } else {
      return ExtendedECKey.masterParentFingerprint()
    }
  }
  
  /// Returns the depth of this key.
  public var depth: UInt8 {
    if let parent = parent {
      return parent.depth + 1
    } else {
      return 0
    }
  }
  
  /// Returns true if this key has no parent.
  public var isMaster: Bool {
    return parent == nil
  }
  
  /// Returns the master key by traversing the parents until a parentless key is found.
  public var master: ExtendedECKey {
    if let parent = self.parent {
      return parent.master
    } else {
      return self
    }
  }
  
  /// Returns an array of path components from the master key.
  /// Adding apostrophe (') to hardened indexes, and use the letter (m) to represent the master
  public var pathComponents: Array<String> {
    if let parent = self.parent {
      if let hIndex = self.hardenedIndex {
        return parent.pathComponents + [NSNumber(unsignedInt: hIndex).stringValue + "'"]
      } else {
        return parent.pathComponents + [NSNumber(unsignedInt: self.index).stringValue]
      }
    } else {
      return ["m"]
    }
  }
  
  /// Returns the absolute path string.
  public var path: String {
    let seporator = String(ExtendedECKey.pathSeporator())
    return seporator.join(self.pathComponents)
  }
  
  private func serializedExtendedKey(#version: NSData, keyData: NSData) -> NSMutableData {
    let extKey = NSMutableData()
    
    extKey.appendData(version)                              // version
    extKey.appendUInt8(self.depth)                          // depth
    extKey.appendData(self.parentFingerprint)               // parent fingerprint
    extKey.appendUInt32(self.index, endianness: .BigEndian) // child number
    extKey.appendData(self.chainCode.mutableData)           // chain code
    extKey.appendData(keyData)                              // public/private key
    
    return extKey
  }
  
  private func encodedExtendedKey(extendedKey:NSData) -> String {
    let keyData = NSMutableData(data: extendedKey)
    let checksum = extendedKey.SHA256Hash().SHA256Hash().subdataWithRange(NSRange(location: 0, length: 4))
    keyData.appendData(checksum)
    
    return keyData.base58String
  }
  
  /// return a serialized public key data.
  public func serializedExtendedPublicKey(params: ExtendedKeyVersionParameters = BitcoinMainNetParameters.get()) -> NSMutableData {
    return serializedExtendedKey(version: params.extendedPublicKeyVersion, keyData: self.publicKey)
  }
  
  /// return a serialized private key data.
  public func serializedExtendedPrivateKey(params: ExtendedKeyVersionParameters = BitcoinMainNetParameters.get()) -> NSMutableData {
    let keyData = NSMutableData()
    keyData.appendUInt8(0x00)
    keyData.appendData(self.privateKey.mutableData)
    
    return serializedExtendedKey(version: params.extendedPrivateKeyVersion, keyData: keyData)
  }
  
  /// return a Base58 encoded public key.
  public func encodedExtendedPublicKey(params: ExtendedKeyVersionParameters = BitcoinMainNetParameters.get()) -> String {
    return encodedExtendedKey(serializedExtendedPublicKey(params: params))
  }
  
  /// return a Base58 encoded private key.
  public func encodedExtendedPrivateKey(params: ExtendedKeyVersionParameters = BitcoinMainNetParameters.get()) -> String {
    return encodedExtendedKey(serializedExtendedPrivateKey(params: params))
  }

  /// Creates a new master extended key (both private and public).
  /// Returns the key and the randomly-generated seed used to create the key.
  public class func masterKey(params: ExtendedKeyVersionParameters = BitcoinMainNetParameters.get()) -> (key: ExtendedECKey, seed: SecureData) {
    var masterKey: ExtendedECKey? = nil
    let randomData = SecureData(length: UInt(ECKey.privateKeyLength()))
    var tries = 0
    while masterKey == nil {
      let result = SecRandomCopyBytes(kSecRandomDefault,
                                      UInt(randomData.length),
                                      UnsafeMutablePointer<UInt8>(randomData.mutableBytes))
      assert(result == 0)
      masterKey = ExtendedECKey.masterKeyWithSeed(randomData, params: params)
      assert(++tries < 5)
    }
    return (masterKey!, randomData)
  }

  /// Can return nil in the (very very very very) unlikely case the randomly generated private key
  /// is invalid. If nil is returned, retry.
  public class func masterKeyWithSeed(seed: SecureData, params: ExtendedKeyVersionParameters = BitcoinMainNetParameters.get()) -> ExtendedECKey? {
    let indexHash = seed.HMACSHA512WithKeyData(ExtendedECKey.masterKeySeed())
    let privateKey = indexHash[0..<32]
    let chainCode = indexHash[32..<64]
    let privateKeyInt = SecureBigInteger(secureData: privateKey)
    if privateKeyInt.isEqual(BigInteger(0)) ||
        privateKeyInt.greaterThanOrEqual(ECKey.curveOrder()) {
      return nil
    }
    return ExtendedECKey(privateKey: privateKey, chainCode: chainCode, params:params)
  }

  /// Creates a new child key derived from self with index.
  public func childKeyWithIndex(index: UInt32) -> ExtendedECKey? {
    var data = SecureData()
    if indexIsHardened(index) {
      data.appendBytes([0] as [UInt8], length: 1)
      data.appendSecureData(privateKey)
      data.appendUInt32(index, endianness: .BigEndian)
    } else {
      data.appendData(publicKey)
      data.appendUInt32(index, endianness: .BigEndian)
    }
    var indexHash = data.HMACSHA512WithKey(chainCode)
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
    var childPrivateKey = SecureData()
    let offset = ECKey.privateKeyLength() - Int32(childPrivateKeyInt.secureData.length)
    assert(offset >= 0)
    if offset > 0 {
      let offsetBytes = [UInt8](count: Int(offset), repeatedValue: 0)
      childPrivateKey.appendBytes(offsetBytes, length: UInt(offsetBytes.count))
    }
    childPrivateKey.appendSecureData(childPrivateKeyInt.secureData)
    assert(Int32(childPrivateKey.length) == ECKey.privateKeyLength())
    let childChainCode = indexHash[32..<64]
    return ExtendedECKey(privateKey: childPrivateKey, chainCode: childChainCode, index: index, parent:self)
  }
  
  /// Returns a new hardened child key derived from self with index.
  public func childKeyWithHardenedIndex(index: UInt32) -> ExtendedECKey? {
    // guard agains overflows
    if index > UInt32.max / 2 {
      return nil
    }
    return childKeyWithIndex(index + ExtendedECKey.hardenedIndexOffset())
  }

  /// Derive a key from the path.
  /// Supports both absolute or relative paths.
  /// The format is '/' delimitered, while 'm' represents the master key, and ' appended indexes
  /// represend hardened indexes.
  /// This follows the Bip32, which can be found here:
  /// https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
  public func deriveFromExtendedKeyPath(path: String, isAbsolute isAbsolutePath: Bool = true) -> ExtendedECKey? {
    func keyFromLinkString(link: String) -> ExtendedECKey? {
      var link = link.lowercaseString
      if first(link) == "m" {
        // only allow 'm' to be used at the begining of an absolute path or directly on the master key
        if isAbsolutePath || self.isMaster {
          return master
        } else {
          return nil
        }
      } else {
        let isHardened = last(link) == "'"
        if isHardened {
          link = dropLast(link)
        }
        if let index = NSNumberFormatter().numberFromString(link)?.unsignedIntValue {
          if isHardened {
            return self.childKeyWithHardenedIndex(index)
          } else {
            return self.childKeyWithIndex(index)
          }
        } else {
          return nil
        }
      }
    }
    
    // seporate and parse the first link in the chain.
    let pathLinks = split(path,
                          {$0 == ExtendedECKey.pathSeporator()},
                          maxSplit: 1,
                          allowEmptySlices: false)
    let link = pathLinks[0]
    let key = keyFromLinkString(link)
    // derive the rest of the path untill the last link is parsed.
    if pathLinks.count > 1 {
      // the sub path can not be absolute.
      return key?.deriveFromExtendedKeyPath(pathLinks[1], isAbsolute: false)
    } else {
      return key
    }
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

  private init(privateKey: SecureData, chainCode: SecureData, index: UInt32 = 0, parent: ExtendedECKey? = nil, params: ExtendedKeyVersionParameters? = nil) {
    // params setting priority is parent, then specified verion, then defaults to MainNet.
    self.params = parent != nil ? parent!.params : params != nil ? params! : BitcoinMainNetParameters.get()
    
    self.parent = parent
    self.chainCode = chainCode
    self.index = index
    super.init(privateKey: privateKey)
  }

  private func indexIsHardened(index: UInt32) -> Bool {
    return index >= ExtendedECKey.hardenedIndexOffset()
  }
}
