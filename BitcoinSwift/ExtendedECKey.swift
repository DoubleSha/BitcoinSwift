//
//  DeterministicECKey.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/20/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation




public enum KeyType {
  case PublicKey
  case PrivateKey
}

public enum ExtendedKeyVersion {
  case MainNet
  case TestNet
  
  public var addresses:(pub:UInt32, prv: UInt32) {
    switch self {
    case .MainNet:
      return (pub:0x0488B21E, prv:0x0488ADE4)
    case .TestNet:
      return (pub:0x043587CF, prv:0x04358394)
    }
  }
  
  public func addressForKeyType(type:KeyType) -> UInt32 {
    
    let addresses = self.addresses
    return type == .PublicKey ? addresses.pub : addresses.prv
  }
}


/// An ExtendedECKey represents a key that is part of a DeterministicECKeyChain. It is just an
/// ECKey except an additional chainCode parameter and an index are used to derive the key.
/// Extended keys can be used to derive child keys.
/// BIP 32: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
public class ExtendedECKey : ECKey {
  
  public let chainCode: SecureData
  public let index: UInt32
  public let version: ExtendedKeyVersion
  public let parent: ExtendedECKey?
  
  
  // This key's identifier (this corresponds exactly to a traditional bitcoin address)
  public var identifier:NSData {
    return publicKey.SHA256Hash().RIPEMD160Hash()
  }
  
  // Return this key's fingerprint
  public var fingerprint:NSData {
    return self.identifier.subdataWithRange(NSMakeRange(0, 4))
  }
  
  // Return the parent's fingerprint. 0x0000000 if master
  public var parentFingerprint:NSData {
    if let parent = parent {
      return parent.fingerprint
    }
    else {
      let masterprint: [UInt8] = [
        0x00, 0x00, 0x00, 0x00]
      return NSData(bytes: masterprint, length: masterprint.count)
    }
  }
  
  // Find the depth of this key
  public var depth:UInt8 {
    if let parent = parent {
      return parent.depth + 1
    }
    else {
      return 0
    }
  }
  
  // True if this key has no parent
  public var isMaster:Bool {
    return self.parent == nil
  }
  
  // Find the master key by traversing the parents until a parentless key is found.
  public var master:ExtendedECKey {
    if let parent = self.parent {
      return parent.master
    }
    else {
      return self
    }
  }
  
  // Return an array of path components from the master key.
  // Add apostrophe (') to hardened indexes, and use the letter (m) to represent the master - to make an absolute path.
  public var pathComponents:Array<String> {
    if let parent = self.parent {
      if let hIndex = self.hardenedIndex {
        return parent.pathComponents + [NSNumber(unsignedInt: hIndex).stringValue + "'"]
      }
      else {
        return parent.pathComponents + [NSNumber(unsignedInt: self.index).stringValue]
      }
    }
    else {
      return ["m"]
    }
  }
  
  // Combines the path components into a string path separated with slashes (\)
  public var path:String {
    return "\\".join(self.pathComponents)
  }
  
  // Serialize the extended key data
  public func serializeExtendedKey(ofType type:KeyType = .PublicKey, version: ExtendedKeyVersion = .MainNet) -> NSMutableData {
    
    func keyDataForType(type:KeyType) -> NSData {
      
      if type == .PublicKey {
        return self.publicKey
      }
      else {
        let keyData = NSMutableData()
        keyData.appendUInt8(0x00)
        keyData.appendData(self.privateKey.mutableData)
        
        return keyData
      }
    }
    
    let extKey = NSMutableData()
    
    extKey.appendUInt32(version.addressForKeyType(type), endianness: .BigEndian)    // address
    extKey.appendUInt8(self.depth)                                                  // depth
    extKey.appendData(self.parentFingerprint)                                       // parent fingerprint
    extKey.appendUInt32(self.index, endianness: .BigEndian)                         // child number
    extKey.appendData(self.chainCode.mutableData)                                   // chain code
    extKey.appendData(keyDataForType(type))                                         // public/private key
    
    return extKey
  }
  
