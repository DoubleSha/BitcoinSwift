//
//  BigInteger.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

/// A wrapper around the OpenSSL BIGNUM implementation to make it useable in swift.
@interface BigInteger : NSObject

@property(nonatomic, readonly) NSData *data;
@property(nonatomic, readonly) NSData *compactData;
@property(nonatomic, readonly) unsigned int UIntValue;

- (instancetype)init;
- (instancetype)initWithSecure:(BOOL)secure;
- (instancetype)init:(int)value;
- (instancetype)initWithIntegerLiteral:(int)value;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithSecureData:(NSData *)data;
- (instancetype)initWithCompactData:(NSData *)compactData;

- (BigInteger *)add:(BigInteger *)other;
- (BigInteger *)subtract:(BigInteger *)other;
- (BigInteger *)multiply:(BigInteger *)other;
- (BigInteger *)divide:(BigInteger *)other;
- (BigInteger *)modulo:(BigInteger *)other;
- (BigInteger *)add:(BigInteger *)other modulo:(BigInteger *)modulo;
- (BigInteger *)shiftLeft:(int)bits;
- (BigInteger *)shiftRight:(int)bits;
- (BOOL)isEqual:(BigInteger *)other;
- (BOOL)greaterThan:(BigInteger *)other;
- (BOOL)greaterThanOrEqual:(BigInteger *)other;
- (BOOL)lessThan:(BigInteger *)other;
- (BOOL)lessThanOrEqual:(BigInteger *)other;

@end
