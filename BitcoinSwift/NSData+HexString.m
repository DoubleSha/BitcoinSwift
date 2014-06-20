//
//  NSData+HexString.m
//  BitcoinSwift
//
//  Created by Kevin Greene on 6/15/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import "NSData+HexString.h"

@implementation NSData (HexString)

- (NSString *)hexString {
  const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
  if (!dataBuffer) {
    return [NSString string];
  }
  NSUInteger dataLength = [self length];
  NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
  for (int i = 0; i < dataLength; ++i) {
    [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
  }
  return hexString;
}

@end
