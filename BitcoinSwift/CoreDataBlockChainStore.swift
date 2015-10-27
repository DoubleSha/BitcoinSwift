//
//  CoreDataBlockChainStore.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 2/10/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

import CoreData
import Foundation

/// Stores the blockchain using CoreData.
public class CoreDataBlockChainStore: BlockChainStore {

  private var context: NSManagedObjectContext!
  private let blockChainHeaderEntityName = "BlockChainHeader"
  private let blockChainHeadEntityName = "BlockChainHead"
  private let blockChainHeightEntityName = "BlockChainHeight"

  public init() {}

  public var isSetUp: Bool {
    return context != nil
  }

  /// Helper for setUpWithURL() that uses the default directory location, and the blockStoreFileName
  /// provided by params.
  /// One of the setUp functions MUST be called before using the store, and can only be called once.
  /// If setup fails, throws the error.
  public func setUpWithParams(params: BlockChainStoreParameters) throws {
    try setUpWithParams(params, dir: defaultDir)
  }

  /// Helper for setUpWithURL() that uses the provided |dir|, and the blockStoreFileName
  /// provided by params.
  /// One of the setUp functions MUST be called before using the store, and can only be called once.
  /// If setup fails, throws the error.
  public func setUpWithParams(params: BlockChainStoreParameters, dir: NSURL) throws {
    try setUpWithURL(dir.URLByAppendingPathComponent(params.blockChainStoreFileName + ".sqlite"))
  }

  /// Sets up the SQLite file a the path specified by |url|, and the CoreData managed object.
  /// This MUST be called before using the store, and can only be called once.
  /// If setup fails, throws the error.
  /// In most cases, you should just use setUpWithParams() rather than calling this directly.
  public func setUpWithURL(url: NSURL) throws {
    try setUpContextWithType(NSSQLiteStoreType, URL: url)
  }

  /// Sets up an in-memory persistent store, and the CoreData managed object.
  /// If setup fails, throws the error.
  /// This is only used for unit tests. If you want to store the blockchain in memory in your
  /// app, use the InMemoryBlockChainStore instead.
  public func setUpInMemory() throws {
    try setUpContextWithType(NSInMemoryStoreType)
  }

