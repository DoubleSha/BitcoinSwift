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

    init(inputStream: NSInputStream, outputStream: NSOutputStream) {
      self.inputStream = inputStream
      self.outputStream = outputStream
      super.init(hostname: hostname, port: port, network: network)
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

  // If non-nil, fulfilled when peerConnection(:didDisconnectWithError:) is invoked.
  private var connectionDidFailExpectation: XCTestExpectation?
  private var connectionDidConnectExpectation: XCTestExpectation?

  override func setUp() {
    let (inputStream, connOutputStream) = NSStream.boundStreamsWithBufferSize(1024)
    self.inputStream = inputStream
    let (connInputStream, outputStream) = NSStream.boundStreamsWithBufferSize(1024)
    self.outputStream = outputStream
    inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    inputStreamDelegate = TestInputStreamDelegate()
    inputStream.delegate = inputStreamDelegate
    outputStreamDelegate = TestOutputStreamDelegate()
    outputStream.delegate = outputStreamDelegate
    peerConnection = MockPeerConnection(inputStream: connInputStream,
                                        outputStream: connOutputStream)
    peerConnection.delegate = self
    inputStream.open()
    outputStream.open()
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

  // TODO: Fix this test and re-enable.
  func DISABLED_testConnectionTimeout() {
    connectionDidFailExpectation = expectationWithDescription("timeout")
    peerConnection.connectWithVersionMessage(DummyMessage.versionMessagePayload, timeout: 1)
    waitForExpectationsWithTimeout(2, handler: nil)
  }

  // TODO: Fix this test and re-enable.
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

  // TODO: Fix this test and re-enable.
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

  // TODO: Make these optional once Swift supports pure-Swift optional methods.

  func peerConnection(peerConnection: PeerConnection,
                      didReceiveAddressMessage addressMessage: AddressMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveInventoryMessage inventoryMessage: InventoryMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveGetDataMessage getDataMessage: GetDataMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveNotFoundMessage notFoundMessage: NotFoundMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveGetBlocksMessage getBlocksMessage: GetBlocksMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveGetHeadersMessage getHeadersMessage: GetHeadersMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveTransaction transaction: Transaction) {}
  func peerConnection(peerConnection: PeerConnection, didReceiveBlock block: Block) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveHeadersMessage headersMessage: HeadersMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveGetAddressMessage getAddressMessage: GetAddressMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveMemPoolMessage memPoolMessage: MemPoolMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceivePingMessage pingMessage: PingMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceivePongMessage pongMessage: PongMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveRejectMessage rejectMessage: RejectMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveFilterLoadMessage filterLoadMessage: FilterLoadMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveFilterAddMessage filterAddMessage: FilterAddMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveFilterClearMessage filterClearMessage: FilterClearMessage) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveFilteredBlock filteredBlock: FilteredBlock) {}
  func peerConnection(peerConnection: PeerConnection,
                      didReceiveAlertMessage alertMessage: AlertMessage) {}
}
