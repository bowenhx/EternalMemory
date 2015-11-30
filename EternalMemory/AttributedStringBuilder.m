//
//  AttributedStringBuilder.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-28.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "AttributedStringBuilder.h"
@import CoreText;

@implementation AttributedStringBuilder

- (NSAttributedString *)buildUpAttributedStringForBlogListDateLabelWithDictionary:(NSDictionary *)dic
{
    NSMutableAttributedString *attrString = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    
    NSString *monthYearStr = [NSString stringWithFormat:@"%@-%@",dic[kDateLabelYear],dic[kDateLabelMonth]];
    NSString *dayStr = [NSString stringWithFormat:@"%@", dic[kDateLabelDay]];
    
    UIFont *monthYearFont = [UIFont systemFontOfSize:11.];
    NSDictionary *monthYearAttr = @{(id)kCTFontAttributeName : monthYearFont, (id)kCTForegroundColorAttributeName : [UIColor blackColor]};
    NSAttributedString *monthYearAttrStr = [[NSAttributedString alloc] initWithString:monthYearStr attributes:monthYearAttr];
    
    [attrString appendAttributedString:monthYearAttrStr];
    
    UIFont *dayFont = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
    NSDictionary *dayAttr = @{(id)kCTFontAttributeName : dayFont, (id)kCTForegroundColorAttributeName : [UIColor blackColor]};
    NSAttributedString *dayAttrStr = [[NSAttributedString alloc] initWithString:dayStr attributes:dayAttr];
    
    [attrString appendAttributedString:dayAttrStr];
    
    CTTextAlignment alignment = kCTTextAlignmentCenter;
    CTParagraphStyleSetting setting[] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(setting, sizeof(setting)/sizeof(setting[0]));
    NSDictionary *paragraphAttr = @{(id)kCTParagraphStyleAttributeName : (id)paragraphStyle};
    [attrString addAttributes:paragraphAttr range:NSMakeRange(0, attrString.length)];
    
    
    [dayAttrStr release];
    [monthYearAttrStr release];
    
    return attrString;
}

@end
