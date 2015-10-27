[![Build Status](https://travis-ci.org/DoubleSha/BitcoinSwift.svg?branch=master)](https://travis-ci.org/DoubleSha/BitcoinSwift)  
Note: Travis CI is not yet compatible with Swift 2, so it will look broken until they fix that.

BitcoinSwift
============

BitcoinSwift is a framework for iOS and OSX Bitcoin wallet developers. It is an implementation of the Bitcoin SPV protocol written (almost) entirely in swift.

Please dive in and feel free to get your hands dirty. If you want to contribute, just send an email to the mailing list or ping me directly. Cypherpunks write code.

Mailing list: https://groups.google.com/forum/#!forum/bitcoinswift  
IRC (freenode): #bitcoinswift


Features
============

Secure BIP32 key hierarchy. See ExtendedECKey.  
Key store for storing private keys in the OSX/iOS keychain. See OSKeyChainSecureDataStore.  
All bitcoin protocol messages are supported.  
The low-level networking layer is finished. See PeerConnection.  
Initial block header sync. See PeerController.  
Persistent BlockChainStore using CoreData.  


Roadmap (in order of priority)
============

Transaction building and signing.  
Wallet for tracking balance and transaction history.  
Full SPV support with bloom filtering.  
