//
//  ForbidApplyInfoView.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "ForbidApplyInfoView.h"
#import "ForbidInfo.h"

@interface ForbidApplyInfoView ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *mobileLabel;
@property (nonatomic, strong) UILabel *addressLabel;

@end

@implementation ForbidApplyInfoView

- (id)initWithFrame:(CGRect)frame
{
    
    frame = (CGRect){
        .origin.x = 0,
        .origin.y = 0,
        .size.width  = 215,
        .size.height = 80
    };
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    UIColor *textColor = RGBCOLOR(42, 128, 207);
    UIColor *backgroundColor = [UIColor clearColor];
    CGFloat labelWidth = 40;
    CGFloat labelHeight = 17;
    CGFloat offset = 10;
    
    NSArray *titles = @[@"姓名：",@"手机：",@"地址："];
    NSMutableArray *labels = [NSMutableArray arrayWithCapacity:0];

    for (int i = 0 ; i < 3 ; i ++) {
        CGFloat x = 0;
        CGFloat y = i * (offset + labelHeight);
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){
            .origin.x = x,
            .origin.y = y,
            .size.width  = labelWidth,
            .size.height = labelHeight
        }];
        
        label.font = font;
        label.backgroundColor = backgroundColor;
        label.textColor = textColor;
        label.text = titles[i];
        [self addSubview:label];
        
        UILabel *dataLabel = ({
            UILabel *aLabel = [[UILabel alloc] initWithFrame:(CGRect){
                .origin.x = label.frame.origin.x + label.frame.size.width,
                .origin.y = label.frame.origin.y,
                .size.width  = 180,
                .size.height = label.frame.size.height
            }];
            
            aLabel.font = font;
            aLabel.backgroundColor = backgroundColor;
            aLabel.textColor = textColor;
            
            aLabel;
        });
        
        [self addSubview:dataLabel];
        
        labels[i] = dataLabel;
    }
    
    self.nameLabel = labels[0];
    self.mobileLabel = labels[1];
    self.addressLabel = labels[2];
    
    CGRect frame = _addressLabel.frame;
    frame.size.height = [_info.address sizeWithFont:_addressLabel.font constrainedToSize:CGSizeMake(_nameLabel.frame.size.width, 9999)].height;
    _addressLabel.frame = frame;
    _addressLabel.numberOfLines = 0;
    
    [labels removeAllObjects];
    labels = nil;
    
    [self setViewData];
    
}

- (void)setViewData
{
    
    
    self.nameLabel.text = _info.name;
    self.mobileLabel.text = _info.mobile;
    self.addressLabel.text = _info.address;
}



@end
