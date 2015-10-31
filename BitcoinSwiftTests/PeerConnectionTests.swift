//
//  PeerConnectionTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/31/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import Foundation
import XCTest

private let hostname = "mock_hostname"
private let port: UInt16 = 8333
private let network = Message.Network.MainNet

class PeerConnectionTests: XCTestCase {

  class MockPeerConnection: PeerConnection {

    let inputStream: NSInputStream
    let outputStream: NSOutputStream

    init(inputStream: NSInputStream,
         outputStream: NSOutputStream,
         delegate: PeerConnectionDelegate,
         delegateQueue: NSOperationQueue) {
      self.inputStream = inputStream
      self.outputStream = outputStream
      super.init(hostname: hostname,
                 port: port,
                 network: network.rawValue,
                 delegate: delegate,
                 delegateQueue: delegateQueue)
    }

    override func streamsToPeerWithHostname(hostname: String, port: UInt16) ->
        (inputStream: NSInputStream, outputStream: NSOutputStream)? {
      return (inputStream, outputStream)
    }
  }

  // Used to write mock data to the PeerConnection and read data from it to verify the results.
  private var inputStream: NSInputStream!
  private var outputStream: NSOutputStream!
  private var peerConnection: MockPeerConnection!
  private var inputStreamDelegate: TestInputStreamDelegate!
  private var outputStreamDelegate: TestOutputStreamDelegate!
  private var backgroundThread: Thread!
  private var delegateQueue: NSOperationQueue!

  // If non-nil, fulfilled when peerConnection(:didDisconnectWithError:) is invoked.
  private var connectionDidFailExpectation: XCTestExpectation?
  private var connectionDidConnectExpectation: XCTestExpectation?

  override func setUp() {
    super.setUp()
    let (inputStream, connOutputStream) = NSStream.boundStreamsWithBufferSize(1024)
    self.inputStream = inputStream
    let (connInputStream, outputStream) = NSStream.boundStreamsWithBufferSize(1024)
    self.outputStream = outputStream
    backgroundThread = Thread()
    inputStreamDelegate = TestInputStreamDelegate(thread: backgroundThread)
    outputStreamDelegate = TestOutputStreamDelegate(thread: backgroundThread)
    self.inputStream = inputStream
    self.outputStream = outputStream
    self.inputStream.delegate = inputStreamDelegate
    self.outputStream.delegate = outputStreamDelegate
    let semaphore = dispatch_semaphore_create(0)
    backgroundThread.startWithCompletion {
      self.backgroundThread.addOperationWithBlock {
        self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(),
                                           forMode: NSDefaultRunLoopMode)
        self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(),
                                            forMode: NSDefaultRunLoopMode)
        self.inputStream.open()
        self.outputStream.open()
        dispatch_semaphore_signal(semaphore)
      }
    }
    // Set the delegate queue to a background queue because the main queue might be blocked waiting
    // for expectatations. That would cause deadlocks.
    delegateQueue = NSOperationQueue()
    peerConnection = MockPeerConnection(inputStream: connInputStream,
                                        outputStream: connOutputStream,
                                        delegate: self,
                                        delegateQueue: delegateQueue)
    // Wait for the backgroundThread to start.
    let timeoutError =
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)))
    XCTAssertEqual(timeoutError, 0, "Timed out waiting for backgroundThread to start")
  }

  func testSendVersionMessageOnConnect() {
    let versionExpectation = expectationWithDescription("version")
    inputStreamDelegate.expectToReceiveBytes(DummyMessage.versionMessageBytes,
                                             withExpectation: versionExpectation)
    peerConnection.connectWithVersionMessage(DummyMessage.versionMessagePayload, timeout: 5)
    waitForExpectationsWithTimeout(5, handler: nil)
  }

  func testSuccessfulVersionExchange() {
    let versionExpectation = expectationWithDescription("version")
    inputStreamDelegate.expectToReceiveBytes(DummyMessage.versionMessageBytes,
                                             withExpectation: versionExpectation)
    peerConnection.connectWithVersionMessage(DummyMessage.versionMessagePayload, timeout: 5)
    waitForExpectationsWithTimeout(5, handler: nil)

    connectionDidConnectExpectation = expectationWithDescription("connect")
    let versionAckExpectation = expectationWithDescription("versionack")
    inputStreamDelegate.expectToReceiveBytes(DummyMessage.versionAckMessageBytes,
                                             withExpectation: versionAckExpectation)
    outputStreamDelegate.sendBytes(DummyMessage.versionAckMessageBytes,
                                   outputStream: outputStream)
    outputStreamDelegate.sendBytes(DummyMessage.versionMessageBytes,
                                   outputStream: outputStream)
    waitForExpectationsWithTimeout(5, handler: nil)
  }

  // TODO: Fix on Travis-CI and re-enable.
  func DISABLED_testConnectionTimeout() {
    connectionDidFailExpectation = expectationWithDescription("timeout")
    peerConnection.connectWithVersionMessage(DummyMessage.versionMessagePayload, timeout: 1)
    waitForExpectationsWithTimeout(2, handler: nil)
  }

  // TODO: Fix on Travis-CI and re-enable.
  func DISABLED_testVersionButNoVersionAckTimeout() {
    let versionExpectation = expectationWithDescription("version")
    inputStreamDelegate.expectToReceiveBytes(DummyMessage.versionMessageBytes,
                                             withExpectation: versionExpectation)
    peerConnection.connectWithVersionMessage(DummyMessage.versionMessagePayload, timeout: 1)
    waitForExpectationsWithTimeout(5, handler: nil)

    connectionDidFailExpectation = expectationWithDescription("timeout")
    let versionAckExpectation = expectationWithDescription("versionack")
    inputStreamDelegate.expectToReceiveBytes(DummyMessage.versionAckMessageBytes,
                                             withExpectation: versionAckExpectation)
    outputStreamDelegate.sendBytes(DummyMessage.versionMessageBytes, outputStream: outputStream)
    waitForExpectationsWithTimeout(2, handler: nil)
  }

  // TODO: Fix on Travis-CI and re-enable.
  func DISABLED_testVersionAckButNoVersionTimeout() {
    let versionExpectation = expectationWithDescription("version")
    inputStreamDelegate.expectToReceiveBytes(DummyMessage.versionMessageBytes,
                                             withExpectation: versionExpectation)
    peerConnection.connectWithVersionMessage(DummyMessage.versionMessagePayload, timeout: 1)
    waitForExpectationsWithTimeout(5, handler: nil)

    connectionDidFailExpectation = expectationWithDescription("timeout")
    outputStreamDelegate.sendBytes(DummyMessage.versionAckMessageBytes,
                                   outputStream: outputStream)
    waitForExpectationsWithTimeout(2, handler: nil)
  }
}

extension PeerConnectionTests: PeerConnectionDelegate {

  func peerConnection(peerConnection: PeerConnection,
                      didConnectWithPeerVersion peerVersion: VersionMessage) {
    connectionDidConnectExpectation?.fulfill()
  }

  func peerConnection(peerConnection: PeerConnection, didDisconnectWithError error: NSError?) {
    connectionDidFailExpectation?.fulfill()
  }

  func peerConnection(peerConnection: PeerConnection,
                      didReceiveMessage message: PeerConnectionMessage) {
    // NOP.
  }
}
