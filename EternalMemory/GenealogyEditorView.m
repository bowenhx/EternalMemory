//
//  GenealogyEditorView.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-16.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "GenealogyEditorView.h"
#import <QuartzCore/QuartzCore.h>

@interface GenealogyEditorView ()

@end

@implementation GenealogyEditorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    
    self.clipsToBounds = YES;
    
    self.layer.cornerRadius = 5;
    self.layer.borderColor  = RGBCOLOR(212, 212, 212).CGColor;
    self.layer.borderWidth  = 0.5;
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    UIColor *strokColor = RGBCOLOR(212, 212, 212);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(ctx, 0.5);
//    CGContextSetStrokeColorWithColor(ctx, strokColor.CGColor);
//    for(int i = 45;  i <= 3 * 45; i += 41)
//    {
//        CGContextMoveToPoint(ctx, 0, i);
//        CGContextAddLineToPoint(ctx, rect.size.width, i);
//        CGContextStrokePath(ctx);
//        
//    }
//}


@end
