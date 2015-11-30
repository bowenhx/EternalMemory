//
//  EMAudioEngine.h
//  EternalMemory
//
//  Created by FFF on 14-2-18.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^EMRecordEngineBlock)(NSString *path, CGFloat duration);

@interface EMRecordEngine : NSObject

extern NSString * const EMRecordTimeupNotification;
extern NSString * const EMRecordTimeTooShortNotification;

@property (nonatomic, assign) NSInteger    maxRecordTime;
@property (nonatomic, readonly, getter = isRecording) BOOL          recording;
@property (nonatomic, copy)   EMRecordEngineBlock timeupBlock;

+ (instancetype)sharedEngine;

- (void)startRecordWithFilename:(NSString *)fileName;
- (void)stopRecordWithCompletionBlock:(void(^)(NSString *path, CGFloat duration))completion;

- (void)deprecated;

@end
