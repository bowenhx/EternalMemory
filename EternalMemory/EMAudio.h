//
//  EMAudio.h
//  EternalMemory
//
//  Created by FFF on 14-2-19.
//  Copyright (c) 2014年 sun. All rights reserved.
//

typedef NS_ENUM(NSInteger, EMAudioSyncStatus) {
    EMAudioSyncStatusNone = 0,
    EMAudioSyncStatusNeedsToBeUpload ,
    EMAudioSyncStatusNeedsToBeDeleted ,
    EMAudioSyncStatusNeedsToBeUpdated 
};

#import <Foundation/Foundation.h>


@interface EMAudio : NSObject <NSCopying>

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, retain) NSData    *audioData;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, copy)   NSString  *wavPath;
@property (nonatomic, copy)   NSString  *amrPath;
@property (nonatomic, retain) NSString  *blogId;
@property (nonatomic, copy)   NSString  *audioURL;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) BOOL      isUploading;


@property (nonatomic, assign) EMAudioSyncStatus audioStatus;

@end
