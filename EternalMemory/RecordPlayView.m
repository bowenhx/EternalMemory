//
//  RecordPlayView.m
//  EternalMemory
//
//  Created by xiaoxiao on 2/24/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "RecordPlayView.h"

@interface RecordPlayView()
{
    UIButton        *stopButton;//停止试听按钮
}

-(void)setinitView;

@end

@implementation RecordPlayView
//@synthesize progressView = _progressView;
@synthesize showTimeLabel = _showTimeLabel;


- (void)dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self setinitView];
    }
    return self;
}

-(void)setinitView
{
    
    UIView *backView = [[UIView alloc]initWithFrame:self.bounds];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0.8;
    [self addSubview:backView];
    [backView release];
    
    stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    stopButton.alpha = 1.0f;
    stopButton.frame = CGRectMake(135, (SCREEN_HEIGHT - 150)/2, 50, 50);
    [stopButton setImage:[UIImage imageNamed:@"listen_Record_pause.png"] forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stopListenRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:stopButton];
    
    _showTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (stopButton.frame.origin.y + stopButton.frame.size.height + 25), 320, 20)];
    _showTimeLabel.textColor = [UIColor whiteColor];
    _showTimeLabel.textAlignment = NSTextAlignmentCenter;
    _showTimeLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_showTimeLabel];
    [_showTimeLabel release];
}

-(void)stopListenRecord:(id)sender
{
    self.stopListenRecord();
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
