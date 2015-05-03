//
//  OSKeyChainSecureDataStore.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/27/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import Foundation
import Security

/// Stores the data using the OSX/iOS secure keychain service.
public class OSKeyChainSecureDataStore: SecureDataStore {

  /// The name for your service. This should be a unique value, such as "com.mycompany.myapp".
  public let service: String

  public init(service: String) {
    self.service = service
  }

  public func dataForKey(key: String) -> SecureData? {
    var query = NSMutableDictionary()
    query.setObject("\(kSecClassGenericPassword)", forKey: "\(kSecClass)")
    query.setObject(service, forKey: "\(kSecAttrService)")
    query.setObject(key, forKey: "\(kSecAttrAccount)")
    query.setObject(true, forKey: "\(kSecReturnData)")
    var result = UnsafeMutablePointer<Unmanaged<AnyObject>?>.alloc(1)
    result.initialize(nil)
    let status = SecItemCopyMatching(query, result)
    if status == errSecItemNotFound {
      return nil
    }
    if status != noErr {
      return nil
    }
    let data = result.memory!.takeUnretainedValue() as! NSData
    let secureData = SecureData(data: data)
    result.dealloc(1)
    return secureData
  }

  public func saveData(data: SecureData, forKey key: String) -> Bool {
    precondition(dataForKey(key) == nil, "SecureData already exists with for key \(key)")
    var item = NSMutableDictionary()
    // This prevents the key from being copied to Apple servers.
    item.setObject("\(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)",
                   forKey: "\(kSecAttrAccessible)")
    item.setObject("\(kSecClassGenericPassword)", forKey: "\(kSecClass)")
    item.setObject(service, forKey: "\(kSecAttrService)")
    item.setObject(key, forKey: "\(kSecAttrAccount)")
    item.setObject(data.data, forKey: "\(kSecValueData)")
    return SecItemAdd(item, nil) == noErr
  }

  public func deleteDataForKey(key: String) -> Bool {
    var query = NSMutableDictionary()
    query.setObject("\(kSecClassGenericPassword)", forKey: "\(kSecClass)")
    query.setObject(service, forKey: "\(kSecAttrService)")
    query.setObject(key, forKey: "\(kSecAttrAccount)")
    return SecItemDelete(query) == noErr
  }
}
