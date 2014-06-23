//
//  ECKey.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/15/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

// Represents a private/public EC key pair, created using the secp256k1 curve.
// Note: This is objective-c because it depends on the openssl library, which is in c.
@interface ECKey : NSObject

@property(nonatomic, readonly) NSData *publicKey;
@property(nonatomic, readonly) NSData *privateKey;

// Returns the signature for the provided hash. Only supports 256-bit hash.
- (NSData *)signatureForHash:(NSData *)hash;
- (BOOL)verifySignature:(NSData *)signature forHash:(NSData *)hash;

@end
