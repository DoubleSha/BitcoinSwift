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

class PeerConnectionTests: XCTestCase, PeerConnectionDelegate {

  class MockPeerConnection: PeerConnection {

    let inputStream: NSInputStream
    let outputStream: NSOutputStream

    init(inputStream: NSInputStream, outputStream: NSOutputStream) {
      self.inputStream = inputStream
      self.outputStream = outputStream
      super.init(hostname:hostname, port:port, network:network)
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

  // If non-nil, fulfilled when peerConnection(:didFailWithError:) is invoked.
  private var connectionDidFailExpectation: XCTestExpectation?
  private var connectionDidConnectExpectation: XCTestExpectation?

  override func setUp() {
    let (inputStream, connOutputStream) = NSStream.boundStreamsWithBufferSize(1024)
    self.inputStream = inputStream
    let (connInputStream, outputStream) = NSStream.boundStreamsWithBufferSize(1024)
    self.outputStream = outputStream
    inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode:NSDefaultRunLoopMode)
    outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode:NSDefaultRunLoopMode)
    inputStreamDelegate = TestInputStreamDelegate()
    inputStream.delegate = inputStreamDelegate
    outputStreamDelegate = TestOutputStreamDelegate()
    outputStream.delegate = outputStreamDelegate
    peerConnection = MockPeerConnection(inputStream:connInputStream,
                                        outputStream:connOutputStream)
    peerConnection.delegate = self
    inputStream.open()
    outputStream.open()
  }

  func testSendVersionMessageOnConnect() {
    let versionExpectation = expectationWithDescription("version")
    inputStreamDelegate.expectToReceiveBytes(dummyVersionMessageBytes(),
                                             withExpectation:versionExpectation)
    peerConnection.connectWithVersionMessage(dummyVersionMessage(), timeout:5)
    waitForExpectationsWithTimeout(5, handler:nil)
  }

  func testSuccessfulVersionExchange() {
    let versionExpectation = expectationWithDescription("version")
    inputStreamDelegate.expectToReceiveBytes(dummyVersionMessageBytes(),
                                             withExpectation:versionExpectation)
    peerConnection.connectWithVersionMessage(dummyVersionMessage(), timeout:5)
    waitForExpectationsWithTimeout(5, handler:nil)

    connectionDidConnectExpectation = expectationWithDescription("connect")
    let versionAckExpectation = expectationWithDescription("versionack")
    inputStreamDelegate.expectToReceiveBytes(dummyVersionAckMessageBytes(),
                                             withExpectation:versionAckExpectation)
    outputStreamDelegate.sendBytes(dummyVersionAckMessageBytes(), outputStream:outputStream)
    outputStreamDelegate.sendBytes(dummyVersionMessageBytes(), outputStream:outputStream)
    waitForExpectationsWithTimeout(5, handler:nil)
  }

  func testConnectionTimeout() {
    connectionDidFailExpectation = expectationWithDescription("timeout")
    peerConnection.connectWithVersionMessage(dummyVersionMessage(), timeout:1)
    waitForExpectationsWithTimeout(3, handler:nil)
  }

  func testVersionButNoVersionAckTimeout() {
    let versionExpectation = expectationWithDescription("version")
    inputStreamDelegate.expectToReceiveBytes(dummyVersionMessageBytes(),
                                             withExpectation:versionExpectation)
    peerConnection.connectWithVersionMessage(dummyVersionMessage(), timeout:1)
    waitForExpectationsWithTimeout(5, handler:nil)

    connectionDidFailExpectation = expectationWithDescription("timeout")
    let versionAckExpectation = expectationWithDescription("versionack")
    inputStreamDelegate.expectToReceiveBytes(dummyVersionAckMessageBytes(),
                                             withExpectation:versionAckExpectation)
    outputStreamDelegate.sendBytes(dummyVersionMessageBytes(), outputStream:outputStream)
    waitForExpectationsWithTimeout(2, handler:nil)
  }

  func testVersionAckButNoVersionTimeout() {
    let versionExpectation = expectationWithDescription("version")
    inputStreamDelegate.expectToReceiveBytes(dummyVersionMessageBytes(),
                                             withExpectation:versionExpectation)
    peerConnection.connectWithVersionMessage(dummyVersionMessage(), timeout:1)
    waitForExpectationsWithTimeout(5, handler:nil)

    connectionDidFailExpectation = expectationWithDescription("timeout")
    outputStreamDelegate.sendBytes(dummyVersionAckMessageBytes(), outputStream:outputStream)
    waitForExpectationsWithTimeout(2, handler:nil)
  }

  // MARK: - PeerConnectionDelegate

  func peerConnection(peerConnection: PeerConnection,
                      didConnectWithPeerVersion peerVersion: VersionMessage) {
    connectionDidConnectExpectation?.fulfill()
  }

  func peerConnection(peerConnection: PeerConnection, didFailWithError error: NSError?) {
    connectionDidFailExpectation?.fulfill()
  }

  // MARK: - Helper methods

  func dummyVersionMessage() -> VersionMessage {
    let senderPeerAddress = PeerAddress(services:PeerServices.NodeNetwork,
                                        IP:IPAddress.IPV4(0xad08a669),
                                        port:8333)
    let receiverPeerAddress = PeerAddress(services:PeerServices.NodeNetwork,
                                          IP:IPAddress.IPV4(0x00000000),
                                          port:0)
    return VersionMessage(protocolVersion:70002,
                          services:PeerServices.NodeNetwork,
                          date:NSDate(timeIntervalSince1970:1409635854),
                          senderAddress:senderPeerAddress,
                          receiverAddress:receiverPeerAddress,
                          nonce:0x5e9e17ca3e515405,
                          userAgent:"/Satoshi:0.9.1/",
                          blockStartHeight:172153,
                          announceRelayedTransactions:true)
  }

  func dummyVersionMessageBytes() -> [UInt8] {
    return [
      0xf9, 0xbe, 0xb4, 0xd9,                           // Main network magic bytes
      0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x00, 0x00, 0x00, 0x00, 0x00, // "version" command
      0x65, 0x00, 0x00, 0x00,                           // Payload is 101 bytes long
      0x2f, 0x80, 0x9b, 0xfa,                           // Payload checksum
      0x72, 0x11, 0x01, 0x00,                           // 70002 (protocol version 70002)
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // 1 (NODE_NETWORK services)
      0x0e, 0x56, 0x05, 0x54, 0x00, 0x00, 0x00, 0x00,   // Timestamp
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Recipient address info
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xff, 0xff, 0xad, 0x08, 0xa6, 0x69, 0x20, 0x8d, // Sender address info
      0x05, 0x54, 0x51, 0x3e, 0xca, 0x17, 0x9e, 0x5e,   // Node ID
      0x0f, 0x2f, 0x53, 0x61, 0x74, 0x6f, 0x73, 0x68,
      0x69, 0x3a, 0x30, 0x2e, 0x39, 0x2e, 0x31, 0x2f,   // sub-version string "/Satoshi:0.9.1/"
      0x79, 0xa0, 0x02, 0x00,                           // Last block #172153
      0x01]                                             // Relay transactions
  }

  func dummyVersionAckMessageBytes() -> [UInt8] {
    return [
        0xf9, 0xbe, 0xb4, 0xd9,                         // Main network magic bytes
        0x76, 0x65, 0x72, 0x61, 0x63, 0x6b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // "versionack" cmd
        0x00, 0x00, 0x00, 0x00,                         // Payload is 0 bytes long
        0x5d, 0xf6, 0xe0, 0xe2,                         // Payload checksum
    ]
  }
}
