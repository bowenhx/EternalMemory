//
//  RecordPromptView.m
//  EternalMemory
//
//  Created by xiaoxiao on 2/24/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RecordPromptView.h"
@interface RecordPromptView()
{
    NSTimer     * _timer;
    NSInteger     recordTime;//录音的总时长
    NSInteger     listenTime;//录音播放的时长
    
    BOOL          _fromSelectPhoto;//判断添加该试图的来源
}

//设置初始化界面
-(void)addinitialView;

//点击按钮操作
//停止录音
-(void)stopRecord:(id)sender;
//删除录音
-(void)deleteRecord:(id)sender;
//上传录音
-(void)uploadRecord:(id)sender;
//各种操作下停止试听录音
-(void)stopListenRecordRightNow;

@end

@implementation RecordPromptView
@synthesize islisten = _islisten;

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame WithSelectPhoto:(BOOL)selectFromPhoto
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isRecord = NO;
        _islisten = NO;
        _fromSelectPhoto = selectFromPhoto;
        [self addinitialView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRecordState:) name:@"recording" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRecord:) name:@"EMRecordDidStopNotification" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordReceiveEnd:) name:@"recordReceiveEnd" object:nil];
    }
    return self;
}

//设置初始化界面
-(void)addinitialView
{
    UITapGestureRecognizer *tapGesture = nil;
    if (_fromSelectPhoto == NO)
    {
        
        lowerSoundBackView = [[UIView alloc] initWithFrame:CGRectMake(65, (SCREEN_HEIGHT - 210)/ 2, 190, 210)];
        soundBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 190, 210)];
        tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickPlayOrStop)];
        [soundBackView addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
    else
    {
        lowerSoundBackView = [[UIView alloc] initWithFrame:CGRectMake(65, (SCREEN_HEIGHT - 160)/ 2, 190, 180)];
        soundBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 190, 180)];
    }

    soundBackView.backgroundColor = [UIColor blackColor];
    soundBackView.layer.cornerRadius = 5.0f;
    soundBackView.alpha = 0.5f;
    
    lowerSoundBackView.backgroundColor = [UIColor clearColor];
    [lowerSoundBackView addSubview:soundBackView];
    [soundBackView release];
    
    recordingView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 30, 55, 75)];
    recordingView.image = [UIImage imageNamed:@"record.png"];
    recordingView.alpha = 1.0f;
    [lowerSoundBackView addSubview:recordingView];
    [recordingView release];
    
    volumeView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 30, 45, 75)];
    volumeView.alpha = 1.0f;
    volumeView.image = [UIImage imageNamed:@"sound_size1.png"];
    [lowerSoundBackView addSubview:volumeView];
    [volumeView release];
    
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 110, 190, 20)];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.text = @"00:00";
    timeLabel.alpha = 1.0f;
    timeLabel.textColor = [UIColor whiteColor];
    [lowerSoundBackView addSubview:timeLabel];
    [timeLabel release];
    
    listenLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 135, 190, 15)];
    listenLabel.textAlignment = NSTextAlignmentCenter;
    listenLabel.backgroundColor = [UIColor clearColor];
//    listenLabel.hidden = YES;
    listenLabel.textColor = [UIColor whiteColor];
    [lowerSoundBackView addSubview:listenLabel];
    [listenLabel release];
    if (_fromSelectPhoto == NO)
    {
        volumeView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"sound_size1.png"],
                                      [UIImage imageNamed:@"sound_size2.png"],
                                      [UIImage imageNamed:@"sound_size3.png"],
                                      [UIImage imageNamed:@"sound_size4.png"],
                                      [UIImage imageNamed:@"sound_size4.png"],nil];
        
        listenLabel.text = @"点击麦克风试听";
        listenLabel.hidden = YES;
        stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        stopButton.frame = CGRectMake(0, 165, 190, 45);
        [stopButton setTitle:@"停止录音" forState:UIControlStateNormal];
        [stopButton setBackgroundImage:[UIImage imageNamed:@"stop_record_long.png"] forState:UIControlStateNormal];
        [stopButton addTarget:self action:@selector(stopRecord:) forControlEvents:UIControlEventTouchUpInside];
        [lowerSoundBackView addSubview:stopButton];
        
        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(0, 165, 93, 45);
        [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"stop_record_short.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteRecord:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.hidden = YES;
        [lowerSoundBackView addSubview:deleteButton];
        
        confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmButton.frame = CGRectMake(98,165, 93, 45);
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setBackgroundImage:[UIImage imageNamed:@"stop_record_short.png"] forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(uploadRecord:) forControlEvents:UIControlEventTouchUpInside];
        confirmButton.hidden = YES;
        [lowerSoundBackView addSubview:confirmButton];
    }
    else
    {
        timeLabel.frame = CGRectMake(0, 115, 190, 20);
        listenLabel.frame = CGRectMake(0, 145, 190, 15);
        listenLabel.text = @"点击停止录音按钮将停止";
//        listenLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    [self addSubview:lowerSoundBackView];
    [lowerSoundBackView release];
}
    
