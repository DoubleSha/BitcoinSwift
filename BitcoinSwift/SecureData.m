//
//  SecureData.m
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/11/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

#import "SecureData.h"

#import "SecureMemoryAllocator.h"

@interface SecureData()

@property(nonatomic, strong) NSMutableData *mutableData;

@end

@implementation SecureData

- (instancetype)init {
  self = [super init];
  if (self) {
    _mutableData = CFBridgingRelease(CFDataCreateMutable([SecureMemoryAllocator allocator], 0));
  }
  return self;
}

- (instancetype)initWithLength:(NSUInteger)length {
  self = [super init];
  if (self) {
    _mutableData = CFBridgingRelease(CFDataCreateMutable([SecureMemoryAllocator allocator],
                                                         length));
    _mutableData.length = length;
  }
  return self;
}

- (instancetype)initWithData:(NSData *)data {
  self = [self initWithLength:data.length];
  if (self) {
    memcpy(_mutableData.mutableBytes, data.bytes, data.length);
  }
  return self;
}

- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length {
  self = [self initWithLength:length];
  if (self) {
    memcpy(_mutableData.mutableBytes, bytes, length);
  }
  return self;
}

- (NSData *)data {
  return _mutableData;
}

- (NSMutableData *)mutableData {
  return _mutableData;
}

- (const void *)bytes {
  return _mutableData.bytes;
}

- (void *)mutableBytes {
  return _mutableData.mutableBytes;
}

- (NSUInteger)length {
  return _mutableData.length;
}

- (void)appendBytes:(const void *)bytes length:(NSUInteger)length {
  [_mutableData appendBytes:bytes length:length];
}

- (void)appendData:(NSData *)data {
  [_mutableData appendData:data];
}

- (void)appendSecureData:(SecureData *)secureData {
  [_mutableData appendData:secureData.mutableData];
}

@end
