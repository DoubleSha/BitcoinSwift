BitcoinSwift
============

A library for working with Bitcoin for iOS and OSX.

IRC (freenode): #bitcoinswift

So far the networking layer is almost finished. The PeerConnection struct can be used to connect to a peer and exchange version information. A PeerConnection instance handles receiving/sending as well as serializing & deserializing messages on a background thread, and passes received messages to a delegate to be processed.

The biggest todo right now is to finish adding model objects for each message command. The commands are defined in Message.swift (https://github.com/DoubleSha/BitcoinSwift/blob/master/BitcoinSwift/Message.swift#L25). There are comments deliniating which messages have been done already, which are in progress, and which still need to be added.

Feel free to grab one and send a pull request if you're looking for a quick project :). Just be sure to ping me on irc or email beforehand so we don't overlap.
