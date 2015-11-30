//
//  DownloadModel.m
//  EternalMemory
//
//  Created by Guibing on 06/09/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DownloadModel.h"
#import "CommonData.h"
#import "MyToast.h"
#define FileModel [FileModel sharedInstance]

static DownloadModel* _shareInstance = nil;

@implementation DownloadModel
@synthesize didDownloadCellProgressBlock;

+ (DownloadModel*)shareInstance
{
    if (!_shareInstance) {
        _shareInstance = [[DownloadModel alloc] init];

    }
    return _shareInstance;
}

- (void)dicUploadingListAction:(NSInteger)index
{


}
- (void)dicDownloadListAction:(NSDictionary *)dic downloadType:(NSString *)type isBeginDown:(BOOL)isDownload
{
    if ([type isEqualToString:@"Video"])
    {
        FileModel.isDownVideo = YES;
        isVideo = fileVideo;
        //如果不存在则创建临时存储目录
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSError *error;
        if(![fileManager fileExistsAtPath:[CommonData getMovieTempFolderPath]])
        {
            [fileManager createDirectoryAtPath:[CommonData getMovieTempFolderPath] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        //获取下载地址
        NSString *url = [CommonData getMovVideoPath:dic];//判断视频是否mov视频
       
        NSArray *tmpArr = [url componentsSeparatedByString:@"."];
        //文件类型
        NSString *fileType = [tmpArr lastObject];
        //文件名称
        NSString *fileName = dic[@"content"];
  
        //建立临时数组，把要下载的文件存在临时数组中
        if (FileModel.downloadArr) {
            [FileModel.downloadArr removeAllObjects];
        }
        
        [FileModel.downloadArr addObject:dic];

        //如果文件重复下载或暂停、继续，则把队列中的请求删除，重新添加
        for(ASIHTTPRequest *tempRequest in FileModel.arrDownloadList)
        {
            if([[NSString stringWithFormat:@"%@",tempRequest.url] isEqual:url])
            {
                [FileModel.arrDownloadList removeObject:tempRequest];
                break;
            }
        }
        
        //开启下载
        ASIHTTPRequest *request=[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:url]];
        
        request.temporaryFileDownloadPath = [[CommonData getMovieTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",fileName]];
        request.downloadDestinationPath = [Utilities dataPath:[NSString stringWithFormat:@"%@.%@",fileName,fileType] FileType:@"Videos" UserID:USERID];

        [request setAllowResumeForFileDownloads:YES];//允许断点
        [request setUserInfo:dic];
        request.allowCompressedResponse = NO;//禁止压缩
        [request setDownloadProgressDelegate:self];
        [request setDelegate:self];
        [request setPersistentConnectionTimeoutSeconds:600];
        [request setShouldAttemptPersistentConnection:NO];
        [request setNumberOfTimesToRetryOnTimeout:2];

        [request setTimeOutSeconds:30.0f];
       
        [request startAsynchronous];
        
        [FileModel.arrDownloadList addObject:request];
    }
    else if ([type isEqualToString:@"homeType"])
    {
        isVideo = homeType;
        NSFileManager *fileHome = [NSFileManager defaultManager];
        NSError *error;
        //创建下载临时文件
        if(![fileHome fileExistsAtPath:[CommonData getTempFolderPath]])
        {
            [fileHome createDirectoryAtPath:[CommonData getTempFolderPath] withIntermediateDirectories:YES attributes:nil error:&error];
        }
       
        
        NSString *homeUrl = dic[@"zippath"];
        NSString *typeStr = [[homeUrl componentsSeparatedByString:@"."] lastObject];
        NSString *styleName = dic[@"styleName"];
        
        //建立临时数组，把要下载的文件存在临时数组中
        if (FileModel.downloadArr) {
            [FileModel.downloadArr removeAllObjects];
        }
        
        [FileModel.downloadArr addObject:dic];
        
        //如果文件重复下载或暂停、继续，则把队列中的请求删除，重新添加
        for(ASIHTTPRequest *tempRequest in FileModel.arrDownloadList)
        {
            if([[NSString stringWithFormat:@"%@",tempRequest.url] isEqual:homeUrl])
            {
                [FileModel.arrDownloadList removeObject:tempRequest];
                break;
            }
        }
        
        ASIHTTPRequest *request=[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:homeUrl]];
        //先把下载内容放入本地临时文件
        request.temporaryFileDownloadPath = [[CommonData getTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",styleName]];
        //再把下载完后内容归到本地文件
        request.downloadDestinationPath = [[CommonData getTargetFloderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",styleName,typeStr]];
        
        [request setAllowResumeForFileDownloads:YES];//允许断点
        [request setUserInfo:dic];
        request.allowCompressedResponse = NO;//禁止压缩
        [request setDownloadProgressDelegate:self];
        [request setDelegate:self];
        [request setPersistentConnectionTimeoutSeconds:600];
        [request setShouldAttemptPersistentConnection:NO];
        [request setNumberOfTimesToRetryOnTimeout:2];
        
        [request setTimeOutSeconds:30.0f];
        
        [request startAsynchronous];
        [FileModel.arrDownloadList addObject:request];
    }else
    {
        FileModel.download_musicNum ++;
        isVideo = fileMusic;
        //如果不存在则创建临时存储目录
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSError *error;
        if(![fileManager fileExistsAtPath:[CommonData getTempFolderPath]])
        {
            [fileManager createDirectoryAtPath:[CommonData getTempFolderPath] withIntermediateDirectories:YES attributes:nil error:&error];
        }

        NSString *url = dic[@"fullURL"];
       // NSArray *tmpArr = [url componentsSeparatedByString:@"."];
        //文件类型
       // NSString *fileType = [tmpArr lastObject];
        //文件名称
        NSString *fileName = dic[@"musicName"];
        //文件大小
        //NSString *fileSize = [NSString stringWithFormat:@"%d",[dic[@"attachSize"] integerValue]];

        //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //保存目录，Documents
        //NSString *tpath = [paths lastObject];

        //如果文件重复下载或暂停、继续，则把队列中的请求删除，重新添加
        for(ASIHTTPRequest *tempRequest in FileModel.arrDownloadList)
        {
            if([[NSString stringWithFormat:@"%@",tempRequest.url] isEqual:url])
            {
                [FileModel.arrDownloadList removeObject:tempRequest];
                break;
            }
        }
        
        //保存路径
//        NSString *tmpPath = [tpath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@.%@",fileName,fileSize,fileType]];

//        NSString *savePath = [tpath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName,fileType]];


        //开启下载
        ASIHTTPRequest *request=[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:url]];

        request.temporaryFileDownloadPath = [[CommonData getTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",fileName]];
        request.downloadDestinationPath = [[CommonData getTargetFloderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",fileName]];


        [request setAllowResumeForFileDownloads:YES];//允许断点
        [request setUserInfo:dic];
        request.allowCompressedResponse = NO;//禁止压缩
        [request setDownloadProgressDelegate:self];
        [request setDelegate:self];
        [request setPersistentConnectionTimeoutSeconds:600];
        [request setShouldAttemptPersistentConnection:NO];
        [request setNumberOfTimesToRetryOnTimeout:2];

        [request setTimeOutSeconds:30.0f];

        [request startAsynchronous];
        [FileModel.arrDownloadList addObject:request];
    }

    
}

#pragma mark ASIHTTPRequestDelegate

-(void)requestFailed:(ASIHTTPRequest *)request
{
    FileModel.isDownMusic = NO;
    FileModel.isDownVideo = NO;
    FileModel.download_videoNum = 0;
    FileModel.download_musicNum = 0;
    FileModel.downReceivedSize = @"0";
    FileModel.downFileSize = @"0";
//    [request release];
}
//下载之前获取信息的方法,主要获取下载内容的大小
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
   
    FileModel.downFileSize = [request responseHeaders][@"Content-Length"];

}

//这里注意第一次返回的bytes是已经下载的长度，以后便是每次请求数据的大小
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    if (isVideo == fileVideo) {
        if(!FileModel.isFistReceived)
        {
            FileModel.downReceivedSize = [NSString stringWithFormat:@"%lld",[FileModel.downReceivedSize longLongValue]+bytes];
        }
        
        
        if ([FileModel.downFileSize longLongValue] == [FileModel.downReceivedSize longLongValue]) {
            FileModel.isDownMusic = NO;
            FileModel.isDownVideo = NO;
            FileModel.download_musicNum = 0;
            FileModel.download_videoNum = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeVideoList" object:[NSNumber numberWithBool:NO]];
        }else
        {
            FileModel.isDownMusic = YES;
            FileModel.isDownVideo = YES;
        }
        
        FileModel.isFistReceived=NO;
        if (didDownloadCellProgressBlock) {
            didDownloadCellProgressBlock(bytes);
        }

    }else if (isVideo == homeType)
    {
    }
    
    
}

//将正在下载的文件请求ASIHttpRequest从队列里移除，并将其配置文件删除掉,然后向已下载列表里添加该文件对象
-(void)requestFinished:(ASIHTTPRequest *)request
{
    if (isVideo == fileVideo) {
        FileModel.isDownMusic = NO;
        FileModel.isDownVideo = NO;
        FileModel.download_videoNum = 0;
        FileModel.download_musicNum = 0;
        FileModel.downReceivedSize = @"0";
        FileModel.downFileSize = @"0";
        for (ASIHTTPRequest *request in FileModel.arrDownloadList) {
            [request cancel];
            [request clearDelegatesAndCancel];
            request = nil;
        }
        //把下载完成的视频路劲存入本地
        NSString *videoPath = [CommonData strPathGetTargetFloderTranscodingPath:request.userInfo];
        NSDictionary *dicPath = @{@"videoPath":videoPath,@"videoName":request.userInfo[@"content"]};
        [FileModel.videoPathArr addObject:dicPath];
        //把本地视频路劲存入本地
        [[SavaData shareInstance] savaArray:FileModel.videoPathArr KeyString:@"videoPath"];

        
        [FileModel.arrDownloadList removeAllObjects];
        [MyToast showWithText:@"视频下载成功":[UIScreen mainScreen].bounds.size.height/2-40];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadVedioNumber" object:nil];
    }else if (isVideo == homeType)
    {
       
    }

}



@end