-(void)setsubViewFrameWithState:(NSInteger)rotation
{
    if (rotation == UIInterfaceOrientationLandscapeLeft ||  rotation == UIInterfaceOrientationLandscapeRight)
    {
        CGFloat width = iPhone5? 568 :480;
        self.frame = CGRectMake(0, 0, width, 320);
        lowerSoundBackView.frame = CGRectMake((width - 190) / 2, 70, 190, 210);
    }
    else if (rotation == UIInterfaceOrientationPortrait)
    {
        self.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT);
        lowerSoundBackView.frame = CGRectMake(65, (SCREEN_HEIGHT - 160)/ 2, 190, 210);
    }
}

#pragma mark -UITapGesture

-(void)clickPlayOrStop
{

    if (_isRecord == YES)
    {
        if (_islisten == YES)
        {
            self.stopListenRecord();
            [self stopListenRecordRightNow];
        }
        else
        {
            self.listenRecord();
            volumeView.animationDuration = 2.0f;
            [volumeView startAnimating];
            timeLabel.text = [NSString stringWithFormat:@"00:00"];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimeLabelInfo) userInfo:nil repeats:YES];
            listenLabel.text = @"点击麦克风停止试听";
            _islisten = !_islisten;
        }
    }
}

#pragma mark - UIButtonEvent
//停止录音
-(void)stopRecord:(id)sender
{
    _isRecord = YES;
    stopButton.hidden = YES;
    listenLabel.hidden = NO;
    deleteButton.hidden = NO;
    confirmButton.hidden = NO;
    volumeView.image = [UIImage imageNamed:@"sound_size5.png"];
    self.stopRecord();
}
//删除录音
-(void)deleteRecord:(id)sender
{
    [self stopListenRecordRightNow];
    self.deleteRecord();
}
//上传录音
-(void)uploadRecord:(id)sender
{
    [self stopListenRecordRightNow];
    self.uploadRecord();
}

#pragma mark - 录音时时间和音量大小的实时状态监测---通知

-(void)showRecordState:(NSNotification *)sender
{
    NSInteger time = [sender.object[@"recordTime"] intValue];
    timeLabel.text = [NSString stringWithFormat:@"0%d:%02d",(time / 60),(time % 60)];
    recordTime = time;
    NSInteger volume = [sender.object[@"recordVolume"] intValue];
    NSInteger level = abs( volume / 10 - 4);
//    volumeView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sound_size%d.png",abs(level - 4)]];
    if (level >= 4)
    {
        volumeView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sound_size5.png"]];
    }
    else if (level >=3 && level < 4)
    {
        volumeView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sound_size4.png"]];

    }
    else if (level >= 2 && level < 3)
    {
        volumeView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sound_size3.png"]];

    }
    else if (level >= 1 && level < 2)
    {
        volumeView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sound_size2.png"]];
    }
    else
    {
        volumeView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sound_size1.png"]];
    }
}

-(void)finishRecord:(NSNotification *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recording" object:nil];
    volumeView.image = [UIImage imageNamed:@"sound_size5.png"];
    if (_fromSelectPhoto == NO)
    {
        [self stopRecord:nil];
    }
}
-(void)recordReceiveEnd:(NSNotification *)sender
{
    [self stopListenRecordRightNow];
}
//各种操作下停止试听录音
-(void)stopListenRecordRightNow
{
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
    if (volumeView.isAnimating)
    {
        [volumeView stopAnimating];
    }
    volumeView.image = [UIImage imageNamed:@"sound_size4.png"];
    timeLabel.text = [NSString stringWithFormat:@"0%d:%02d",(recordTime / 60),(recordTime % 60)];
    listenTime = 0;
    listenLabel.text = @"点击麦克风试听";
    _islisten = NO;
}

#pragma mark - NSTimer

-(void)updateTimeLabelInfo
{
    listenTime ++;
    timeLabel.text = [NSString stringWithFormat:@"0%d:%02d",(listenTime / 60),(listenTime % 60)];
    if (listenTime == recordTime)
    {
        [self stopListenRecordRightNow];
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
