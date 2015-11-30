//
//  ResumeVedioSendOperation.m
//  EternalMemory
//
//  Created by xiaoxiao on 12/28/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import "ResumeVedioSendOperation.h"
#import "RequestParams.h"
#import "CommonData.h"
#import "FileModel.h"
#import "BackgroundMusicViewCtrl.h"
#import "EternalMemoryAppDelegate.h"
#import "CommonData.h"
#import "ShowListHeadView.h"
#import "DownloadViewCtrl.h"
#import "SavaData.h"
#import "MyToast.h"
#import "MusicSendOperation.h"
#import "UploadingDebugging.h"


@interface ResumeVedioSendOperation()
{
    __block long long        size;//文件大小
    int                      resumeIndex;
    long long                receivedSize;
    BOOL                     firstUpload;//判断是否为第一次上传
    ASIHTTPRequest          *uploadRequest;//上传数据请求
    ASIFormDataRequest      *beginRequest;
    NSFileHandle            *fileHandle;//数据进行分段
    MPMediaItemCollection   *mediaItem;
}

@property(nonatomic,copy)  NSString                *path;//文件路径
@property(nonatomic,copy)  NSString                *content;//文件描述
@property(nonatomic,copy)  NSString                *identifier;//文件在服务器标识
//@property(nonatomic,assign)long long                size;//文件大小


//断点上传的状态值  state: 0表示简单加入队列中等待上传  1表示正在上传  2表示暂停上传  3表示排队等待上传 4表示上传失败

//视频数据开始上传
-(void)beginUploadVedioDataWithId:(NSString *)Id ResumePoint:(NSString *)resumePint Info:(NSDictionary *)infoDic;
//视频断点续传需要的数据请求
-(void)resumeUploadVedioInfoRequestWithinfo:(NSDictionary *)infoDic;


//音频数据开始上传
//-(void)beginUploadMusicDataWithId:(NSString *)Id ResumePoint:(NSString *)resumePint musicLocalPath:(NSString *)localPath;
-(void)beginUploadMusicDataWithId:(NSString *)Id ResumePoint:(NSString *)resumePint musicLocalPath:(NSString *)localPath Info:(NSDictionary *)infoDic;
//音频断点续传需要的数据请求
//-(void)resumeUploadMusicInfoRequestWithID:(NSString *)Id;
-(void)resumeUploadMusicInfoRequestWithinfo:(NSDictionary *)infoDic;

//音频数据上传前获取参数的准备接口
//-(void)setMusicRequestWithFileName:(NSString *)fileName FileSize:(NSString *)fileSize RequestTag:(NSInteger)tag resumeUpload:(NSString *)musicIdentifier ;
-(void)setMusicRequestWithFileName:(NSString *)fileName FileSize:(NSString *)fileSize RequestTag:(NSInteger)tag resumeUpload:(NSString *)musicIdentifier Info:(NSDictionary *)infoDic;

//视频数据上传前获取参数的准备接口
-(void)setVedioRequestWithInfo:(NSDictionary *)infoDic RequestTag:(NSInteger)tag;

//视频文件
-(void)uploadVedioFile:(int)index;

//音频文件
-(void)uploadMusicFile:(int)index;

@end

//视频网络请求tag值标记
#define UPDATE_VEDIO_READY_TAG  1001
#define UPDATE_VEDIO_RSUME_TAG  1002
#define UPDATE_VEDIO_FIRST_TAG  1003

//音频网络请求tag值标记
#define UPDATE_MUSIC_READY_TAG  2001
#define UPDATE_MUSIC_RSUME_TAG  2002
#define UPDATE_MUSIC_FIRST_TAG  2003


static ResumeVedioSendOperation *resumeVedioSend = nil;
#define FileModel      [FileModel sharedInstance]

@implementation ResumeVedioSendOperation
@synthesize uploadProgress;
@synthesize uploadSuccess;
@synthesize unexceptedSituation;
//@synthesize musicCoverting;
@synthesize convertingMusicName;
@synthesize delegate;
@synthesize showProgress;
@synthesize uploadFialed;
@synthesize fileIndex;
- (void)dealloc
{
    [super dealloc];
}

