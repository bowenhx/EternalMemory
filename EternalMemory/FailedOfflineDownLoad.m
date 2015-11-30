//
//  FailedOfflineDownLoad.m
//  EternalMemory
//
//  Created by xiaoxiao on 12/6/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import "FailedOfflineDownLoad.h"
#import "DownlaodDebugging.h"
#import "OfflineDownLoad.h"
#import "StyleListSQL.h"
#import "ZipArchive.h"
#import "CommonData.h"
#import "SavaData.h"

//风格模板
#define REQUEST_FOR_STYLE_MODEL  4000
//视频
#define REQUEST_FOR_VEDIO_INFO   3000
//音乐
#define REQUEST_FOR_MUSIC_INFO   6000

@interface FailedOfflineDownLoad()
{
    BOOL                suspend;//下载挂起
}

@end

static FailedOfflineDownLoad *failedOfflineDownload = nil;
#define offLine         [OfflineDownLoad shareOfflineDownload]

@implementation FailedOfflineDownLoad

@synthesize tempPath         = _tempPath;
@synthesize totalBytes       = _totalBytes;
@synthesize downloading      = _downloading;
@synthesize receiveBytes     = _receiveBytes;
@synthesize downloadIndex    = _downloadIndex;
@synthesize downloadFinished = _downloadFinished;

+ (FailedOfflineDownLoad*)shareInstance
{
    if (!failedOfflineDownload) {
        failedOfflineDownload = [[FailedOfflineDownLoad alloc] init];
    }
    return failedOfflineDownload;
}

- (id)init
{
    self = [super init];
    if (self) {
        _downloadIndex = 0;
        _downloadFinished = NO;
        suspend = NO;
    }
    return self;
}

//退出登录时重置数据
-(void)reset
{
    _downloadIndex = 0;
    _downloadFinished = NO;
    suspend = NO;
    _receiveBytes = 0;
}

//停止离线下载
-(void)stopOfflineDownLoad
{
    suspend = NO;
    [self setsupendOfflineDownLoad];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.tempPath error:&error];
    self.tempPath = nil;
    _receiveBytes = 0;
}

//暂停离线下载
-(void)setsupendOfflineDownLoad
{
    _downloading = NO;
    suspend = YES;
    if (httpRequest)
    {
        [httpRequest clearDelegatesAndCancel];
        httpRequest = nil;
    }
}
//开始下载
-(void)startOfflineDownLoad
{
    _downloading = YES;
    NSInteger count = offLine.failedArr.count;
    if (count != 0)
    {
        for (int i = 0; i < count; i++)
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:offLine.failedArr[i]];
            if ([dic[@"waiting"] intValue] == 1)
            {
                [dic setValue:[NSNumber numberWithInt:4] forKey:@"waiting"];
                [offLine.failedArr replaceObjectAtIndex:i withObject:dic];
                self.downloadIndex = i;
                self.totalBytes = [dic[@"size"] longLongValue];
                [self dicDownloadListAction:dic downloadType:dic[@"style"]];
                break;
            }
        }
    }
    else
    {
        self.downloadFinished = YES;
        self.didDownLoadFailedFiles();
    }
}

//回复离线下载
-(void)resumeOfflineDownLoad
{
    _downloading = YES;
    BOOL failedloading = NO;
    NSInteger index = 0;
    NSInteger count = offLine.failedArr.count;
    for ( int i = 0; i < count; i++)
    {
        NSDictionary *dic = offLine.failedArr[i];
        if ([dic[@"waiting"] intValue] == 4)
        {
            index = i;
            failedloading = YES;
            break;
        }
    }
    if (failedloading == YES)
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:offLine.failedArr[index]];
        self.downloadIndex = index;
        self.totalBytes = [dic[@"size"] longLongValue];
        [self dicDownloadListAction:dic downloadType:dic[@"style"]];
    }
    else
    {
        [self startOfflineDownLoad];
    }
}

//下载完成清理数据
-(void)clearData
{
    RELEASE_SAFELY(_tempPath);
    
    Block_release(_didDownloadCellProgressBlock);
}
//异号登陆重新设置数据
-(void)resetData
{
    
}

