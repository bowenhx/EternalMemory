//
//  FailedOfflineDownLoad.h
//  EternalMemory
//
//  Created by xiaoxiao on 12/6/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FailedOfflineDownLoad : NSObject<ASIHTTPRequestDelegate>
{
    ASIHTTPRequest *httpRequest;
}
@property (nonatomic,copy)  void (^didDownloadCellProgressBlock)(CGFloat progress);
@property (nonatomic,copy)  void (^didDownLoadFinishedSuccess)(BOOL success);
@property (nonatomic,copy)  void (^didDownLoadFailedFiles)();

@property(nonatomic,copy)  NSString      *tempPath;
@property (nonatomic,assign)NSInteger     downloadIndex;
@property (nonatomic,assign)BOOL          downloadFinished;
@property (nonatomic,assign)BOOL          downloading;

@property (nonatomic,assign)long long int totalBytes;
@property (nonatomic,assign)__block long long int receiveBytes;


+ (FailedOfflineDownLoad*)shareInstance;

//退出登录时重置数据
-(void)reset;

//开始下载
-(void)startOfflineDownLoad;
//停止离线下载
-(void)stopOfflineDownLoad;

//暂停离线下载
-(void)setsupendOfflineDownLoad;
//回复离线下载
-(void)resumeOfflineDownLoad;

- (void)dicDownloadListAction:(NSDictionary *)dic downloadType:(NSString *)type;

//下载完成清理数据
-(void)clearData;
//异号登陆重新设置数据
-(void)resetData;

//ASIHTTPRequest Delegate

-(void)httpRequestSucess:(ASIHTTPRequest *)request;
-(void)httpRequestFail:(ASIHTTPRequest *)request;

@end
