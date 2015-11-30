//
//  MD5.m
//  EternalMemory
//
//  Created by sun on 13-5-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MD5.h"
#import <commoncrypto/CommonDigest.h>
@implementation MD5
+ (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [[NSString stringWithFormat:
			 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1], result[2], result[3],
			 result[4], result[5], result[6], result[7],
			 result[8], result[9], result[10], result[11],
			 result[12], result[13], result[14], result[15]
			 ] lowercaseString];
}

@end
