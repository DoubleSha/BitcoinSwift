//
//  AlertMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/10/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: AlertMessage, rhs: AlertMessage) {
  return lhs.alert == rhs.alert && lhs.signature == rhs.signature
}

/// An alert is sent between nodes to send a general notification message throughout the network.
/// If the alert can be confirmed with the signature as having come from the the core development
/// group of the Bitcoin software, the message is suggested to be displayed for end-users.
/// Attempts to perform transactions, particularly automated transactions through the client, are
/// suggested to be halted. The text in the Message string should be relayed to log files and any
/// user interfaces.
public struct AlertMessage: Equatable {

  public let alert: Alert
  public let signature: NSData

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
    data.appendData(alert.data)
    data.appendData(signature)
    return data
  }

  public static func fromData(data: NSData) -> AlertMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let alert = Alert.fromStream(stream)
    if alert == nil {
      Logger.warn("Failed to parse alert from AlertMessage \(data)")
      return nil
    }
    let signature = stream.readData()
    if signature == nil {
      Logger.warn("Failed to parse signature from AlertMessage \(data)")
      return nil
    }
    // TODO: Validate signature.
    return AlertMessage(alert: alert!, signature: signature!)
  }
}
