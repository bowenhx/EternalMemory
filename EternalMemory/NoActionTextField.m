//
//  NoActionTextField.m
//  EternalMemory
//
//  Created by FFF on 13-12-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "NoActionTextField.h"

@implementation NoActionTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        menuController.menuVisible = NO;
    }
    
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
