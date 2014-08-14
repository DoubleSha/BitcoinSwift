//
//  PeerConnection.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public protocol PeerDiscovery {
  func peersWithCompletion(completion: [IPAddress] -> Void)
}

public protocol PeerConnectionDelegate : class {
}

public class PeerConnection: NSObject, NSURLConnectionDataDelegate {

  public let peerDiscovery: PeerDiscovery
  public weak var delegate: PeerConnectionDelegate?

  public init(peerDiscovery: PeerDiscovery, delegate: PeerConnectionDelegate? = nil) {
    self.peerDiscovery = peerDiscovery
    self.delegate = delegate
  }

  public func open() {
//    let request = NSURLRequest(URL:peerDiscovery.nextPeerHostname())
//    var conn = NSURLConnection(request:request, delegate:self)
  }

  public func close() {

  }

  // MARK: - NSURLConnectionDataDelegate

  public func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
  }

  public func connection(connection: NSURLConnection!,
                         didReceiveResponse response: NSURLResponse!) {
  }

  public func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
  }
}
