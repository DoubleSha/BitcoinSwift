//
//  PeerConnectionLiveTest.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/18/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class PeerConnectionLiveTest: XCTestCase, PeerConnectionDelegate {
  var connectedExpectation: XCTestExpectation?

  override func setUp() {
    connectedExpectation = expectationWithDescription("connected")
  }

  func testConnect() {
    let conn = PeerConnection(hostname:"173.8.166.106", port:8333, delegate:self)
    conn.connect()
    waitForExpectationsWithTimeout(5, handler:nil)
  }

  // MARK: - PeerConnectionDelegate

  func peerConnectionDidConnect(peerConnection: PeerConnection) {
    NSLog("Did connect on run loop \(NSRunLoop.currentRunLoop())")
    connectedExpectation!.fulfill()
  }
}
