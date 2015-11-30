//
//  EMAudioUploader.m
//  EternalMemory
//
//  Created by FFF on 14-2-19.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMAudioUploader.h"
#import "SavaData.h"
#import "EMAudio.h"
#import "RequestParams.h"
#import "MessageModel.h"
#import "MessageSQL.h"
#import "EMPhotoSyncEngine.h"
#import "ASINetworkQueue.h"
#import "amrFileCodec.h"

#define UPLOAD_AUDIO_KEY        @"upload_audio_key"
NSString * const EMAudioUploadStartedNotification = @"EMAudioUploadStartedNotification";
NSString * const EMAudioUploadSuccessNotification = @"EMAudioUploadSuccessNotification";
NSString * const EMAudioUploadFailureNotification = @"EMAudioUploadFailureNotification";
NSString * const EMAudioDeleteSuccessNotification = @"EMAudioDeleteSuccessNotification";
NSString * const EMAudioDeleteFailureNotification = @"EMAudioDeleteFailureNotification";
@interface ASIFormDataRequest (UploadAudio)

- (void)setupRequestOfUploadingAudio:(EMAudio *)audio;

@end

@interface EMAudioUploader ()<ASIHTTPRequestDelegate, ASIProgressDelegate>

@property (nonatomic, retain) ASIFormDataRequest *uploadRequest;
@property (nonatomic, retain) ASINetworkQueue    *uploadQueue;
@property (nonatomic, copy)   NSString           *wavPath;
@property (nonatomic, copy)   NSString           *amrPath;
@property (nonatomic, retain) EMAudio            *audio;

@end

@implementation EMAudioUploader

+ (instancetype)sharedUploader
{
    static EMAudioUploader *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)dealloc {
    
    [_uploadRequest clearDelegatesAndCancel];
    [_uploadQueue cancelAllOperations];
    [_uploadQueue release];
    [_uploadRequest release];
    [self.audio release];
    [super dealloc];
    
}

- (instancetype)init {
    
    if (self = [super init]) {
        
    }
    return self;
}
#pragma mark - send notifications

- (void)sendDeleteSuccessNotification:(EMAudio *)audio
{
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EMAudioDeleteSuccessNotification object:nil];
    });
}
- (void)sendDeleteFailureNotification:(EMAudio *)audio
{
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EMAudioDeleteFailureNotification object:nil];
    });
}
- (void)sendUploadSuccessNotification:(EMAudio *)audio
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EMAudioUploadSuccessNotification object:audio];
    });
}
- (void)sendUploadFailureNotification {
    self.audio.isUploading = NO;
    self.audio.audioURL = @"";
    self.audio.amrPath = @"";
    self.audio.wavPath = @"";
    self.audio.audioData = nil;
    self.audio.size = 0;
    self.audio.duration = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EMAudioUploadFailureNotification object:self.audio];
    });
}

#pragma mark - upload method


- (void)startUploadAudio:(EMAudio *)audio
{
    
    self.audio = audio;
    if (audio.audioURL.length > 0 && audio.audioStatus == EMAudioSyncStatusNeedsToBeDeleted) {
        audio.audioStatus = EMAudioSyncStatusNeedsToBeUpdated;
    } else {
        audio.audioStatus = EMAudioSyncStatusNeedsToBeUpload;
    }
    BOOL networkConnected = [Utilities checkNetwork];
    if (!networkConnected) {
        if ([[EMPhotoSyncEngine sharedEngine] cacheAudioWhenOffline:audio]) {
            audio.isUploading = NO;
            [self sendUploadSuccessNotification:audio];
        }
        return;
    }
    
    self.uploadRequest = [ASIFormDataRequest requestWithURL:[[RequestParams sharedInstance] uploadAudio]];
    [self.uploadRequest setupRequestOfUploadingAudio:audio];
    self.wavPath = audio.wavPath;
    self.amrPath = audio.amrPath;
    
    self.uploadRequest.delegate = self;

    [self.uploadRequest startAsynchronous];
    
}

- (void)startUploadAudios:(NSArray *)audioes {
    
    NSArray *uploadArr = [[NSArray alloc] initWithArray:audioes];
    NSURL *uploadURL = [[RequestParams sharedInstance] uploadAudio];
    
    ASINetworkQueue *uploadQueue = [ASINetworkQueue queue];
    uploadQueue.delegate = self;
    uploadQueue.requestDidFinishSelector = @selector(requestFinished:);
    uploadQueue.queueDidFinishSelector   = @selector(queueFinashed:);
    for (EMAudio *audio in uploadArr) {
        if (! audio.wavPath && audio.wavPath.length == 0) {
            continue;
        }
        
        NSString *fileType = [Utilities fileTypeOfPath:audio.wavPath];
        if ([fileType isEqualToString:@"wav"]) {
            NSString *amrFilePath = [Utilities fullPathForAudioFileOfType:@"amr"];
            if (! EncodeWAVEFileToAMRFile([audio.wavPath cStringUsingEncoding:NSASCIIStringEncoding], [amrFilePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16)) {
                return;
            }
            audio.audioData = [NSData dataWithContentsOfFile:amrFilePath];
        }
        
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:uploadURL];
        [request setupRequestOfUploadingAudio:audio];
        [uploadQueue addOperation:request];
    }
    
    [uploadQueue go];
    
    [uploadArr release];
}

