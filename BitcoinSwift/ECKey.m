//
//  ECKey.m
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/15/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import "ECKey.h"

#import <openssl/bn.h>
#import <openssl/ecdsa.h>
#import <openssl/obj_mac.h>

#import "BigInteger+objc.h"

@interface ECKey()

@property(nonatomic, assign) EC_KEY *key;

@end

@implementation ECKey

@synthesize publicKey = _publicKey;
@synthesize privateKey = _privateKey;

- (instancetype)init {
  self = [super init];
  if (self) {
    _key = EC_KEY_new_by_curve_name(NID_secp256k1);
    NSAssert(_key, @"Failed to create ECKey");
    NSAssert(EC_KEY_generate_key(_key), @"Failed to generate ECKey");
    EC_KEY_set_conv_form(_key, POINT_CONVERSION_COMPRESSED);
  }
  return self;
}

- (instancetype)initWithPrivateKey:(NSData *)privateKey {
  self = [super init];
  if (self) {
    _key = EC_KEY_new_by_curve_name(NID_secp256k1);
    NSAssert(_key, @"Failed to create ECKey");
    BN_CTX *ctx = BN_CTX_new();
    const EC_GROUP *group = EC_KEY_get0_group(_key);
    EC_POINT *publicKey = EC_POINT_new(group);
    BIGNUM *privateKeyBn = BN_new();
    BN_bin2bn(privateKey.bytes, (int) privateKey.length, privateKeyBn);
    EC_POINT_mul(group, publicKey, privateKeyBn, NULL, NULL, ctx);
    EC_KEY_set_private_key(_key, privateKeyBn);
    EC_KEY_set_public_key(_key, publicKey);
    EC_KEY_set_conv_form(_key, POINT_CONVERSION_COMPRESSED);
    BN_clear_free(privateKeyBn);
    EC_POINT_free(publicKey);
    BN_CTX_free(ctx);
    NSAssert(EC_KEY_check_key(_key), @"Invalid key");
  }
  return self;
}

- (instancetype)initWithPublicKey:(NSData *)publicKey {
  self = [super init];
  if (self) {
    _key = EC_KEY_new_by_curve_name(NID_secp256k1);
    NSAssert(_key, @"Failed to create ECKey");
    const unsigned char *bytes = publicKey.bytes;
    o2i_ECPublicKey(&_key, &bytes, publicKey.length);
  }
  return self;
}

- (void)dealloc {
  if (_key) {
    EC_KEY_free(_key);
  }
}

- (NSData *)publicKey {
  if (_publicKey) {
    return _publicKey;
  }
  int publicKeyLength = i2o_ECPublicKey(_key, NULL);
  if (!publicKeyLength) {
    return nil;
  }
  unsigned char publicKeyBytes[publicKeyLength];
  unsigned char *publicKeyBytesP = publicKeyBytes;
  if (i2o_ECPublicKey(_key, &publicKeyBytesP) != publicKeyLength) {
    return nil;
  }
  _publicKey = [NSData dataWithBytes:publicKeyBytes length:publicKeyLength];
  return _publicKey;
}

- (NSData *)privateKey {
  if (_privateKey) {
    return _privateKey;
  }
  const BIGNUM *privateKeyBn = EC_KEY_get0_private_key(_key);
  if (privateKeyBn == nil) {
    return nil;
  }
  NSMutableData *privateKey = [[NSMutableData alloc] initWithLength:BN_num_bytes(privateKeyBn)];
  BN_bn2bin(privateKeyBn, privateKey.mutableBytes);
  _privateKey = privateKey;
  return _privateKey;
}

- (NSData *)signatureForHash:(NSData *)hash {
  NSAssert([hash length] == 32, @"signatureForHash: only supports 256-bit hashes");
  ECDSA_SIG *signature = ECDSA_do_sign([hash bytes], (int)[hash length], _key);
  if (!signature) {
    return nil;
  }
  BN_CTX *ctx = BN_CTX_new();
  BN_CTX_start(ctx);
  const EC_GROUP *group = EC_KEY_get0_group(_key);
  BIGNUM *order = BN_CTX_get(ctx);
  BIGNUM *halforder = BN_CTX_get(ctx);
  EC_GROUP_get_order(group, order, ctx);
  BN_rshift1(halforder, order);
  if (BN_cmp(signature->s, halforder) > 0) {
    // Enforce low S values by negating the value (modulo the order) if above order / 2.
    BN_sub(signature->s, order, signature->s);
  }
  BN_CTX_end(ctx);
  BN_CTX_free(ctx);
  unsigned int signatureLength = i2d_ECDSA_SIG(signature, NULL);
  unsigned char signatureBytes[signatureLength];
  unsigned char *signatureBytesP = signatureBytes;
  if (i2d_ECDSA_SIG(signature, &signatureBytesP) != signatureLength) {
    ECDSA_SIG_free(signature);
    return nil;
  }
  ECDSA_SIG_free(signature);
  return [NSData dataWithBytes:signatureBytes length:signatureLength];
}

- (BOOL)verifySignature:(NSData *)signature forHash:(NSData *)hash {
  NSAssert([hash length] == 32, @"verifySignature: forHash: only supports 256-bit hashes");
  int result = ECDSA_verify(0,
                            [hash bytes],
                            (int)[hash length],
                            [signature bytes],
                            (int)[signature length],
                            _key);
  // -1 = error, 0 = bad sig, 1 = good.
  return result == 1;
}

+ (BigInteger *)curveOrder {
  BIGNUM *order = BN_new();
  EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
  EC_GROUP_get_order(group, order, NULL);
  EC_GROUP_free(group);
  return [[BigInteger alloc] initWithBIGNUM:order];
}

@end
