//
//  SecureMemoryAllocator.m
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/3/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

#import "SecureMemoryAllocator.h"

#import "MemoryLockController.h"

static void *secureAllocate(CFIndex allocSize, CFOptionFlags hint, void *info);
static void secureDeallocate(void *ptr, void *info);
static void *secureReallocate(void *ptr, CFIndex newSize, CFOptionFlags hint, void *info);

@interface SecureMemoryAllocator()

// Keeps track of the size of objects we have allocated so we know how many bytes to clear when the
// object is deallocated.
@property(nonatomic, strong) NSMutableDictionary *memorySizes;
@property(nonatomic, strong) MemoryLockController *memoryLockController;

@end

@implementation SecureMemoryAllocator

+ (CFAllocatorRef)allocator {
  static CFAllocatorRef allocator;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    CFAllocatorContext context;
    CFAllocatorGetContext(kCFAllocatorDefault, &context);
    context.version = 0;
    context.allocate = secureAllocate;
    context.deallocate = secureDeallocate;
    context.reallocate = secureReallocate;
    allocator = CFAllocatorCreate(kCFAllocatorDefault, &context);
  });
  return allocator;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _memorySizes = [[NSMutableDictionary alloc] init];
    _memoryLockController = [MemoryLockController instance];
  }
  return self;
}

#pragma mark Private Methods

+ (SecureMemoryAllocator *)instance {
  static SecureMemoryAllocator *instance = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (void *)allocateWithSize:(CFIndex)allocSize hint:(CFOptionFlags)hint info:(void *)info {
  @synchronized(self) {
    void *memory = malloc(allocSize);
    if (memory == NULL) {
      return nil;
    }
    [_memoryLockController lockMemory:memory size:(int)allocSize];
    _memorySizes[[NSValue valueWithPointer:memory]] = [NSNumber numberWithInteger:allocSize];
    return memory;
  }
}

- (void)deallocateMemory:(void *)ptr info:(void *)info {
  @synchronized(self) {
    NSAssert(ptr != NULL, @"Cannot deallocate null pointer");
    NSValue *ptrValue = [NSValue valueWithPointer:ptr];
    NSNumber *size = (NSNumber *)_memorySizes[ptrValue];
    NSAssert(size != nil, @"Cannot deallocate unknown pointer");
    memset(ptr, 0, size.intValue);
    [_memorySizes removeObjectForKey:ptrValue];
    [_memoryLockController unlockMemory:ptr size:size.intValue];
    free(ptr);
  }
}

- (void *)reallocateWithMemory:(void *)ptr
                       newSize:(CFIndex)newSize
                          hint:(CFOptionFlags)hint
                          info:(void *)info {
  @synchronized(self) {
    if (ptr == nil || newSize <= 0) {
      return nil;
    }
    NSNumber *size = _memorySizes[[NSValue valueWithPointer:ptr]];
    if (size == nil) {
      return nil;
    }
    void *newPtr = [self allocateWithSize:newSize hint:hint info:info];
    if (newPtr == nil) {
      return nil;
    }
    int cpySize = size.intValue < newSize ? size.intValue : (int)newSize;
    memcpy(newPtr, ptr, cpySize);
    [self deallocateMemory:ptr info:info];
    return newPtr;
  }
}

@end

static void *secureAllocate(CFIndex allocSize, CFOptionFlags hint, void *info) {
  return [[SecureMemoryAllocator instance] allocateWithSize:allocSize hint:hint info:info];
}

static void secureDeallocate(void *ptr, void *info) {
  [[SecureMemoryAllocator instance] deallocateMemory:ptr info:info];
}

static void *secureReallocate(void *ptr, CFIndex newSize, CFOptionFlags hint, void *info) {
  return [[SecureMemoryAllocator instance] reallocateWithMemory:ptr
                                                        newSize:newSize
                                                           hint:hint
                                                           info:info];
}
