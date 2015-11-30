//
//  ForbidApplySuccessView.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-24.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "ForbidApplySuccessView.h"

#import "ForbidInfo.h"


@interface ForbidApplySuccessView ()

@property (nonatomic, strong) UILabel *ieternalNumLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation ForbidApplySuccessView


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)layoutSubviews
{
    UIColor *textColor = RGBCOLOR(40, 121, 191);
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){
                .origin.x = 0,
                .origin.y = 0,
                .size.width  = self.frame.size.width,
                .size.height = 17
            }];
            
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = textColor;
            label.text = @"记忆码：";
            
            label;
        });
        
        [self addSubview:_titleLabel];
    }
    
    if (!_ieternalNumLabel) {
        _ieternalNumLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){
                .origin.x = 0,
                .origin.y = 25,
                .size.width  = self.frame.size.width,
                .size.height = 17
            }];
            
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = textColor;
            label.text = @"80061101091992071924096HBV";

            label;
        });
        
        [self addSubview:_ieternalNumLabel];
    }
    
    [self setViewData];
}

- (void)setViewData
{
    self.ieternalNumLabel.text = _info.ieternalNum;
}


@end
