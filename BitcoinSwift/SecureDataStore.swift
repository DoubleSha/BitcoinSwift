//
//  SecureDataStore.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/27/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import Foundation

/// Used to store SecureData indexed by a String key.
public protocol SecureDataStore {

  /// Returns the data for the given key, or nil if not found.
  func dataForKey(key: String) -> SecureData?

  /// Saves the data, indexed by the given key. This must only be called if there is not a value
  /// already present with the same key.
  func saveData(data: SecureData, forKey key: String) -> Bool

  /// Deletes the data for the given key. This must only be called if a value exists for the given
  /// key.
  func deleteDataForKey(key: String) -> Bool
}
