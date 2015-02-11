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

  /// Sets up the SQLite file a the path specified by |url|, and the CoreData managed object.
  /// This MUST be called before using the store, and can only be called once.
  /// If setup fails, returns the error.
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
      return error
    }
    return nil
  }

  public var height: Int {
    precondition(context != nil)
    return 0
  }

  public var head: BlockChainHeader? {
    precondition(context != nil)
    return nil
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

  public func addBlockChainHeader(blockChainHeader: BlockChainHeader) -> NSError? {
    precondition(context != nil)
    let errorP = NSErrorPointer()
    context.performBlockAndWait() {
      let hash = blockChainHeader.blockHeader.hash
      if let headerEntity = self.fetchBlockChainHeaderEntityWithHash(hash, error: errorP) {
        return
      } else if errorP.memory != nil {
        return
      }
      let headerEntity: BlockChainHeaderEntity =
          NSEntityDescription.insertNewObjectForEntityForName(self.blockChainHeaderEntityName,
              inManagedObjectContext:self.context) as BlockChainHeaderEntity
      headerEntity.setBlockChainHeader(blockChainHeader)
      self.context.save(nil)
    }
    return errorP.memory
  }

  public func deleteBlockChainHeaderWithHash(hash: SHA256Hash) -> NSError? {
    precondition(context != nil)
    let errorP = NSErrorPointer()
    context.performBlockAndWait() {
      if let headerEntity = self.fetchBlockChainHeaderEntityWithHash(hash, error: errorP) {
        self.context.deleteObject(headerEntity)
        self.context.save(nil)
      } else if errorP.memory != nil {
        return
      }
      self.context.save(nil)
    }
    return errorP.memory
  }

  // MARK: - Private Methods

  private func fetchBlockChainHeaderEntityWithHash(hash: SHA256Hash, error: NSErrorPointer)
      -> BlockChainHeaderEntity? {
    let request = NSFetchRequest(entityName: self.blockChainHeaderEntityName)
    request.predicate = NSPredicate(format: "blockHash == \(hash)", argumentArray: nil)
    if let results = self.context.executeFetchRequest(request, error: error) {
      assert(results.count <= 1)
      if results.count > 0 {
        return (results[0] as BlockChainHeaderEntity)
      }
    }
    return nil
  }
}
