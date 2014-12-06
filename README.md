[![Build Status](https://travis-ci.org/DoubleSha/BitcoinSwift.svg?branch=master)](https://travis-ci.org/DoubleSha/BitcoinSwift)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

BitcoinSwift
============

BitcoinSwift is a framework built to make it easy for developers to create bitcoin wallet apps for iOS and OSX. It is an implementation of the Bitcoin protocol written (almost) entirely in swift.

Mailing list: https://groups.google.com/forum/#!forum/bitcoinswift

IRC (freenode): #bitcoinswift

It is a framework that can be linked into any iOS or OSX project. The code is modular, well-documented and very well-tested.

Please dive in and feel free to get your hands dirty. If you want to contribute, just send an email to the mailing list or find me on irc (#bitcoinswift).

Cypherpunks write code. Pull requests welcome. Hack the planet!


Status
============

So far the low-level networking layer is finished. The PeerConnection class can be used to connect to a peer and exchange version information. A PeerConnection instance handles receiving & sending as well as serializing & deserializing protocol messages on a background thread. It passes received messages to a delegate (typically a PeerController) to be processed at a higher level.