- (void)stopUpload {
    if (_uploadQueue) {
        [_uploadQueue cancelAllOperations];
    }
    if (_uploadRequest) {
        [_uploadRequest clearDelegatesAndCancel];
    }
}

#pragma mark - delete method
- (void)deleteAudio:(EMAudio *)audio {
    if ([Utilities checkNetwork]) {
        [self sendDeleteAudioRequestWithBlogid:audio];
    } else {
        [[EMPhotoSyncEngine sharedEngine] deleteNeedsSyncWithAudio:audio];
    }
}

- (void)sendDeleteAudioRequestWithBlogid:(EMAudio *)audio {
    NSURL *deleteAudioUrl = [[RequestParams sharedInstance] deleteAudio];
    ASIFormDataRequest *deleteRequest = [ASIFormDataRequest requestWithURL:deleteAudioUrl];
    [deleteRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [deleteRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [deleteRequest setPostValue:audio.blogId forKey:@"blogid"];
    [deleteRequest setRequestMethod:@"POST"];
    [deleteRequest setTimeOutSeconds:30];
    
    [deleteRequest startAsynchronous];
    
    __block typeof(self) bself = self;
    [deleteRequest setCompletionBlock:^{
        NSData *data = [deleteRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *msg = dic[@"message"];
        NSInteger success = [dic[@"success"] integerValue];
        if (!success) {
            [bself sendUploadFailureNotification];
            return;
        }
        
        if (audio.wavPath) [[NSFileManager defaultManager] removeItemAtPath:audio.wavPath error:nil];
        if (audio.amrPath) [[NSFileManager defaultManager] removeItemAtPath:audio.amrPath error:nil];
        
        [MessageSQL deleteAUdioDataForBlogId:audio.blogId];
        audio.audioURL = @"";
        audio.wavPath = @"";
        audio.amrPath = @"";
        audio.audioData = nil;
        [bself sendDeleteSuccessNotification:audio];
    }];
    
    [deleteRequest setFailedBlock:^{
        [bself sendDeleteFailureNotification:nil];
    }];
}

#pragma mark - handle request response
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes {
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    NSData *result = request.responseData;
    NSError *error = nil;
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        return;
    }
    
    NSString *msg = resultDic[@"message"];
    NSInteger success = [resultDic[@"success"] integerValue];
    NSDictionary *modelDic = resultDic[@"data"];
    if (success == 0) {
        [self sendUploadFailureNotification];
        if ([msg isEqualToString:@"录音已存在"]) {
            //按updata重新上传音频。
        }
        return;
    }
    
   
    EMAudio *audio = request.userInfo[UPLOAD_AUDIO_KEY];
    [[NSFileManager defaultManager] removeItemAtPath:self.amrPath error:nil];
    MessageModel *model = [[MessageModel alloc] initWithDict:modelDic];
    model.audio.wavPath = audio.wavPath;
    model.audio.audioStatus = EMAudioSyncStatusNone;
    model.audio.audioURL = model.audio.audioURL;
    model.audio.blogId = model.blogId;
    self.audio = model.audio;
    audio.isUploading = NO;
    [MessageSQL updateAudio:model.audio forBlogid:model.blogId];
    [[NSNotificationCenter defaultCenter] postNotificationName:EMAudioUploadSuccessNotification object:model.audio];
    
    [model release];
    
}

- (void) requestFailed:(ASIHTTPRequest *)request {
    self.isUploading = NO;
    self.audio.isUploading = self.isUploading;
}


- (void)requestStarted:(ASIHTTPRequest *)request{
    self.isUploading = YES;
    self.audio.isUploading = self.isUploading;
    [[NSNotificationCenter defaultCenter] postNotificationName:EMAudioUploadStartedNotification object:self.audio];
}

- (void)queueFinashed:(ASINetworkQueue *)queue {
    self.isUploading = NO;
    self.audio.isUploading = self.isUploading;
}

#pragma mark -

@end

@implementation ASIFormDataRequest (UploadAudio)

- (void)setupRequestOfUploadingAudio:(EMAudio *)audio {
    
    self.userInfo = @{UPLOAD_AUDIO_KEY : audio};
    [self setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [self setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [self setPostValue:audio.blogId forKey:@"blogid"];
    self.timeOutSeconds = 300;
    [self setPostValue:[NSString stringWithFormat:@"%d",audio.duration] forKey:@"duration"];
    NSString *flag = @"";
    if (audio.audioStatus == EMAudioSyncStatusNeedsToBeUpload || !audio.audioStatus) flag = @"add";
    if (audio.audioStatus == EMAudioSyncStatusNeedsToBeUpdated) flag = @"update";
    [self setPostValue:flag forKey:@"flag"];
    [self addData:audio.audioData withFileName:@"audio.amr" andContentType:@"audio/amr" forKey:@"upfile"];
}

@end
