//
//  PassWordTextField.m
//  EternalMemory
//
//  Created by zhaogl on 13-12-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "PassWordTextField.h"

@implementation PassWordTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
