//
//  RecordOperation.h
//  EternalMemory
//
//  Created by xiaoxiao on 2/24/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordOperation : NSObject

//开始录音
+(void)startRecord:(NSInteger)duration;
//停止录音
+(void)stopRecord;

@end
