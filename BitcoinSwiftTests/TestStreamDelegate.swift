//
//  TestStreamDelegate.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/1/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation
import XCTest

/// Set this as the delegate for an input stream for unit testing.
/// Waits until it receives expectedBytesToReceive. If the received bytes match the
/// expectedBytesToReceive, then the expectedBytesReceivedExpectation is fulfilled.
/// Otherwise XCTFail() is invoked.
class TestInputStreamDelegate: NSObject, NSStreamDelegate {

  private let expectation: XCTestExpectation
  private let expectedBytes: [UInt8]
  private var receivedBytes: [UInt8] = []
  private var readBuffer = [UInt8](count:1024, repeatedValue:0)

  init(expectation: XCTestExpectation, expectedBytes: [UInt8]) {
    self.expectation = expectation
    self.expectedBytes = expectedBytes
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
        let inputStream = stream as NSInputStream
        while inputStream.hasBytesAvailable {
          let bytesRead = inputStream.read(&readBuffer, maxLength:readBuffer.count)
          if bytesRead > 0 {
            receivedBytes += readBuffer[0..<bytesRead]
          }
        }
        if receivedBytes.count >= expectedBytes.count {
          // Use XCTAssertEqual so we can see what is wrong with the bytes we received if they
          // are not equal.
          XCTAssertEqual(receivedBytes, expectedBytes)
          expectation.fulfill()
        }
      default:
        XCTFail("Invalid NSStreamEvent \(event)")
    }
  }
}
