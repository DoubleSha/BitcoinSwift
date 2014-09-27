//
//  DeterministicECKey.h
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/23/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECKey.h"

@interface DeterministicECKey : ECKey

// Designated initializer.
- (instancetype)initWithSecret:(NSData *)secret chainCode:(NSData *)chainCode;

@end
