//
//  TestStreamDelegate.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/1/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import Foundation
import XCTest

/// Set this as the delegate for an input stream for unit testing.
class TestInputStreamDelegate: NSObject, NSStreamDelegate {

  private var thread: Thread
  private var expectation: XCTestExpectation?
  private var expectedBytes: [UInt8] = []
  private var receivedBytes: [UInt8] = []
  private var readBuffer = [UInt8](count: 1024, repeatedValue: 0)

  init(thread: Thread) {
    self.thread = thread
  }

  /// Waits until it receives expectedReceivedBytes or times out if not enough bytes are received
  /// before timeout expires.
  /// When the expected bytes are received, expectation is fulfilled.
  func expectToReceiveBytes(expectedBytes: [UInt8],
                            withExpectation expectation: XCTestExpectation) {
    thread.addOperationWithBlock {
      XCTAssertNil(self.expectation)
      self.expectedBytes = expectedBytes
      self.expectation = expectation
      self.verifyExpectedBytes()
    }
  }

  func stream(stream: NSStream, handleEvent event: NSStreamEvent) {
    switch event {
      case NSStreamEvent.None: 
        break
      case NSStreamEvent.OpenCompleted: 
        break
      case NSStreamEvent.HasSpaceAvailable: 
        break
      case NSStreamEvent.HasBytesAvailable: 
        readFromStream(stream as! NSInputStream)
      default: 
        XCTFail("Invalid NSStreamEvent \(event)")
    }
  }

  private func readFromStream(inputStream: NSInputStream) {
    thread.addOperationWithBlock {
      while inputStream.hasBytesAvailable {
        let bytesRead = inputStream.read(&self.readBuffer, maxLength: self.readBuffer.count)
        if bytesRead > 0 {
          self.receivedBytes += self.readBuffer[0..<bytesRead]
        }
      }
      self.verifyExpectedBytes()
    }
  }

  private func verifyExpectedBytes() {
    if expectedBytes.count > 0 && receivedBytes.count >= expectedBytes.count {
      // Use XCTAssertEqual so we can see what is wrong with the bytes we received if they
      // are not equal.
      XCTAssertEqual(receivedBytes, expectedBytes)
      receivedBytes.removeAll()
      expectation?.fulfill()
      expectation = nil
    }
  }
}
