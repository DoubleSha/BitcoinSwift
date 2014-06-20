//
//  NSData+HexString.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/15/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HexString)

// Returns hexadecimal string representation of NSData. Empty string if data is empty.
- (NSString *)hexString;

@end
