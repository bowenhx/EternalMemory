//
//  AssoiatedFailureView.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-18.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "AssoiatedFailureView.h"
#import "Utilities.h"
#import "GenealogyMetaData.h"

@import QuartzCore;

@interface AssoiatedFailureView ()

@property (nonatomic, retain) UIImageView   *infoImageView;
@property (nonatomic, retain) UILabel       *titleLabel;
@property (nonatomic, retain) UILabel       *messageLabel;
@property (nonatomic, retain) UILabel       *infoLabel;
@property (nonatomic, retain) UIButton      *confirmButton;
@property (nonatomic, retain) UIButton      *cancelButton;
@property (nonatomic, retain) UIView        *containerView;

@property (nonatomic, copy) NSString        *infoStr;
@property (nonatomic, copy) NSString        *title;
@property (nonatomic, copy) NSString        *promptMessage;
@property (nonatomic, copy) NSString        *cancelButtonTitle;

@end

@implementation AssoiatedFailureView


- (void)dealloc
{
    [_confirmBlock release];
    [_cancelBlock release];
    
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    
    CGRect aFrame = (CGRect) {
        .origin.x = 0,
        .origin.y = 0,
        .size.width = 255,
        .size.height = 240
        
    };
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = aFrame;
        self.layer.cornerRadius = 3;
        self.backgroundColor = RGBCOLOR(231, 241, 249);
    }
    return self;
}

- (id)initWithTitle:(NSString *)title promptMessage:(NSString *)message canelButton:(NSString *)cancelButton containerView:(UIView *)container
{
    self = [super init];
    if (self) {
        self.title = title;
        self.promptMessage = message;
        self.cancelButtonTitle = cancelButton;
        self.containerView = container;
    }
    
    return self;
}

- (void)layoutSubviews
{
    
    UIColor *clearColor = [UIColor clearColor];
    UIColor *textColor = RGBCOLOR(65, 65, 65);
    
    CGRect infoIVFrame = (CGRect) {
        .origin.x = 18,
        .origin.y = 18,
        .size.width = 24,
        .size.height = 24
    };
    if (!_infoImageView) {
        _infoImageView = [[UIImageView alloc] initWithFrame:infoIVFrame];
        _infoImageView.backgroundColor = clearColor;
        [_infoImageView setImage:[UIImage imageNamed:@"jsth.png"]];
        [self addSubview:_infoImageView];

    }
    
    
    CGRect titleLabelFrame = (CGRect) {
        .origin.x = infoIVFrame.origin.x + infoIVFrame.size.width + 15,
        .origin.y = 20,
        .size.width = 200,
        .size.height = 20
    };
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = textColor;
        [self addSubview:_titleLabel];

    }
   
    
    CGRect messageLabelFrame = (CGRect) {
        .origin.x = 18,
        .origin.y = infoIVFrame.origin.y + infoIVFrame.size.height + 10,
        .size.width = 215,
        .size.height = [_promptMessage sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:(CGSize){.width = 215,.height = 9999}].height
    };
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:messageLabelFrame];
        _messageLabel.backgroundColor = clearColor;
        _messageLabel.textColor = textColor;
        _messageLabel.font = [UIFont systemFontOfSize:13];
        _messageLabel.numberOfLines = 0;
        [self addSubview:_messageLabel];


    }
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, messageLabelFrame.origin.y + messageLabelFrame.size.height + 8, self.frame.size.width, 10)];
    lineImageView.backgroundColor = clearColor;
    [lineImageView setImage:[UIImage imageNamed:@"cyxxbg.png"]];
    [self addSubview:lineImageView];
    [lineImageView release];
    
//    CGRect infoLabelFrame = (CGRect) {
//        .origin.x = (255 - 240) / 2.,
//        .origin.y = lineImageView.frame.size.height + lineImageView.frame.origin.y + 15,
//        .size.width = 240,
//        .size.height = 25
//    };
//    _infoLabel = [[UILabel alloc] initWithFrame:infoLabelFrame];
//    _infoLabel.backgroundColor = clearColor;
//    _infoLabel.font = [UIFont systemFontOfSize:15];
//    _infoLabel.textColor = RGBCOLOR(43, 132, 207);
//    _infoLabel.textAlignment = NSTextAlignmentCenter;
//    _infoLabel.text = self.infoStr;
//    [self addSubview:_infoLabel];

    
    if (!self.containerView.superview) {
        _containerView.frame = (CGRect){
            .origin.x = 20,
            .origin.y = lineImageView.frame.size.height + lineImageView.frame.origin.y + 15,
            .size = _containerView.frame.size
        };
        [self addSubview:_containerView];

    }
    
    CGRect cancelButtonFrame = CGRectZero;
    if (_cancelButtonTitle.length != 0 && !_cancelButton) {
        cancelButtonFrame = (CGRect){
            .origin.x = 20,
            .origin.y = _containerView.frame.origin.y + _containerView.frame.size.height + 15,
            .size.width  = 95,
            .size.height = 39
        };
        
        _cancelButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = cancelButtonFrame;
            button.layer.cornerRadius = 3;
            [button setTitle:_cancelButtonTitle forState:UIControlStateNormal];
            [button addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = RGBCOLOR(63, 163, 214);
            button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
            button.titleLabel.textColor = [UIColor whiteColor];
            button;
        });
        if (!_cancelButton.superview) {
            [self addSubview:_cancelButton];
        }

    }
    
    
    CGRect confirmBtnFrame = (CGRect) {
        .origin.x = (CGRectEqualToRect(cancelButtonFrame, CGRectZero)) ? (CGRectGetMinX(self.frame) + (95 / 2.)) : (cancelButtonFrame.origin.x + cancelButtonFrame.size.width + 15),
        .origin.y = _containerView.frame.origin.y + _containerView.frame.size.height + 15,
        .size.width = 95,
        .size.height = 39
    };
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = confirmBtnFrame;
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        _confirmButton.titleLabel.textColor = [UIColor whiteColor];
        _confirmButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        _confirmButton.backgroundColor = RGBCOLOR(40, 131, 203);
        _confirmButton.layer.cornerRadius = 3;
        [_confirmButton addTarget:self action:@selector(confirmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (!_confirmButton.superview) {
            [self addSubview:_confirmButton];
        }
    }
    
    
    CGSize s_f = (CGSize) {

        .width = 255,
        .height = infoIVFrame.size.height + messageLabelFrame.size.height + lineImageView.frame.size.height +  confirmBtnFrame.size.height + _containerView.frame.size.height + 80
    };
    
    self.frame = (CGRect){
        .origin = self.frame.origin,
        .size = s_f
    };
    [self bindViewDate];
}

- (void)bindViewDate
{
    _titleLabel.text = _title;
    _messageLabel.text = _promptMessage;
}

- (void)configData:(NSDictionary *)data
{
    NSString *gender = ([data[kSex] integerValue] == 1) ? (@"男") : (@"女");
    NSString *birthStr = data[@"birthdate"];
    NSString *birthDate = [Utilities convertTimestempToDateWithString:birthStr andDateFormat:@"yyyy-MM-dd"];
    
    self.infoStr = [NSString stringWithFormat:@"%@  %@  %@", data[@"realName"], gender, birthDate];
}

- (void)cancel:(id)sender
{
    if (_cancelBlock) {
        _cancelBlock();
    }
}

- (void)confirmButtonPressed:(id)sender
{
    if (_confirmBlock) {
        _confirmBlock();
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
