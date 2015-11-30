//
//  AttributedStringBuilder.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-28.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kDateLabelYear          = @"kDateLabelYear";
static NSString * const kDateLabelMonth         = @"kDateLabelMonth";
static NSString * const kDateLabelDay           = @"KdateLabelDay";

@interface AttributedStringBuilder : NSObject

- (NSAttributedString *)buildUpAttributedStringForBlogListDateLabelWithDictionary:(NSDictionary *)dic;

@end
