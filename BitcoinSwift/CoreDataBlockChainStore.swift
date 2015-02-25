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
    precondition(context == nil)
    let model = NSManagedObjectModel.mergedModelFromBundles(nil)!
    context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    var errorP = NSErrorPointer()
    context.persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType,
                                                                   configuration: nil,
                                                                   URL: url,
                                                                   options: nil,
                                                                   error: errorP)
    if let error = errorP.memory {
      Logger.error("Failed to setup CoreDataBlockChainStore \(error)")
      context = nil
      return error
    }
    return nil
  }

  public var defaultDir: NSURL {
    return NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory,
                                                           inDomains: .UserDomainMask)[0] as NSURL
  }

  // MARK: - BlockChainStore

  public func height() -> (height: UInt32?, error: NSError?) {
    precondition(context != nil)
    let (headValue, error) = head()
    return (height: headValue?.height, error: error)
  }

  public func head() -> (head: BlockChainHeader?, error: NSError?) {
    precondition(context != nil)
    var blockChainHeader: BlockChainHeader? = nil
    let errorP = NSErrorPointer()
    context.performBlockAndWait() {
      if let headerEntity = self.fetchBlockChainHeadEntityWithError(errorP) {
        blockChainHeader = headerEntity.blockChainHeader
      }
    }
    return (head: blockChainHeader, error: errorP.memory)
  }

  public func addBlockChainHeaderAsNewHead(blockChainHeader: BlockChainHeader) -> NSError? {
    precondition(context != nil)
    let errorP = NSErrorPointer()
    context.performBlockAndWait() {
      // Add the block to the block store if it's not already present.
      let hash = blockChainHeader.blockHeader.hash
      if self.fetchBlockChainHeaderEntityWithHash(hash, error: errorP) != nil {
        // The blockChainHeader already exists, so there's nothing to do.
      } else if errorP.memory != nil {
        return
      } else {
        // The blockChainHeader doesn't exist, so create a new entity for it.
        let headerEntity: BlockChainHeaderEntity =
            NSEntityDescription.insertNewObjectForEntityForName(self.blockChainHeaderEntityName,
                inManagedObjectContext:self.context) as BlockChainHeaderEntity
        headerEntity.setBlockChainHeader(blockChainHeader)
      }

      // Update the head entity as the new block.
      if let headEntity = self.fetchBlockChainHeadEntityWithError(errorP) {
        if blockChainHeader == headEntity.blockChainHeader {
          // The head is already the correct value, so there is nothing more to do.
          self.attemptToSaveWithError(errorP)
          return
        } else {
          // Delete the old head entity so we can replace it (below) with the new head entity.
          self.context.deleteObject(headEntity)
        }
      } else if errorP.memory != nil {
        self.context.undo()
        return
      }
      let headEntity: BlockChainHeaderEntity =
          NSEntityDescription.insertNewObjectForEntityForName(self.blockChainHeadEntityName,
              inManagedObjectContext:self.context) as BlockChainHeaderEntity
      headEntity.setBlockChainHeader(blockChainHeader)
      self.attemptToSaveWithError(errorP)
    }
    return errorP.memory
  }

  public func deleteBlockChainHeaderWithHash(hash: SHA256Hash) -> NSError? {
    precondition(context != nil)
    let errorP = NSErrorPointer()
    context.performBlockAndWait() {
      if let headerEntity = self.fetchBlockChainHeaderEntityWithHash(hash, error: errorP) {
        if errorP.memory == nil {
          self.context.deleteObject(headerEntity)
          self.attemptToSaveWithError(errorP)
        }
      }
    }
    return errorP.memory
  }

  public func blockChainHeaderWithHash(hash: SHA256Hash)
      -> (blockChainHeader: BlockChainHeader?, error: NSError?) {
    precondition(context != nil)
    var blockChainHeader: BlockChainHeader? = nil
    let errorP = NSErrorPointer()
    context.performBlockAndWait() {
      if let headerEntity = self.fetchBlockChainHeaderEntityWithHash(hash, error: errorP) {
        blockChainHeader = headerEntity.blockChainHeader
      }
    }
    return (blockChainHeader: blockChainHeader, error: errorP.memory)
  }

  // MARK: - Private Methods

  /// Returns the BlockChainHeaderEntity keyed by the given hash, or nil if not found.
  /// This MUST be called from within context.performBlock().
  private func fetchBlockChainHeaderEntityWithHash(hash: SHA256Hash, error: NSErrorPointer)
      -> BlockChainHeaderEntity? {
    let request = NSFetchRequest(entityName: blockChainHeaderEntityName)
    request.predicate = NSPredicate(format: "blockHash == \(hash)", argumentArray: nil)
    if let results = self.context.executeFetchRequest(request, error: error) {
      assert(results.count <= 1)
      if results.count > 0 {
        return (results[0] as BlockChainHeaderEntity)
      }
    }
    return nil
  }

  /// Returns the BlockChainHeaderEntity that is currently the head of the blockchain, or nil if
  /// not found. This MUST be called from within context.performBlock().
  private func fetchBlockChainHeadEntityWithError(error: NSErrorPointer)
      -> BlockChainHeaderEntity? {
    let request = NSFetchRequest(entityName: blockChainHeadEntityName)
    if let results = self.context.executeFetchRequest(request, error: error) {
      assert(results.count <= 1)
      if results.count > 0 {
        return (results[0] as BlockChainHeaderEntity)
      }
    }
    return nil
  }

  /// Attempts to save changes to context. If there is an error, all changes to context are undone
  /// and the error is saved to errorP.
  private func attemptToSaveWithError(errorP: NSErrorPointer) {
    if context.save(errorP) == false {
      self.context.undo()
    }
  }
}
