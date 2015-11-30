//
//  PhotoOrderUploadEngine.m
//  EternalMemory
//
//  Created by zhaogl on 14-3-14.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "PhotoOrderUploadEngine.h"
#import "MyToast.h"
#import "EMMemorizeMessageModel.h"
#import "DiaryPictureClassificationModel.h"
#import "EMAllLifeMemoDAO.h"
#import "DiaryPictureClassificationSQL.h"
#import "ErrorCodeHandle.h"
#import "EternalMemoryAppDelegate.h"

@implementation PhotoOrderUploadEngine


+ (instancetype)sharedEngine
{
    static PhotoOrderUploadEngine *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PhotoOrderUploadEngine alloc] init];
    });
    return _sharedInstance;
}
- (void)setUploadRequests:(NSArray *)uploadRequests
{
    if (_uploadRequests != uploadRequests) {
        [_uploadRequests release];
        _uploadRequests = [uploadRequests retain];
    }
    
    [self initilizeUploadQueue];
}

- (void)initilizeUploadQueue
{
    if (!_uploadQueue) {
        
        self.uploadQueue = [ASINetworkQueue queue];
        self.uploadQueue.delegate = self;
        self.uploadQueue.requestDidStartSelector = @selector(UploadingStarted:);
        self.uploadQueue.requestDidFinishSelector = @selector(FinishUpLoaded:);
        self.uploadQueue.requestDidFailSelector = @selector(FailedUploaded:);
        self.uploadQueue.queueDidFinishSelector = @selector(FinishUploadingQueue:);
    }
    
    for (ASIFormDataRequest *request  in _uploadRequests) {
        [self.uploadQueue addOperation:request];
    }
}
- (void)startUpload
{
    if (_uploadQueue && !_isUploading) {
//        self.failureArr = [[NSMutableArray alloc] init];
//        self.succeedArr = [[NSMutableArray alloc] init];
        
        [_uploadQueue go];
    }
}

- (void)stopUpload
{
    if (_isUploading) {
        [_uploadQueue cancelAllOperations];
        _isUploading = NO;
    }
}

- (void)setUploadQueue:(ASINetworkQueue *)uploadQueue
{
    if (_uploadQueue != uploadQueue) {
        [_uploadQueue release];
        _uploadQueue = [uploadQueue retain];
    }
    
    if (!_uploadQueue.delegate) {
        _uploadQueue.delegate = self;
        _uploadQueue.uploadProgressDelegate = self;
        _uploadQueue.requestDidStartSelector = @selector(UploadingStarted:);
        _uploadQueue.requestDidFinishSelector = @selector(FinishUpLoaded:);
        _uploadQueue.requestDidFailSelector = @selector(FailedUploaded:);
        _uploadQueue.queueDidFinishSelector = @selector(FinishUploadingQueue:);
    }
    
}
-(void)UploadingStarted:(ASIFormDataRequest *)request{
    
}
-(void)FinishUpLoaded:(ASIFormDataRequest *)request{
    
    NSData *data = [request responseData];
    NSDictionary *dic = [data objectFromJSONData];
    NSInteger success = [dic[@"success"] integerValue];
    NSString *message = dic[@"message"];
    NSInteger tag = [request.userInfo[@"tag"] integerValue];
    if (success == 1) {
        if (tag == SortRequest) {
            
            NSArray *dataAry = dic[@"data"];
            NSMutableArray *sortAry = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i = 0; i < dataAry.count; i ++) {
                MessageModel *originalModel = (MessageModel *)_modelDataAry[i];
                MessageModel *model = [[MessageModel alloc] initWithDict:dataAry[i]];
                model.thumbnailImage = originalModel.thumbnailImage;
                model.thumbnailType = originalModel.thumbnailType;
                model.paths = originalModel.paths;
                model.spaths = originalModel.spaths;
                model.rawImage = originalModel.rawImage;
                model.audio = originalModel.audio;
                [sortAry addObject:model];
                [model release];
            }
            [EMAllLifeMemoDAO insertMemoModels:sortAry];
            [[NSNotificationCenter defaultCenter] postNotificationName:Refresh_Sort_Photo object:sortAry];
            [sortAry release];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissCurrentViewToPhotoList" object:nil];
            
        }else if (tag == UploadAudioRequest){
            
            DiaryPictureClassificationModel *model = [[DiaryPictureClassificationModel alloc] initWithDict:dic[@"data"]];
            model.audio.audioStatus = EMAudioSyncStatusNone;
            model.audio.wavPath = _wavPath;
            [DiaryPictureClassificationSQL updateDiaryAudioForServerData:model ForGrouID:model.groupId];
            [[NSNotificationCenter defaultCenter] postNotificationName:Refresh_Life_Audio object:model];
            [model release];
        }
    }else if(success == 0){
        
        [ErrorCodeHandle handleErrorCode:dic[@"errorcode"] AndMsg:message];
        if (tag == SortRequest) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FailUploadSortAndDescription" object:nil];
        }else if (tag == UploadAudioRequest){
            
        }
    }

}
-(void)FailedUploaded:(ASIFormDataRequest *)request{
    
    NSInteger tag = [request.userInfo[@"tag"] integerValue];
    if (tag == SortRequest) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FailUploadSortAndDescription" object:nil];
        [MyToast showWithText:@"保存照片编辑失败" :150];
    }else if (tag == UploadAudioRequest){
        [MyToast showWithText:@"上传录音失败" :150];
    }
}
-(void)FinishUploadingQueue:(ASINetworkQueue *)requestQueue{
    
}
@end
