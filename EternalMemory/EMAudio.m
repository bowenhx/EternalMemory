//
//  EMAudio.m
//  EternalMemory
//
//  Created by FFF on 14-2-19.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMAudio.h"

@implementation EMAudio


- (id)copyWithZone:(NSZone *)zone {
    EMAudio *audio = [[EMAudio allocWithZone:zone] init];
    audio.ID = _ID;
    audio.audioData = [_audioData copy];
    audio.duration = _duration;
    audio.wavPath = [_wavPath copy];
    audio.amrPath = [_amrPath copy];
    audio.blogId = [_blogId copy];
    audio.audioURL = [_audioURL copy];
    audio.size = _size;
    audio.audioStatus = _audioStatus;
    
    return audio;
}
- (void)dealloc {
    [super dealloc];
    
    [_audioData release];
    [_amrPath release];
    [_wavPath release];
    [_blogId release];
    [_audioURL release];
    
}

@end
