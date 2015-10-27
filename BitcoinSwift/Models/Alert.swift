//
//  Alert.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/10/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: Alert, right: Alert) -> Bool {
  // Xcode 6 has a bug where it can't handle long expressions. So break it up.
  let a = left.version == right.version &&
      left.relayUntilDate == right.relayUntilDate &&
      left.expirationDate == right.expirationDate &&
      left.ID == right.ID &&
      left.cancelID == right.cancelID &&
      left.cancelIDs == right.cancelIDs &&
      left.minimumVersion == right.minimumVersion &&
      left.maximumVersion == right.maximumVersion
  return a &&
      left.affectedUserAgents == right.affectedUserAgents &&
      left.priority == right.priority &&
      left.comment == right.comment &&
      left.message == right.message &&
      left.reserved == right.reserved
}

public struct Alert: Equatable {

  /// Alert format version.
  public let version: Int32
  /// The timestamp beyond which nodes should stop relaying this alert.
  public let relayUntilDate: NSDate
  /// The timestamp beyond which this alert is no longer in effect and should be ignored.
  public let expirationDate: NSDate
  /// A unique ID number for this alert.
  public let ID: Int32
  /// All alerts with an ID number less than or equal to this number should be cancelled: deleted
  /// and not accepted in the future.
  public let cancelID: Int32
  /// All alert IDs contained in this set should be cancelled as above.
  public let cancelIDs: [Int32]
  /// This alert only applies to versions greater than or equal to this version.
  /// Other versions should still relay it.
  public let minimumVersion: Int32
  /// This alert only applies to versions less than or equal to this version.
  /// Other versions should still relay it.
  public let maximumVersion: Int32
  /// If this set contains any elements, then only nodes that have their userAgent contained in this
  /// set are affected by the alert. Other versions should still relay it.
  public let affectedUserAgents: [String]
  /// Relative priority compared to other alerts.
  public let priority: Int32
  /// A comment on the alert that is not displayed.
  public let comment: String
  /// The alert message that is displayed to the user.
  public let message: String
  /// Reserved for something apparently. *shrug*
  public let reserved: String

  public init(version: Int32,
              relayUntilDate: NSDate,
              expirationDate: NSDate,
              ID: Int32,
              cancelID: Int32,
              cancelIDs: [Int32],
              minimumVersion: Int32,
              maximumVersion: Int32,
              affectedUserAgents: [String],
              priority: Int32,
              comment: String,
              message: String,
              reserved: String) {
    self.version = version
    self.relayUntilDate = relayUntilDate
    self.expirationDate = expirationDate
    self.ID = ID
    self.cancelID = cancelID
    self.cancelIDs = cancelIDs
    self.minimumVersion = minimumVersion
    self.maximumVersion = maximumVersion
    self.affectedUserAgents = affectedUserAgents
    self.priority = priority
    self.comment = comment
    self.message = message
    self.reserved = reserved
  }
}

extension Alert: BitcoinSerializable {

  public var bitcoinData: NSData {
    let data = NSMutableData()
    data.appendInt32(version)
    data.appendDateAs64BitUnixTimestamp(relayUntilDate)
    data.appendDateAs64BitUnixTimestamp(expirationDate)
    data.appendInt32(ID)
    data.appendInt32(cancelID)
    data.appendVarInt(cancelIDs.count)
    for cancelID in cancelIDs {
      data.appendInt32(cancelID)
    }
    data.appendInt32(minimumVersion)
    data.appendInt32(maximumVersion)
    data.appendVarInt(affectedUserAgents.count)
    for userAgent in affectedUserAgents {
      data.appendVarString(userAgent)
    }
    data.appendInt32(priority)
    data.appendVarString(comment)
    data.appendVarString(message)
    data.appendVarString(reserved)
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> Alert? {
    let version = stream.readInt32()
    if version == nil {
      Logger.warn("Failed to parse version from Alert")
      return nil
    }
    let relayUntilDate = stream.readDateFrom64BitUnixTimestamp()
    if relayUntilDate == nil {
      Logger.warn("Failed to parse relayUntilDate from Alert")
      return nil
    }
    let expirationDate = stream.readDateFrom64BitUnixTimestamp()
    if expirationDate == nil {
      Logger.warn("Failed to parse expirationDate from Alert")
      return nil
    }
    let ID = stream.readInt32()
    if ID == nil {
      Logger.warn("Failed to parse ID from Alert")
      return nil
    }
    let cancelID = stream.readInt32()
    if cancelID == nil {
      Logger.warn("Failed to parse cancelID from Alert")
      return nil
    }
    let cancelIDsCount = stream.readVarInt()
    if cancelIDsCount == nil {
      Logger.warn("Failed to parse cancelIDsCount from Alert")
      return nil
    }
    var cancelIDs: [Int32] = []
    for i in 0..<cancelIDsCount! {
      let cancelID = stream.readInt32()
      if cancelID == nil {
        Logger.warn("Failed to parse cancelID \(i) from Alert")
        return nil
      }
      cancelIDs.append(cancelID!)
    }
    let minimumVersion = stream.readInt32()
    if minimumVersion == nil {
      Logger.warn("Failed to parse minimumVersion from Alert")
      return nil
    }
    let maximumVersion = stream.readInt32()
    if maximumVersion == nil {
      Logger.warn("Failed to parse maximumVersion from Alert")
      return nil
    }
    let affectedUserAgentsCount = stream.readVarInt()
    if affectedUserAgentsCount == nil {
      Logger.warn("Failed to parse affectedUserAgentsCount from Alert")
      return nil
    }
    var affectedUserAgents: [String] = []
    for i in 0..<affectedUserAgentsCount! {
      let affectedUserAgent = stream.readVarString()
      if affectedUserAgent == nil {
        Logger.warn("Failed to parse affectedUserAgent \(i) from Alert")
        return nil
      }
      affectedUserAgents.append(affectedUserAgent!)
    }
    let priority = stream.readInt32()
    if priority == nil {
      Logger.warn("Failed to parse priority from Alert")
      return nil
    }
    let comment = stream.readVarString()
    if comment == nil {
      Logger.warn("Failed to parse comment from Alert")
      return nil
    }
    let message = stream.readVarString()
    if message == nil {
      Logger.warn("Failed to parse message from Alert")
      return nil
    }
    let reserved = stream.readVarString()
    if reserved == nil {
      Logger.warn("Failed to parse reserved from Alert")
      return nil
    }
    return Alert(version: version!,
                 relayUntilDate: relayUntilDate!,
                 expirationDate: expirationDate!,
                 ID: ID!,
                 cancelID: cancelID!,
                 cancelIDs: cancelIDs,
                 minimumVersion: minimumVersion!,
                 maximumVersion: maximumVersion!,
                 affectedUserAgents: affectedUserAgents,
                 priority: priority!,
                 comment: comment!,
                 message: message!,
                 reserved: reserved!)
  }
}
