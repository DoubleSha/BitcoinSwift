//
//  DNSPeerDiscovery.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/9/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public class DNSPeerDiscovery: PeerDiscovery {

  public let seeds: [String]

  public init(seeds: [String]) {
    self.seeds = seeds
  }

  // MARK: - PeerDiscovery

  public func peersWithCompletion(completion: [IPAddress] -> Void) {
//    let hostRef = CFHostCreateWithName(kCFAllocatorDefault, "google.com").takeRetainedValue()
//    var resolved = CFHostStartInfoResolution(hostRef, CFHostInfoType.Addresses, nil)
//    let sockAddrs = CFHostGetAddressing(hostRef, &resolved).takeRetainedValue() as NSArray
//    var IPAddresses: [IPAddress] = []
//    for sockAddrData in sockAddrs as [NSData] {
//      let sockAddrP = UnsafePointer<sockaddr_storage>.alloc(1)
//      sockAddrData.getBytes(sockAddrP, length:sizeof(sockaddr_storage))
//      let sockAddr = sockAddrP.memory
//      switch Int32(sockAddr.ss_family) {
//        case AF_INET:
//          IPAddresses.append(IPAddress.IPV4(0))
//        case AF_INET6:
//          IPAddresses.append(IPAddress.IPV6(0, 0, 0, 0))
//        default:
//          break
//      }
//      sockAddrP.destroy()
//    }
//    completion(IPAddresses)
  }
}
