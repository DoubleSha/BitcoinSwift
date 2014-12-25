//
//  BigInteger+objc.m
//  BitcoinSwift
//
//  Created by Kevin Greene on 12/23/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import "BigInteger+objc.h"

@implementation BigInteger (objc)

@dynamic bn;

- (instancetype)initWithBIGNUM:(BIGNUM *)bn {
  self = [super init];
  if (self) {
    self.bn = bn;
  }
  return self;
}

@end
