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
#import "SecureData.h"
#import "SecureBigInteger.h"

@interface ECKey()

@property(nonatomic, strong) SecureData *privateKey;
@property(nonatomic, strong) NSData *publicKey;

@end

@implementation ECKey

+ (const int)privateKeyLength {
  return 32;
}

+ (const int)compressedPublicKeyLength {
  return 33;
}

+ (const int)uncompressedPublicKeyLength {
  return 65;
}

+ (BigInteger *)curveOrder {
  BIGNUM *order = BN_new();
  EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
  EC_GROUP_get_order(group, order, NULL);
  EC_GROUP_free(group);
  return [[BigInteger alloc] initWithBIGNUM:order];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _privateKey = [[SecureData alloc] initWithLength:[ECKey privateKeyLength]];
    BigInteger *zero = [[BigInteger alloc] initWithIntegerLiteral:0];
    BigInteger *order = [ECKey curveOrder];
    SecureBigInteger *privateKeyInt = nil;
    int tries = 0;
    while (privateKeyInt == nil || [privateKeyInt isEqual:zero] ||
        [privateKeyInt greaterThanOrEqual:order]) {
      int result = SecRandomCopyBytes(kSecRandomDefault,
                                      _privateKey.length,
                                      _privateKey.mutableBytes);
      NSAssert(result == 0, @"Failed to generate private key");
      privateKeyInt = [[SecureBigInteger alloc] initWithSecureData:_privateKey];
      NSAssert(++tries <= 5, @"Failed to generate private key");
    }
  }
  return self;
}

- (instancetype)initWithPrivateKey:(SecureData *)privateKey {
  NSAssert(privateKey != nil && privateKey.length == [ECKey privateKeyLength],
           @"Invalid privateKey");
  self = [super init];
  if (self) {
    _privateKey = privateKey;
  }
  return self;
}

- (instancetype)initWithPublicKey:(NSData *)publicKey {
  NSAssert(publicKey != nil && (publicKey.length == [ECKey compressedPublicKeyLength] ||
           publicKey.length == [ECKey uncompressedPublicKeyLength]), @"Invalid publicKey");
  self = [super init];
  if (self) {
    if (publicKey.length == [ECKey compressedPublicKeyLength]) {
      _publicKey = publicKey;
    } else {
      _publicKey = [self compressedPublicKeyFromUncompressedPublicKey:publicKey];
    }
  }
  return self;
}

- (NSData *)publicKey {
  if (_publicKey) {
    return _publicKey;
  }
  EC_POINT *publicKeyPoint = [self publicKeyPointFromPrivateKey:_privateKey];
  _publicKey = [self publicKeyFromECPoint:publicKeyPoint compressed:YES];
  EC_POINT_clear_free(publicKeyPoint);
  return _publicKey;
}

- (NSData *)uncompressedPublicKey {
  return [self uncompressedPublicKeyFromCompressedPublicKey:self.publicKey];
}

- (NSData *)signatureForHash:(NSData *)hash {
  NSAssert(hash.length == 32, @"signatureForHash: only supports 256-bit hashes");
  EC_KEY *key = [self ECKeyWithPrivateKey:_privateKey];
  ECDSA_SIG *signature = ECDSA_do_sign([hash bytes], (int)hash.length, key);
  EC_KEY_free(key);
  if (!signature) {
    return nil;
  }
  BN_CTX *ctx = BN_CTX_new();
  BN_CTX_start(ctx);
  EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
  BIGNUM *order = BN_CTX_get(ctx);
  EC_GROUP_get_order(group, order, ctx);
  EC_GROUP_free(group);
  BIGNUM *halforder = BN_CTX_get(ctx);
  BN_rshift1(halforder, order);
  if (BN_cmp(signature->s, halforder) > 0) {
    // Enforce low S values by negating the value (modulo the order) if above order / 2.
    BN_sub(signature->s, order, signature->s);
  }
  BN_CTX_end(ctx);
  BN_CTX_free(ctx);
  unsigned int signatureLength = i2d_ECDSA_SIG(signature, NULL);
  NSMutableData *signatureData = [[NSMutableData alloc] initWithLength:signatureLength];
  unsigned char *signatureBytes = signatureData.mutableBytes;
  // TODO: Use hmac-drbg to create the signature.
  if (i2d_ECDSA_SIG(signature, &signatureBytes) != signatureLength) {
    ECDSA_SIG_free(signature);
    return nil;
  }
  ECDSA_SIG_free(signature);
  return signatureData;
}

- (BOOL)verifySignature:(NSData *)signature forHash:(NSData *)hash {
  NSAssert(hash.length == 32, @"verifySignature: forHash: only supports 256-bit hashes");
  EC_KEY *key = [self ECKeyWithPublicKey:self.publicKey];
  int result = ECDSA_verify(0,
                            hash.bytes,
                            (int)hash.length,
                            signature.bytes,
                            (int)signature.length,
                            key);
  EC_KEY_free(key);
  // -1 = error, 0 = bad sig, 1 = good.
  return result == 1;
}

#pragma mark Private Methods

