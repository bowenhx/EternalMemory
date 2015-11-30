//
//  BlogListDateLabel.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-28.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "BlogListDateLabel.h"

@import CoreText;

@implementation BlogListDateLabel

- (void)dealloc
{
    [_dateAttrStr release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    NSAttributedString *dateStr = [self dateAttrStr];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)dateStr);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, dateStr.length), path, NULL);
    CTFrameDraw(frame, ctx);
    
    CFRelease(frame);
    CFRelease(framesetter);
    CFRelease(path);

}


@end
