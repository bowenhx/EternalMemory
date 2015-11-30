//
//  PhotoUoloadEngine.h
//  EternalMemory
//
//  Created by FFF on 13-12-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASINetworkQueue;
@class StatusIndicatorView;
@class EMAudio;

extern NSString * const PhotosHaveSuccessfullyUploadedNotification;
extern NSString * const SinglePhotoHasSuccessfullyUploadedNotification;
extern NSString * const PhotosUploadingSuccessPushListNotification;

typedef void(^UploadEngineBlock)();

@interface PhotoUploadEngine : NSObject
{
    ASINetworkQueue *_uploadQueue;
    StatusIndicatorView *_indicatorView;
}

@property (nonatomic, retain) NSArray *uploadRequests;
@property (nonatomic, retain) ASINetworkQueue *uploadQueue;
@property (nonatomic, assign) NSUInteger retryTimes;

@property (nonatomic, retain) EMAudio *audio;

@property (nonatomic, copy) UploadEngineBlock completionBlock;

@property (nonatomic, assign) BOOL isUploading;

+ (instancetype)sharedEngine;

- (void)startUpload;
- (void)stopUpload;


@end
