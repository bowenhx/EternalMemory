//
//  PhotoUoloadEngine.m
//  EternalMemory
//
//  Created by FFF on 13-12-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "PhotoUploadEngine.h"
#import "PhotoUploadRequest.h"
#import "MessageModel.h"
#import "MessageSQL.h"
#import "ASINetworkQueue.h"
#import "StatusIndicatorView.h"
#import "SavaData.h"
#import "MyToast.h"
#import "EMPhotoSyncEngine.h"
#import "EternalMemoryAppDelegate.h"
#import "EMAudio.h"
#import "EMAudioUploader.h"

#include "amrFileCodec.h"
#define tLoginAtOtherPlaceAlert   101



NSString * const PhotosHaveSuccessfullyUploadedNotification = @"PhotosHasSuccessfullyUploadedNotification";
NSString * const SinglePhotoHasSuccessfullyUploadedNotification = @"SinglePhotoHasSuccessfullyUploadedNotification";
NSString * const PhotosUploadingSuccessPushListNotification = @"PhotosUploadingSuccessPushListNotification";

@interface PhotoUploadEngine ()<ASIProgressDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) NSMutableArray *succeedArr;
@property (nonatomic, retain) NSMutableArray *failureArr;

@end

@implementation PhotoUploadEngine

+ (instancetype)sharedEngine
{
    static PhotoUploadEngine *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PhotoUploadEngine alloc] init];
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
        self.uploadQueue.requestDidStartSelector = @selector(imageUploadingStarted:);
        self.uploadQueue.requestDidFinishSelector = @selector(imageFinashUpLoaded:);
        self.uploadQueue.requestDidFailSelector = @selector(imageFailedUploaded:);
        self.uploadQueue.queueDidFinishSelector = @selector(imagesFinashUploading:);
    }
    
    for (PhotoUploadRequest *request  in _uploadRequests) {
        [self.uploadQueue addOperation:request];
    }
}

- (void)startUpload
{
    if (_uploadQueue && !_isUploading) {
        self.failureArr = [[NSMutableArray alloc] init];
        self.succeedArr = [[NSMutableArray alloc] init];
        
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
        _uploadQueue.requestDidStartSelector = @selector(imageUploadingStarted:);
        _uploadQueue.requestDidFinishSelector = @selector(imageFinashUpLoaded:);
        _uploadQueue.requestDidFailSelector = @selector(imageFailedUploaded:);
        _uploadQueue.queueDidFinishSelector = @selector(imagesFinashUploading:);
    }
    
}

- (void)imageUploadingStarted:(ASIHTTPRequest *)request
{
    _isUploading = YES;
    if (!_indicatorView) {
        _indicatorView = [[StatusIndicatorView alloc] initWithTaskCount:_uploadQueue.requestsCount message:@"正在上传..."];
    }
    _indicatorView.message = @"↑正在上传...";
    _indicatorView.total   = _uploadQueue.operations.count;
    [_indicatorView show];
}

