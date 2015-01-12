//
//  BigInteger.m
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import "BigInteger.h"

#import <openssl/bn.h>

@interface BigInteger()

@property(nonatomic, assign) BIGNUM *bn;

@end

@implementation BigInteger

- (instancetype)init {
  self = [super init];
  if (self) {
    _bn = BN_new();
  }
  return self;
}

- (instancetype)init:(int)value {
  return [self initWithIntegerLiteral:value];
}

- (instancetype)initWithIntegerLiteral:(int)value {
  self = [super init];
  if (self) {
    _bn = BN_new();
    BN_set_word(_bn, value);
  }
  return self;
}

- (instancetype)initWithData:(NSData *)data {
  self = [super init];
  if (self) {
    _bn = BN_new();
    if (data) {
      BN_bin2bn([data bytes], (int)[data length], _bn);
    }
  }
  return self;
}

- (instancetype)initWithCompactData:(NSData *)compactData {
  self = [super init];
  if (self) {
    _bn = BN_new();
    if (compactData) {
      BN_mpi2bn([compactData bytes], (int)[compactData length], _bn);
    }
  }
  return self;
}

- (void)dealloc {
  BN_clear_free(_bn);
}

- (unsigned int)UIntValue {
  return BN_get_word(_bn);
}

- (NSData *)data {
  int size = BN_num_bytes(_bn);
  if (size == 0) {
    return [[NSData alloc] init];
  }
  NSMutableData *buffer = [[NSMutableData alloc] initWithLength:size];
  BN_bn2bin(_bn, buffer.mutableBytes);
  return buffer;
}

- (NSData *)compactData {
  int size = BN_bn2mpi(_bn, NULL);
  if (size == 0) {
    return [[NSData alloc] init];
  }
  NSMutableData *buffer = [[NSMutableData alloc] initWithLength:size];
  BN_bn2mpi(_bn, buffer.mutableBytes);
  return buffer;
}

- (BigInteger *)add:(BigInteger *)other {
  BigInteger *result = [[BigInteger alloc] init];
  BN_add(result.bn, _bn, other.bn);
  return result;
}

- (BigInteger *)subtract:(BigInteger *)other {
  BigInteger *result = [[BigInteger alloc] init];
  BN_sub(result.bn, _bn, other.bn);
  return result;
}

- (BigInteger *)multiply:(BigInteger *)other {
  BN_CTX *ctx = BN_CTX_new();
  BigInteger *result = [[BigInteger alloc] init];
  BN_mul(result.bn, _bn, other.bn, ctx);
  BN_CTX_free(ctx);
  return result;
}

- (BigInteger *)divide:(BigInteger *)other {
  BN_CTX *ctx = BN_CTX_new();
  BigInteger *result = [[BigInteger alloc] init];
  BN_div(result.bn, NULL, _bn, other.bn, ctx);
  BN_CTX_free(ctx);
  return result;
}

- (BigInteger *)modulo:(BigInteger *)other {
  BN_CTX *ctx = BN_CTX_new();
  BigInteger *result = [[BigInteger alloc] init];
  BN_mod(result.bn, _bn, other.bn, ctx);
  BN_CTX_free(ctx);
  return result;
}

- (BigInteger *)add:(BigInteger *)other modulo:(BigInteger *)modulo {
  BN_CTX *ctx = BN_CTX_new();
  BigInteger *result = [[BigInteger alloc] init];
  BN_mod_add(result.bn, _bn, other.bn, modulo.bn, ctx);
  BN_CTX_free(ctx);
  return result;
}

- (BigInteger *)shiftLeft:(int)bits {
  BigInteger *result = [[BigInteger alloc] init];
  BN_lshift(result.bn, _bn, bits);
  return result;
}

- (BigInteger *)shiftRight:(int)bits {
  BigInteger *result = [[BigInteger alloc] init];
  BN_rshift(result.bn, _bn, bits);
  return result;
}

- (BOOL)isEqual:(BigInteger *)other {
  return BN_cmp(_bn, other.bn) == 0;
}

- (BOOL)greaterThan:(BigInteger *)other {
  return BN_cmp(_bn, other.bn) > 0;
}

- (BOOL)greaterThanOrEqual:(BigInteger *)other {
  return BN_cmp(_bn, other.bn) >= 0;
}

- (BOOL)lessThan:(BigInteger *)other {
  return BN_cmp(_bn, other.bn) < 0;
}

- (BOOL)lessThanOrEqual:(BigInteger *)other {
  return BN_cmp(_bn, other.bn) <= 0;
}

@end
