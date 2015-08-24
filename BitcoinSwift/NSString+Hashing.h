//
//  NSString+Hashing.h
//  BitcoinSwift
//
//  Created by Huang Yu on 8/19/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hashing)

/// Initialize NSData using a stirng representation of hex hash
- (NSData *)dataFromHexString;

@end
