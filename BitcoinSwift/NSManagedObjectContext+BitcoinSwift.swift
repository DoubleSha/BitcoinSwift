//
//  NSManagedObjectContext+BitcoinSwift.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/26/15.
//  Copyright © 2015 DoubleSha. All rights reserved.
//

import CoreData
import Foundation

extension NSManagedObjectContext {

  /// The same as performBlockAndWait, except it can handle closures that throw.
  func performBlockAndWaitOrThrow(block: (() throws -> Void)) throws {
    var error: NSError? = nil
    performBlockAndWait() {
      do {
        try block()
      } catch let innerError as NSError {
        error = innerError
      }
    }
    if let error = error {
      throw error
    }
  }
}
