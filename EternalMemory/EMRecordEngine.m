//
//  EMAudioEngine.m
//  EternalMemory
//
//  Created by FFF on 14-2-18.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMRecordEngine.h"
#import "Utilities.h"
#import "Config.h"
@import AVFoundation;

NSString * const EMRecordTimeupNotification = @"EMRecordDidStopNotification";
NSString * const EMRecordTimeTooShortNotification = @"EMRecordTimeTooShortNotification";

@interface EMRecordEngine ()<AVAudioRecorderDelegate>
{
    NSTimer *_timer;
    CGFloat _curCount;
}

@property (nonatomic, retain)   AVAudioSession *audioSession;
@property (nonatomic, retain)   AVAudioRecorder *recorder;

@property (nonatomic, copy)     NSString  *filePath;
@property (nonatomic, copy)     NSString  *fileName;

@end

@implementation EMRecordEngine

#pragma mark - public method

- (void)deprecated {
    [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
}

- (void)startRecordWithFilename:(NSString *)fileName
{
    self.fileName = fileName;
    self.filePath = [Utilities dataPath:fileName FileType:@"Audioes" UserID:USERID];
    NSError *error = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_filePath] settings:[self recordSetting] error:&error];
    if (error) {
        return;
    }
    
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    
    [self.recorder prepareToRecord];
    error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        return;
    }
    
    error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    _curCount = 0;
    [self.recorder record];
    
    [self startTimer];
}

- (void)stopRecordWithCompletionBlock:(void(^)(NSString *path, CGFloat duration))completion {
    
    if (self.recorder.isRecording) {
        [self.recorder stop];
        [self stopTimer];
    }
    
    if (completion) {
        completion(self.filePath, _curCount);
    }
}

- (void)startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - AVAudioSessionDelegate 

- (void)audioRecorderDidFinishReclording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
}
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags{
}

#pragma mark - initializer

+ (instancetype)sharedEngine
{
    static EMRecordEngine *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        _maxRecordTime = 60;
        _curCount = 0;
    }
    
    return self;
}

#pragma mark - getter & setter

- (BOOL)isRecording {
    return _recorder.isRecording;
}

#pragma mark - privete

- (NSDictionary *)recordSetting {
    NSDictionary *dic = @{AVSampleRateKey: @(8000.0),
                          AVFormatIDKey: @(kAudioFormatLinearPCM),
                          AVLinearPCMBitDepthKey: @(16),
                          AVNumberOfChannelsKey: @(1)};
    return dic;
}

- (void)updateMeters {
    
    if (_recorder.isRecording){
        
        //更新峰值
        [_recorder updateMeters];
        //倒计时
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(int)_curCount],@"recordTime",[NSNumber numberWithInt:(int)fabs([_recorder averagePowerForChannel:0])],@"recordVolume", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"recording" object:dic];
        if (_curCount >= _maxRecordTime - 10 && _curCount < _maxRecordTime) {
            //剩下10秒
            NSString *left = [NSString stringWithFormat:@"录音剩下:%d秒",(int)(_maxRecordTime - _curCount)];
        }else if (_curCount >= _maxRecordTime){
            //时间到
            [self stopRecordWithCompletionBlock:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EMRecordTimeupNotification object:nil];
        }
        _curCount += 0.1f;
    }
}


@end
