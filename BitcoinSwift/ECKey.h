//
//  ECKey.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/15/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BigInteger;
@class SecureData;

/// Represents a private/public EC key pair, created using the secp256k1 curve.
@interface ECKey : NSObject

+ (BigInteger *)curveOrder;
+ (const int)privateKeyLength;
+ (const int)compressedPublicKeyLength;
+ (const int)uncompressedPublicKeyLength;

/// The ECDSA private key. Can be nil if the ECKey was created with only a public key.
@property(nonatomic, readonly) SecureData *privateKey;

/// The ECDSA public key in compressed format.
@property(nonatomic, readonly) NSData *publicKey;

/// The ECDSA public key in uncompressed format.
@property(nonatomic, readonly) NSData *uncompressedPublicKey;

/// Creates a randomly generated private/public key pair.
- (instancetype)init;

/// Creates a key with a given private key.
- (instancetype)initWithPrivateKey:(SecureData *)privateKey;

/// Creates a key with only a public key. Cannot be used to sign data. Does not allocate any secure
/// memory. publicKey can be either compressed or uncompressed.
- (instancetype)initWithPublicKey:(NSData *)publicKey;

/// Returns the signature for the provided hash. Only supports 256-bit hash.
- (NSData *)signatureForHash:(NSData *)hash;
- (BOOL)verifySignature:(NSData *)signature forHash:(NSData *)hash;

@end
