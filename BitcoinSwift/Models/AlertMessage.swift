//
//  AlertMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/10/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: AlertMessage, rhs: AlertMessage) -> Bool {
  return lhs.alert == rhs.alert && lhs.signature == rhs.signature
}

/// An alert is sent between nodes to send a general notification message throughout the network.
/// If the alert can be confirmed with the signature as having come from the the core development
/// group of the Bitcoin software, the message is suggested to be displayed for end-users.
/// Attempts to perform transactions, particularly automated transactions through the client, are
/// suggested to be halted. The text in the Message string should be relayed to log files and any
/// user interfaces.
/// https://en.bitcoin.it/wiki/Protocol_specification#alert
public struct AlertMessage: Equatable {

  public let alert: Alert
  public let signature: NSData

  private let coreDevPublicKeyBytes: [UInt8] = [
      0x04, 0xfc, 0x97, 0x02, 0x84, 0x78, 0x40, 0xaa,
      0xf1, 0x95, 0xde, 0x84, 0x42, 0xeb, 0xec, 0xed,
      0xf5, 0xb0, 0x95, 0xcd, 0xbb, 0x9b, 0xc7, 0x16,
      0xbd, 0xa9, 0x11, 0x09, 0x71, 0xb2, 0x8a, 0x49,
      0xe0, 0xea, 0xd8, 0x56, 0x4f, 0xf0, 0xdb, 0x22,
      0x20, 0x9e, 0x03, 0x74, 0x78, 0x2c, 0x09, 0x3b,
      0xb8, 0x99, 0x69, 0x2d, 0x52, 0x4e, 0x9d, 0x6a,
      0x69, 0x56, 0xe7, 0xc5, 0xec, 0xbc, 0xd6, 0x82,
      0x84]

  public init(alert: Alert, signature: NSData) {
    self.alert = alert
    self.signature = signature
  }

  public func isSignatureValid() -> Bool {
    // TODO: Actually validate the signature.
    return true
  }
}

extension AlertMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Alert
  }

  public var data: NSData {
    var data = NSMutableData()
    let alertData = alert.data
    data.appendVarInt(alertData.length)
    data.appendData(alertData)
    data.appendVarInt(signature.length)
    data.appendData(signature)
    return data
  }

  public static func fromData(data: NSData) -> AlertMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let alertDataLength = stream.readVarInt()
    if alertDataLength == nil {
      Logger.warn("Failed to parse alertDataLength from AlertMessage \(data)")
      return nil
    }
    if alertDataLength! > UInt64(data.length) {
      Logger.warn("Invalid alertDataLength \(alertDataLength!) in AlertMessage \(data)")
      return nil
    }
    let alertData = stream.readData(length: Int(alertDataLength!))
    if alertData == nil {
      Logger.warn("Failed to parse alertData in AlertMessage \(data)")
      return nil
    }
    let alert = Alert.fromData(alertData!)
    if alert == nil {
      Logger.warn("Failed to parse alert from AlertMessage \(data)")
      return nil
    }
    let signatureLength = stream.readVarInt()
    if signatureLength == nil {
      Logger.warn("Failed to parse signatureLength from AlertMessage \(data)")
      return nil
    }
    let signature = stream.readData(length: Int(signatureLength!))
    if signature == nil {
      Logger.warn("Failed to parse signature from AlertMessage \(data)")
      return nil
    }
    // TODO: Validate signature.
    if stream.hasBytesAvailable {
      Logger.warn("Failed to parse AlertMessage. Too much data \(data)")
      return nil
    }
    return AlertMessage(alert: alert!, signature: signature!)
  }
}
