//
//  SecureData.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/11/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

/// A wrapper around NSMutableData that uses the SecureAllocator to allocate memory.
///
/// The memory associated with a SecureData object is automatically cleared when deallocated, and
/// the memory is also prevented from being paged to disk.
///
/// NOTE: Your application is only allowed a maximum of 64kb of secure data, so it is important to
/// allocate a limited number of SecureData objects at a time, and any SecureData objects you create
/// should be as short-lived as possible.
@interface SecureData : NSObject

@property(nonatomic, readonly) NSData *data;
@property(nonatomic, readonly) NSMutableData *mutableData;
@property(nonatomic, readonly) const void *bytes;
@property(nonatomic, readonly) void *mutableBytes;
@property(nonatomic, readonly) NSUInteger length;

- (instancetype)init;
- (instancetype)initWithLength:(NSUInteger)length;
- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length;

- (void)appendBytes:(const void *)bytes length:(NSUInteger)length;
- (void)appendData:(NSData *)data;
- (void)appendSecureData:(SecureData *)secureData;

@end
