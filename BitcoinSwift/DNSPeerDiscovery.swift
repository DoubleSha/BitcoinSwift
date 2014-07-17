//
//  DNSPeerDiscovery.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/9/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

class DNSPeerDiscovery: PeerDiscovery {

  let seeds: [String]

  init(seeds: [String]) {
    self.seeds = seeds
  }

  // MARK: - PeerDiscovery

  func peersWithCompletion(completion: [IPAddress] -> Void) {
    completion([IPAddress]())
  }

//  func peersWithCompletion(completion: [IPAddress] -> Void) {
//    let hostRef = CFHostCreateWithName(kCFAllocatorDefault, "google.com").takeRetainedValue()
//    var resolved = CFHostStartInfoResolution(hostRef, CFHostInfoType.Addresses, nil)
//    let sockaddrs = CFHostGetAddressing(hostRef, &resolved).takeRetainedValue() as NSArray
//    var addresses = IPAddress[]()
//    for sockaddrObject: AnyObject in sockaddrs {
//      var addr: sockaddr = sockaddr(sa_len:0,
//                                    sa_family:0,
//                                    sa_data:(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
//      let data = sockaddrObject as NSData
//      data.getBytes(&addr, length:sizeof(sockaddr))
//      if Int(addr.sa_family) == Int(AF_INET) {
//        let (byte0, byte1, byte2, byte3, _, _, _, _, _, _, _, _, _, _) = addr.sa_data
//        let data = NSMutableData()
//        data.appendUInt8(UInt8(byte0))
//        data.appendUInt8(UInt8(byte1))
//        data.appendUInt8(UInt8(byte2))
//        data.appendUInt8(UInt8(byte3))
//        addresses.append(IPAddress.IPV4(data.UInt32AtIndex(0, endianness:.BigEndian)!))
//      } else if Int(addr.sa_family) == Int(AF_INET6) {
//        println("Ignoring IPV6 address. How can we handle this? length: \(addr.sa_len)")
//      }
//    }
//    completion(addresses)
//  }
}
