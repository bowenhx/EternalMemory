//
//  AddRecordWarningView.m
//  EternalMemory
//
//  Created by xiaoxiao on 2/24/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "AddRecordWarningView.h"

@interface AddRecordWarningView()
{
    UIView       *backView;
    NSTimer      *_timer;
    NSInteger     listenTime;//录音播放的时长
    NSInteger     recordTime;//录音的总时长

}
-(void)setInitView;

@end

@implementation AddRecordWarningView

@synthesize testLabel = _testLabel;
@synthesize stateImageView = _stateImageView;
@synthesize recordState = _recordState;

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setInitView];
    }
    return self;
}
-(void)setInitView
{
    self.backgroundColor = [UIColor clearColor];
    backView = [[UIView alloc]initWithFrame:self.bounds];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0.5f;
    [self addSubview:backView];
    [backView release];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeOrPlayRecord)];
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeOrPlayRecord)];

    _stateImageView = [[UIImageView alloc] init];
    _stateImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"record_play_1.png"],
                                                                [UIImage imageNamed:@"record_play_2.png"],
                                                                [UIImage imageNamed:@"record_play_3.png"],nil];
    _stateImageView.animationDuration = 1;
    _stateImageView.userInteractionEnabled = YES;
    [_stateImageView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [self addSubview:_stateImageView];
    [_stateImageView release];
    
    _testLabel = [[UILabel alloc] init];
    _testLabel.textAlignment = NSTextAlignmentLeft;
    _testLabel.backgroundColor = [UIColor clearColor];
    _testLabel.textColor = [UIColor whiteColor];
    _testLabel.userInteractionEnabled = YES;
    [_testLabel addGestureRecognizer:tapGesture1];
    [tapGesture1 release];
    [self addSubview:_testLabel];
    [_testLabel release];
}
-(void)setsubViewFrame
{
    backView.frame = self.bounds;
}
-(void)makeOrPlayRecord
{
    if (_recordState == RecordStateMake)
    {
        self.makeRecord();
    }
    else if (_recordState == RecordStateReadyPlay)
    {
        [_stateImageView startAnimating];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimeLabelInfo) userInfo:nil repeats:YES];
        self.playRecord();
    }
    else if (_recordState == RecordStateStop)
    {
        [self stopListenRecordRightNow];
        self.stopRecord();
    }
}

-(void)setRecordState:(RecordState)recordState WithEMAudio:(EMAudio *)audio
{
    if (_stateImageView.isAnimating)
    {
        [_stateImageView stopAnimating];
    }
    [self stopListenRecordRightNow];
    if (recordState == RecordStateMake)
    {
        backView.backgroundColor = [UIColor blackColor];
        _stateImageView.frame = CGRectMake(25, 7, 15, 21);
        _stateImageView.image = [UIImage imageNamed:@"record.png"];
        _testLabel.text = @"  还没录音，点击这里进行录音...";
        _testLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    else if(recordState == RecordStateReadyPlay)
    {
        _stateImageView.frame = CGRectMake(15, 8, 15, 21);
        backView.backgroundColor = [UIColor clearColor];
        _stateImageView.image = [UIImage imageNamed:@"record_play_3.png"];
        _testLabel.text =[NSString stringWithFormat:@"  0%d:%02d",(audio.duration / 60),(audio.duration % 60)];
        _testLabel.font = [UIFont systemFontOfSize:17.0f];

    }
    else if (recordState == RecordStateStop)
    {
        backView.backgroundColor = [UIColor clearColor];
        _stateImageView.frame = CGRectMake(15, 8, 15, 21);
        [_stateImageView startAnimating];
        if (_timer == nil)
        {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimeLabelInfo) userInfo:nil repeats:YES];
        }
        listenTime = 0;
        recordTime = audio.duration;
        _testLabel.text = [NSString stringWithFormat:@"  0%d:%02d / 0%d:%02d",(listenTime / 60),(listenTime % 60),(recordTime / 60),(recordTime % 60)];
        _testLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    else if (recordState == RecordStateUpload)
    {
        backView.backgroundColor = [UIColor blackColor];
        _stateImageView.frame = CGRectMake(25, 7, 15, 21);
        _stateImageView.image = [UIImage imageNamed:@"record.png"];
        _testLabel.text = @"  录音正在上传中...";
        _testLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    CGFloat testLabelX = _stateImageView.frame.size.width + _stateImageView.frame.origin.x;
    _testLabel.frame = CGRectMake(testLabelX, 2.5, SCREEN_WIDTH - testLabelX, 30);
    _recordState = recordState;
}
    
#pragma mark ------ NSTimer
    
-(void)updateTimeLabelInfo
{
    listenTime++;
    _testLabel.text = [NSString stringWithFormat:@"  0%d:%02d / 0%d:%02d",(listenTime / 60),(listenTime % 60),(recordTime / 60),(recordTime % 60)];
    if (listenTime == recordTime)
    {
        [self stopListenRecordRightNow];
        if (_stateImageView.isAnimating)
        {
            [_stateImageView stopAnimating];
        }
        _testLabel.text =[NSString stringWithFormat:@"  0%d:%02d",(recordTime / 60),(recordTime % 60)];
    }
}
-(void)stopListenRecordRightNow
{
    if (_timer && _timer.isValid)
    {
        [_timer invalidate];
        _timer = nil;
    }
    listenTime = 0;
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
