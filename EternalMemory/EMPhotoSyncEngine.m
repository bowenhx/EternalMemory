//
//  EMPhotoSyncEngine.m
//  EternalMemory
//
//  Created by FFF on 13-12-12.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import "PhotoListFormedRequest.h"
#import "PhotoUploadRequest.h"
#import "EMPhotoSyncEngine.h"
#import "PhotoUploadEngine.h"
#import "ASINetworkQueue.h"
#import "RequestParams.h"
#import "MessageModel.h"
#import "MessageSQL.h"
#import "SavaData.h"
#import "EMAudio.h"
#import "EMAudioUploader.h"
#import "UIImage+UIImageExt.h"
#import "DiaryPictureClassificationSQL.h"

NSString * const kModelsNeedsToBeUpload  = @"kModelsNeedsToBeUpload";
NSString * const kModelsNeedsToBeUpdated = @"kModelsNeedsToBeUpdated";
NSString * const kModelsNeedsToBeDeleted = @"kModelsNeedsToBeDeleted";

#define tDeleteRequest      101
#define tUploadRequest      102
#define tUpdateRequest      103

#define tDeleteRequestQueue 201
#define tUpdateRequestQueue 202


@interface EMPhotoSyncEngine (private)

- (BOOL)deletePhotoFromSandboxForModel:(MessageModel *)model;

@end

@interface EMPhotoSyncEngine () <ASIHTTPRequestDelegate>
{
    NSInteger _updateCount;
    NSInteger _deleteCount;
}

@property (nonatomic, assign) __block BOOL uploadFinashed;
@property (nonatomic, assign) BOOL deleteFinashed;
@property (nonatomic, assign) BOOL updateFinashed;

@property (nonatomic, retain) PhotoListFormedRequest *activeUpdateRequest;
@property (nonatomic, retain) PhotoListFormedRequest *activeDeleteRequest;
@property (nonatomic, retain) DiaryPictureClassificationModel *diaryModel;

@property (nonatomic, retain) EMAudio *audio;
@end

@implementation EMPhotoSyncEngine

+ (instancetype)sharedEngine
{
    static EMPhotoSyncEngine *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[EMPhotoSyncEngine alloc] init];
    });
    
    return _sharedInstance;
}

- (void)dealloc
{
    [_activeDeleteRequest release];
    [_activeUpdateRequest release];
    [_writeFileSuccessBlock release];
    [_diaryModel release];
    [super dealloc];
}


- (BOOL)handleMessageModel:(MessageModel *)model localBlock:(BOOL (^)(void))lblock syncBlock:(BOOL (^)(void))sblock
{
    BOOL success = NO;
    if (model.blogId.length == 0) {
        success = lblock();
    } else {
        success = sblock();
    }
    
    return success;
}

- (BOOL)handleDeleteAudio:(EMAudio *)audio localBlock:(BOOL (^)(void))lblock syncBlock:(BOOL (^)(void))sblock
{
    BOOL success = NO;
    if (audio.audioURL.length == 0 || !audio.audioURL) {
        success = lblock();
    } else {
        success = sblock();
    }
    
    return success;
}

- (BOOL)handleUploadAudio:(EMAudio *)audio locaBlock:(BOOL (^)(void))lBlock syncBlock:(BOOL (^)(void))sBlock {
    BOOL success = NO;
    if (audio.blogId.length == 0 || !audio.blogId) {
        success = lBlock();
    } else {
        success = sBlock();
    }
    
    return success;
}


- (void)cacheDataAndSavePicToLocalWhenOffline:(NSArray *)images toGroup:(DiaryPictureClassificationModel *)groupModel {
    
    return;
}

- (void)uploadOperationNeedsSyncWithImages:(NSArray *)images toGroup:(DiaryPictureClassificationModel *)groupModel {
    [_diaryModel release];
    _diaryModel = [groupModel retain];
    [self cacheDataAndSavePicToLocalWhenOffline:images upGroupId:groupModel.groupId];
}
- (void)uploadOperationNeedsSyncWithImages:(NSArray *)images upGroupId:(NSString *)groupId
{

    [self cacheDataAndSavePicToLocalWhenOffline:images upGroupId:groupId];

}

