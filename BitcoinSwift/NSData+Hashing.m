//
//  NSData+Hashing.m
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/19/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import "NSData+Hashing.h"

#import <openssl/ripemd.h>
#import <openssl/sha.h>

@implementation NSData (Hashing)

- (NSData *)SHA256Hash {
  SHA256_CTX ctx;
  unsigned char hash[32];
  if (![self length]) {
    return nil;
  }
  SHA256_Init(&ctx);
  SHA256_Update(&ctx, [self bytes], [self length]);
  SHA256_Final(hash, &ctx);
  return [NSData dataWithBytes:hash length:32];
}

- (NSData *)RIPEMD160Hash {
  RIPEMD160_CTX ctx;
  unsigned char hash[20];
  if (![self length]) {
    return nil;
  }
  RIPEMD160_Init(&ctx);
  RIPEMD160_Update(&ctx, [self bytes], [self length]);
  RIPEMD160_Final(hash, &ctx);
  return [NSData dataWithBytes:hash length:20];
}

@end