  public var defaultDir: NSURL {
    return NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory,
                                                           inDomains: .UserDomainMask)[0] 
  }

  /// Returns the full path of the sqlite file backing the persistent store.
  /// This is only valid after calling one of the setUp functions.
  public var URL: NSURL {
    precondition(context != nil)
    let persistentStore = context.persistentStoreCoordinator!.persistentStores[0]
        
    return persistentStore.URL!
  }

  /// Deletes the sqlite file backing the persistent store.
  /// After calling this function, one of the setUp functions must be called again in order to
  /// continue to use the same object.
  public func deletePersistentStore() throws {
    try NSFileManager.defaultManager().removeItemAtURL(URL)
    // NOTE: context won't be set to nil if an exception is thrown in the line above.
    context = nil
  }

  // MARK: - BlockChainStore

  public func height() throws -> UInt32? {
    precondition(context != nil)
    return try head()?.height
  }

  public func head() throws -> BlockChainHeader? {
    precondition(context != nil)
    var blockChainHeader: BlockChainHeader? = nil
    try context.performBlockAndWaitOrThrow() {
      if let headerEntity = try self.fetchBlockChainHeadEntity() {
        blockChainHeader = headerEntity.blockChainHeader
      }
    }
    return blockChainHeader
  }

  public func addBlockChainHeaderAsNewHead(blockChainHeader: BlockChainHeader) throws {
    precondition(context != nil)
    try context.performBlockAndWaitOrThrow() {
      // Add the block to the block store if it's not already present.
      let hash = blockChainHeader.blockHeader.hash
      if try self.fetchBlockChainHeaderEntityWithHash(hash) != nil {
        // The blockChainHeader already exists, so there's nothing to do.
      } else {
        // The blockChainHeader doesn't exist, so create a new entity for it.
        let headerEntity =
            NSEntityDescription.insertNewObjectForEntityForName(self.blockChainHeaderEntityName,
                inManagedObjectContext: self.context) as! BlockChainHeaderEntity
        headerEntity.setBlockChainHeader(blockChainHeader)
      }

      // Update the head entity as the new block.
      do {
        if let headEntity = try self.fetchBlockChainHeadEntity() {
          if blockChainHeader == headEntity.blockChainHeader {
            // The head is already the correct value, so there is nothing more to do.
            try self.attemptToSave()
            return
          } else {
            // Delete the old head entity so we can replace it (below) with the new head entity.
            self.context.deleteObject(headEntity)
          }
        }
      } catch let innerError as NSError {
        self.context.undo()
        throw innerError
      }
      let headEntity =
          NSEntityDescription.insertNewObjectForEntityForName(self.blockChainHeadEntityName,
              inManagedObjectContext: self.context) as! BlockChainHeaderEntity
      headEntity.setBlockChainHeader(blockChainHeader)
      try self.attemptToSave()
    }
  }

  public func deleteBlockChainHeaderWithHash(hash: SHA256Hash) throws {
    precondition(context != nil)
    try context.performBlockAndWaitOrThrow() {
      if let headerEntity = try self.fetchBlockChainHeaderEntityWithHash(hash) {
        self.context.deleteObject(headerEntity)
        try self.attemptToSave()
      }
    }
  }

  public func blockChainHeaderWithHash(hash: SHA256Hash) throws -> BlockChainHeader? {
    precondition(context != nil)
    var blockChainHeader: BlockChainHeader? = nil
    try context.performBlockAndWaitOrThrow() {
      if let headerEntity = try self.fetchBlockChainHeaderEntityWithHash(hash) {
        blockChainHeader = headerEntity.blockChainHeader
      }
    }
    return blockChainHeader
  }

  // MARK: - Private Methods

  /// Sets up the context ivar with the provided type and URL.
  /// URL can be nil if the type is NSInMemoryStoreType.
  private func setUpContextWithType(type: NSString, URL: NSURL? = nil) throws {
    precondition(context == nil)
    let bundle = NSBundle(forClass: self.dynamicType)
    let model = NSManagedObjectModel.mergedModelFromBundles([bundle])!
    context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    do {
      try context.persistentStoreCoordinator!.addPersistentStoreWithType(type as String,
                                                                         configuration: nil,
                                                                         URL: URL,
                                                                         options: nil)
    } catch let error as NSError {
      Logger.error("Failed to setup CoreDataBlockChainStore \(error)")
      context = nil
      throw error
    }
  }

  /// Returns the BlockChainHeaderEntity keyed by the given hash, or nil if not found.
  /// This MUST be called from within context.performBlock().
  private func fetchBlockChainHeaderEntityWithHash(hash: SHA256Hash) throws
      -> BlockChainHeaderEntity? {
    let request = NSFetchRequest(entityName: blockChainHeaderEntityName)
    request.predicate = NSPredicate(format: "blockHash == %@", hash.data)
    let results = try self.context.executeFetchRequest(request)
    assert(results.count <= 1)
    if results.count > 0 {
      return (results[0] as! BlockChainHeaderEntity)
    }
    return nil
  }

  /// Returns the BlockChainHeaderEntity that is currently the head of the blockchain, or nil if
  /// not found. This MUST be called from within context.performBlock().
  private func fetchBlockChainHeadEntity() throws -> BlockChainHeaderEntity? {
    let request = NSFetchRequest(entityName: blockChainHeadEntityName)
    let results = try self.context.executeFetchRequest(request)
    assert(results.count <= 1)
    if results.count > 0 {
      return (results[0] as! BlockChainHeaderEntity)
    }
    return nil
  }

  /// Attempts to save changes to context. If there is an error, all changes to context are undone
  /// and the error is thrown.
  private func attemptToSave() throws {
    do {
      try context.save()
    } catch let error as NSError {
      self.context.undo()
      throw error
    }
  }
}
