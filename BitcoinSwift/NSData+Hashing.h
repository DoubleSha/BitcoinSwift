//
//  NSData+Hashing.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/19/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Hashing)

/// Returns the SHA-256 hash of self.
- (NSData *)SHA256Hash;

/// Returns the RIPEMD-160 hash of self.
- (NSData *)RIPEMD160Hash;

/// Performs the HMAC512-SHA256 algorithm on self using key and stores the result in digest.
- (void)HMACSHA512WithKey:(NSData *)key digest:(NSMutableData *)digest;

@end
