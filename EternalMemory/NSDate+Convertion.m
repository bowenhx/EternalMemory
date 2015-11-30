//
//  NSDate+Convertion.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-18.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "NSDate+Convertion.h"

@implementation NSDate (Convertion)


- (NSString *)convertDateToTimeStampWithJavaScriptFormatWhitString:(NSString *)dateStr
{
    NSTimeInterval interval = [self timeIntervalSince1970];
    NSString *javascriptFormatTimeStamp = [NSString stringWithFormat:@"%f",interval * 1000];
    return javascriptFormatTimeStamp;
}

@end
