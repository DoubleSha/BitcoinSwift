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

@interface ECKey()

@property(nonatomic, assign) EC_KEY *ECKey;

@end

@implementation ECKey

@synthesize publicKey = _publicKey;
@synthesize privateKey = _privateKey;

- (instancetype)init {
  self = [super init];
  if (self) {
    _ECKey = EC_KEY_new_by_curve_name(NID_secp256k1);
    NSAssert(_ECKey, @"Failed to create ECKey");
    NSAssert(EC_KEY_generate_key(_ECKey), @"Failed to generate ECKey");
    EC_KEY_set_conv_form(_ECKey, POINT_CONVERSION_COMPRESSED);
  }
  return self;
}

- (void)dealloc {
  if (_ECKey) {
    EC_KEY_free(_ECKey);
  }
}

- (NSData *)publicKey {
  if (_publicKey) {
    return _publicKey;
  }
  int publicKeyLength = i2o_ECPublicKey(_ECKey, NULL);
  if (!publicKeyLength) {
    return nil;
  }
  unsigned char publicKeyBytes[publicKeyLength];
  unsigned char *publicKeyBytesP = publicKeyBytes;
  if (i2o_ECPublicKey(_ECKey, &publicKeyBytesP) != publicKeyLength) {
    return nil;
  }
  _publicKey = [NSData dataWithBytes:publicKeyBytes length:publicKeyLength];
  return _publicKey;
}

- (NSData *)privateKey {
  if (_privateKey) {
    return _privateKey;
  }
  int privateKeyLength = i2d_ECPrivateKey(_ECKey, NULL);
  if (!privateKeyLength) {
    return nil;
  }
  unsigned char privateKeyBytes[privateKeyLength];
  unsigned char *privateKeyBytesP = privateKeyBytes;
  if (i2d_ECPrivateKey(_ECKey, &privateKeyBytesP) != privateKeyLength) {
    return nil;
  }
  _privateKey = [NSData dataWithBytes:privateKeyBytes length:privateKeyLength];
  return _privateKey;
}

- (NSData *)signatureForHash:(NSData *)hash {
  NSAssert([hash length] == 32, @"signatureForHash: only supports 256-bit hashes");
  ECDSA_SIG *signature = ECDSA_do_sign([hash bytes], (int)[hash length], _ECKey);
  if (!signature) {
    return nil;
  }
  BN_CTX *ctx = BN_CTX_new();
  BN_CTX_start(ctx);
  const EC_GROUP *group = EC_KEY_get0_group(_ECKey);
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
                            _ECKey);
  // -1 = error, 0 = bad sig, 1 = good.
  return result == 1;
}

@end