+ (ResumeVedioSendOperation*)shareInstance
{
    if (!resumeVedioSend) {
        resumeVedioSend = [[ResumeVedioSendOperation alloc] init];
    }
    return resumeVedioSend;
}

//开始上传
-(void)startOrResumeUploadingWithFileIndex:(int)index
{
    fileIndex = index;
    if ([FileModel.uploadingArr[index][@"type"] isEqualToString:@"vedio"])
    {
        [self uploadVedioFile:index];
    }
    else
    {
        [self uploadMusicFile:index];
    }
}

//视频文件
-(void)uploadVedioFile:(int)index
{
    NSDictionary *info = FileModel.uploadingArr[index];
    [self setupUploadVedioFileInfo:info];
    BOOL first = [info[@"first"] boolValue];
    NSMutableDictionary *replaceDict = [NSMutableDictionary dictionaryWithDictionary:info];
    [replaceDict setObject:[NSNumber numberWithInt:1] forKey:@"state"];
    [replaceDict setObject:@"正在上传..." forKey:@"stateDescription"];
    if (first == NO)
    {
        if (info[@"identifier"] != nil)
        {
            self.identifier = [[NSString alloc] initWithString:info[@"identifier"]];
        }
        [self setVedioRequestWithInfo:replaceDict RequestTag:UPDATE_VEDIO_RSUME_TAG];
    }
    else
    {
        [replaceDict setObject:[NSNumber numberWithBool:NO] forKey:@"first"];
        [self setVedioRequestWithInfo:replaceDict RequestTag:UPDATE_VEDIO_READY_TAG];
    }
    [FileModel.uploadingArr replaceObjectAtIndex:index withObject:replaceDict];
    [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];
}

