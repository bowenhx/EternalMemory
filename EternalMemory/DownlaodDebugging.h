//
//  DownlaodDebugging.h
//  EternalMemory
//
//  Created by xiaoxiao on 2/7/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

typedef NS_ENUM(NSInteger, FileType)
{
    FileTypeStyle = 0,
    FileTypeMusic,
    FileTypeVedio,
    FileTypeAudio,
};


@interface DownlaodDebugging : NSObject

///-------------------------- 图片 --------------------///
//判断沙盒中相册图片数据是否存在
+(NSArray *)enumeratorthumbnail:(NSMutableArray *)thumbnailArr AttachURL:(NSMutableArray *)attachurlArr UserID:(NSString *)ID imagePathsWithBOOL:(BOOL(^)(NSString *path))block;
//初始化下载多列
+(ASINetworkQueue *)initQueueFinish:(SEL)finish Failed:(SEL)failed Delegte:(id)handler;
//设置图片下载队列
+(void)setQueue:(ASINetworkQueue *)queue PhotosArray:(NSArray *)photosArray;
////相册图片数据路径
//+(NSString *)dataPath:(NSString *)file FileType:(NSString *)fileType UserID:(NSString *)ID;

//家谱头像（判断家谱中头像是否本地存在）
+(NSArray *)enumeratorHeadPortrait:(NSMutableArray *)portraitArr PortraitPathsWithBOOL:(BOOL(^)(NSString *path))block;
//家谱图片路径
+(NSString *)portraitImagePath:(NSString *)file;


///-------------------------- 视频 --------------------///
//视频数据（判断视频是否本地存在）
+(NSArray *)enumerator:(NSArray *)vedioArr UserID:(NSString *)ID VedioPathsWithBOOL:(BOOL(^)(NSString *path))block;
//设置下载视频时数据（视频大小、总的进度等）
+(long long int)setVedioDownLoadDataWithConfigurationArr:(NSArray *)configureArr  BytesArr:(NSMutableArray *)bytesArr;


///-------------------------- 音频 --------------------///
//音频数据（判断音频是否本地存在）
+(NSArray *)enumerator:(NSArray *)musicArr UserID:(NSString *)ID musicPathsWithBOOL:(BOOL(^)(NSString *path))block;
//设置下载音频时数据（音频大小、总的进度等）
+(long long int)setMusicDownLoadDataWithConfigurationArr:(NSArray *)configureArr  BytesArr:(NSMutableArray *)bytesArr;


///-------------------------- 网络请求 --------------------///
//网络请求的公共配置
+(void)setHttpRequestConfigure:(ASIHTTPRequest *)request Handler:(id)handler;
//大数据(音频、视频、模板)的网络请求、临时文件路径、最终文件存储路径的整合
+(void)setRequest:(ASIHTTPRequest *)httpRequest userInfo:(NSDictionary *)dic UserID:(NSString *)ID fileName:(NSString *)fileName fileType:(NSString *)fileType Tag:(NSInteger)tag Type:(int)type;

//请求完成后数据处理
+(void)synsynchronizeBlogVersionStr:(NSString *)versionsStr ClientVersionStr:(NSString *)clientversionStr Meta:(id)meta synchronizeArr:(NSArray *)synArray;




@end
