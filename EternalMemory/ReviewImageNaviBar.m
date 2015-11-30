//
//  ReviewImageNaviBar.m
//  EternalMemory
//
//  Created by FFF on 14-1-7.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "ReviewImageNaviBar.h"

@implementation ReviewImageNaviBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    CGRect frame = (CGRect) {
        .origin.x = 0,
        .origin.y = 0,
        .size.width = (iPhone5 ? 568 : 480),
        .size.height = 40
    };
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.backgroundImageView setImage:[UIImage imageNamed:@"top.png"]];
    [self addSubview:self.backgroundImageView];
    
    
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = (CGRect){
            .origin.x = 12,
            .origin.y = 8,
            .size.width  = 44,
            .size.height = 25
        };
        _backButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"but_left_nav_normal.png"] forState:UIControlStateNormal];
        [self addSubview:_backButton];
    }
    
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = (CGRect){
            .origin.x = self.frame.size.width - 12 - 42,
            .origin.y = 8,
            .size.width  = 42,
            .size.height = 25
        };
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_rightButton setTitle:@"更多" forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"but_right_nav_normal.png"] forState:UIControlStateNormal];
        [self addSubview:_rightButton];
    }
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:(CGRect){
            .origin.x = 0,
            .origin.y = 10,
            .size.width  = 242,
            .size.height = 21
        }];
        _titleLabel.center = self.center;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
}



- (void)dealloc
{
    [_backButton  release];
    [_rightButton release];
    [_backgroundImageView release];
    [_titleLabel  release];
    [super dealloc];
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
