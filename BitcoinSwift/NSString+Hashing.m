//
//  NSString+Hashing.m
//  BitcoinSwift
//
//  Created by Huang Yu on 8/19/15.
//  Copyright (c) 2015 DoubleSha. All rights reserved.
//

#import "NSString+Hashing.h"

@implementation NSString (Hashing)

- (NSData *)dataFromHexString {
    const char *chars = [self UTF8String];
    int i = 0;
    NSUInteger len = self.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

@end
