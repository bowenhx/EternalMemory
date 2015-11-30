//
//  RecordOperation.m
//  EternalMemory
//
//  Created by xiaoxiao on 2/24/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "RecordOperation.h"
#import "EMRecordEngine.h"
#import "Utilities.h"
#import "EMAudio.h"
@implementation RecordOperation


//开始录音
+(void)startRecord:(NSInteger)duration
{
    NSString *fileName = [Utilities audioFileNameWithType:@"wav"];
    
    [EMRecordEngine sharedEngine].maxRecordTime = duration;
    [[EMRecordEngine sharedEngine] startRecordWithFilename:fileName];
}

//停止录音
+(void)stopRecord
{
    [[EMRecordEngine sharedEngine] stopRecordWithCompletionBlock:^(NSString *path, CGFloat duration) {
        EMAudio *audio = [EMAudio new];
        audio.wavPath = path;
        audio.duration = duration;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getRecordInfo" object:audio];
        [audio release];
    }];
}

@end