- (BOOL)updateOperationNeesdsSyncWithModel:(MessageModel *)model
{
    return [self handleMessageModel:model localBlock:^{
        //TODO:修改数据库，将同步状态修改为“上传”
        model.status = @"2";
        BOOL flag = [MessageSQL refershMessagesByMessageModelArray:@[model]];
        return flag;
    } syncBlock:^{
        //TODO:修改数据库，将同步状态修改为“修改”
        model.status = @"4";
        BOOL flag = [MessageSQL refershMessagesByMessageModelArray:@[model]];
        return flag;
    }];
    
}

- (BOOL)deleteNeedsSyncWithAudio:(EMAudio *)audio{
    
    return [self handleDeleteAudio:audio localBlock:^BOOL{
        BOOL flag = NO;
        flag = [MessageSQL deleteAudioDataForAnID:[@(audio.ID) stringValue]];
        if (!flag) return flag;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:EMAudioDeleteSuccessNotification object:audio];
        });
        return [[NSFileManager defaultManager] removeItemAtPath:audio.wavPath error:nil];
        
    } syncBlock:^BOOL{
        audio.audioStatus = EMAudioSyncStatusNeedsToBeDeleted;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:EMAudioDeleteSuccessNotification object:audio];
        });
        return [MessageSQL updateAudio:audio forBlogid:audio.blogId];
    }];
}

- (BOOL)deleteOperationNeedsSyncWithModel:(MessageModel *)model
{
    
    return [self handleMessageModel:model localBlock:^{
        BOOL flag = NO;
        if ([MessageSQL deletePhoto:@[model]])
        {
            flag =  [self deletePhotoFromSandboxForModel:model];
        }
        return flag;
        
    } syncBlock:^{
        model.status = @"3";
        model.deletestatus = YES;
        model.needSyn = YES;
        model.needUpdate = YES;
        return [MessageSQL refershMessagesByMessageModelArray:@[model]];
    }];
    

}


