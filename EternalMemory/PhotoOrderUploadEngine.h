//
//  PhotoOrderUploadEngine.h
//  EternalMemory
//
//  Created by zhaogl on 14-3-14.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

@interface PhotoOrderUploadEngine : NSObject{
    
    ASINetworkQueue *_uploadQueue;

}
@property (nonatomic,retain) ASINetworkQueue *uploadQueue;
@property (nonatomic,retain) NSArray *uploadRequests;
@property (nonatomic,assign) BOOL isUploading;
@property (nonatomic,retain) NSArray *modelDataAry;
@property (nonatomic,retain) NSString *wavPath;

+ (instancetype)sharedEngine;

- (void)startUpload;
- (void)stopUpload;

@end
