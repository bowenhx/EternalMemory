//
//  EMEditLifeMemoCollectionHeaderView.m
//  EternalMemory
//
//  Created by FFF on 14-3-13.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMEditLifeMemoCollectionHeaderView.h"

@interface EMEditLifeMemoCollectionHeaderView ()

@property (nonatomic, retain) UILabel  *titleLabel;

@end

@implementation EMEditLifeMemoCollectionHeaderView

- (void) dealloc {
    
    [_title release];
    [_titleLabel release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width - 20, self.frame.size.height)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
        
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        [_title release];
        _title = [title copy];
    }
    
    self.titleLabel.text = _title;
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