- (void)dicDownloadListAction:(NSDictionary *)dic downloadType:(NSString *)type
{
    if ([type isEqualToString:@"family"])
    {
        NSFileManager *fileHome = [NSFileManager defaultManager];
        NSError *error;
        //创建下载临时文件
        if(![fileHome fileExistsAtPath:[CommonData getTempFolderPath]])
        {
            [fileHome createDirectoryAtPath:[CommonData getTempFolderPath] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        NSString *homeUrl = dic[@"url"];
        NSString *typeStr = [[homeUrl componentsSeparatedByString:@"."] lastObject];
//        NSString *styleName = dic[@"fileName"];
        NSString *styleName = [NSString stringWithFormat:@"style%d",[dic[@"styleId"] intValue]];

        CLEAR_REQUEST(httpRequest);
        httpRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:homeUrl]];
        [DownlaodDebugging setRequest:httpRequest userInfo:dic UserID:USERID fileName:styleName fileType:typeStr Tag:REQUEST_FOR_STYLE_MODEL Type:FileTypeStyle];
        self.tempPath = httpRequest.temporaryFileDownloadPath;
        [DownlaodDebugging setHttpRequestConfigure:httpRequest Handler:self];
        [httpRequest startAsynchronous];
    }
    if ([type isEqualToString:@"music"])
    {
        NSString *fileType = dic[@"fileType"];;
        NSString *fileName = dic[@"fileName"];
        
        //开启下载
        CLEAR_REQUEST(httpRequest);
        httpRequest=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:dic[@"url"]]];
        [DownlaodDebugging setRequest:httpRequest userInfo:dic UserID:USERID fileName:fileName fileType:fileType Tag:REQUEST_FOR_MUSIC_INFO Type:FileTypeMusic];
        self.tempPath = httpRequest.temporaryFileDownloadPath;
        [DownlaodDebugging setHttpRequestConfigure:httpRequest Handler:self];

        [httpRequest startAsynchronous];
    }
    if ([type isEqualToString:@"vedio"])
    {
        //文件类型
        NSString *fileType = dic[@"fileType"];
        //文件名称
        NSString *fileName = dic[@"fileName"];
        //开启下载
        if (httpRequest)
        {
            [httpRequest clearDelegatesAndCancel];
            httpRequest =nil;
        }
        httpRequest=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:dic[@"url"]]];
        [DownlaodDebugging setRequest:httpRequest userInfo:dic UserID:USERID fileName:fileName fileType:fileType Tag:REQUEST_FOR_VEDIO_INFO Type:FileTypeVedio];
        self.tempPath = httpRequest.temporaryFileDownloadPath;
        [DownlaodDebugging setHttpRequestConfigure:httpRequest Handler:self];
        [httpRequest startAsynchronous];
    }
}

#pragma mark - ASIHTTPRequestDelegate 

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{

}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    if (suspend == YES)
    {
        suspend = NO;
        _receiveBytes = bytes;
    }
    if (bytes >= _receiveBytes)
    {
        _receiveBytes = bytes;
    }
    else
    {
        _receiveBytes += bytes;
    }
    __block CGFloat progress = (((float)_receiveBytes) / _totalBytes) >= 1 ? 1.0f:(((float)_receiveBytes) / _totalBytes);
    self.didDownloadCellProgressBlock(progress);
}

-(void)httpRequestSucess:(ASIHTTPRequest *)request
{
    _receiveBytes = 0;
    self.didDownLoadFinishedSuccess(YES);
    NSInteger tag = [request.userInfo[@"tag"] intValue];
    httpRequest = nil;
    if (tag == REQUEST_FOR_STYLE_MODEL)
    {
        [StyleListSQL updateDownLoadState:[request.userInfo[@"styleId"] integerValue]];
        //在模板页面下载，删除zip压缩文件，并解压
        [[SavaData shareInstance] savadataStr:[NSString stringWithFormat:@"style%d",[request.userInfo[@"styleId"] integerValue]] KeyString:@"styleId"];

        [[SavaData shareInstance] savadataStr:request.userInfo[@"zipname"] KeyString:@"specificStyle"];
        [[SavaData shareInstance] savadataStr:[NSString stringWithFormat:@"%@",request.userInfo[@"styleId"]] KeyString:[NSString stringWithFormat:@"%@homeStyle",USERID]];
        [CommonData beginDecompressionFile:request.userInfo];
    }
    if (tag == REQUEST_FOR_VEDIO_INFO)
    {
    }
    if (tag == REQUEST_FOR_MUSIC_INFO)
    {
    }
}

-(void)httpRequestFail:(ASIHTTPRequest *)request
{
    _receiveBytes = 0;
    self.didDownLoadFinishedSuccess(NO);
    NSInteger tag = [request.userInfo[@"tag"] intValue];
    httpRequest = nil;
    if (tag == REQUEST_FOR_STYLE_MODEL)
    {
    }
    if(tag == REQUEST_FOR_MUSIC_INFO)
    {

    }
    if (tag == REQUEST_FOR_VEDIO_INFO)
    {
    }
}

@end
