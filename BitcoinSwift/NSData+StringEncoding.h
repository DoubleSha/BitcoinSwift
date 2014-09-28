//
//  NSData+StringEncoding.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/19/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

// Note: This is objective-c because it depends on openssl's BIGNUM implementation, which is in c.
@interface NSData (StringEncoding)

/// Returns base58 string representation of NSData. Leading 0's in the data are preserved as '1' in
/// in base58 encoding.
/// If the NSData object is empty or has 0 length, returns an empty string.
/// https://en.bitcoin.it/wiki/Base58Check_encoding
- (NSString *)base58String;

/// Returns hexadecimal string representation of NSData. Empty string if data is empty.
/// There is no leading '0x'.
- (NSString *)hexString;

@end