- (NSData *)publicKeyFromECPoint:(EC_POINT *)publicKeyPoint compressed:(BOOL)compressed {
  EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
  BIGNUM publicKeyBn;
  BN_init(&publicKeyBn);
  point_conversion_form_t pointConversionForm = compressed ? POINT_CONVERSION_COMPRESSED :
      POINT_CONVERSION_UNCOMPRESSED;
  EC_POINT_point2bn(group, publicKeyPoint, pointConversionForm, &publicKeyBn, NULL);
  int length = compressed ? [ECKey compressedPublicKeyLength] : [ECKey uncompressedPublicKeyLength];
  NSMutableData *publicKey = [[NSMutableData alloc] initWithLength:length];
  NSUInteger offset = publicKey.length - BN_num_bytes(&publicKeyBn);
  NSAssert(offset < publicKey.length, @"Invalid offset");
  BN_bn2bin(&publicKeyBn, publicKey.mutableBytes + offset);
  BN_clear(&publicKeyBn);
  EC_GROUP_free(group);
  return publicKey;
}

- (NSData *)uncompressedPublicKeyFromCompressedPublicKey:(NSData *)compressedPublicKey {
  NSAssert(compressedPublicKey.length == [ECKey compressedPublicKeyLength],
           @"Invalid compressed public key length");
  EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
  BIGNUM publicKeyBn;
  BN_init(&publicKeyBn);
  BN_bin2bn(compressedPublicKey.bytes, (int)compressedPublicKey.length, &publicKeyBn);
  EC_POINT *publicKeyPoint = EC_POINT_new(group);
  EC_POINT_bn2point(group, &publicKeyBn, publicKeyPoint, NULL);
  NSData *uncompressedPublicKey = [self publicKeyFromECPoint:publicKeyPoint compressed:NO];
  EC_POINT_clear_free(publicKeyPoint);
  BN_clear(&publicKeyBn);
  EC_GROUP_free(group);
  return uncompressedPublicKey;
}

- (NSData *)compressedPublicKeyFromUncompressedPublicKey:(NSData *)uncompressedPublicKey {
  NSAssert(uncompressedPublicKey.length == [ECKey uncompressedPublicKeyLength],
           @"Invalid uncompressed public key length");
  EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
  BIGNUM publicKeyBn;
  BN_init(&publicKeyBn);
  BN_bin2bn(uncompressedPublicKey.bytes, (int)uncompressedPublicKey.length, &publicKeyBn);
  EC_POINT *publicKeyPoint = EC_POINT_new(group);
  EC_POINT_bn2point(group, &publicKeyBn, publicKeyPoint, NULL);
  NSData *compressedPublicKey = [self publicKeyFromECPoint:publicKeyPoint compressed:YES];
  EC_POINT_clear_free(publicKeyPoint);
  BN_clear(&publicKeyBn);
  EC_GROUP_free(group);
  return compressedPublicKey;
}

- (EC_POINT *)publicKeyPointFromPrivateKey:(SecureData *)privateKey {
  NSAssert(privateKey != nil, @"nil privateKey");
  // Allocate the intermediate private key bn on the stack so it can't be paged to disk.
  BIGNUM privateKeyBn;
  BN_init(&privateKeyBn);
  BN_bin2bn(_privateKey.bytes, (int)_privateKey.length, &privateKeyBn);
  EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
  EC_POINT *publicKeyPoint = EC_POINT_new(group);
  int result = EC_POINT_mul(group, publicKeyPoint, &privateKeyBn, NULL, NULL, NULL);
  NSAssert(result == 1, @"Failed to create public key from private key");
  BN_clear(&privateKeyBn);
  EC_GROUP_free(group);
  return publicKeyPoint;
}

// NOTE: There is nothing preventing the EC_KEY from being paged to disk, so keep it in memory
// only for the shortest time necessary.
- (EC_KEY *)ECKeyWithPrivateKey:(SecureData *)privateKey {
  EC_KEY *key = EC_KEY_new_by_curve_name(NID_secp256k1);
  // Allocate the intermediate private key bn on the stack so it can't be paged to disk.
  BIGNUM privateKeyBn;
  BN_init(&privateKeyBn);
  BN_bin2bn(_privateKey.bytes, (int)_privateKey.length, &privateKeyBn);
  EC_POINT *publicKeyPoint = [self publicKeyPointFromPrivateKey:_privateKey];
  EC_KEY_set_public_key(key, publicKeyPoint);
  EC_KEY_set_private_key(key, &privateKeyBn);
  BN_clear(&privateKeyBn);
  EC_POINT_clear_free(publicKeyPoint);
  NSAssert(EC_KEY_check_key(key), @"Invalid key");
  return key;
}

- (EC_KEY *)ECKeyWithPublicKey:(NSData *)publicKey {
  EC_KEY *key = EC_KEY_new_by_curve_name(NID_secp256k1);
  const EC_GROUP *group = EC_KEY_get0_group(key);
  BIGNUM publicKeyBn;
  BN_init(&publicKeyBn);
  BN_bin2bn(publicKey.bytes, (int)publicKey.length, &publicKeyBn);
  EC_POINT *publicKeyPoint = EC_POINT_new(group);
  EC_POINT_bn2point(group, &publicKeyBn, publicKeyPoint, NULL);
  EC_KEY_set_public_key(key, publicKeyPoint);
  BN_clear(&publicKeyBn);
  EC_POINT_clear_free(publicKeyPoint);
  NSAssert(EC_KEY_check_key(key), @"Invalid key");
  return key;
}

@end
