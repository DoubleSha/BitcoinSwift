//
//  NSData+StringEncoding.m
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/19/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import "NSData+StringEncoding.h"

#import <openssl/bn.h>

static const char base58Chars[] = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

@implementation NSData (StringEncoding)

- (NSString *)base58String {
  if (![self length]) {
    return @"";
  }
  // May as well use openssl's big number implementation since we already have it as a dependency.
  // TODO: Write a BigInteger implementation for swift : )
  BN_CTX *ctx = BN_CTX_new();
  BN_CTX_start(ctx);
  BIGNUM *value = BN_CTX_get(ctx);
  BIGNUM *remainder = BN_CTX_get(ctx);
  BIGNUM *bn58 = BN_CTX_get(ctx);
  BN_set_word(bn58, 58);
  BN_bin2bn([self bytes], (int)[self length], value);
  NSMutableString *base58String = [NSMutableString string];
  char base58CString[2];
  // NULL-terminate the c string.
  base58CString[1] = '\0';
  while (!BN_is_zero(value)) {
    BN_div(value, remainder, value, bn58, ctx);
    // TODO: Find a more efficient way to do this. Blech.
    base58CString[0] = base58Chars[BN_get_word(remainder)];
    [base58String appendString:[NSString stringWithCString:base58CString
                                                  encoding:NSUTF8StringEncoding]];
  }
  for (int i = 0 ; i < [self length] && ((char *)[self bytes])[i] == '\0'; ++i) {
    // For each leading 0, append a '1' to the base58 string.
    base58CString[0] = base58Chars[0];
    [base58String appendString:[NSString stringWithCString:base58CString
                                                  encoding:NSUTF8StringEncoding]];
  }
  BN_CTX_end(ctx);
  BN_CTX_free(ctx);
  // Reverse the string because we have been building it backwards. It's more efficient to reverse
  // the string after we are finished, rather than appending to the front as we go.
  return [self reversedStringWithString:base58String];
}

- (NSString *)hexString {
  const unsigned char *dataBuffer = (const unsigned char *)self.bytes;
  if (!dataBuffer) {
    return [NSString string];
  }
  NSUInteger dataLength = [self length];
  NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
  for (int i = 0; i < dataLength; ++i) {
    [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
  }
  return hexString;
}

#pragma mark Private Methods

- (NSString *)reversedStringWithString:(NSString *)string {
  NSMutableString *reversedString = [NSMutableString string];
  NSInteger charIndex = string.length;
  while (charIndex > 0) {
    charIndex--;
    NSRange subStrRange = NSMakeRange(charIndex, 1);
    [reversedString appendString:[string substringWithRange:subStrRange]];
  }
  return reversedString;
}

@end
