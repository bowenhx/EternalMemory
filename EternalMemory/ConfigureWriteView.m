//
//  ConfigureWriteView.m
//  EternalMemory
//
//  Created by SuperAdmin on 13-11-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "ConfigureWriteView.h"

@implementation ConfigureWriteView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
//    UIButton *colorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
    UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    colorButton.frame = CGRectMake(0, 0, 160, 44);
    [colorButton setTitle:@"设置文字颜色" forState:UIControlStateNormal];
    [colorButton addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
    colorButton.hidden = YES;
    [self addSubview:colorButton];
    
    UIButton *bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bgButton.frame = CGRectMake(160, 0, 160, 44);

    [bgButton setTitle:@"设置背景图" forState:UIControlStateNormal];
    [bgButton addTarget:self action:@selector(selectBackgroundImage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:bgButton];
    
    UIButton *showButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showButton.frame = CGRectMake(140, 44, 40, 40);
    [showButton setTitle:@"设置" forState:UIControlStateNormal];

    [showButton addTarget:self action:@selector(showView:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:showButton];
    return self;
}

-(void)showView:(id)sener
{
    
}

-(void)selectColor:(id)sender
{
    if ([_delegate respondsToSelector:@selector(setTextColor)])
    {
        [_delegate setTextColor];
    }
}
-(void)selectBackgroundImage:(id)sender
{
    if ([_delegate respondsToSelector:@selector(showCoverFlow)])
    {
        [_delegate showCoverFlow];
    }
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
