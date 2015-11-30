//
//  EditListCell.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "EditListCell.h"

@interface EditListCell ()

@property (nonatomic, retain) UIView    *containerView;
@property (nonatomic, retain) UIButton  *reviewButton;
@property (nonatomic, retain) UIButton  *addButton;

@end

@implementation EditListCell

- (void)dealloc
{
    [_containerView release];
    [_reviewButton release];
    [_addButton release];
    [_addtionOperationBlock release];
    [_reviewOperationBlock release];
    [_additionButtonBackgroud release];
    [_reviewButtonBackground release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 286, 70)];
        _containerView.center = CGPointMake(CGRectGetMidX(self.frame)-20, CGRectGetMidY(self.frame)+ 40);
        _containerView.clipsToBounds = YES;
        _containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_containerView];
        
        _reviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reviewButton.frame = CGRectMake(3, 0, 138, 70);
        _reviewButton.backgroundColor = [UIColor clearColor];
        [_reviewButton addTarget:self action:@selector(reviewOperation:) forControlEvents:UIControlEventTouchUpInside];
        [_containerView addSubview:_reviewButton];
        
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.frame = CGRectMake(143, 0, 138, 70);
        _addButton.backgroundColor = [UIColor clearColor];
        [_addButton addTarget:self action:@selector(additionOperation:) forControlEvents:UIControlEventTouchUpInside];
        [_containerView addSubview:_addButton];
        
        UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"android_linebg.png"]];
        lineView.frame = CGRectMake(CGRectGetMinX(_containerView.frame), 0, 2, 70);
        [_containerView addSubview:lineView];
        [lineView release];
        
        
    }
    return self;
}

- (void)reviewOperation:(id)sender
{
    if (_reviewOperationBlock) {
        _reviewOperationBlock();
    }
}

- (void)additionOperation:(id)sender
{
    if (_addtionOperationBlock) {
        _addtionOperationBlock();
    }
}

- (void)setAdditionButtonBackgroud:(UIImage *)additionButtonBackgroud
{
    [_addButton setBackgroundImage:additionButtonBackgroud forState:UIControlStateNormal];
}

- (void)setReviewButtonBackground:(UIImage *)reviewButtonBackground
{
    [_reviewButton setBackgroundImage:reviewButtonBackground forState:UIControlStateNormal];
}

- (void)setContainerPosition:(CGPoint)containerPosition
{
    _containerView.center = containerPosition;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEnable:(BOOL)enable
{
    _addButton.enabled = enable;
    _reviewButton.enabled = enable;
}

@end
