//
//  BitcoinSerializable.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/7/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

public protocol BitcoinSerializable {

  // Gets the bitcoin-serialized data that can be transmitted over the wire to peers.
  var bitcoinData: NSData { get }

  /// Tries to parse the object from the stream. If the data is invalid for any reason, returns nil.
  static func fromBitcoinStream(stream: NSInputStream) -> Self?
}
