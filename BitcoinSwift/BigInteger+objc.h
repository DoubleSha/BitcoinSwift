//
//  BigInteger+objc.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/23/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import "BigInteger.h"

#import <openssl/bn.h>

@interface BigInteger (objc)

@property(nonatomic, assign) BIGNUM *bn;

- (instancetype)initWithBIGNUM:(BIGNUM *)bn;

@end
