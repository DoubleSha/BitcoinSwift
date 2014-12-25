//
//  ECKey.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/15/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BigInteger;

// Represents a private/public EC key pair, created using the secp256k1 curve.
// Note: This is objective-c because it depends on the openssl library, which is in c.
@interface ECKey : NSObject

+ (BigInteger *)curveOrder;

@property(nonatomic, readonly) NSData *publicKey;
@property(nonatomic, readonly) NSData *privateKey;

- (instancetype)init;
- (instancetype)initWithPrivateKey:(NSData *)privateKey;
- (instancetype)initWithPublicKey:(NSData *)publicKey;

// Returns the signature for the provided hash. Only supports 256-bit hash.
- (NSData *)signatureForHash:(NSData *)hash;
- (BOOL)verifySignature:(NSData *)signature forHash:(NSData *)hash;

@end
