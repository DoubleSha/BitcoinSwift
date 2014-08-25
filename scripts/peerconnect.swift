#!/usr/bin/env xcrun swift -sdk /Applications/Xcode6-Beta6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk -F /Users/kevin/Library/Developer/Xcode/DerivedData/BitcoinSwift-aghrfqozlzzfdwgznnqzifwhidhq/Build/Products/Debug

import BitcoinSwift
import Foundation

let conn = PeerConnection(hostname:"localhost",
                          port:8333,
                          networkMagicValue:Message.NetworkMagicValue.MainNet)

let emptyPeerAddress = PeerAddress(services:PeerServices.NodeNetwork,
                                   IP:IPAddress.IPV4(0),
                                   port:8333)
let versionMessage = VersionMessage(protocolVersion:70002,
                                    services:PeerServices.NodeNetwork,
                                    date: NSDate(),
                                    senderAddress:emptyPeerAddress,
                                    receiverAddress:emptyPeerAddress,
                                    nonce:0,
                                    userAgent:"test",
                                    blockStartHeight:0,
                                    announceRelayedTransactions:true)

conn.connectWithVersionMessage(versionMessage)

while true {
  NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow:0.1))
}