  // Encode the extended key into a base64check string
  public func encodeExtendedKey(ofType type:KeyType = .PublicKey, version: ExtendedKeyVersion = .MainNet) -> String {
    
    let extKey = self.serializeExtendedKey(ofType: type, version: version)
    
    let checksum = extKey.SHA256Hash().SHA256Hash().subdataWithRange(NSRange(location: 0, length: 4))
    extKey.appendData(checksum)
    
    return extKey.base58String
  }
  

  /// Creates a new master extended key (both private and public).
  /// Returns the key and the randomly-generated seed used to create the key.
  public class func masterKey(version:ExtendedKeyVersion = .MainNet) -> (key: ExtendedECKey, seed: SecureData) {
    var masterKey: ExtendedECKey? = nil
    let randomData = SecureData(length: UInt(ECKey.privateKeyLength()))
    var tries = 0
    while masterKey == nil {
      let result = SecRandomCopyBytes(kSecRandomDefault,
                                      UInt(randomData.length),
                                      UnsafeMutablePointer<UInt8>(randomData.mutableBytes))
      assert(result == 0)
      masterKey = ExtendedECKey.masterKeyWithSeed(randomData, version:version)
      assert(++tries < 5)
    }
    return (masterKey!, randomData)
  }

  /// Can return nil in the (very very very very) unlikely case the randomly generated private key
  /// is invalid. If nil is returned, retry.
  public class func masterKeyWithSeed(seed: SecureData, version:ExtendedKeyVersion = .MainNet) -> ExtendedECKey? {
    let indexHash = seed.HMACSHA512WithKeyData(ExtendedECKey.masterKeySeed())
    let privateKey = indexHash[0..<32]
    let chainCode = indexHash[32..<64]
    let privateKeyInt = SecureBigInteger(secureData: privateKey)
    if privateKeyInt.isEqual(BigInteger(0)) ||
        privateKeyInt.greaterThanOrEqual(ECKey.curveOrder()) {
      return nil
    }
    return ExtendedECKey(privateKey: privateKey, chainCode: chainCode, version:version)
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

  public func childKeyWithHardenedIndex(index: UInt32) -> ExtendedECKey? {
    // guard agains overflows
    if index > UInt32(UInt16.max) {
      return nil
    }
    return childKeyWithIndex(index + ExtendedECKey.hardenedIndexOffset())
  }

  // Derive a key from the path.
  // Supports both absolute or relative paths.
  public func derive(path:String, isAbsolute isAbsolutePath:Bool = true) -> ExtendedECKey? {
    func keyFromLinkString(link:String) -> ExtendedECKey? {
      var link = link.lowercaseString
      if first(link) == "m" {
        // only allow 'm' to be used at the begining of an absolute path or directly on the master key
        if isAbsolutePath || self.isMaster {
          return master
        }
        else {
          return nil
        }
      }
      else {
        let isHardened = last(link) == "'"
        if isHardened {
          link = dropLast(link)
        }
        if let index = NSNumberFormatter().numberFromString(link)?.unsignedIntValue {
          if isHardened {
            return self.childKeyWithHardenedIndex(index)
          }
          else {
            return self.childKeyWithIndex(index)
          }
        }
        else {
          return nil
        }
      }
    }
    
    // seporate and parse the first link in the chain
    let pathLinks = split(path, {$0 == "\\"} , maxSplit: 1, allowEmptySlices: false)
    let link = pathLinks[0]
    let key = keyFromLinkString(link)
    // derive the rest of the path untill the last link is parsed
    if pathLinks.count > 1 {
      // the sub path can not be absolute.
      return key?.derive(pathLinks[1], isAbsolute: false)
    }
    else {
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

  private init(privateKey: SecureData, chainCode: SecureData, index: UInt32 = 0, parent:ExtendedECKey? = nil, version:ExtendedKeyVersion? = nil) {
    // version setting priority is parent, then specified verion, then defaults to .MainNet
    self.version = parent != nil ? parent!.version : version != nil ? version! : .MainNet
    
    self.parent = parent
    self.chainCode = chainCode
    self.index = index
    super.init(privateKey: privateKey)
  }

  private func indexIsHardened(index: UInt32) -> Bool {
    return index >= ExtendedECKey.hardenedIndexOffset()
  }
}
