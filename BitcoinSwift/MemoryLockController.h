//
//  MemoryLockController.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/3/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryLockController : NSObject

+ (MemoryLockController *)instance;
- (void)lockMemory:(void *)ptr size:(int)size;
- (void)unlockMemory:(void *)ptr size:(int)size;

@end