- (void)SyncOperation
{
    if (![Utilities checkNetwork]) {
        return;
    }
    
    NSArray *allModel = [[MessageSQL getNeedsSyncPhotos] retain];
    
    if (allModel.count == 0) {
        [allModel release];
        return;
    }
    
    NSMutableArray *uploadArr = [[NSMutableArray alloc] init];
    NSMutableArray *deleteArr = [[NSMutableArray alloc] init];
    NSMutableArray *updateArr = [[NSMutableArray alloc] init];
    
    for (MessageModel *model in allModel) {
        NSInteger status = [model.status integerValue];
        NSInteger audioStatus = model.audio.audioStatus;
        if (status == 2 || audioStatus == EMAudioSyncStatusNeedsToBeUpload || audioStatus == EMAudioSyncStatusNeedsToBeUpdated) {
            [uploadArr addObject:model];
        } else if (status == 4) {
            [updateArr addObject:model];
        } else if (status == 3 || audioStatus == EMAudioSyncStatusNeedsToBeDeleted) {
            [deleteArr addObject:model];
        }
    }
    
    [allModel release];
    
    if (uploadArr.count > 0) {
        ASINetworkQueue *photoUploadQueue = [[ASINetworkQueue alloc] init];
        NSMutableArray *uploadAudio = [[NSMutableArray alloc]  init];
        for (MessageModel *model in uploadArr) {
            @autoreleasepool {
                if (model.status.integerValue == 2) {
                    PhotoUploadRequest *request = [PhotoUploadRequest requestWithURL:[[RequestParams sharedInstance] uploadPhoto]];
                    UIImage *bImage = [UIImage imageWithContentsOfFile:model.paths];
                    model.rawImage = [bImage fixOrientation];
                    request.userInfo = @{kModel: model};
                    [request setupRequestForUplodingImage:bImage groupid:model.groupId];
                    [photoUploadQueue addOperation:request];
                } else if (model.audio.audioStatus == EMAudioSyncStatusNeedsToBeUpload || model.audio.audioStatus == EMAudioSyncStatusNeedsToBeUpdated) {
                    EMAudio *audio = model.audio;
                    NSData *audioData = [NSData dataWithContentsOfFile:audio.wavPath];
                    audio.audioData = audioData;
                    audio.blogId = model.blogId;
                    [uploadAudio addObject:audio];
                }
            }
        }
        __block typeof(self) bself = self;
        PhotoUploadEngine *engine = [PhotoUploadEngine sharedEngine];
        engine.completionBlock = ^{
            [bself setValue:@(YES) forKeyPath:@"self.uploadFinashed"];
        };
        engine.uploadQueue = photoUploadQueue;

        if (photoUploadQueue.requestsCount > 0)
            [engine startUpload];
        [photoUploadQueue release];
        
        EMAudioUploader *audioUploader = [EMAudioUploader sharedUploader];
        if (uploadAudio.count > 0)
            [audioUploader startUploadAudios:uploadAudio];
        [uploadAudio release];
    }
    
    SEL queueFinashedSelector = @selector(queueFinashed:);
    
    if (updateArr.count > 0) {
        ASINetworkQueue *queue = [[ASINetworkQueue alloc] init];
        queue.queueDidFinishSelector = queueFinashedSelector;
        queue.delegate = self;
        queue.userInfo = @{@"tag": @(tUpdateRequestQueue)};
        _updateCount = updateArr.count;
        for (MessageModel *model in updateArr) {
            @autoreleasepool {
                PhotoListFormedRequest *request = [PhotoListFormedRequest requestWithURL:[[RequestParams sharedInstance] updatePhotoDetail]];
                [request setupRequestForUpdatePhotoDes:model];
                request.delegate = self;
                request.userInfo = @{@"tag": @(tUpdateRequest), @"model" : model};
//                [request startAsynchronous];
//                self.activeUpdateRequest = request;
                [queue addOperation:request];
                
            }
        }
        [queue go];
        [queue release];
    }
    
    if (deleteArr.count > 0) {
        ASINetworkQueue *queue = [[ASINetworkQueue alloc] init];
        queue.queueDidFinishSelector = queueFinashedSelector;
        queue.delegate = self;
        queue.userInfo = @{@"tag": @(tDeleteRequestQueue)};
        _deleteCount = deleteArr.count;
        for (MessageModel *model in deleteArr) {
            @autoreleasepool {
                if (model.status.integerValue == 3) {
                    PhotoListFormedRequest *request = [PhotoListFormedRequest requestWithURL:[[RequestParams sharedInstance] deletePhoto]];
                    [request setupRequestForDeletingPhoto:model];
                    request.delegate = self;
                    request.userInfo = @{@"tag": @(tDeleteRequest), @"model" : model};
                    [queue addOperation:request];
                } else if (model.audio.audioStatus == EMAudioSyncStatusNeedsToBeDeleted) {
                    //TODO: 删除录音的操作
                    model.audio.blogId = model.blogId;
                    [[EMAudioUploader sharedUploader] deleteAudio:model.audio];
                }
            }
        }
        [queue go];
        [queue release];
    }
    
//    NSDictionary *dic = @{
//                            kModelsNeedsToBeUpload  : uploadArr,
//                            kModelsNeedsToBeUpdated : updateArr,
//                            kModelsNeedsToBeDeleted : deleteArr
//                          };
    
    [uploadArr release];
    [updateArr release];
    [deleteArr release];
    
}

- (void)queueFinashed:(ASINetworkQueue *)queue
{
    NSInteger tag = [queue.userInfo[@"tag"] integerValue];
    if (tag == tDeleteRequestQueue) {
        [self setValue:@(YES) forKeyPath:@"self.deleteFinashed"];
    }
    if (tag == tUpdateRequestQueue) {
        [self setValue:@(YES) forKeyPath:@"self.updateFinashed"];
    }
}

