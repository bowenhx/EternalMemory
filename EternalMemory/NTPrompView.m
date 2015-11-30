//
//  NTPrompView.m
//  EternalMemory
//
//  Created by FFF on 13-11-29.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "NTPrompView.h"

@interface NTPrompView ()
{
    UIWindow    *_mainWindow;
    UIView      *_bgView;
    UILabel     *_msgLabel;
    
    CGRect      _frame;
}

@end

@implementation NTPrompView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:_frame];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.6;
        [self addSubview:_bgView];
        [_bgView release];
    }
    
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] initWithFrame:_frame];
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.textColor = [UIColor whiteColor];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        [self addSubview:_msgLabel];
        [_msgLabel release];
    }
    
    _msgLabel.text = _message;
}

- (void)setMessage:(NSString *)message
{
    if (_message != message) {
        [_message release];
        _message = [message copy];
    }
    [self setNeedsLayout];
}

- (instancetype)initWithMessage:(NSString *)message
{
    _frame = (CGRect){
        .origin.x = 0,
        .origin.y = iOS7 ? 32 : 44,
        .size.width  = SCREEN_WIDTH,
        .size.height = 30
    };
    self = [super initWithFrame:_frame];
    if (self) {
        _mainWindow = [UIApplication sharedApplication].keyWindow;
        _message = message;
    }
    
    return self;
}

- (void)show
{
    [_mainWindow addSubview:self];
    __block typeof(self) bself = self;
    [UIView animateWithDuration:0.3 animations:^{
        bself.alpha = 0;
        bself.alpha = 1;
    }];
}

- (void)dismiss
{
    
    [self removeFromSuperview];
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
