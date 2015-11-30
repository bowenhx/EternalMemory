//
//  DownlaodDebugging.m
//  EternalMemory
//
//  Created by xiaoxiao on 2/7/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "DownlaodDebugging.h"
#import "OfflineDownLoad.h"
#import "DiaryMessageSQL.h"
#import "CommonData.h"
#import "SavaData.h"
#import "MD5.h"

@implementation DownlaodDebugging

///-------------------------- 图片 --------------------///
//判断沙盒中相册图片数据是否存在
+(NSArray *)enumeratorthumbnail:(NSMutableArray *)thumbnailArr AttachURL:(NSMutableArray *)attachurlArr UserID:(NSString *)ID imagePathsWithBOOL:(BOOL(^)(NSString *path))block
{
    NSMutableArray *tempArr = [NSMutableArray array];
    NSInteger thumbnailcount = thumbnailArr.count;
    for (int i = 0; i < thumbnailcount; i++)
    {
        NSString *paths = thumbnailArr[i][0];
        NSString *imageName = [NSString stringWithFormat:@"simg_%@.png",paths];
        NSString *localImageName = [MD5 md5:imageName];
        NSString *thumbpath = [Utilities dataPath:localImageName FileType:@"Photos" UserID:ID];
        
        if (block(thumbpath))
        {
        }
        else
        {
            [tempArr addObject:@{@"key": @"photo",@"data":@[thumbnailArr[i],thumbpath]}];
        }
    }
    NSInteger attachURLCount = attachurlArr.count;
    for (int i = 0; i < attachURLCount; i++)
    {
        NSInteger photowall = [attachurlArr[i][3] intValue];
        NSString *paths = attachurlArr[i][0];
        if (photowall == 0)
        {
            NSString *imageName = [NSString stringWithFormat:@"img_%@.png",paths];
            NSString *localImageName = [MD5 md5:imageName];
            NSString *attachpath = [Utilities dataPath:localImageName FileType:@"Photos" UserID:ID];
            if (block(attachpath))
            {
            }
            else
            {
                [tempArr addObject:@{@"key": @"photo",@"data":@[attachurlArr[i],attachpath]}];
            }
        }
        else
        {
            NSString *fileName = [Utilities fileNameOfURL:paths];
            NSString *fullPath = nil;
            if ([attachurlArr[i][1] length] != 0)
            {
               fullPath  = [[Utilities lifeMemoPathOfUserUploaded] stringByAppendingPathComponent:fileName];
            }
            else
            {
               fullPath = [[Utilities lifeMemoPathOfTemplate] stringByAppendingPathComponent:fileName];
            }
            if (block(fullPath))
            {
                
            }
            else
            {
                [tempArr addObject:@{@"key": @"photo",@"data":@[attachurlArr[i],fullPath]}];
            }
        }
    }
    return (NSArray *)tempArr;
}
//初始化下载多列
+(ASINetworkQueue *)initQueueFinish:(SEL)finish Failed:(SEL)failed Delegte:(id)handler
{
    ASINetworkQueue *queue = [[ASINetworkQueue alloc] init];
    [queue setRequestDidFinishSelector:finish];
    [queue setRequestDidFailSelector:failed];
    [queue setDelegate:handler];
    return queue;
}

//设置图片下载队列
+(void)setQueue:(ASINetworkQueue *)queue PhotosArray:(NSArray *)photosArray
{
    NSInteger count = photosArray.count;
    for (int i = 0 ; i < count; i++)
    {
        ASIHTTPRequest *downloadImageRequest = nil;
        NSDictionary *dict = photosArray[i];
        NSArray *data = (NSArray *)dict[@"data"];
        if ([dict[@"key"] isEqualToString:@"photo"])
        {
            NSURL *url = [NSURL URLWithString:data[0][0]];
            NSString *path = data[1];
            downloadImageRequest = [[ASIHTTPRequest alloc] initWithURL:url];
            downloadImageRequest.userInfo = @{@"blogId": data[0][1],@"type":@"photo",@"path":path,@"kind":data[0][2],@"attachURL":data[0][0],@"object":photosArray[i],@"photowall":data[0][3]};
            [downloadImageRequest setDownloadDestinationPath:path];
        }
        else
        {
            NSURL *url = [NSURL URLWithString:data[0]];
            NSString *path = data[1];
            downloadImageRequest = [[ASIHTTPRequest alloc] initWithURL:url];
            downloadImageRequest.userInfo = @{@"object": photosArray[i]};
            [downloadImageRequest setDownloadDestinationPath:path];
        }
        [queue addOperation:downloadImageRequest];
        [downloadImageRequest release];
    }
}

