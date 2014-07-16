//
//  DNSPeerDiscovery.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/9/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

class DNSPeerDiscovery: PeerDiscovery {

  let seeds: String[]

  init(seeds: String[]) {
    self.seeds = seeds
  }

  // MARK: - PeerDiscovery

  func peersWithCompletion(completion: (peerAddresses: IPAddress[])) {
    let hostRef = CFHostCreateWithName(kCFAllocatorDefault, "google.com").takeRetainedValue()
    var resolved = CFHostStartInfoResolution(hostRef, CFHostInfoType.Addresses, nil)
    let addresses = CFHostGetAddressing(hostRef, &resolved).takeUnretainedValue()
  }
}
