//
//  MessageParser.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/13/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public protocol MessageParserDelegate : class {
  func didParseMessage(message: Message)
}

/// Parses Messages from raw data received from the wire. Handles framing and ensuring message
/// data integrety.
public class MessageParser {

  public weak var delegate: MessageParserDelegate? = nil

  private let network: Message.Network

  // We receive a message in chunks. When we have received only part of a message, but not the
  // whole thing, receivedBytes stores the pending bytes, and adds onto it the next time
  // we receive a NSStreamEvent.HasBytesAvailable event.
  private var receivedBytes: [UInt8] = []

  // The header for the message we are about to receive. This is non-nil when we have received
  // enough bytes to parse the header, but haven't received the full message yet.
  private var receivedHeader: Message.Header? = nil

  public init(network: Message.Network) {
    self.network = network
  }

  /// Consumes the data in bytes by parsing it into Messages, or discarding invalid data.
  /// Doesn't return until all data in receivedBytes has been consumed, or until more data must be
  /// received to parse a valid message.
  public func parseBytes(bytes: [UInt8]) {
    receivedBytes += bytes
    while true {
      if receivedHeader == nil {
        let headerStartIndex = headerStartIndexInBytes(receivedBytes)
        if headerStartIndex < 0 {
          // We did not find the message start, so we must wait for more bytes.
          // Throw away the bytes we have since we couldn't figure out how to handle them.
          // We might have all but the last byte of the networkMagicBytes for the next message,
          // so keep the last 3 bytes.
          let end = receivedBytes.count - network.magicBytes.count + 1
          if end > 0 {
            receivedBytes.removeRange(0..<end)
          }
          return
        }
        // Remove the bytes before startIndex since we don't know what they are.
        receivedBytes.removeRange(0..<headerStartIndex)
        if receivedBytes.count < Message.Header.length {
          // We're expecting a header, but there aren't enough bytes yet to parse one.
          // Wait for more bytes to be received.
          return
        }
        let data = NSData(bytes:receivedBytes, length:receivedBytes.count)
        receivedHeader = Message.Header.fromData(data)
        if receivedHeader == nil {
          // Failed to parse the header for some reason. It's possible that the networkMagicBytes
          // coincidentally appeared in the byte data, or the header was invalid for some reason.
          // Strip the networkMagicBytes so we can advance and try to parse again.
          receivedBytes.removeRange(0..<network.magicBytes.count)
          continue
        }
        // receivedHeader is guaranteed to be non-nil at this point.
        // We successfully parsed the header from receivedBytes, so remove those bytes.
        receivedBytes.removeRange(0..<Message.Header.length)
      }
      assert(Message.Header.length == 24)
      // NOTE: payloadLength can be 0 for some message types, e.g. VersionAck.
      let payloadLength = Int(receivedHeader!.payloadLength)
      // TODO: Need to figure out a maximum length to allow here, or somebody could DOS us by
      // providing a huge value for payloadLength.
      if receivedBytes.count < payloadLength {
        // Haven't received the whole message yet. Wait for more bytes.
        return
      }
      let payloadData = NSData(bytes:receivedBytes, length:payloadLength)
      let message = Message(header:receivedHeader!, payloadData:payloadData)
      if message.isChecksumValid() {
        delegate?.didParseMessage(message)
      } else {
        println("WARN: Dropping \(message.command.toRaw()) message with invalid checksum")
      }
      receivedBytes.removeRange(0..<payloadLength)
      receivedHeader = nil
    }
  }

  // MARK: - Private Methods

  // Returns -1 if the header start (the position of network.magicBytes) was not found.
  // Otherwise returns the position where the message header begins.
  private func headerStartIndexInBytes(bytes: [UInt8]) -> Int {
    let networkMagicBytes = network.magicBytes
    if bytes.count < networkMagicBytes.count {
      return -1
    }
    for i in 0...(bytes.count - networkMagicBytes.count) {
      var found = true
      for j in 0..<networkMagicBytes.count {
        if bytes[i + j] != networkMagicBytes[j] {
          found = false
          break
        }
      }
      if found {
        return i
      }
    }
    return -1
  }
}
