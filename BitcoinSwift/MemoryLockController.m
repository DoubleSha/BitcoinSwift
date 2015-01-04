//
//  MemoryLockController.m
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/3/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

#import "MemoryLockController.h"

#import <sys/mman.h>
#import <sys/sysctl.h>

@interface MemoryLockController()

// Stores how many references there are to each locked page. Keyed by the memory address of a given
// page. When there are 0 references to a page, the page is unlocked and removed from
// lockedPageRefs.
@property(nonatomic, strong) NSMutableDictionary *lockedPageRefs;
@property(nonatomic, assign) size_t pageSize;
@property(nonatomic, assign) size_t pageMask;

@end

@implementation MemoryLockController

- (instancetype)init {
  self = [super init];
  if (self) {
    _lockedPageRefs = [[NSMutableDictionary alloc] init];
    _pageSize = [self systemPageSize];
    NSAssert(!(_pageSize & (_pageSize - 1)), @"Page size must be a power of two (%zu)", _pageSize);
    _pageMask = ~(_pageSize - 1);
  }
  return self;
}

+ (MemoryLockController *)instance {
  static MemoryLockController *instance = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (void)lockMemory:(void *)ptr size:(int)size {
  NSAssert(size >= 0, @"Cannot lock memory with negative size %d", size);
  if (size == 0) {
    return;
  }
  size_t ptrAddr = (size_t) ptr;
  size_t startPageAddr = ptrAddr & _pageMask;
  size_t endPageAddr = (ptrAddr + size - 1) & _pageMask;
  for (size_t pageAddr = startPageAddr; pageAddr <= endPageAddr; pageAddr += _pageSize) {
    NSValue *page = [NSValue valueWithPointer:(void *) pageAddr];
    NSNumber *refCount = _lockedPageRefs[page];
    if (refCount == nil) {
      mlock((void *) pageAddr, _pageSize);
      _lockedPageRefs[page] = [NSNumber numberWithInt:1];
    } else {
      _lockedPageRefs[page] = [NSNumber numberWithInt:(refCount.intValue + 1)];
    }
  }
}

- (void)unlockMemory:(void *)ptr size:(int)size {
  NSAssert(size >= 0, @"Cannot lock memory with negative size %d", size);
  if (size == 0) {
    return;
  }
  size_t ptrAddr = (size_t) ptr;
  size_t startPageAddr = ptrAddr & _pageMask;
  size_t endPageAddr = (ptrAddr + size - 1) & _pageMask;
  for (size_t pageAddr = startPageAddr; pageAddr <= endPageAddr; pageAddr += _pageSize) {
    NSValue *page = [NSValue valueWithPointer:(void *) pageAddr];
    NSNumber *refCount = _lockedPageRefs[page];
    NSAssert(refCount != nil, @"Asymmetric call to unlockMemory");
    munlock((void *) pageAddr, _pageSize);
    _lockedPageRefs[page] = [NSNumber numberWithInt:(refCount.intValue - 1)];
  }
}

#pragma mark Private Methods

- (size_t)systemPageSize {
  int mib[2];
  mib[0] = CTL_HW;
  mib[1] = HW_PAGESIZE;
  size_t pageSize;
  size_t length;
  length = sizeof(pageSize);
  int result = sysctl(mib, 2, &pageSize, &length, NULL, 0);
  NSAssert(result >= 0, @"Failed to get system page size in MemoryLockController");
  return pageSize;
}

@end
