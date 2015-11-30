//
//  EMAudioUploader.h
//  EternalMemory
//
//  Created by FFF on 14-2-19.
//  Copyright (c) 2014年 sun. All rights reserved.
//


@class EMAudio;

extern NSString * const EMAudioUploadStartedNotification;
extern NSString * const EMAudioUploadSuccessNotification;
extern NSString * const EMAudioUploadFailureNotification;

extern NSString * const EMAudioDeleteSuccessNotification;
extern NSString * const EMAudioDeleteFailureNotification;

@interface EMAudioUploader : NSObject

@property (nonatomic, assign) BOOL isUploading;

+ (instancetype)sharedUploader;

- (void)startUploadAudio:(EMAudio *)audio;
- (void)startUploadAudios:(NSArray *)audioes;

- (void)stopUpload;

- (void)deleteAudio:(EMAudio *)audio;
@end
