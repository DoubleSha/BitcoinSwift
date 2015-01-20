[![Build Status](https://travis-ci.org/DoubleSha/BitcoinSwift.svg?branch=master)](https://travis-ci.org/DoubleSha/BitcoinSwift)

BitcoinSwift
============

BitcoinSwift is a framework for iOS and OSX Bitcoin wallet developers. It is an implementation of the Bitcoin SPV protocol written (almost) entirely in swift.

Please dive in and feel free to get your hands dirty. If you want to contribute, just send an email to the mailing list or ping me directly. Cypherpunks write code.

Mailing list: https://groups.google.com/forum/#!forum/bitcoinswift  
IRC (freenode): #bitcoinswift


Features
============

Secure BIP32 key hierarchy. See ExtendedECKey.  
All bitcoin protocol messages are supported.  
The low-level networking layer is finished. See PeerConnection.  
Initial block header synching, with InMemorySPVBlockStore. See PeerController.  


Roadmap (in order of priority)
============

Transaction building and signing.  
KeyStore for storing private keys in the OSX/iOS keychain.  
Persistent SPVBlockStore using CoreData.  
Wallet for tracking balance and transaction history.  
Full SPV support with bloom filtering.  