//家谱头像（判断家谱中头像是否本地存在）
+(NSArray *)enumeratorHeadPortrait:(NSMutableArray *)portraitArr PortraitPathsWithBOOL:(BOOL(^)(NSString *path))block
{
    NSMutableArray *tempArr = [NSMutableArray array];
    NSInteger count = portraitArr.count;
    for (int i = 0; i< count; i++)
    {
        NSString *imageStr = portraitArr[i];
        NSString *path = [MD5 md5:imageStr];
        NSString *imagePath = [DownlaodDebugging portraitImagePath:path];
        if (block(imagePath))
        {
        }
        else
        {
            [tempArr addObject:@{@"key": @"other",@"data":@[portraitArr[i],imagePath]}];
        }
    }
    return (NSArray *)tempArr;
}

//家谱图片路径
+(NSString *)portraitImagePath:(NSString *)file
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    NSString *result = [path stringByAppendingPathComponent:file];
    return result;
}

///-------------------------- 视频 --------------------///
//视频数据（判断视频是否本地存在）
+(NSArray *)enumerator:(NSArray *)vedioArr UserID:(NSString *)ID VedioPathsWithBOOL:(BOOL(^)(NSString *path))block
{
    NSMutableArray *tempArr = [NSMutableArray array];
    NSInteger count = vedioArr.count;
    for (int i = 0;  i < count; i++)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:vedioArr[i]];
        NSString *url = [CommonData getMovVideoPath:dict];//判断视频是否mov,mp4,3gp,mpv视频
        
        NSArray *tmpArr = [url componentsSeparatedByString:@"."];
        //文件类型
        NSString *fileType = [tmpArr lastObject];
        //文件名称
        NSString *fileName = dict[@"content"];
        
        NSString *vedioPath = [Utilities dataPath:[NSString stringWithFormat:@"%@.%@",fileName,fileType] FileType:@"Videos" UserID:ID];

        
        
        if (block(vedioPath))
        {
            [dict setValue:[NSNumber numberWithInt:1] forKey:@"exist"];
        }
        else
        {
            [dict setValue:[NSNumber numberWithInt:0] forKey:@"exist"];
            [tempArr addObject:dict];
        }
    }
    return (NSArray *)tempArr;
}
//设置下载视频时数据（视频大小、总的进度等）
+(long long int)setVedioDownLoadDataWithConfigurationArr:(NSArray *)configureArr  BytesArr:(NSMutableArray *)bytesArr
{
    long long int tempTotalCapacity = 0;
    for (NSDictionary *dict in configureArr)
    {
        if ([dict[@"attachURL"] length] > 10)
        {
            [bytesArr addObject:dict[@"attachSize"]];
            tempTotalCapacity += [dict[@"attachSize"] longLongValue];
        }
        else if ([dict[@"transcodingState"] intValue] == 3 && [dict[@"transcodingURL"] length] > 0)
        {
            [bytesArr addObject:dict[@"transcodingSize"]];
            tempTotalCapacity += [dict[@"transcodingSize"] longLongValue];
        }
    }
    return tempTotalCapacity;
}

