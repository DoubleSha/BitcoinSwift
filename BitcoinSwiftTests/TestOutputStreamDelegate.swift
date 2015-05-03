//
//  TestOutputStreamDelegate.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/5/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import Foundation
import XCTest

class TestOutputStreamDelegate: NSObject, NSStreamDelegate {

  private var thread: Thread
  private var pendingSendBytes: [UInt8] = []

  init(thread: Thread) {
    self.thread = thread
  }

  func sendBytes(bytes: [UInt8], outputStream: NSOutputStream) {
    thread.addOperationWithBlock {
      self.pendingSendBytes += bytes
      self.send(outputStream)
    }
  }

  func stream(stream: NSStream, handleEvent event: NSStreamEvent) {
    switch event {
      case NSStreamEvent.None:
        break
      case NSStreamEvent.OpenCompleted: 
        break
      case NSStreamEvent.HasSpaceAvailable: 
        send(stream as! NSOutputStream)
      case NSStreamEvent.HasBytesAvailable: 
        break
      case NSStreamEvent.EndEncountered:
        break
      default: 
        XCTFail("Invalid NSStreamEvent \(event)")
    }
  }

  private func send(outputStream: NSOutputStream) {
    thread.addOperationWithBlock {
      if self.pendingSendBytes.count > 0 {
        let bytesWritten = outputStream.write(self.pendingSendBytes,
                                              maxLength: self.pendingSendBytes.count)
        if bytesWritten > 0 {
          self.pendingSendBytes.removeRange(0..<bytesWritten)
        }
        if self.pendingSendBytes.count > 0 {
          self.thread.addOperationWithBlock {
            self.send(outputStream)
          }
        }
      }
    }
  }
}
