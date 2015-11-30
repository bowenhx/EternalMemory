//
//  EMAudioPlayer.h
//  EternalMemory
//
//  Created by FFF on 14-2-18.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVAudioPlayer;

@interface EMAudioPlayer : NSObject

@property (nonatomic, retain, readonly) AVAudioPlayer *player;

+ (instancetype)sharedPlayer;

- (void)playAudioWithPath:(NSString *)audioURL;
- (void)stop;

@end