///-------------------------- 音频 --------------------///
//音频数据（判断音频是否本地存在）
+(NSArray *)enumerator:(NSArray *)musicArr UserID:(NSString *)ID musicPathsWithBOOL:(BOOL(^)(NSString *path))block
{
    NSInteger count = musicArr.count;
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0;  i < count; i++)
    {
        NSDictionary *dict = musicArr[i];
        NSString *fileType = [[dict[@"fullURL"] componentsSeparatedByString:@"."] lastObject];
        NSString *fileName = dict[@"musicName"];
        NSString *musicPath = [Utilities dataPath:[NSString stringWithFormat:@"%@.%@",fileName,fileType] FileType:@"Music" UserID:ID];
        if (block(musicPath))
        {
        }
        else
        {
            [tempArr addObject:dict];
        }
    }
    return (NSArray *)tempArr;
}
//设置下载音频时数据（音频大小、总的进度等）
+(long long int)setMusicDownLoadDataWithConfigurationArr:(NSArray *)configureArr  BytesArr:(NSMutableArray *)bytesArr
{
    long long int tempTotalCapacity = 0;
    for (NSDictionary *dict in configureArr)
    {
        [bytesArr addObject:dict[@"attachSize"]];
        tempTotalCapacity += [dict[@"attachSize"] longLongValue];
    }
    return tempTotalCapacity;
}

///-------------------------- 网络请求 --------------------///
//网络请求的公共配置
+(void)setHttpRequestConfigure:(ASIHTTPRequest *)request Handler:(id)handler
{
    [request setAllowResumeForFileDownloads:YES];//允许断点
    request.allowCompressedResponse = NO;//禁止压缩
    [request setDownloadProgressDelegate:handler];
    [request setPersistentConnectionTimeoutSeconds:600];
    [request setShouldAttemptPersistentConnection:NO];
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request setTimeOutSeconds:30.0f];
    __block typeof (handler) this=handler;
    [request setCompletionBlock:^{
        [this httpRequestSucess:request];
    }];
    [request setFailedBlock:^{
        [this httpRequestFail:request];
    }];
}
//大数据(音频、视频、模板)的网络请求、临时文件路径、最终文件存储路径的整合
+(void)setRequest:(ASIHTTPRequest *)httpRequest userInfo:(NSDictionary *)dic UserID:(NSString *)ID fileName:(NSString *)fileName fileType:(NSString *)fileType Tag:(NSInteger)tag Type:(int)type
{
    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [userInfoDic setObject:[NSNumber numberWithInt:tag] forKey:@"tag"];
    [httpRequest setUserInfo:userInfoDic];
    
    switch (type)
    {
        case 0:
            httpRequest.temporaryFileDownloadPath = [[CommonData getTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",fileName]];
            httpRequest.downloadDestinationPath = [[CommonData getTargetFloderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName,fileType]];
            break;
        case 1:
            httpRequest.temporaryFileDownloadPath = [[CommonData getMusicTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName,fileType]];
            httpRequest.downloadDestinationPath = [Utilities dataPath:[NSString stringWithFormat:@"%@.%@",fileName,fileType] FileType:@"Music" UserID:ID];
            break;
        case 2:
            httpRequest.temporaryFileDownloadPath = [[CommonData getMovieTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tmp",fileName]];
            httpRequest.downloadDestinationPath = [Utilities dataPath:[NSString stringWithFormat:@"%@.%@",fileName,fileType] FileType:@"Videos" UserID:ID];

            break;
        case 3:
            httpRequest.temporaryFileDownloadPath = [[CommonData getMovieTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tmp",fileName]];
            httpRequest.downloadDestinationPath = [Utilities dataPath:[NSString stringWithFormat:@"%@.%@",fileName,fileType] FileType:@"Audioes" UserID:ID];
            break;
        default:
            break;
    }
}

//请求完成后数据处理
+(void)synsynchronizeBlogVersionStr:(NSString *)versionsStr ClientVersionStr:(NSString *)clientversionStr Meta:(id)meta synchronizeArr:(NSArray *)synArray
{
    if (![versionsStr isEqualToString:clientversionStr])
    {
        [DiaryMessageSQL synchronizeBlog:synArray WithUserID:USERID];
        if (meta != nil)
        {
            if ([meta isKindOfClass:[NSString class]])
            {
            }
            else if ([meta isKindOfClass:[NSDictionary class]])
            {
                if ([meta objectForKey:@"deletelist"] != nil)
                {
                    [DiaryMessageSQL deleteDiaryBlogs:(NSArray *)meta[@"deletelist"]];
                }
            }
        }
        NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
        NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:User_File];
        NSMutableDictionary *userDataDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
//        [userDataDic setObject:versionsStr forKey:@"DiaryVerson"];
        [userDataDic writeToFile:plistPath atomically:YES];
    }
}

@end
