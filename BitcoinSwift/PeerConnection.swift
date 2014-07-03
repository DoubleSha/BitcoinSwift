//
//  PeerConnection.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

protocol PeerDiscovery {
  func nextPeerHostname() -> NSURL
}

@class_protocol protocol PeerConnectionDelegate {

}

class PeerConnection: NSObject, NSURLConnectionDataDelegate {

  let peerDiscovery: PeerDiscovery
  weak var delegate: PeerConnectionDelegate?

  init(peerDiscovery: PeerDiscovery, delegate: PeerConnectionDelegate? = nil) {
    self.peerDiscovery = peerDiscovery
    self.delegate = delegate
  }

  func open() {
    let request = NSURLRequest(URL:peerDiscovery.nextPeerHostname())
    var conn = NSURLConnection(request:request, delegate:self)
  }

  func close() {

  }

  // NSURLConnectionDataDelegate

  func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {

  }

  func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {

  }

  func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {

  }
}
