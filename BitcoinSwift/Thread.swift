//
//  Thread.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/24/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

// A convenience wrapper around NSThread that adds support for a completion block once the thread
// starts, and nice syntax for scheduling operations on the thread's runloop.
class Thread: NSThread {

  var runLoop: NSRunLoop!
  var completionBlock: (() -> Void)?

  override func main() {
    runLoop = NSRunLoop.currentRunLoop()
    completionBlock?()
    completionBlock = nil
    runLoop.run()
  }

  func startWithCompletion(completionBlock: () -> Void) {
    self.completionBlock = completionBlock
    start()
  }

  func addOperationWithBlock(block: () -> Void) {
    assert(runLoop != nil, "Cannot add operation to thread before it is started")
    CFRunLoopPerformBlock(runLoop.getCFRunLoop(), kCFRunLoopDefaultMode, block)
  }
}
