//
//  SecureBigInteger.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/7/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BigInteger;
@class SecureData;

@interface SecureBigInteger : NSObject

@property(nonatomic, readonly) SecureData *secureData;

- (instancetype)initWithSecureData:(SecureData *)secureData;

- (SecureBigInteger *)add:(SecureBigInteger *)other modulo:(BigInteger *)modulo;
- (BOOL)isEqual:(BigInteger *)other;
- (BOOL)greaterThan:(BigInteger *)other;
- (BOOL)greaterThanOrEqual:(BigInteger *)other;
- (BOOL)lessThan:(BigInteger *)other;
- (BOOL)lessThanOrEqual:(BigInteger *)other;

@end
