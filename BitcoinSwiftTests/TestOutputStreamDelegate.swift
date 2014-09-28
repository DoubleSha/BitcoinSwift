//
//  TestOutputStreamDelegate.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/5/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation
import XCTest

class TestOutputStreamDelegate: NSObject, NSStreamDelegate {

  private var pendingSendBytes: [UInt8] = []

  func sendBytes(bytes: [UInt8], outputStream: NSOutputStream) {
    pendingSendBytes += bytes
    send(outputStream)
  }

  func stream(stream: NSStream, handleEvent event: NSStreamEvent) {
    switch event {
      case NSStreamEvent.None: 
        break
      case NSStreamEvent.OpenCompleted: 
        break
      case NSStreamEvent.HasSpaceAvailable: 
        send(stream as NSOutputStream)
      case NSStreamEvent.HasBytesAvailable: 
        break
      default: 
        XCTFail("Invalid NSStreamEvent \(event)")
    }
  }

  private func send(outputStream: NSOutputStream) {
    if pendingSendBytes.count > 0 {
      let bytesWritten = outputStream.write(pendingSendBytes, maxLength: pendingSendBytes.count)
      if bytesWritten > 0 {
        pendingSendBytes.removeRange(0..<bytesWritten)
      }
      if pendingSendBytes.count > 0 {
        dispatch_async(dispatch_get_main_queue()) {
          self.send(outputStream)
        }
      }
    }
  }
}
