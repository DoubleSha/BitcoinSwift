//
//  NSData+Hashing.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/19/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Hashing)

- (NSData *)SHA256Hash;
- (NSData *)RIPEMD160Hash;

@end
