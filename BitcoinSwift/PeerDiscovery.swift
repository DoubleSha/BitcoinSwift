//
//  PeerDiscovery.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/17/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public protocol PeerDiscovery {
  func peersWithCompletion(completion: [IPAddress] -> Void)
}
