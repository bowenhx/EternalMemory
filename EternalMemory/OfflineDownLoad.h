//
//  OfflineDownLoad.h
//  EternalMemory
//
//  Created by xiaoxiao on 12/3/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

typedef void(^DownloadProgress)(CGFloat progress);
typedef void(^DownloadName)(NSString *name,int model);
typedef void(^DownloadFailed)();
typedef void(^DownLoadFinish)();
typedef void(^LoginOther)();


typedef NS_ENUM(NSInteger, DownLoadLocation)
{
    DownLoadLocation_Blog_Photo_List = 0,
    DownLoadLocation_Blogs,
    DownLoadLocation_Leave_Message,
    DownLoadLocation_Family_Tree,
    DownLoadLocation_Photos_Urls,
    DownLoadLocation_Family_models_Info,
    DownLoadLocation_Photos_DownLoad,
    DownLoadLocation_Style_Download,
    DownLoadLocation_Musics_Urls,
    DownLoadLocation_Musics_Download,
    DownLoadLocation_Vedios_Urls,
    DownLoadLocation_Vedio_Download,
    DownLoadLocation_Audio,

};

@interface OfflineDownLoad : NSObject<ASIHTTPRequestDelegate>

@property(nonatomic,retain)NSMutableArray  *failedArr;
@property(nonatomic,assign)NSInteger        downModelNum;
@property(nonatomic,assign)BOOL             downloading;
@property(nonatomic,copy)  NSString        *styleName;
@property(nonatomic,copy)  NSString        *tempPath;
@property(nonatomic,copy)  DownloadProgress downloadProgress;
@property(nonatomic,copy)  DownloadName     downloadName;
@property(nonatomic,copy)  DownloadFailed   downloadFailed;
@property(nonatomic,copy)  DownLoadFinish   downloadFinish;
@property(nonatomic,copy)  LoginOther       loginOtherPlace;

@property(nonatomic,assign)BOOL             downloadFinished;
@property(nonatomic,assign)BOOL             suspend;
@property(nonatomic,assign)BOOL             associateDownload;
@property(nonatomic,assign)BOOL             associateStop;
@property(nonatomic,assign)float            percentage;


//单例
+(OfflineDownLoad *)shareOfflineDownload;

//退出登录时重置数据
-(void)reset;

//开始离线下载
-(void)startOfflineDownLoad;

//停止离线下载
-(void)stopOfflineDownLoad;

//网络切换或其他情况挂起下载
-(void)setsupendOfflineDownLoad;

//回复挂起的下载
-(void)resumeOfflineDownLoad;

//下载完成清理数据
-(void)clearData;

//异号登陆重新设置数据
-(void)resetData;

-(void)httpRequestSucess:(ASIHTTPRequest *)request;
-(void)httpRequestFail:(ASIHTTPRequest *)request;

@end
