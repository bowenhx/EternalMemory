//
//  EMPhotoSyncEngine.h
//  EternalMemory
//
//  Created by FFF on 13-12-12.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SyncBlock)(NSString *path);

extern NSString * const kModelsNeedsToBeUpload;
extern NSString * const kModelsNeedsToBeUpdated;
extern NSString * const kModelsNeedsToBeDeleted;

@class MessageModel, EMAudio, DiaryPictureClassificationModel;

@interface EMPhotoSyncEngine : NSObject

@property (nonatomic, copy) SyncBlock writeFileSuccessBlock;

+ (instancetype)sharedEngine;

- (void)cacheDataAndSavePicToLocalWhenOffline:(NSArray *)images upGroupId:(NSString *)groupId;
- (void)cacheDataAndSavePicToLocalWhenOffline:(NSArray *)images toGroup:(DiaryPictureClassificationModel *)groupModel;

- (void)uploadOperationNeedsSyncWithImages:(NSArray *)images toGroup:(DiaryPictureClassificationModel *)groupModel;
- (BOOL)cacheAudioWhenOffline:(EMAudio *)audio;

- (void)uploadOperationNeedsSyncWithImages:(NSArray *)images upGroupId:(NSString *)groupId;

- (BOOL)updateOperationNeesdsSyncWithModel:(MessageModel *)model;

- (BOOL)deleteOperationNeedsSyncWithModel:(MessageModel *)model;

- (BOOL)deleteNeedsSyncWithAudio:(EMAudio *)audio;

- (void)SyncOperation;
- (void)stopSync;

@end
