Build status: [![Build Status](https://travis-ci.org/DoubleSha/BitcoinSwift.svg?branch=master)](https://travis-ci.org/DoubleSha/BitcoinSwift)

Note: Travis-CI doesn't work yet with 6.1, so it'll be broken until they fix that.


BitcoinSwift
============

BitcoinSwift is an implementation of the Bitcoin protocol written (almost) entirely in swift.

Mailing list: https://groups.google.com/forum/#!forum/bitcoinswift

IRC (freenode): #bitcoinswift

It is a framework that can be linked into any iOS or OSX project. The code is modular, well-documented and very well-tested. I expect all pull requests to include unit tests. We don't take shortcuts around here.

Please dive in and feel free to get your hands dirty. If you want to contribute, just send an email to the mailing list or find me on irc (#bitcoinswift).

Cypherpunks write code. Pull requests welcome. Hack the planet!


Status
============

So far the low-level networking layer is almost finished. The PeerConnection class can be used to connect to a peer and exchange version information. A PeerConnection instance handles receiving & sending as well as serializing & deserializing messages on a background thread, and passes received messages to a delegate to be processed.

The biggest todo right now is to finish adding model objects for each message command. The commands are defined in Message.swift (https://github.com/DoubleSha/BitcoinSwift/blob/master/BitcoinSwift/Message.swift#L25). There are comments deliniating which messages have been done already, which are in progress, and which still need to be added.

Feel free to grab one and send a pull request if you're looking for a quick project :). Just be sure to ping me on irc or on the mailing list beforehand so we don't overlap.
