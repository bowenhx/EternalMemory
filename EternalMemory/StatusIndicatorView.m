//
//  StatusIndicatorView.m
//  EternalMemory
//
//  Created by FFF on 13-12-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "StatusIndicatorView.h"

@interface StatusIndicatorView ()

@property (nonatomic, retain) UILabel   *textLabel;

@end

@implementation StatusIndicatorView


- (void)dealloc
{
    [_message release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithTaskCount:(NSInteger)taskCount message:(NSString *)message
{
    CGRect frame = (CGRect){
        .origin.x = 0,
        .origin.y = 0,
        .size.width  = SCREEN_WIDTH,
        .size.height = 20
    };
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel  = UIWindowLevelStatusBar + 10;
        self.hidden = YES;
        self.alpha = 0;
        _total = taskCount;
        self.message = message;
        
        [self setupSubLayers];
    }
    
    return self;
}

- (void)setupSubLayers
{
    
    CALayer *colorLayer        = [CALayer layer];
    colorLayer.frame           = self.bounds;
    colorLayer.backgroundColor = [UIColor blackColor].CGColor;
    colorLayer.opacity         = 0.6;
    [self.layer addSublayer:colorLayer];
    
    if (!_textLabel) {

        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        _textLabel = [[UILabel alloc] init];
        _textLabel.frame = self.bounds;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = font;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_textLabel];
        [_textLabel release];
        
    }
}

- (void)setMessage:(NSString *)message{
    if (_message != message) {
        [_message release];
        _message = [message copy];
    }
    
    _textLabel.text = _message;
}

- (void)show
{
    __block typeof(self) bself = self;
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        bself.alpha = 0.8;
    }];
}
- (void)dismiss
{
    __block typeof(self) bself = self;
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.5 animations:^{
            bself.hidden = YES;
            bself.alpha = 0;
        } completion:nil];
    });
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