- (void)stopSync
{
    [self.activeDeleteRequest clearDelegatesAndCancel];
    [self.activeUpdateRequest clearDelegatesAndCancel];
    [[PhotoUploadEngine sharedEngine] stopUpload];
    [[EMAudioUploader sharedUploader] stopUpload];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    PhotoListFormedRequest *prequest = (PhotoListFormedRequest *)request;
    NSInteger tag = [prequest.userInfo[@"tag"] integerValue];
    switch (tag) {
        case tDeleteRequest:{
            _deleteCount --;
            if ([prequest handleDeletingRequest]) {
                
            }
            break;
        }
        case tUpdateRequest:{
            _updateCount --;
            if ([prequest requestForUpdatingPhotoDesSuccess]) {
            }
            
            break;
        }
        default:
            break;
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    PhotoListFormedRequest *prequest = (PhotoListFormedRequest *)request;
    NSInteger tag = [prequest.userInfo[@"tag"] integerValue];
    switch (tag) {
        case tDeleteRequest:
        {
            _deleteCount --;
            break;
        }
        case tUpdateRequest:
        {
            _updateCount --;
            break;
        }
            
        default:
            break;
    }
}


- (BOOL)cacheAudioWhenOffline:(EMAudio *)audio {
    self.audio = audio;
    
    return [self handleUploadAudio:audio locaBlock:^BOOL{
        return [MessageSQL updataAudio:audio forID:@(audio.ID)];
    } syncBlock:^BOOL{
        return [MessageSQL updateAudio:audio forBlogid:audio.blogId];
    }];
    
}

- (void)cacheDataAndSavePicToLocalWhenOffline:(NSArray *)images upGroupId:(NSString *)groupId
{
    NSArray *cacheImages = [images retain];
    
    NSString *tempFilePath = [NSString stringWithFormat:@"%@/Library/ETMemory/Photos/%@",NSHomeDirectory(),USERID];
    NSMutableArray *savedBlogs = [[NSMutableArray alloc] init];
    for (UIImage *image in cacheImages) {
        NSDate *date = [[NSDate alloc] init];
        NSTimeInterval timestamp = [date timeIntervalSince1970];
        NSString *filePath = [tempFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"img_%f.png",timestamp]];
        
        NSData *data = UIImageJPEGRepresentation(image, 1);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:tempFilePath]) {

            if ( ![fileManager createDirectoryAtPath:tempFilePath withIntermediateDirectories:YES attributes:nil error:nil]) {
                
                [savedBlogs release];
                [date release];
                data = nil;
                return;
            }
        }
        
        if ([data writeToFile:filePath atomically:YES]) {
            
        }
        
        NSTimeInterval interval = [date timeIntervalSince1970] * 1000;
        NSString *createTimeStr = [NSString stringWithFormat:@"%f",interval];
        [date release];
        
        MessageModel *blog = [[MessageModel alloc] init];
        blog.paths      = filePath;
        blog.spaths     = filePath;
        blog.tempPath   = filePath;
        blog.tempSPath  = filePath;
        blog.groupId    = groupId;
        blog.needSyn    = YES;
        blog.status     = @"2";
        blog.blogType   = @"1";
        blog.createTime = createTimeStr;
        [savedBlogs addObject:blog];
        
        [blog release];
        data = nil;
        
    }
    [cacheImages release];
    
    NSInteger count = 0;
    for (MessageModel *blog in savedBlogs) {
        
        [MessageSQL updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
            
            NSString *str = [NSString stringWithFormat:@"insert into %@ (content, paths, spaths, temp_paths, temp_spaths,status, groupid, blogType, createTime) values (?,?,?,?,?,?,?,?,?)",tableName];
            if(![db executeUpdate:str, blog.content,blog.paths,blog.spaths,blog.tempPath,blog.tempSPath,blog.status,blog.groupId,blog.blogType,blog.createTime])
            {
            }
            else
            {
                if (self.writeFileSuccessBlock) {
                    self.writeFileSuccessBlock(blog.paths);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:PhotosHaveSuccessfullyUploadedNotification object:nil];
                });
            }
            
        }WithUserID:USERID];
        
        if (count == savedBlogs.count - 1) {
            NSString *path = [Utilities relativePathOfFullPath:blog.paths];
            [DiaryPictureClassificationSQL updatePostPhotoPath:path andPhotoCount:@([_diaryModel.blogcount integerValue] + savedBlogs.count).stringValue forGroupId:blog.groupId userId:USERID];
        }
        count ++;
    }
    
    [savedBlogs release];
}


@end



@implementation EMPhotoSyncEngine(private)

- (BOOL)deletePhotoFromSandboxForModel:(MessageModel *)model
{
    BOOL flag = NO;
    
    NSError *error = nil;
    flag = [[NSFileManager defaultManager] removeItemAtPath:model.paths error:&error];
    
    return flag;
}




@end
