//
//  SecureMemoryAllocator.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 1/3/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecureMemoryAllocator : NSObject

+ (CFAllocatorRef)allocator;

@end
