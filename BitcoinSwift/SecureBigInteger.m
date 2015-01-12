//
//  SecureBigInteger.m
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/7/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

#import "SecureBigInteger.h"

#import <openssl/bn.h>

#import "BigInteger+objc.h"
#import "SecureData.h"

@interface SecureBigInteger()

@property(nonatomic, strong) SecureData *secureData;

@end

@implementation SecureBigInteger

- (instancetype)initWithSecureData:(SecureData *)secureData {
  self = [super init];
  if (self) {
    _secureData = secureData;
  }
  return self;
}

- (SecureBigInteger *)add:(SecureBigInteger *)other modulo:(BigInteger *)modulo {
  BN_CTX *ctx = BN_CTX_new();
  // Allocate intermediate bignums on the stack so there is no chance they can be paged to disk.
  BIGNUM result, bn, otherBn;
  BN_init(&result);
  BN_init(&bn);
  BN_init(&otherBn);
  BN_bin2bn(_secureData.mutableBytes, (int)_secureData.length, &bn);
  BN_bin2bn(other.secureData.mutableBytes, (int)other.secureData.length, &otherBn);
  BN_mod_add(&result, &bn, &otherBn, modulo.bn, ctx);
  SecureData *resultData = [[SecureData alloc] initWithLength:BN_num_bytes(&result)];
  BN_bn2bin(&result, resultData.mutableBytes);
  BN_clear(&result);
  BN_clear(&bn);
  BN_clear(&otherBn);
  BN_CTX_free(ctx);
  return [[SecureBigInteger alloc] initWithSecureData:resultData];
}

- (BOOL)isEqual:(BigInteger *)other {
  // Allocate intermediate bignums on the stack so there is no chance they can be paged to disk.
  BIGNUM bn;
  BN_init(&bn);
  BN_bin2bn(_secureData.mutableBytes, (int)_secureData.mutableData.length, &bn);
  BOOL isEqual = BN_cmp(&bn, other.bn) == 0;
  BN_clear(&bn);
  return isEqual;
}

- (BOOL)greaterThan:(BigInteger *)other {
  // Allocate intermediate bignums on the stack so there is no chance they can be paged to disk.
  BIGNUM bn;
  BN_init(&bn);
  BN_bin2bn(_secureData.mutableBytes, (int)_secureData.mutableData.length, &bn);
  BOOL isEqual = BN_cmp(&bn, other.bn) > 0;
  BN_clear(&bn);
  return isEqual;
}

- (BOOL)greaterThanOrEqual:(BigInteger *)other {
  // Allocate intermediate bignums on the stack so there is no chance they can be paged to disk.
  BIGNUM bn;
  BN_init(&bn);
  BN_bin2bn(_secureData.mutableBytes, (int)_secureData.mutableData.length, &bn);
  BOOL isEqual = BN_cmp(&bn, other.bn) >= 0;
  BN_clear(&bn);
  return isEqual;
}

- (BOOL)lessThan:(BigInteger *)other {
  // Allocate intermediate bignums on the stack so there is no chance they can be paged to disk.
  BIGNUM bn;
  BN_init(&bn);
  BN_bin2bn(_secureData.mutableBytes, (int)_secureData.mutableData.length, &bn);
  BOOL isEqual = BN_cmp(&bn, other.bn) < 0;
  BN_clear(&bn);
  return isEqual;
}

- (BOOL)lessThanOrEqual:(BigInteger *)other {
  // Allocate intermediate bignums on the stack so there is no chance they can be paged to disk.
  BIGNUM bn;
  BN_init(&bn);
  BN_bin2bn(_secureData.mutableBytes, (int) _secureData.mutableData.length, &bn);
  BOOL isEqual = BN_cmp(&bn, other.bn) <= 0;
  BN_clear(&bn);
  return isEqual;
}

@end
