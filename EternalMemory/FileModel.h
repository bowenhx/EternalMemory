//
//  FileModel.h
//  EternalMemory
//
//  Created by Guibing on 06/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMusicPlayerController.h>

@interface FileModel : NSObject
{
    NSMutableArray * _arrDownloadList;
    NSOperationQueue *sendingQueue;
}

@property (nonatomic , retain) NSString *downFileSize;
@property (nonatomic , retain) NSString *downReceivedSize;
@property (nonatomic , retain) NSString *upFileSize;                //上传的文件大小
@property (nonatomic , retain) NSString *upReceivedSize;             //上传文件进度


@property (nonatomic) BOOL isFistReceived;//是否是第一次接受数据，如果是则不累加第一次返回的数据长度，之后变累加
@property (nonatomic) BOOL isDownMusic;//是否正在下载

@property (nonatomic) BOOL isUpMusic;    //判断是否正在上传
@property (nonatomic) BOOL isDownVideo;
@property (nonatomic) BOOL isBackDownVideo; //判断视频暂停后在进入下载列表操作
@property (nonatomic) BOOL isUpVideo;
@property (nonatomic) BOOL isDelectFile; //判断是否删除文件

//存放下载request
@property (nonatomic , retain) NSMutableArray *arrDownloadList;
//存放下载文件
@property (nonatomic , retain) NSMutableArray *downloadArr;
//存放上传request
@property (nonatomic , retain) NSMutableArray *arrUplodingList;
//存放上传文件
@property (nonatomic , retain) NSMutableArray *uploadingArr;
//存放上传视频的文件大小
@property (nonatomic , retain) NSMutableArray *upVideoSize;

//@property (nonatomic , retain) NSMutableArray *audioPlayArr;
//存放本地视频路径
@property (nonatomic , retain) NSMutableArray *videoPathArr;
//存放风格图片
@property (nonatomic , retain) NSMutableArray *styleNameArr;

//存放下载的风格ID
@property (nonatomic , retain) NSMutableArray  *downStyleIDArr;//存放下载风格ID
//存放模板下面的每一个子view
@property (nonatomic , retain) __block NSMutableArray  *downStyleArr;//存放下载的子View
//存放要移除的progressView;
@property (nonatomic , retain) NSMutableArray  *downLoadBtn;

@property (nonatomic , retain) NSMutableDictionary *dicUserInfo;
//存放下载队列operation
@property (nonatomic , retain) NSMutableArray  *styleOperation;

//存放正在下载的风格的名字
@property (nonatomic , retain) NSString *downStyleName;
@property (nonatomic, assign)NSInteger upload_videoNum;
@property (nonatomic ,assign)NSInteger download_videoNum;

@property (nonatomic ,assign)NSInteger upload_musicNum;
@property (nonatomic ,assign)NSInteger download_musicNum;

@property (nonatomic ,assign)NSInteger upVideo_Num;//记录上传视频个数，主要是在网速差得情况下上传判断上传个数

@property (nonatomic , assign)NSInteger styleID;    //记录当前下载风格ID
@property (nonatomic )BOOL isHomeDown;              //记录在家园中是否是下载状态

@property (nonatomic , retain)id delegateStyle;

@property (nonatomic ,assign)BOOL getVedioInfo;
@property (nonatomic) BOOL isUploading;    //判断是否正在上传
@property (nonatomic ,retain)NSString *fileName;//上传的文件名字
@property (nonatomic ,assign)NSInteger videoNumber;//存储上传的视频个数
@property (nonatomic ,assign)NSInteger musicNumber;//存储上传的音频个数
@property (nonatomic ,assign)BOOL      notificationSend;
@property (nonatomic ,retain)id        operation;//上传使用的的线程（音频、视频线程）
@property (nonatomic ,copy)  NSString *vedioName;
@property (nonatomic , retain)UIButton *downStyleBut;       //记录下载风格but
//控制GCD线程是否参数
@property (nonatomic ) __block BOOL isOpenGcd;

@property (nonatomic , assign)NSInteger editSort;//记录撰记编辑分类序号

//@property (nonatomic ,retain)VedioSendOperation *vedioOperation;

-(NSInteger)allVideoNumber;
-(NSInteger)allMusicNumber;


+ (FileModel*)sharedInstance;
//-(NSOperationQueue *)getSendingQueue;
- (void)cancleRequestDelegate;
-(NSOperationQueue *)getSendingQueue;

@end