- (void)imageFinashUpLoaded:(ASIHTTPRequest *)request
{
    PhotoUploadRequest *aRequest = (PhotoUploadRequest *)request;
    NSData *data = [aRequest responseData];
    NSDictionary *dic = [data objectFromJSONData];
    NSInteger success = [dic[@"success"] integerValue];
//    NSString *message = dic[@"message"];
    NSInteger tag = [aRequest.userInfo[@"tag"] integerValue];

    if (success == 1) {
        NSDictionary *modelDic = dic[@"data"];
        NSDictionary *metaDic = dic[@"meta"];
        MessageModel *localModel = [request.userInfo[kModel] retain];
        if (localModel) {
            [MessageSQL deletePhoto:@[localModel]];
        }
        
        NSString *imageName = [NSString stringWithFormat:@"simg_%d.png",localModel.rawImage.hash];
        NSString *path = [Utilities FileFolder:@"Photos" UserID:USERID];
        NSString *imagePath = [path stringByAppendingPathComponent:imageName];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *imageData = UIImagePNGRepresentation(localModel.rawImage);
            if ([imageData writeToFile:imagePath atomically:YES]) {
            }
        });
        
        MessageModel *model = [[MessageModel alloc] initWithDict:modelDic];
        model.status        = @"1";
        model.spaths        = imagePath;
        model.paths         = imagePath;
        [self.succeedArr addObject:model];
        [model release];
        
        [SavaData  fileSpaceUseAmount:[NSNumber numberWithInteger:[metaDic[@"spaceused"] integerValue]]];
        
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SinglePhotoHasSuccessfullyUploadedNotification object:model];
        
        if (localModel.audio) {
            localModel.audio.blogId = modelDic[@"blogId"];
            localModel.audio.amrPath = [Utilities fullPathForAudioFileOfType:@"amr"];
            
            if (EncodeWAVEFileToAMRFile([localModel.audio.wavPath cStringUsingEncoding:NSASCIIStringEncoding], [localModel.audio.amrPath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16)) {
                localModel.audio.audioData = [NSData dataWithContentsOfFile:localModel.audio.amrPath];
                [[EMAudioUploader sharedUploader] startUploadAudio:localModel.audio];
//                self.audio = nil;
            }
        }
        
        [localModel release];
        
    } else if (success == 0) {
        
        NSInteger errorCode = [dic[@"errorcode"] integerValue];
        if (tag == SortRequest && errorCode == 3014) {
            [MyToast showWithText:@"您没有更多存储空间，无法上传。" :130];
            [_uploadQueue cancelAllOperations];
            return;
        }
        if (errorCode == 3014) {
            [MyToast showWithText:@"您没有更多存储空间，照片无法上传。" :130];
            [_uploadQueue cancelAllOperations];
            return;
        }
//        if (errorCode == 1005) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的账号在异地登录，请重新登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//            alert.tag = tLoginAtOtherPlaceAlert;
//            [alert show];
//            [alert release];
//        }
        //TODO: 上传失败，空间不足的处理
    }
   
}

- (void)imageFailedUploaded:(ASIHTTPRequest *)request
{
//    PhotoUploadRequest *pRequest = (PhotoUploadRequest *)request;
    MessageModel *model = (MessageModel *)request.userInfo[kModel];
    model.status = @"2";
    if (model) {
        [self.failureArr addObject:model];
    }
}

- (void)imagesFinashUploading:(ASINetworkQueue *)queue
{
    
    _isUploading = NO;
    if (self.failureArr.count > 0) {
        [self cacheFailerModels:self.failureArr];
    }
    
    if (self.succeedArr.count > 0) {
        [MessageSQL addBlogs:self.succeedArr];
        [[NSNotificationCenter defaultCenter] postNotificationName:PhotosHaveSuccessfullyUploadedNotification object:nil];
        
        _indicatorView.message = @"上传结束!";
    }
    
    if (_completionBlock) {
        _completionBlock();
    }
    
    [_indicatorView dismiss];
}

- (void)cacheFailerModels:(NSArray *)failureModels
{
    NSMutableArray *imageArr = [[NSMutableArray alloc] init];
    for (MessageModel *model in failureModels) {
        UIImage *image = model.rawImage;
        [imageArr addObject:image];
        image= nil;
    }
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [[EMPhotoSyncEngine sharedEngine] cacheDataAndSavePicToLocalWhenOffline:imageArr upGroupId:<#(NSString *)#>];
//    });
//    
    [imageArr release];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = alertView.tag;
    if (tag == tLoginAtOtherPlaceAlert) {
        if (buttonIndex == 1) {
            BOOL isLogin = NO;
//
            [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
        }
    }
}

- (void)dealloc
{
    [_completionBlock release];
    [_failureArr release];
    [_succeedArr release];
    [_uploadQueue release];
    [_uploadRequests release];
    [super dealloc];
}

@end