//音频文件
-(void)uploadMusicFile:(int)index
{
    NSDictionary *info = FileModel.uploadingArr[index];
    [self setupUploadMusicFileInfo:info];
    BOOL first = [info[@"first"] boolValue];
    __block NSMutableDictionary *replaceDict = [NSMutableDictionary dictionaryWithDictionary:info];
    [replaceDict setObject:[NSNumber numberWithInt:1] forKey:@"state"];
    if (first == NO && [replaceDict[@"completeConvet"] boolValue] == YES)
    {
        [replaceDict setObject:@"正在上传..." forKey:@"stateDescription"];
        if (info[@"identifier"] == nil)
        {
            size = [replaceDict[@"size"] longLongValue];
            [self setMusicRequestWithFileName:[self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] FileSize:[NSString stringWithFormat:@"%lld",size] RequestTag:UPDATE_MUSIC_READY_TAG resumeUpload:nil Info:replaceDict];
        }
        else
        {
            size = [replaceDict[@"size"] longLongValue];
            if (info[@"identifier"] != nil)
            {
                self.identifier = [[NSString alloc] initWithString:info[@"identifier"]];
            }
            [self setMusicRequestWithFileName:[self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] FileSize:[NSString stringWithFormat:@"%lld",size] RequestTag:UPDATE_MUSIC_RSUME_TAG resumeUpload:self.identifier Info:replaceDict];
        }
        [FileModel.uploadingArr replaceObjectAtIndex:index withObject:replaceDict];
        [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];

    }
    else if (first == NO && [replaceDict[@"completeConvet"] boolValue] == NO)
    {
        [replaceDict setObject:@"正在解析..." forKey:@"stateDescription"];
        NSString *path = replaceDict[@"path"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            NSFileManager *FM = [NSFileManager defaultManager];
            NSDictionary *dic = [FM attributesOfItemAtPath:path error:nil];
            size = [dic[@"NSFileSize"] longLongValue];
            [replaceDict setObject:[NSNumber numberWithLongLong:size] forKey:@"size"];
            [replaceDict setObject:[NSNumber numberWithBool:YES] forKey:@"completeConvet"];
            [FileModel.uploadingArr replaceObjectAtIndex:index withObject:replaceDict];
            if ([replaceDict[@"state"] intValue] == 1)
            {
                [self setMusicRequestWithFileName:[self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] FileSize:[NSString stringWithFormat:@"%lld",size] RequestTag:UPDATE_MUSIC_READY_TAG resumeUpload:nil Info:replaceDict];
            }
            [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];
        }
    }
    else
    {
        [replaceDict setObject:@"正在解析..." forKey:@"stateDescription"];
        [replaceDict setObject:[NSNumber numberWithBool:NO] forKey:@"first"];
        [FileModel.uploadingArr replaceObjectAtIndex:index withObject:replaceDict];
        [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];

        info = FileModel.uploadingArr[index];
        mediaItem = info[@"mediaItem"];
        NSURL *assetURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
        
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
        
        AVAssetExportSession *exporter = [[[AVAssetExportSession alloc] initWithAsset: urlAsset presetName: AVAssetExportPresetAppleM4A] autorelease];
        
        exporter.outputFileType = @"com.apple.m4a-audio";
        NSString *strName = [NSString stringWithFormat:@"%@.m4a",[mediaItem valueForProperty:MPMediaItemPropertyTitle]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path =  [paths objectAtIndex:0];
        NSString *exportFile = [[path stringByAppendingPathComponent:strName] retain];
        self.path = exportFile;
        if ([CommonData isExistFile:exportFile])
        {
//            musicCoverting = NO;
            NSURL *path_url = [NSURL fileURLWithPath:exportFile];
            NSData *data = [NSData dataWithContentsOfURL:path_url];
            size = (long long)data.length;
            
            NSString *tempName = nil;
            NSInteger count = FileModel.uploadingArr.count;
            for (int i = 0;  i < count; i++)
            {
                if ([FileModel.uploadingArr[i][@"state"] intValue] == 1)
                {
                    tempName = FileModel.uploadingArr[i][@"name"];
                    break;
                }
            }
            if ([self.name isEqualToString:tempName])
            {
                [replaceDict setObject:exportFile forKey:@"path"];
                [replaceDict removeObjectForKey:@"mediaItem"];
                [replaceDict setObject:[NSNumber numberWithLongLong:size] forKey:@"size"];
                [replaceDict setObject:[NSNumber numberWithInt:1] forKey:@"state"];
                [replaceDict setObject:@"正在上传..." forKey:@"stateDescription"];
                [FileModel.uploadingArr replaceObjectAtIndex:index withObject:replaceDict];
                [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];

                [self setMusicRequestWithFileName:[self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] FileSize:[NSString stringWithFormat:@"%lld",size] RequestTag:UPDATE_MUSIC_READY_TAG resumeUpload:nil Info:replaceDict];
            }
        }
        else
        {
            NSURL *path_url = [NSURL fileURLWithPath:exportFile];
            exporter.outputURL = path_url;
            self.convertingMusicName = self.name;
            __block typeof(self) this = self;
            [exporter exportAsynchronouslyWithCompletionHandler:^{
                switch (exporter.status)
                {
                    case AVAssetExportSessionStatusCompleted:
                    {
                        NSString *completePath = [[exporter.outputURL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        completePath = [completePath substringFromIndex:7];
                        if ([completePath hasPrefix:@"localhost"])
                        {
                            completePath = [completePath substringFromIndex:9];
                        }
                        BOOL pathExist = NO;
                        NSInteger replaceIndex = -1;
                        NSInteger count = FileModel.uploadingArr.count;
                        for (int i = 0;  i < count; i++)
                        {
                            if([completePath hasSuffix:FileModel.uploadingArr[i][@"path"]])
                            {
                                replaceIndex = i;
                                pathExist = YES;
                                break;
                            }
                        }
                        if (pathExist == NO)
                        {
                            [[NSFileManager defaultManager] removeItemAtPath:completePath error:nil];
                            return;
                        }
                        
                        replaceDict = [NSMutableDictionary dictionaryWithDictionary:FileModel.uploadingArr[replaceIndex]];
                        [replaceDict removeObjectForKey:@"mediaItem"];
                        fileIndex = replaceIndex;
                        NSFileManager *FM = [NSFileManager defaultManager];
                        NSDictionary *dic = [FM attributesOfItemAtPath:completePath error:nil];
                        size = [dic[@"NSFileSize"] longLongValue];
                        [replaceDict setObject:completePath forKey:@"path"];
                        [replaceDict setObject:[NSNumber numberWithBool:YES] forKey:@"completeConvet"];
                        [replaceDict setObject:[NSNumber numberWithLongLong:size] forKey:@"size"];
                        if ([replaceDict[@"state"] intValue] == 1)
                        {
                            [replaceDict setObject:@"正在上传..." forKey:@"stateDescription"];
                            [this setMusicRequestWithFileName:[this.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] FileSize:[NSString stringWithFormat:@"%lld",size] RequestTag:UPDATE_MUSIC_READY_TAG resumeUpload:nil Info:replaceDict];
                        }
                        [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];
                        [FileModel.uploadingArr replaceObjectAtIndex:replaceIndex withObject:replaceDict];
                        break;
                    }
                }
            }];
    }
    }
}

//设置上传视频文件的信息
-(void)setupUploadVedioFileInfo:(NSDictionary *)fileInfo
{
    self.name    = fileInfo[@"name"];
    self.path    = fileInfo[@"path"];
    self.content = fileInfo[@"content"];
    receivedSize = [fileInfo[@"receiveSize"] longLongValue];
         size    = [fileInfo[@"size"] longLongValue];
    
}
//设置上传音频文件
-(void)setupUploadMusicFileInfo:(NSDictionary *)fileInfo
{
    self.name    = fileInfo[@"name"];
    self.path    = fileInfo[@"path"];
    receivedSize = [fileInfo[@"receiveSize"] longLongValue];
}
//断点续传需要的数据请求
-(void)resumeUploadVedioInfoRequestWithinfo:(NSDictionary *)infoDic
{
    if (infoDic[@"identifier"] != nil)
    {
//        self.identifier = [[NSString alloc] initWithString:infoDic[@"identifier"]];
        self.identifier = [NSString stringWithString:infoDic[@"identifier"]];
    }
    [self setVedioRequestWithInfo:infoDic RequestTag:UPDATE_VEDIO_RSUME_TAG];
}

//数据开始上传
-(void)beginUploadVedioDataWithId:(NSString *)Id ResumePoint:(NSString *)resumePint Info:(NSDictionary *)infoDic
{
    receivedSize = [resumePint longLongValue];
    fileHandle = [NSFileHandle fileHandleForReadingAtPath:self.path];
    self.identifier = Id;
    uploadRequest = [ASIHTTPRequest requestWithURL:[[RequestParams sharedInstance] breakPointUploadVedio]];
    NSData *uploadData = nil;
    if ([resumePint longLongValue] != 0)
    {
        [fileHandle seekToFileOffset:[resumePint longLongValue]];
    }
    if ((size - [resumePint longLongValue]) > 10000000)
    {
        uploadData = [fileHandle readDataOfLength:10000000];
    }
    else
    {
        uploadData = [fileHandle readDataToEndOfFile];
    }
    [fileHandle closeFile];
    uploadRequest.delegate = self;
    [uploadRequest setRequestMethod:@"POST"];
    [uploadRequest addRequestHeader:@"serverauth" value:USER_AUTH_GETOUT];
    [uploadRequest addRequestHeader:@"clienttoken" value:USER_TOKEN_GETOUT];
    [uploadRequest addRequestHeader:@"sourceid" value:Id];
    [uploadRequest addRequestHeader:@"filesize" value:[NSString stringWithFormat:@"%lld",size]];
    [uploadRequest setPostBody:(NSMutableData *)uploadData];
    uploadRequest.userInfo = @{@"tag": [NSNumber numberWithInt:UPDATE_VEDIO_FIRST_TAG],@"type":@"vedio",@"info":infoDic};
    [uploadRequest setUploadProgressDelegate:self];
    [uploadRequest setTimeOutSeconds:30];
    [uploadRequest startAsynchronous];
}

//音频数据开始上传
-(void)beginUploadMusicDataWithId:(NSString *)Id ResumePoint:(NSString *)resumePint musicLocalPath:(NSString *)localPath Info:(NSDictionary *)infoDic
{
    receivedSize = [resumePint longLongValue];
    fileHandle = [NSFileHandle fileHandleForReadingAtPath:localPath];
    self.identifier = [[NSString alloc]initWithString:Id];
    NSData *uploadData = nil;
    if ([resumePint longLongValue] != 0)
    {
        [fileHandle seekToFileOffset:[resumePint longLongValue]];
    }
    if ((size - [resumePint longLongValue]) > 50000000)
    {
        uploadData = [fileHandle readDataOfLength:50000000];
    }
    else
    {
        uploadData = [fileHandle readDataToEndOfFile];
    }
    [fileHandle closeFile];
    NSURL *url = [[RequestParams sharedInstance] resumeUploadMusic];
    uploadRequest = [ASIHTTPRequest requestWithURL:url];
    uploadRequest.delegate = self;
    [uploadRequest setRequestMethod:@"POST"];
    [uploadRequest addRequestHeader:@"serverauth" value:USER_AUTH_GETOUT];
    [uploadRequest addRequestHeader:@"clienttoken" value:USER_TOKEN_GETOUT];
    [uploadRequest addRequestHeader:@"sourceid" value:Id];
    [uploadRequest addRequestHeader:@"filesize" value:[NSString stringWithFormat:@"%lld",size]];
    [uploadRequest addRequestHeader:@"musicname" value:[self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [uploadRequest addRequestHeader:@"flag" value:@"breakupload"];
    [uploadRequest setPostBody:(NSMutableData *)uploadData];
    uploadRequest.userInfo = @{@"tag": [NSNumber numberWithInt:UPDATE_MUSIC_FIRST_TAG],@"info":infoDic};
    [uploadRequest setUploadProgressDelegate:self];
    [uploadRequest setTimeOutSeconds:30];
    [uploadRequest startAsynchronous];
}

//音频断点续传需要的数据请求
-(void)resumeUploadMusicInfoRequestWithinfo:(NSDictionary *)infoDic
{
    if (infoDic[@"identifier"] != nil)
    {
//        self.identifier = [[NSString alloc] initWithString:infoDic[@"identifier"]];
        self.identifier = [NSString stringWithString:infoDic[@"identifier"]];
    }
    [self setMusicRequestWithFileName:[self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] FileSize:[NSString stringWithFormat:@"%lld",size] RequestTag:UPDATE_MUSIC_RSUME_TAG resumeUpload:self.identifier Info:infoDic];
}

//视频数据上传前获取参数的准备接口
-(void)setVedioRequestWithInfo:(NSDictionary *)infoDic RequestTag:(NSInteger)tag
{
    NSURL *url = [[RequestParams sharedInstance] uploadingVideoFirstRequest];
    beginRequest = [[ASIFormDataRequest alloc]initWithURL:url];
    beginRequest.delegate = self;
    [beginRequest setPostValue:@"ios" forKey:@"platform"];
    [beginRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [beginRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    if (infoDic[@"identifier"] == nil)
    {
        [beginRequest setPostValue:infoDic[@"content"] forKey:@"content"];
        [beginRequest setPostValue:infoDic[@"size"] forKey:@"fileSize"];
        [beginRequest setPostValue:infoDic[@"name"] forKey:@"filename"];
    }
    else
    {
        [beginRequest setPostValue:infoDic[@"identifier"] forKey:@"sourceid"];
    }
    beginRequest.userInfo = @{@"tag": [NSNumber numberWithInt:tag],@"type":@"vedio",@"info":infoDic};
    [beginRequest setTimeOutSeconds:30];
    [beginRequest startAsynchronous];
}
//音频数据上传前获取参数的准备接口
-(void)setMusicRequestWithFileName:(NSString *)fileName FileSize:(NSString *)fileSize RequestTag:(NSInteger)tag resumeUpload:(NSString *)musicIdentifier Info:(NSDictionary *)infoDic
{
    NSURL *url = [[RequestParams sharedInstance] resumeUploadMusic];
    uploadRequest = [ASIHTTPRequest requestWithURL:url];
    [uploadRequest setRequestMethod:@"POST"];
    [uploadRequest addRequestHeader:@"clienttoken" value:USER_TOKEN_GETOUT];
    [uploadRequest addRequestHeader:@"serverauth" value:USER_AUTH_GETOUT];
    
    [uploadRequest addRequestHeader:@"flag" value:@"breakget"];
    [uploadRequest addRequestHeader:@"musicname" value:fileName];
    if (musicIdentifier != nil)
    {
        [uploadRequest addRequestHeader:@"sourceid" value:musicIdentifier];
    }
    [uploadRequest addRequestHeader:@"filesize" value:fileSize];
    uploadRequest.userInfo = @{@"tag": [NSNumber numberWithInt:tag],@"path":_path,@"type":@"music",@"name":self.name,@"info":infoDic};
    
    uploadRequest.delegate = self;
    [uploadRequest setTimeOutSeconds:30];
    [uploadRequest startAsynchronous];
}

#pragma mark - ASIHttpRequestDelegate

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSInteger tag = [request.userInfo[@"tag"] intValue];
    
    if ([resultDictionary[@"errorcode"] intValue] == 3014)
    {
        for (NSMutableDictionary *dic in FileModel.uploadingArr)
        {
            if ([dic[@"name"] isEqualToString:request.userInfo[@"info"][@"name"]])
            {
                [dic setObject:[NSNumber numberWithInt:2] forKey:@"state"];
                [dic setObject:@"暂停中..." forKey:@"stateDescription"];
                if ([dic[@"type"] isEqualToString:@"vedio"])
                {
                    [dic setObject:[NSNumber numberWithBool:YES] forKey:@"first"];
                }
                break;
            }
        }
        self.spaceNotEnough();
        return;
    }
    
    if (tag == UPDATE_MUSIC_READY_TAG)
    {
        NSMutableDictionary *replaceDict = [NSMutableDictionary dictionaryWithDictionary:FileModel.uploadingArr[fileIndex]];
        [replaceDict setObject:resultDictionary[@"data"] forKey:@"identifier"];
        [FileModel.uploadingArr replaceObjectAtIndex:fileIndex withObject:replaceDict];
        [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];

        [self beginUploadMusicDataWithId:resultDictionary[@"data"] ResumePoint:@"0" musicLocalPath:request.userInfo[@"path"] Info:replaceDict];
    }
    if (tag == UPDATE_MUSIC_RSUME_TAG)
    {
        if ([resultDictionary[@"success"] intValue]== 1)
        {
            [self beginUploadMusicDataWithId:self.identifier ResumePoint:resultDictionary[@"data"] musicLocalPath:request.userInfo[@"path"] Info:request.userInfo[@"info"]];
        }
        else if ([resultDictionary[@"success"] intValue] == 0 )
        {
            if ([resultDictionary[@"errorcode"] intValue] == 3049)
            {
                if (FileModel.uploadingArr.count != 0)
                {
                    [self resumeUploadMusicInfoRequestWithinfo:request.userInfo[@"info"]];
                }
                else
                {
                    [self stopUploading];
                    [UploadingDebugging savaUplaodFiles:nil];
                }
            }
            else if ([resultDictionary[@"errorcode"] intValue] == 3077)
            {
                uploadRequest = nil;
                for (NSDictionary *data in FileModel.uploadingArr)
                {
                    if ([data[@"name"] isEqualToString:request.userInfo[@"info"][@"name"]])
                    {
                        [FileModel.uploadingArr removeObject:data];
                        break;
                    }
                }
                FileModel.musicNumber --;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadMusicNumber" object:nil];
                [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];

                self.unexceptedSituation([NSDictionary dictionaryWithObjectsAndKeys:@"达到音乐数量限制",@"3077", nil]);

            }
        }
    }
    if (tag == UPDATE_MUSIC_FIRST_TAG)
    {
        uploadRequest = nil;
        if ([resultDictionary[@"success"] intValue] == 0 &&[resultDictionary[@"message"] isEqualToString:@"没有上传完成，可以续传!"])
        {
            [self resumeUploadMusicInfoRequestWithinfo:request.userInfo[@"info"]];
        }
        if ([resultDictionary[@"success"] intValue] == 1)
        {
            
            NSString *finalPath = [Utilities dataPath:[[self.path componentsSeparatedByString:@"/"] lastObject] FileType:@"Music" UserID:USERID];
            [[NSFileManager defaultManager] moveItemAtPath:self.path toPath:finalPath error:nil];
            if (showProgress == YES)
            {
                self.uploadProgress(1.0, fileIndex,request.userInfo[@"info"][@"identifier"]);
            }
            self.uploadSuccess(fileIndex);
        }
    }

    if (tag == UPDATE_VEDIO_READY_TAG)
    {
        NSMutableDictionary *replaceDict = [NSMutableDictionary dictionaryWithDictionary:FileModel.uploadingArr[fileIndex]];
        [replaceDict setObject:resultDictionary[@"data"][@"blogId"] forKey:@"identifier"];
        [FileModel.uploadingArr replaceObjectAtIndex:fileIndex withObject:replaceDict];
        [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];

        [self beginUploadVedioDataWithId:resultDictionary[@"data"][@"blogId"] ResumePoint:resultDictionary[@"data"][@"position"] Info:replaceDict];
    }
    if (tag == UPDATE_VEDIO_RSUME_TAG)
    {
        if ([resultDictionary[@"success"] intValue]== 1)
        {
            [self beginUploadVedioDataWithId:resultDictionary[@"data"][@"blogId"] ResumePoint:resultDictionary[@"data"][@"position"] Info:request.userInfo[@"info"]];
        }
        else if ([resultDictionary[@"errorcode"] intValue] == 3092)
        {
            for (NSDictionary *data in FileModel.uploadingArr)
            {
                if ([data[@"name"] isEqualToString:request.userInfo[@"info"][@"name"]] && [data[@"content"] isEqualToString:request.userInfo[@"info"][@"content"]])
                {
                    [FileModel.uploadingArr removeObject:data];
                    break;
                }
            }
            FileModel.videoNumber --;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadVedioNumber" object:nil];
            [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];

            self.unexceptedSituation(nil);
        }
        else if ([resultDictionary[@"success"] intValue] == 0 && [resultDictionary[@"errorcode"] intValue] == 3049)
        {
            if (FileModel.uploadingArr.count != 0)
            {
                for (NSDictionary *dic in FileModel.uploadingArr)
                {
                    if ([dic[@"name"] isEqualToString:request.userInfo[@"info"][@"name"]] && [dic[@"content"] isEqualToString:request.userInfo[@"info"][@"content"]])
                    {
                        [self resumeUploadVedioInfoRequestWithinfo:request.userInfo[@"info"]];
                        break;
                    }
                }
            }
            else
            {
                [self stopUploading];
                [UploadingDebugging savaUplaodFiles:nil];
            }
        }
    }
    if (tag == UPDATE_VEDIO_FIRST_TAG)
    {
        if ([resultDictionary[@"success"] intValue] == 0 &&[resultDictionary[@"message"] isEqualToString:@"未上传完毕，可以继续上传!"])
        {
            [self resumeUploadVedioInfoRequestWithinfo:request.userInfo[@"info"]];
        }
        if ([resultDictionary[@"success"] intValue] == 1)
        {
            NSString *finalPath = [Utilities dataPath:[NSString stringWithFormat:@"%@.mov",self.content] FileType:@"Videos" UserID:USERID];

            [[NSFileManager defaultManager] moveItemAtPath:self.path toPath:finalPath error:nil];
            if (showProgress == YES)
            {
                self.uploadProgress(1.0, fileIndex,request.userInfo[@"info"][@"identifier"]);
            }
            self.uploadSuccess(fileIndex);
        }
        uploadRequest = nil;
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    if ([Utilities checkNetwork])
    {
        self.uploadFialed(self.identifier ,fileIndex);
    }
}

-(void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    NSInteger tag = [request.userInfo[@"tag"] intValue];

    if (tag == UPDATE_VEDIO_FIRST_TAG || tag == UPDATE_MUSIC_FIRST_TAG)
    {
        if (bytes > 0)
        {
            receivedSize += bytes;
        }
        for (NSMutableDictionary *dic in FileModel.uploadingArr)
        {
            if ([dic[@"name"] isEqualToString:request.userInfo[@"info"][@"name"]])
            {
                [dic setObject:[NSNumber numberWithLongLong:abs(receivedSize)] forKey:@"receiveSize"];
                [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];
                break;
            }
        }
        
        if (showProgress == YES)
        {
//            self.uploadProgress((CGFloat)receivedSize / size, fileIndex,_name);
            self.uploadProgress((CGFloat)receivedSize / size, fileIndex,request.userInfo[@"info"][@"identifier"]);
        }
    }
    if (FileModel.uploadingArr.count == 0)
    {
        [self stopUploading];
        FileModel.videoNumber = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadVedioNumber" object:nil];
        FileModel.musicNumber = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadMusicNumber" object:nil];
    }
}

//退到后台继续上传
-(void)resumeUploading
{
    NSInteger count = FileModel.uploadingArr.count;
    BOOL tempUploading = NO;
    BOOL uploadingIndex = -1;
    for (int i = 0; i< count; i++)
    {
        if ([FileModel.uploadingArr[i][@"state"] intValue] == 1)
        {
            tempUploading = YES;
            uploadingIndex = i;
            break;
        }
    }
    if (tempUploading == YES)
    {
        self.isUploading = YES;
        [self startOrResumeUploadingWithFileIndex:uploadingIndex];
    }
}

#pragma mark - 停止或暂停网络请求

//暂停上传
-(void)suspendUploadingWithFileIndex:(int)index
{
    if (beginRequest)
    {
        [beginRequest clearDelegatesAndCancel];
        beginRequest = nil;
    }
    [self stopUploading];
    NSMutableDictionary *replaceDict = [NSMutableDictionary dictionaryWithDictionary:FileModel.uploadingArr[index]];
    [replaceDict setObject:[NSNumber numberWithFloat:(CGFloat)receivedSize / size] forKey:@"progress"];
    [replaceDict setObject:[NSNumber numberWithLongLong:receivedSize] forKey:@"receiveSize"];
    [replaceDict setObject:[NSNumber numberWithInt:2] forKey:@"state"];
    [replaceDict setObject:@"暂停中..." forKey:@"stateDescription"];
    [FileModel.uploadingArr replaceObjectAtIndex:index withObject:replaceDict];
    [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];

    receivedSize = 0;
}

//退到后台进行暂停
-(void)suspendUploadingInBackIndex
{
    NSInteger count = FileModel.uploadingArr.count;
//    BOOL uploadingIndex = -1;
    for (int i = 0; i< count; i++)
    {
        if ([FileModel.uploadingArr[i][@"state"] intValue] == 1)
        {
            self.isUploading = YES;
//            uploadingIndex = i;
            break;
        }
    }
    if (self.isUploading == YES)
    {
        [self stopUploading];
    }
}

//终止上传
-(void)stopUploading
{
    if (uploadRequest)
    {
        [uploadRequest clearDelegatesAndCancel];
    }
    uploadRequest = nil;
//    self.isUploading = NO;
}

//用户退出停止上传
-(void)stopUploadingWhenExit
{
    NSInteger count = FileModel.uploadingArr.count;
    BOOL uploading = NO;
    NSInteger stopIndex = 0;
    for (int i = 0; i< count; i++)
    {
        if ([FileModel.uploadingArr[i][@"state"] intValue] == 1)
        {
            uploading = YES;
            stopIndex = i;
            break;
        }
    }
    if (uploading == YES)
    {
        [self suspendUploadingWithFileIndex:stopIndex];
    }
}
//断网或退出情况下将所有得上传设置为暂停状态
-(void)setSuspendWhenNetworkNoReachible
{
    if (self.isUploading == YES)
    {
        [self stopUploading];
    }
    NSInteger count = FileModel.uploadingArr.count;
    for (int i = 0; i < count; i++)
    {
        NSMutableDictionary *dic = FileModel.uploadingArr[i];
        if ([dic[@"state"] intValue] == 1)
        {
            [dic setObject:[NSNumber numberWithFloat:(CGFloat)receivedSize / size] forKey:@"progress"];
            [dic setObject:[NSNumber numberWithLongLong:receivedSize] forKey:@"receiveSize"];
            [dic setObject:[NSNumber numberWithInt:2] forKey:@"state"];
            [dic setObject:@"暂停中..." forKey:@"stateDescription"];
            [FileModel.uploadingArr replaceObjectAtIndex:i withObject:dic];
        }
        else if ([dic[@"state"] intValue] != 2)
        {
            [dic setObject:[NSNumber numberWithInt:2] forKey:@"state"];
            [dic setObject:@"暂停中..." forKey:@"stateDescription"];
        }
    }
    [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];
}


@end
