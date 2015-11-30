//
//  ResumeVedioSendOperation.h
//  EternalMemory
//
//  Created by xiaoxiao on 12/28/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^UploadProgress)(CGFloat progress,int fileIndex,NSString *identifier);
typedef void(^UploadFailed)(NSString *identifier,int fileIndex);
typedef void (^UnexceptedSituation)(NSDictionary *dic);
typedef void(^UploadSuccess)(int fileIndex);
typedef void(^SpaceNotEnough)();

typedef NS_ENUM(NSInteger, UploadState)
{
    UploadStateUpLoading = 0,
    UploadStateStop,
    UploadStateWaiting,
    UploadStateWait,
};

@protocol ResumeVedioSendOperationDelegate <NSObject>

@optional
-(void)uploadProgress:(CGFloat)progress FileIndex:(int)fileIndex FileName:(NSString *)fileName;
-(void)uploadFileSuccess:(int)fileIndex;
-(void)spaceNotEnough;
-(void)unexceptedCrash;

@end

@interface ResumeVedioSendOperation : NSObject<ASIHTTPRequestDelegate>

@property(nonatomic,retain)    ASIFormDataRequest *dataRequest;
@property(nonatomic,copy)      UploadProgress      uploadProgress;
@property(nonatomic,copy)      UploadSuccess       uploadSuccess;
@property(nonatomic,copy)      UploadFailed        uploadFialed;
@property(nonatomic,copy)      SpaceNotEnough      spaceNotEnough;
@property(nonatomic,copy)      UnexceptedSituation unexceptedSituation;
@property(nonatomic,assign)    __block int         fileIndex;
@property(nonatomic,copy)      __block NSString   *convertingMusicName;
@property(nonatomic,copy)      __block NSString   *name;//文件名
//@property(nonatomic,assign)    __block BOOL        musicCoverting;
@property(nonatomic,assign)    BOOL                isUploading;
@property(nonatomic,assign)    BOOL                showProgress;//是否展示进度

@property(nonatomic,assign)    id<ResumeVedioSendOperationDelegate> delegate;

+ (ResumeVedioSendOperation*)shareInstance;

//设置上传文件的信息
//-(void)setupUploadFileInfo:(NSDictionary *)fileInfo;

//开始上传
//-(void)startOrResumeUploadingWithInfo:(NSDictionary *)info;
-(void)startOrResumeUploadingWithFileIndex:(int)index;

//退到后台继续上传
-(void)resumeUploading;

//暂停上传
-(void)suspendUploadingWithFileIndex:(int)index;

//退到后台进行暂停
-(void)suspendUploadingInBackIndex;

//终止上传
-(void)stopUploading;

//用户退出停止上传
-(void)stopUploadingWhenExit;

//断网情况下将所有得上传设置为暂停状态
-(void)setSuspendWhenNetworkNoReachible;

@end
