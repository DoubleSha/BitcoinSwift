//
//  DNSDiscoveryLiveTests.swift
//  BitcoinSwiftLiveTests
//
//  Created by Kevin Greene on 7/16/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class BitcoinSwiftLiveTests: XCTestCase {
    
  func testDNSAddressResolution() {
    let peerDiscovery = DNSPeerDiscovery(seeds: ["google.com"])
    peerDiscovery.peersWithCompletion() { peerAddresses in
      for peerAddress in peerAddresses {
        switch peerAddress {
          case .IPV4(let word0): 
            print(NSString(format: "%x", word0))
          case .IPV6(let word0, let word1, let word2, let word3): 
            print(NSString(format: "%x%x%x%x", word0, word1, word2, word3))
        }
      }
    }
  }
}
