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
  /// If setup fails, returns the error.
  public func setUpWithParams(params: BlockChainStoreParameters) -> NSError? {
    return setUpWithParams(params, dir: defaultDir)
  }

  /// Helper for setUpWithURL() that uses the provided |dir|, and the blockStoreFileName
  /// provided by params.
  /// One of the setUp functions MUST be called before using the store, and can only be called once.
  /// If setup fails, returns the error.
  public func setUpWithParams(params: BlockChainStoreParameters, dir: NSURL) -> NSError? {
    return setUpWithURL(dir.URLByAppendingPathComponent(params.blockChainStoreFileName + ".sqlite"))
  }

  /// Sets up the SQLite file a the path specified by |url|, and the CoreData managed object.
  /// This MUST be called before using the store, and can only be called once.
  /// If setup fails, returns the error.
  /// In most cases, you should just use setUpWithParams() rather than calling this directly.
  public func setUpWithURL(url: NSURL) -> NSError? {
    return setUpContextWithType(NSSQLiteStoreType, URL: url)
  }

  /// Sets up an in-memory persistent store, and the CoreData managed object.
  /// If setup fails, returns the error.
  /// This is only used for unit tests. If you want to store the blockchain in memory in your
  /// app, use the InMemoryBlockChainStore instead.
  public func setUpInMemory() -> NSError? {
    return setUpContextWithType(NSInMemoryStoreType)
  }

  public var defaultDir: NSURL {
    return NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory,
                                                           inDomains: .UserDomainMask)[0] as! NSURL
  }

  /// Returns the full path of the sqlite file backing the persistent store.
  /// This is only valid after calling one of the setUp functions.
  public var URL: NSURL {
    precondition(context != nil)
    let persistentStore = context.persistentStoreCoordinator!.persistentStores[0]
        as! NSPersistentStore
    return persistentStore.URL!
  }

  /// Deletes the sqlite file backing the persistent store.
  /// After calling this function, one of the setUp functions must be called again in order to
  /// continue to use the same object.
  public func deletePersistentStore() -> NSError? {
    var error: NSError?
    NSFileManager.defaultManager().removeItemAtPath(URL.absoluteString!, error: &error)
    if error == nil {
      context = nil
    }
    return error
  }

  // MARK: - BlockChainStore

  public func height(error: NSErrorPointer) -> UInt32? {
    precondition(context != nil)
    return head(error)?.height
  }

  public func head(error: NSErrorPointer) -> BlockChainHeader? {
    precondition(context != nil)
    var blockChainHeader: BlockChainHeader? = nil
    context.performBlockAndWait() {
      if let headerEntity = self.fetchBlockChainHeadEntity(error) {
        blockChainHeader = headerEntity.blockChainHeader
      }
    }
    return blockChainHeader
  }

  public func addBlockChainHeaderAsNewHead(blockChainHeader: BlockChainHeader,
                                           error: NSErrorPointer) {
    precondition(context != nil)
    context.performBlockAndWait() {
      var internalError: NSError?
      // Add the block to the block store if it's not already present.
      let hash = blockChainHeader.blockHeader.hash
      if self.fetchBlockChainHeaderEntityWithHash(hash, error: &internalError) != nil {
        // The blockChainHeader already exists, so there's nothing to do.
      } else if internalError != nil {
        if error != nil {
          error.memory = internalError
        }
        return
      } else {
        // The blockChainHeader doesn't exist, so create a new entity for it.
        let headerEntity =
            NSEntityDescription.insertNewObjectForEntityForName(self.blockChainHeaderEntityName,
                inManagedObjectContext:self.context) as! BlockChainHeaderEntity
        headerEntity.setBlockChainHeader(blockChainHeader)
      }

      // Update the head entity as the new block.
      if let headEntity = self.fetchBlockChainHeadEntity(&internalError) {
        if blockChainHeader == headEntity.blockChainHeader {
          // The head is already the correct value, so there is nothing more to do.
          self.attemptToSave(error)
          return
        } else {
          // Delete the old head entity so we can replace it (below) with the new head entity.
          self.context.deleteObject(headEntity)
        }
      } else if internalError != nil {
        if error != nil {
          error.memory = internalError
        }
        self.context.undo()
        return
      }
      let headEntity =
          NSEntityDescription.insertNewObjectForEntityForName(self.blockChainHeadEntityName,
              inManagedObjectContext:self.context) as! BlockChainHeaderEntity
      headEntity.setBlockChainHeader(blockChainHeader)
      self.attemptToSave(error)
    }
  }

  public func deleteBlockChainHeaderWithHash(hash: SHA256Hash, error: NSErrorPointer) {
    precondition(context != nil)
    context.performBlockAndWait() {
      if let headerEntity = self.fetchBlockChainHeaderEntityWithHash(hash, error: error) {
        self.context.deleteObject(headerEntity)
        self.attemptToSave(error)
      }
    }
  }

  public func blockChainHeaderWithHash(hash: SHA256Hash, error: NSErrorPointer)
      -> BlockChainHeader? {
    precondition(context != nil)
    var blockChainHeader: BlockChainHeader? = nil
    context.performBlockAndWait() {
      if let headerEntity = self.fetchBlockChainHeaderEntityWithHash(hash, error: error) {
        blockChainHeader = headerEntity.blockChainHeader
      }
    }
    return blockChainHeader
  }

  // MARK: - Private Methods

  /// Sets up the context ivar with the provided type and URL.
  /// URL can be nil if the type is NSInMemoryStoreType.
  private func setUpContextWithType(type: NSString, URL: NSURL? = nil) -> NSError? {
    precondition(context == nil)
    let bundle = NSBundle(forClass: self.dynamicType)
    let model = NSManagedObjectModel.mergedModelFromBundles([bundle])!
    context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    var error: NSError?
    context.persistentStoreCoordinator!.addPersistentStoreWithType(type as String,
                                                                   configuration: nil,
                                                                   URL: URL,
                                                                   options: nil,
                                                                   error: &error)
    if let error = error {
      Logger.error("Failed to setup CoreDataBlockChainStore \(error)")
      context = nil
      return error
    }
    return nil
  }

  /// Returns the BlockChainHeaderEntity keyed by the given hash, or nil if not found.
  /// This MUST be called from within context.performBlock().
  private func fetchBlockChainHeaderEntityWithHash(hash: SHA256Hash, error: NSErrorPointer)
      -> BlockChainHeaderEntity? {
    let request = NSFetchRequest(entityName: blockChainHeaderEntityName)
    request.predicate = NSPredicate(format: "blockHash == %@", hash.data)
    if let results = self.context.executeFetchRequest(request, error: error) {
      assert(results.count <= 1)
      if results.count > 0 {
        return (results[0] as! BlockChainHeaderEntity)
      }
    }
    return nil
  }

  /// Returns the BlockChainHeaderEntity that is currently the head of the blockchain, or nil if
  /// not found. This MUST be called from within context.performBlock().
  private func fetchBlockChainHeadEntity(error: NSErrorPointer)
      -> BlockChainHeaderEntity? {
    let request = NSFetchRequest(entityName: blockChainHeadEntityName)
    if let results = self.context.executeFetchRequest(request, error: error) {
      assert(results.count <= 1)
      if results.count > 0 {
        return (results[0] as! BlockChainHeaderEntity)
      }
    }
    return nil
  }

  /// Attempts to save changes to context. If there is an error, all changes to context are undone
  /// and the error is saved to error.
  private func attemptToSave(error: NSErrorPointer) {
    if context.save(error) == false {
      self.context.undo()
    }
  }
}
