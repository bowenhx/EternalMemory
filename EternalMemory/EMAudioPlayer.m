//
//  EMAudioPlayer.m
//  EternalMemory
//
//  Created by FFF on 14-2-18.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMAudioPlayer.h"

@import AVFoundation;

@interface EMAudioPlayer ()

@property (nonatomic, retain, readwrite) AVAudioPlayer *player;

@end

@implementation EMAudioPlayer


+ (instancetype)sharedPlayer
{
    static EMAudioPlayer *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}


- (void)playAudioWithPath:(NSString *)audioURL {
    NSURL *url = [NSURL fileURLWithPath:audioURL];
    NSData *audioData = [NSData dataWithContentsOfURL:url];
    self.player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
    self.player.numberOfLoops = 0;
    [self.player prepareToPlay];
    
}


- (void)stop {
    [self.player stop];
}

@end
