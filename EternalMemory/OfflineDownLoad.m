//
//  OfflineDownLoad.m
//  EternalMemory
//
//  Created by xiaoxiao on 12/3/13.
//  Copyright (c) 2013 sun. All rights reserved.
//
#import "DiaryPictureClassificationSQL.h"
#import "EternalMemoryAppDelegate.h"
#import "DownlaodDebugging.h"
#import "EMAllLifeMemoDAO.h"
#import "DiaryMessageSQL.h"
#import "OfflineDownLoad.h"
#import "DiaryGroupsSQL.h"
#import "RequestParams.h"
#import "StyleListSQL.h"
#import "StaticTools.h"
#import "MyFamilySQL.h"
#import "CommonData.h"
#import "MessageSQL.h"
#import "ZipArchive.h"
#import "FileModel.h"
#import "EMAudio.h"
#import "MD5.h"

//文献
#define REQUEST_FOR_TEXT_GROUP    1000
#define REQUEST_FOR_TEXT_INFO     1001

//家园留言
#define REQUEST_FOR_LEAVE_MESSAGE 1003

//家谱;
#define REQUEST_FOR_FAMILY_TREE   2000
//视频
#define REQUEST_FOR_VEDIO_INFO    3000
#define REQUEST_FOR_VEDIO_URL     3001

//风格模板
#define REQUEST_FOR_STYLE_MODEL   4000
#define REQUEST_FOR_STYLE_INFO    4001

//图片
#define REQUEST_FOR_PHOTO_GROUP   5000
#define REQUEST_FOR_PHOTO_INFO    5001
#define REQUEST_FOR_PHOTO_URLS    5002

//音乐
#define REQUEST_FOR_MUSIC_INFO    6000
#define REQUEST_FOR_MUSIC_URL     6001

//录音
#define REQUEST_FOR_AUDIO_INFO    8000

//相册、文献的所有分类
#define REQUEST_FOR_GROUP         7000


@interface OfflineDownLoad()
{
    ASIFormDataRequest *formDataRequest;
    ASINetworkQueue    *_downloadQueue;
    ASIHTTPRequest     *httpRequest;//下载视频、音频、模板使用
    
    NSMutableArray     *_photoArray;
    __block NSInteger   downloadPhotoNum;//图片不断下载完成个数
    __block NSInteger   photoTotalNum;   //图片总个数
    int                 downloadStep;//继续下载时开始的位置
    int                 photoVersion;//相册版本号
    int                 vedioVersion;//视频版本号
    BOOL                startstyleDown;//开始了家园模板下载
    BOOL                startFailedPhotoDownLoad;//开始失败的图片下载
    NSInteger           errorcode;//1005 异地登陆
    
}

//设置下载时数据的处理
@property(nonatomic,retain)NSMutableArray *bytesArr;
@property(nonatomic,retain)NSMutableArray *downloadArr;
@property(nonatomic,retain)NSMutableArray *audioArr;//录音文件的数据存储数组
@property(nonatomic,retain)NSMutableArray *successDownArr;

//下载时候文件的大小、接收数据大小
@property(nonatomic,assign)long long int   totalCapacity;
@property(nonatomic,assign)long long int   successCapacity;
@property(nonatomic,assign)long long int   progressCapacity;
//@property(assign) BOOL isDownloading;

//设置各个离线数据调用接口

//设置请求的公共数据
-(void)startRequestWithType:(NSInteger)type;

//一个接口完成后调用另一个接口
-(void)startNextReuqest:(int)nextStep;

//启动图片下载
-(void)startPhotoDownLoad;
//启动失败图片下载
-(void)startFailedPhotoDownLoad;
//设置家园模板的存储
-(void)setFaimilyStyleStorage:(NSDictionary *)dic;
//视频文件下载成功失败处理
-(void)setVedioInfoWithName:(NSString *)name SuccessState:(BOOL)state;
//设置失败数组的字典元素数据
-(void)setFailedarrStyle:(NSString *)style Url:(NSString *)url FileName:(NSString *)fileName FileType:(NSString*)fileType Success:(NSInteger)success Size:(NSString *)size Waiting:(NSInteger)waiting;

//ASIFormDataRequest Delegate
-(void)requestSuccess:(ASIFormDataRequest *)request;
-(void)requestFail:(ASIFormDataRequest *)request;
-(void)selfRequestFinish:(ASIFormDataRequest *)request;

//重置初始化数据
-(void)resetInitData;
//下载模块转换时重置下载进度的相关数据配置（下载大小、已接受数据大小等）
-(void)resetDownlaodData;
//一张图片下载完成之后的操作（包括图片下载成功和失败两种情况）
-(void)setPhotoDownload:(ASIHTTPRequest *)request;
//成功下载一个文件后数据配置
-(void)setDataAfterDownloadSuccess;
//成功下载一个模块后界面显示数据设置
-(void)setUI:(int)module;

@end

static OfflineDownLoad *offlineDownLoad = nil;

@implementation OfflineDownLoad

@synthesize suspend           = _suspend;
@synthesize audioArr          = _audioArr;
@synthesize bytesArr          = _bytesArr;
@synthesize tempPath          = _tempPath;
@synthesize failedArr         = _failedArr;
@synthesize styleName         = _styleName;
@synthesize percentage        = _percentage;
@synthesize downloadArr       = _downloadArr;
@synthesize downloading       = _downloading;
@synthesize downModelNum      = _downModelNum;
@synthesize associateStop     = _associateStop;
//@synthesize isDownloading     = _isDownloading;
@synthesize totalCapacity     = _totalCapacity;
@synthesize downloadFinish    = _downloadFinish;
@synthesize successCapacity   = _successCapacity;
@synthesize downloadFinished  = _downloadFinished;
@synthesize progressCapacity  = _progressCapacity;
@synthesize associateDownload = _associateDownload;

- (void)dealloc
{
    [super dealloc];
}

+(OfflineDownLoad *)shareOfflineDownload
{
    @synchronized(self)
    {
        if (offlineDownLoad == nil)
        {
            offlineDownLoad = [[OfflineDownLoad alloc] init];
        }
        return offlineDownLoad;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        _bytesArr        = [[NSMutableArray alloc] init];
        _audioArr       = [[NSMutableArray alloc] init];
        _failedArr       = [[NSMutableArray alloc] init];
        _downloadArr     = [[NSMutableArray alloc] init];
        _photoArray      = [[NSMutableArray alloc] init];
        
        _tempPath        = [[NSString alloc] init];
        [self resetInitData];
    }
    return self;
}

//退出登录时重置数据
-(void)reset
{
    [_audioArr removeAllObjects];
    [_failedArr   removeAllObjects];
    [_photoArray  removeAllObjects];
    [_downloadArr removeAllObjects];
    [self resetInitData];
    [self resetDownlaodData];
}
//重置初始化数据
-(void)resetInitData
{
    startstyleDown      = NO;
    _suspend            = NO;
    _downloadFinished   = NO;
    _styleName          = @"文献";
    downloadStep        = DownLoadLocation_Blog_Photo_List;
    _percentage         = 0;
    downloadPhotoNum    = 0;
    _downModelNum       = 1;
}

//开始离线下载
-(void)startOfflineDownLoad
{
    [self resumeOfflineDownLoad];
}
//停止离线下载
-(void)stopOfflineDownLoad
{
    [self setsupendOfflineDownLoad];
    if (_downloadQueue)
    {
        [_downloadQueue reset];
        [_downloadQueue release];
        _downloadQueue = nil;
    }
    [self resetDownlaodData];
    _suspend = NO;
    _percentage = 0;
    NSError *error = nil;
    if (_tempPath.length != 0)
    {
        [[NSFileManager defaultManager] removeItemAtPath:_tempPath error:&error];
        _tempPath = nil;
    }
}

//网络切换或其他情况挂起下载
-(void)setsupendOfflineDownLoad
{
    _suspend = YES;
    _downloading = NO;
    CLEAR_REQUEST(httpRequest);
    CLEAR_REQUEST(formDataRequest);
    if (_downloadQueue)
    {
        [_downloadQueue setSuspended:YES];
    }
}

//回复挂起的下载
-(void)resumeOfflineDownLoad
{
    [self resetData];
    _downloading = YES;
    startstyleDown = NO;
    [self startNextReuqest:downloadStep];
}
//一个接口完成后调用另一个接口
-(void)startNextReuqest:(int)nextStep
{
    switch (nextStep)
    {
        case DownLoadLocation_Blog_Photo_List:
            [self getDiaryAndPhotoList];
            break;
        case DownLoadLocation_Blogs:
            [self getBlogs];
            break;
        case DownLoadLocation_Leave_Message:
            [self getLeaveMessage];
            break;
        case DownLoadLocation_Family_Tree:
            [self getFamilyTreeData];
            break;
        case DownLoadLocation_Photos_Urls:
            [self getPhotoUrls];
            break;
        case DownLoadLocation_Family_models_Info:
            [self getFamilyStyleInfo];
            break;
        case DownLoadLocation_Photos_DownLoad:
            [self startPhotoDownLoad];
            break;
        case DownLoadLocation_Style_Download:
            [self getStyleBoardDownload];
            break;
        case DownLoadLocation_Musics_Urls:
            [self getMusicUrls];
            break;
        case DownLoadLocation_Musics_Download:
            [self getMusic];
            break;
        case DownLoadLocation_Vedios_Urls:
            [self getVedioUrls];
            break;
        case DownLoadLocation_Vedio_Download:
            [self getVedio];
            break;
        case DownLoadLocation_Audio:
            [self getAudio];
        default:
            break;
    }
}

#pragma mark - RequestDelegate system and self
#pragma mark - ASIFormDataRequest

-(void)requestSuccess:(ASIFormDataRequest *)request
{
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSInteger tag = [request.userInfo[@"tag"] intValue];
    NSInteger success = [resultDictionary[@"success"] intValue];
    formDataRequest = nil;
    if (success == 1)
    {
        if (tag == REQUEST_FOR_GROUP)
        {
            NSMutableArray *dataArray = [NSMutableArray array];
            [dataArray setArray:[resultDictionary objectForKey:@"data"]];
            [StaticTools updateDiaryAndPhotoGroup:dataArray WithUserID:USERID];
            downloadStep = DownLoadLocation_Blogs;
        }
        if (tag == REQUEST_FOR_TEXT_GROUP)
        {
            [[NSUserDefaults standardUserDefaults] setValue:resultDictionary[@"meta"][@"serverversion"] forKey:DIARYVERSION];
            [DownlaodDebugging synsynchronizeBlogVersionStr:[NSString stringWithFormat:@"%@",[resultDictionary[@"meta"] objectForKey:@"serverversion"]] ClientVersionStr:[NSString stringWithFormat:@"%@",[resultDictionary[@"meta"] objectForKey:@"clientversion"]] Meta:nil synchronizeArr:(NSArray *)[resultDictionary objectForKey:@"data"]];
            downloadStep = DownLoadLocation_Leave_Message;
            self.downloadProgress(1.0f);
            _percentage = 1;
        }
        if (tag == REQUEST_FOR_LEAVE_MESSAGE)
        {
            downloadStep = DownLoadLocation_Family_Tree;
        }
        if (tag == REQUEST_FOR_FAMILY_TREE)
        {
            [MyFamilySQL addFamilyMembers:resultDictionary[@"data"] AndType:@"reAdd" WithUserID:USERID];
            NSArray *dataArr = (NSArray *)resultDictionary[@"data"];
            NSMutableArray *portraitArr = [NSMutableArray array];
            if (dataArr.count != 0)
            {
                for (int i = 0;  i < dataArr.count; i++)
                {
                    NSDictionary *dic = dataArr[i];
                    NSArray *members = dic[@"members"];
                    if (members.count != 0)
                    {
                        for (int j = 0;j < members.count ; j ++)
                        {
                            NSDictionary *memberDic = members[j];
                            if ([memberDic[@"headPortrait"] length] != 0)
                            {
                                [portraitArr addObject:memberDic[@"headPortrait"]];
                            }
                        }
                    }
                }
            }
            [_photoArray addObjectsFromArray:[DownlaodDebugging enumeratorHeadPortrait:portraitArr PortraitPathsWithBOOL:^BOOL(NSString *path){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL result = [fileManager fileExistsAtPath:path];
                return result;
            }]];
            downloadStep = DownLoadLocation_Photos_Urls;
            self.downloadProgress(1.0f);
            _percentage = 1;
        }
        if (tag == REQUEST_FOR_PHOTO_URLS)
        {
            photoVersion = [resultDictionary[@"meta"][@"serverversion"] intValue];
            NSArray *dataArray = (NSArray *)resultDictionary[@"data"];
            [StaticTools insertDBPhotos:dataArray];
            if (dataArray.count > 0)
            {
                NSMutableArray *thumbnail = [NSMutableArray array];
                NSMutableArray *attachURL = [NSMutableArray array];
                
                NSInteger count = dataArray.count;
                
                for (int i = 0; i < count; i++)
                {
                    [attachURL addObject:@[dataArray[i][@"attachURL"],dataArray[i][@"blogId"],@"attach",dataArray[i][@"photowall"]]];
                    [thumbnail addObject:@[dataArray[i][@"thumbnail"],dataArray[i][@"blogId"],@"thumb",dataArray[i][@"photowall"]]];
                    if ([dataArray[i][@"voiceURL"] length] != 0)
                    {
                        NSString *url = dataArray[i][@"voiceURL"];
                        NSString *filename = [[url componentsSeparatedByString:@"/"] lastObject];
                        NSString *path = [Utilities dataPath:filename FileType:@"Audioes" UserID:USERID];
                        if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO])
                        {
                            EMAudio *audio = [[EMAudio alloc] init];
                            audio.duration = [dataArray[i][@"duration"] intValue];
                            audio.size = [dataArray[i][@"voiceSize"] intValue];
                            audio.amrPath = path;
                            audio.audioURL = url;
                            audio.blogId = dataArray[i][@"blogId"];
                            audio.audioStatus = EMAudioSyncStatusNone;
                            [_audioArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:url,@"fullURL",[NSNumber numberWithLongLong:[dataArray[i][@"voiceSize"] longLongValue]],@"attachSize",filename,@"musicName",audio,@"audio" ,nil]];
                            [audio release];
                            //录音文件本地进行存储时需要的数据进行预先处理
                        }
                    }
                }
                [_photoArray addObjectsFromArray:[DownlaodDebugging enumeratorthumbnail:thumbnail  AttachURL:attachURL UserID:USERID imagePathsWithBOOL:^BOOL(NSString *path)
                                                  {
                                                      NSFileManager *fileManager = [NSFileManager defaultManager];
                                                      BOOL result = [fileManager  fileExistsAtPath:path isDirectory:NO];
                                                      return result;
                                                  }]];
            }
            downloadStep = DownLoadLocation_Family_models_Info;
        }
        if (tag == REQUEST_FOR_STYLE_INFO)
        {
            NSArray *dataArray = (NSArray *)resultDictionary[@"data"];
            [StyleListSQL saveAllStyleListData:(NSMutableArray *)dataArray andUid:PUBLICUID];
            NSMutableArray *styleImageArr = [NSMutableArray array];
            NSInteger count = dataArray.count;
            for (int i = 0; i < count; i++)
            {
                NSArray *stylesArr = (NSArray *)dataArray[i][@"styles"];
                NSInteger styleArrCount = stylesArr.count;
                for (int j = 0 ; j < styleArrCount; j++)
                {
                    [styleImageArr addObject:stylesArr[j][@"bigimagepath"]];
                    [styleImageArr addObject:stylesArr[j][@"thumbnail"]];
                }
            }
            [_photoArray addObjectsFromArray:[DownlaodDebugging enumeratorHeadPortrait:styleImageArr PortraitPathsWithBOOL:^BOOL(NSString *path){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL result = [fileManager fileExistsAtPath:path];
                return result;
            }]];
            downloadStep = DownLoadLocation_Photos_DownLoad;
        }
        if (tag == REQUEST_FOR_MUSIC_URL)
        {
            NSFileManager *fileManager=[NSFileManager defaultManager];
            NSError *error;
            if(![fileManager fileExistsAtPath:[CommonData getMusicTempFolderPath]])
            {
                [fileManager createDirectoryAtPath:[CommonData getMusicTempFolderPath] withIntermediateDirectories:YES attributes:nil error:&error];
            }
            NSArray *musicArray = (NSArray *)resultDictionary[@"data"];
            if (musicArray.count > 0)
            {
                [SavaData writeArrToFile:musicArray FileName:Music_File];
                [self resetDownlaodData];
                [_downloadArr addObjectsFromArray:[DownlaodDebugging enumerator:musicArray UserID:USERID musicPathsWithBOOL:^BOOL(NSString *path){
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL result = [fileManager  fileExistsAtPath:path isDirectory:NO];
                    return result;
                }]];
            }
            downloadStep = DownLoadLocation_Musics_Download;
        }
        if (tag == REQUEST_FOR_VEDIO_URL)
        {
            vedioVersion = [resultDictionary[@"meta"][@"serverversion"] intValue];
            NSFileManager *fileManager=[NSFileManager defaultManager];
            NSError *error;
            if(![fileManager fileExistsAtPath:[CommonData getMovieTempFolderPath]])
            {
                [fileManager createDirectoryAtPath:[CommonData getMovieTempFolderPath] withIntermediateDirectories:YES attributes:nil error:&error];
            }
            NSArray *vedioArray = (NSArray *)resultDictionary[@"data"];
            if (vedioArray.count > 0)
            {
                [self resetDownlaodData];
                [SavaData writeArrToFile:vedioArray FileName:Video_File];
                [_downloadArr addObjectsFromArray:[DownlaodDebugging enumerator:vedioArray UserID:USERID VedioPathsWithBOOL:^BOOL(NSString *path){
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL result = [fileManager  fileExistsAtPath:path];
                    return result;
                }]];
            }
            downloadStep = DownLoadLocation_Vedio_Download;
        }
        [self startNextReuqest:downloadStep];
    }
    else if (success == 0)
    {
        if ([resultDictionary[@"errorcode"] intValue] == 1005)
        {
            self.loginOtherPlace();
        }
        else
        {
            if (tag == REQUEST_FOR_LEAVE_MESSAGE)
            {
                downloadStep = DownLoadLocation_Family_Tree;
                [self getFamilyTreeData];
            }
        }
    }
}

-(void)requestFail:(ASIFormDataRequest *)request
{
    NSInteger tag = [request.userInfo[@"tag"] intValue];
    formDataRequest = nil;
    if (tag == REQUEST_FOR_GROUP)
    {
        downloadStep = DownLoadLocation_Blogs;
    }
    if (tag == REQUEST_FOR_TEXT_GROUP)
    {
        downloadStep = DownLoadLocation_Leave_Message;
    }
    if (tag == REQUEST_FOR_LEAVE_MESSAGE)
    {
        downloadStep = DownLoadLocation_Family_Tree;
    }
    if (tag == REQUEST_FOR_FAMILY_TREE)
    {
        //TODO:缓存
        downloadStep = DownLoadLocation_Photos_Urls;
    }
    if (tag == REQUEST_FOR_PHOTO_URLS)
    {
        downloadStep = DownLoadLocation_Family_models_Info;
    }
    if (tag == REQUEST_FOR_MUSIC_URL)
    {
        downloadStep = DownLoadLocation_Musics_Urls;
    }
    if (tag == REQUEST_FOR_VEDIO_URL)
    {
        downloadStep = DownLoadLocation_Vedios_Urls;
    }
    [self startNextReuqest:downloadStep];
}

#pragma mark - ASIHTTPRequest

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
}
-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    
}
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    NSInteger tag = [request.userInfo[@"tag"] intValue];
    if (_suspend == YES)
    {
    if (tag == REQUEST_FOR_STYLE_MODEL || tag == REQUEST_FOR_VEDIO_INFO || tag == REQUEST_FOR_MUSIC_INFO || tag == REQUEST_FOR_AUDIO_INFO)
    {
        _suspend = NO;
    }
    }
    else
    {
        if (bytes >= self.successCapacity)
        {
            self.progressCapacity += (bytes - self.successCapacity);
            self.successCapacity = bytes;
        }
        else
        {
            self.progressCapacity += bytes;
            self.successCapacity += bytes;
        }
        if (tag == REQUEST_FOR_VEDIO_INFO || tag == REQUEST_FOR_MUSIC_INFO || tag == REQUEST_FOR_STYLE_MODEL || tag == REQUEST_FOR_AUDIO_INFO)
        {
            self.downloadProgress(((float)self.progressCapacity)/self.totalCapacity);
            _percentage = ((float)self.progressCapacity)/self.totalCapacity;
        }
    }
}

-(void)httpRequestSucess:(ASIHTTPRequest *)request
{
    self.successCapacity = 0;
    NSInteger tag = [request.userInfo[@"tag"] intValue];
    
    if (tag == REQUEST_FOR_STYLE_MODEL)
    {
        [self setFaimilyStyleStorage:request.userInfo];
        [CommonData beginDecompressionFile:request.userInfo];
        downloadStep = DownLoadLocation_Musics_Urls;
    }
    if (tag == REQUEST_FOR_VEDIO_INFO)
    {
        [self setVedioInfoWithName:request.userInfo[@"blogId"] SuccessState:YES];
        [self setDataAfterDownloadSuccess];
        downloadStep = DownLoadLocation_Vedio_Download;
    }
    if (tag == REQUEST_FOR_MUSIC_INFO)
    {
        [self setDataAfterDownloadSuccess];
        downloadStep = DownLoadLocation_Musics_Download;
    }
    if (tag == REQUEST_FOR_AUDIO_INFO)
    {
        EMAudio *audio = request.userInfo[@"audio"];
        [MessageSQL updateAudio:audio forBlogid:audio.blogId];
        [self setDataAfterDownloadSuccess];
        downloadStep = DownLoadLocation_Audio;
    }
    [self startNextReuqest:downloadStep];
}

-(void)httpRequestFail:(ASIHTTPRequest *)request
{
    NSError *error = nil;
    if ([Utilities checkNetwork] == NO)
    {
        self.downloadProgress(((float)self.progressCapacity)/self.totalCapacity);
        _percentage = ((float)self.progressCapacity)/self.totalCapacity;
    }
    else
    {
        [[NSFileManager defaultManager] removeItemAtPath:_tempPath error:&error];
        [_tempPath release];
        _tempPath = nil;
        self.successCapacity = 0;
    }

    NSInteger tag = [request.userInfo[@"tag"] intValue];
    if (tag == REQUEST_FOR_STYLE_MODEL)
    {
        NSDictionary *dic = [[SavaData shareInstance] printDataDic:@"favoriteStyleDic"];
        NSString *homeUrl = dic[@"zippath"];
        NSString *typeStr = [[homeUrl componentsSeparatedByString:@"."] lastObject];
        [self setFailedarrStyle:@"family" Url:homeUrl FileName:dic[@"styleName"] FileType:typeStr Success:0 Size:[NSString stringWithFormat:@"%@",dic[@"filesize"]] Waiting:0];
        downloadStep = DownLoadLocation_Musics_Urls;
    }
    if(tag == REQUEST_FOR_MUSIC_INFO)
    {
        NSDictionary *dic = self.downloadArr[0];
        NSString *fileType = [[dic[@"fullURL"] componentsSeparatedByString:@"."] lastObject];
        NSString *fileName = dic[@"musicName"];
        [self setFailedarrStyle:@"music" Url:dic[@"fullURL"] FileName:fileName FileType:fileType Success:0 Size:[NSString stringWithFormat:@"%@",dic[@"attachSize"]] Waiting:0];
        self.totalCapacity -= [self.downloadArr[0][@"attachSize"] longLongValue];
        self.progressCapacity -= self.successCapacity;
        [self setDataAfterDownloadSuccess];
        downloadStep = DownLoadLocation_Musics_Download;
    }
    if (tag == REQUEST_FOR_AUDIO_INFO)
    {
        [request removeTemporaryDownloadFile];
        self.totalCapacity -= [self.downloadArr[0][@"attachSize"] longLongValue];
        self.progressCapacity -= self.successCapacity;
        [self setDataAfterDownloadSuccess];
        downloadStep = DownLoadLocation_Audio;
    }
    if (tag == REQUEST_FOR_VEDIO_INFO)
    {
        NSDictionary *dic = self.downloadArr[0];
        NSString *url = [CommonData getMovVideoPath:dic];//判断视频是否mov视频
        NSArray *tmpArr = [url componentsSeparatedByString:@"."];
        //文件类型
        NSString *fileType = [tmpArr lastObject];
        //文件名称
        NSString *fileName = dic[@"content"];
        
        if ([dic[@"attachURL"] length] > 10)
        {
            [self setFailedarrStyle:@"vedio" Url:url FileName:fileName FileType:fileType Success:0 Size:[NSString stringWithFormat:@"%@",dic[@"attachSize"]] Waiting:0];
            self.totalCapacity -= [self.downloadArr[0][@"attachSize"] longLongValue];
        }
        else if ([dic[@"transcodingState"] intValue] == 3 && [dic[@"transcodingURL"] length] > 0)
        {
            [self setFailedarrStyle:@"vedio" Url:url FileName:fileName FileType:fileType Success:0 Size:[NSString stringWithFormat:@"%@",dic[@"transcodingSize"]] Waiting:0];
            self.totalCapacity -= [self.downloadArr[0][@"attachSize"] longLongValue];
        }
        self.progressCapacity -= self.successCapacity;
        [self setVedioInfoWithName:request.userInfo[@"blogId"] SuccessState:NO];
        [self setDataAfterDownloadSuccess];
        downloadStep = DownLoadLocation_Vedio_Download;
    }
    [self startNextReuqest:downloadStep];
    self.downloadFailed();
}

-(void)selfRequestFinish:(ASIFormDataRequest *)formRequest
{
    __block typeof (self) this=self;
    [formRequest setCompletionBlock:^{
        [this requestSuccess:formRequest];
    }];
    [formRequest setFailedBlock:^{
        [this requestFail:formRequest];
    }];
}

#pragma mark - Download Picture Finish or Fail
- (void)imageFatchComplete:(ASIHTTPRequest *)request
{
    if ([request.userInfo[@"type"] isEqualToString:@"photo"])
    {
        if ([request.userInfo[@"kind"] isEqualToString:@"attach"])
        {
            if ([request.userInfo[@"photowall"] intValue] == 0)
            {
                [MessageSQL updataPathForImageURL:request.userInfo[@"attachURL"] withPath:request.userInfo[@"path"] WithUserID:USERID
                 ];
            }
            else
            {
                NSString *fileName = [request.userInfo[@"path"] lastPathComponent];
                NSString *filePaths = [request.userInfo[@"path"] stringByDeletingLastPathComponent];
                NSString *fileFolder = [filePaths lastPathComponent];
                NSString *relativePath = [NSString stringWithFormat:@"Library/ETMemory/AllLifeMemo/%@/%@/%@",USERID,fileFolder,fileName];
                [EMAllLifeMemoDAO updateMemoPath:relativePath forPhotoWall:request.userInfo[@"photowall"]];
            }
        }
        else if ([request.userInfo[@"kind"] isEqualToString:@"thumb"])
        {
            [MessageSQL updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
                NSString *u_sql = [NSString stringWithFormat:@"update %@ set spaths = ? where blogId = ?", tableName];
                [db executeUpdate:u_sql, request.userInfo[@"path"], request.userInfo[@"blogId"]];
            } WithUserID:USERID];
        }
    }
    [self setPhotoDownload:request];
}
- (void)imageFatchFailed:(ASIHTTPRequest *)request
{
    [_failedArr addObject:request];
    [self setPhotoDownload:request];
}
//一张图片下载完成之后的操作（包括图片下载成功和失败两种情况）
-(void)setPhotoDownload:(ASIHTTPRequest *)request
{
    downloadPhotoNum ++;
    self.downloadProgress(((float)downloadPhotoNum)/photoTotalNum);
    _percentage = ((float)downloadPhotoNum)/photoTotalNum;
    [_photoArray removeObject:request.userInfo[@"object"]];
    if (_photoArray.count == 0)
    {
        if (_failedArr.count != 0 && startFailedPhotoDownLoad == NO)
        {
            [self startFailedPhotoDownLoad];
        }
        else
        {
            downloadStep = DownLoadLocation_Style_Download;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:photoVersion] forKey:PHOTOVERSION];
            [self getStyleBoardDownload];
        }
    }
}

#pragma mark - InterFace 接口调用

//获取文献内容
- (void)getBlogs
{
    [self setUI:1];
    NSURL *registerUrl = [[RequestParams sharedInstance] getAllBlogs];
    formDataRequest = [ASIFormDataRequest requestWithURL:registerUrl];
    [formDataRequest setPostValue:@"getall" forKey:@"getall"];
    [formDataRequest setPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:DIARYVERSION] forKey:@"clientversion"];
    [self startRequestWithType:REQUEST_FOR_TEXT_GROUP];
}

//获取家园留言
-(void)getLeaveMessage
{
    NSURL *registerUrl = [[RequestParams sharedInstance] leaveMessage];
    formDataRequest = [ASIFormDataRequest requestWithURL:registerUrl];
    [formDataRequest setPostValue:@"list" forKey:@"flag"];
    [formDataRequest setPostValue:[[SavaData shareInstance] printDataStr:USER_ID_SAVA] forKey:@"userid"];
    [[SavaData shareInstance] printDataStr:USER_ID_SAVA];
    [self startRequestWithType:REQUEST_FOR_LEAVE_MESSAGE];
}

//获取文献、相册列表
-(void)getDiaryAndPhotoList
{
    NSURL *registerUrl = [[RequestParams sharedInstance] manageGroup];
    formDataRequest = [ASIFormDataRequest requestWithURL:registerUrl];
    [formDataRequest setPostValue:@"list" forKey:@"operation"];
    [self startRequestWithType:REQUEST_FOR_GROUP];
}

//获取家谱内容
- (void)getFamilyTreeData
{
    [self setUI:2];
    NSURL *familyUrl = [[RequestParams sharedInstance] newFamilyTree];
    formDataRequest = [ASIFormDataRequest requestWithURL:familyUrl];
    [formDataRequest setPostValue:@"level" forKey:@"struct"];
    [self startRequestWithType:REQUEST_FOR_FAMILY_TREE];
}

//获取相册中图片的地址
-(void)getPhotoUrls
{
    self.downloadProgress(0);
    _percentage = 0;
    [self setUI:3];
    NSURL *url = [[RequestParams sharedInstance] photolist];
    formDataRequest = [ASIFormDataRequest requestWithURL:url];
    [formDataRequest setPostValue:@"-2" forKey:@"groupid"];
    [formDataRequest setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:PHOTOVERSION] forKey:@"clientversion"];
    [self startRequestWithType:REQUEST_FOR_PHOTO_URLS];
}
//获取家园风格列表数据和图片地址
-(void)getFamilyStyleInfo
{
    NSURL *url = [[RequestParams sharedInstance] getHomeStyleList];
    formDataRequest = [ASIFormDataRequest requestWithURL:url];
    [formDataRequest setPostValue:@"typelist" forKey:@"operation"];
    [self startRequestWithType:REQUEST_FOR_STYLE_INFO];
}

//获取视频下载需要的数据
-(void)getVedioUrls
{
    NSURL *url = [[RequestParams sharedInstance] listVideoLockAction];
    formDataRequest = [ASIFormDataRequest requestWithURL:url];
    [formDataRequest setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:VEDIOVERSION] forKey:@"clientversion"];
    [self startRequestWithType:REQUEST_FOR_VEDIO_URL];
}
//获取音频下载需要的数据
-(void)getMusicUrls
{
    NSURL *url = [[RequestParams sharedInstance] didMusicManageAction];
    formDataRequest = [ASIFormDataRequest requestWithURL:url];
    [formDataRequest setPostValue:@"list" forKey:@"operation"];
    [formDataRequest setShouldAttemptPersistentConnection:NO];
    [self startRequestWithType:REQUEST_FOR_MUSIC_URL];
}

//下载音频
-(void)getMusic
{
    if ([Utilities checkNetwork] == NO)
    {
        return;
    }
    [self setUI:5];
    if (self.downloadArr.count > 0)
    {
        if (_totalCapacity == 0)
        {
            _totalCapacity = [DownlaodDebugging setMusicDownLoadDataWithConfigurationArr:_downloadArr BytesArr:_bytesArr];
        }
        
        NSDictionary *dic = self.downloadArr[0];
        NSString *fileType = [[dic[@"fullURL"] componentsSeparatedByString:@"."] lastObject];
        NSString *fileName = dic[@"musicName"];
        //开启下载
        CLEAR_REQUEST(httpRequest);
        httpRequest=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:dic[@"fullURL"]]];
        [DownlaodDebugging setRequest:httpRequest userInfo:dic UserID:USERID fileName:fileName fileType:fileType Tag:REQUEST_FOR_MUSIC_INFO Type:FileTypeMusic];
        self.tempPath = httpRequest.temporaryFileDownloadPath;
        [DownlaodDebugging setHttpRequestConfigure:httpRequest Handler:self];
        [httpRequest startAsynchronous];
    }
    else
    {
        formDataRequest = nil;
        downloadStep = DownLoadLocation_Audio;
        [_downloadArr removeAllObjects];
        [_downloadArr addObjectsFromArray:_audioArr];
        [self resetDownlaodData];
        [self getAudio];
    }
}

//下载录音
-(void)getAudio
{
    if ([Utilities checkNetwork] == NO)
    {
        return;
    }
    [self setUI:7];
    if (self.downloadArr.count > 0)
    {
        if (_totalCapacity == 0)
        {
            _totalCapacity = [DownlaodDebugging setMusicDownLoadDataWithConfigurationArr:_downloadArr BytesArr:_bytesArr];
        }
        NSDictionary *dic = self.downloadArr[0];
        NSString *fileType = [[dic[@"fullURL"] componentsSeparatedByString:@"."] lastObject];
        NSString *fileName = [[dic[@"musicName"] componentsSeparatedByString:@"."] firstObject];
        
        //开启下载
        CLEAR_REQUEST(httpRequest);
        httpRequest=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:dic[@"fullURL"]]];
        [DownlaodDebugging setRequest:httpRequest userInfo:dic UserID:USERID fileName:fileName fileType:fileType Tag:REQUEST_FOR_AUDIO_INFO Type:FileTypeAudio];
        self.tempPath = httpRequest.temporaryFileDownloadPath;
        [DownlaodDebugging setHttpRequestConfigure:httpRequest Handler:self];
        [httpRequest startAsynchronous];
    }
    else
    {
        formDataRequest = nil;
        downloadStep = DownLoadLocation_Vedios_Urls;
        [self getVedioUrls];
    }
}

//下载视频
-(void)getVedio
{
    if ([Utilities checkNetwork] == NO)
    {
        return;
    }
    [self setUI:6];
    if (self.downloadArr.count > 0)
    {
        if (_totalCapacity == 0)
        {
            _totalCapacity = [DownlaodDebugging setVedioDownLoadDataWithConfigurationArr:_downloadArr BytesArr:_bytesArr];
        }
        NSDictionary *dic = self.downloadArr[0];
        
        NSString *url = nil;
        
        if ([dic[@"attachURL"] length] > 0)
        {
            url = dic[@"attachURL"];

        }
        else if ([dic[@"transcodingState"] intValue] == 3 && [dic[@"transcodingURL"] length] > 0)
        {
           url = dic[@"transcodingURL"];
        }
        NSArray *tmpArr = [url componentsSeparatedByString:@"."];
        //文件类型
        NSString *fileType = [tmpArr lastObject];
        //文件名称
        NSString *fileName = dic[@"content"];
        //开启下载
        CLEAR_REQUEST(httpRequest);
        httpRequest=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
        [DownlaodDebugging setRequest:httpRequest userInfo:dic UserID:USERID fileName:fileName fileType:fileType Tag:REQUEST_FOR_VEDIO_INFO Type:FileTypeVedio];
        self.tempPath = httpRequest.temporaryFileDownloadPath;
        [DownlaodDebugging setHttpRequestConfigure:httpRequest Handler:self];
        [httpRequest startAsynchronous];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:vedioVersion] forKey:VEDIOVERSION];
        self.downloadProgress(1);
        _percentage = 1;
        _downloadFinished = YES;
        _downloading = NO;
        self.downloadFinish();
    }
}

//获取默认风格
-(void)getStyleBoardDownload
{
    if ([Utilities checkNetwork] == NO)
    {
        return;
    }
    [_failedArr removeAllObjects];
    if (startstyleDown == NO)
    {
        startstyleDown = YES;
        [self setUI:4];
        NSDictionary *dic = [[SavaData shareInstance] printDataDic:@"favoriteStyleDic"];
        if ([dic[@"styleId"] intValue] == 2 || downloadStep >= DownLoadLocation_Musics_Urls)
        {
            if (downloadStep == DownLoadLocation_Photos_DownLoad)
            {
                downloadStep = DownLoadLocation_Musics_Urls;
            }
            [self getMusicUrls];
            return;
        }
        else
        {
            self.totalCapacity = [dic[@"filesize"] longLongValue];
            [StyleListSQL addDownLoadList:[dic[@"styleId"] integerValue]];
            NSString *homeUrl = dic[@"zippath"];
            NSString *typeStr = [[homeUrl componentsSeparatedByString:@"."] lastObject];

            NSString *styleName = [NSString stringWithFormat:@"style%d",[dic[@"styleId"] intValue]];
            NSString *judgeStr = [NSString stringWithFormat:@"style%d.html",[dic[@"styleId"] intValue]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:[[[CommonData getZipFilePathManager] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",styleName]] stringByAppendingPathComponent:judgeStr]])
            {
                NSFileManager *fileHome = [NSFileManager defaultManager];
                //创建下载临时文件
                if(![fileHome fileExistsAtPath:[CommonData getTempFolderPath]])
                {
                    [fileHome createDirectoryAtPath:[CommonData getTempFolderPath] withIntermediateDirectories:YES attributes:nil error:nil];
                }
                CLEAR_REQUEST(httpRequest);
                httpRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:homeUrl]];
                [DownlaodDebugging setRequest:httpRequest userInfo:dic UserID:USERID fileName:styleName fileType:typeStr Tag:REQUEST_FOR_STYLE_MODEL Type:FileTypeStyle];
                self.tempPath = httpRequest.temporaryFileDownloadPath;
                [DownlaodDebugging setHttpRequestConfigure:httpRequest Handler:self];
                [httpRequest startAsynchronous];
            }
            else
            {
                [self setFaimilyStyleStorage:dic];
                downloadStep = DownLoadLocation_Musics_Urls;
                [self getMusicUrls];
            }
        }
    }
}

//设置请求的公共数据
-(void)startRequestWithType:(NSInteger)type
{
    if ([Utilities checkNetwork] == NO)
    {
        return;
    }
    else
    {
        [formDataRequest setShouldAttemptPersistentConnection:NO];
        [RequestParams setRequestCommonData:formDataRequest];
        formDataRequest.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:type],@"tag", nil];
        [self selfRequestFinish:formDataRequest];
        [formDataRequest startAsynchronous];
    }
}

//下载模块转换时重置下载进度的相关数据配置（下载大小、已接受数据大小等）
-(void)resetDownlaodData
{
    [_bytesArr removeAllObjects];
    _totalCapacity = 0;
    _progressCapacity = 0;
    _successCapacity = 0;
}

//成功下载一个文件后数据配置
-(void)setDataAfterDownloadSuccess
{
    if (self.downloadArr.count != 0)
    {
        [self.downloadArr removeObjectAtIndex:0];
        [self.bytesArr removeObjectAtIndex:0];
    }
    httpRequest = nil;
}
//成功下载一个模块后界面显示数据设置
-(void)setUI:(int)module
{
    __block NSString *moduleName = nil;
    switch (module)
    {
        case 1:
            moduleName = @"文献";
            break;
        case 2:
            moduleName = @"家谱";
            break;
        case 3:
            moduleName = @"相册";
            break;
        case 4:

            moduleName = @"家园风格";
            break;
        case 5:
            moduleName = @"音频";
            break;
        case 6:
            module ++;
            moduleName = @"视频";
            break;
        case 7:
            module = 6;
            moduleName = @"录音";
            break;
        default:
            break;
    }
    self.downloadName(moduleName,module);
    self.styleName = moduleName;
    self.downModelNum = module;
}

//启动图片下载
-(void)startPhotoDownLoad
{
    if (_downloadQueue != nil)
    {
        if (_downloadQueue.operations.count > 0)
        {
            [_downloadQueue go];
        }
        else
        {
            downloadStep = DownLoadLocation_Style_Download;
            [self getStyleBoardDownload];
        }
        return;
    }
    else
    {
    NSInteger count = _photoArray.count;
    downloadPhotoNum = 0;
    photoTotalNum = _photoArray.count;
    if (count > 0)
    {
        if (_downloadQueue == nil)
        {
            _downloadQueue =[DownlaodDebugging initQueueFinish:@selector(imageFatchComplete:) Failed:@selector(imageFatchFailed:) Delegte:self];
        }
       [DownlaodDebugging setQueue:_downloadQueue PhotosArray:_photoArray];
        
    if (_downloadQueue.operations.count > 0)
    {
        [_downloadQueue go];
    }
    }
    else
    {
        downloadStep = DownLoadLocation_Style_Download;
        [self getStyleBoardDownload];
    }
    }
}

//启动失败图片下载
-(void)startFailedPhotoDownLoad
{
    if ([Utilities checkNetwork] == NO)
    {
        return;
    }
    else
    {
    if (startFailedPhotoDownLoad == NO)
    {
        startFailedPhotoDownLoad = YES;
    if (_downloadQueue)
    {
        [_downloadQueue reset];
        [_downloadQueue release];
        _downloadQueue = nil;
    }
    _downloadQueue =[DownlaodDebugging initQueueFinish:@selector(imageFatchComplete:) Failed:@selector(imageFatchFailed:) Delegte:self];
    NSInteger count = _failedArr.count;
    [_photoArray removeAllObjects];
    for (int i = 0; i < count; i++)
    {
        ASIHTTPRequest *downloadImageRequest = (ASIHTTPRequest *)_failedArr[i];
        ASIHTTPRequest  *failedDownloadImageRequest = [[ASIHTTPRequest alloc] initWithURL:downloadImageRequest.url];
        failedDownloadImageRequest.userInfo = downloadImageRequest.userInfo;
        if ([failedDownloadImageRequest.userInfo[@"type"] isEqualToString:@"photo"])
        {
            [failedDownloadImageRequest setDownloadDestinationPath:downloadImageRequest.userInfo[@"path"]];
        }
        else
        {
            [failedDownloadImageRequest setDownloadDestinationPath:downloadImageRequest.userInfo[@"object"][@"data"][1]];
        }
        [_photoArray addObject:failedDownloadImageRequest.userInfo[@"object"]];
        [_downloadQueue addOperation:failedDownloadImageRequest];
        [failedDownloadImageRequest release];
    }
    [_failedArr removeAllObjects];
    if (_downloadQueue.operations.count > 0)
    {
        downloadPhotoNum = 0;
        photoTotalNum = _photoArray.count;
        [_downloadQueue go];
    }
    else
    {
        downloadStep = DownLoadLocation_Style_Download;
        [_failedArr removeAllObjects];
        [self getStyleBoardDownload];
    }
    }
    }
}

//异号登陆重新设置数据
-(void)resetData
{
    if (_failedArr == nil)
    {
        _failedArr = [[NSMutableArray alloc] init];
    }
    if (_styleName == nil)
    {
        _styleName = [[NSString alloc] init];
    }
    if (_tempPath == nil)
    {
        _tempPath = [[NSString alloc] init];
    }
    if (_photoArray == nil)
    {
        _photoArray = [[NSMutableArray alloc] init];
    }
    if (_bytesArr == nil)
    {
        _bytesArr = [[NSMutableArray alloc] init];
    }
    if (_downloadArr == nil)
    {
        _downloadArr = [[NSMutableArray alloc] init];
    }
    if (_successDownArr == nil)
    {
        _successDownArr = [[NSMutableArray alloc] init];
    }
    if (_audioArr == nil)
    {
        _audioArr = [[NSMutableArray alloc] init];
    }
}

//下载完成清理数据
-(void)clearData
{
    RELEASE_SAFELY(_failedArr);
    RELEASE_SAFELY(_styleName);
    RELEASE_SAFELY(_tempPath);
    RELEASE_SAFELY(_photoArray);
    RELEASE_SAFELY(_bytesArr);
    RELEASE_SAFELY(_downloadArr);
    RELEASE_SAFELY(_successDownArr);
    
//    Block_release(_downloadProgress);
//    Block_release(_downloadName);
//    Block_release(_downloadFailed);
//    Block_release(_downloadFinish);
}

//视频文件下载成功失败处理
-(void)setVedioInfoWithName:(NSString *)name SuccessState:(BOOL)state
{
    NSMutableArray *VideoArr = [SavaData parseArrFromFile:Video_File];
    NSInteger count = VideoArr.count;
    for (int i = 0; i < count; i++)
    {
        NSMutableDictionary *dic = VideoArr[i];
        if ([dic[@"blogId"] isEqualToString:name])
        {
            if (state == YES)
            {
                [dic setObject:[NSNumber numberWithInt:1] forKey:@"exist"];
            }
            else
            {
                [dic setObject:[NSNumber numberWithInt:0] forKey:@"exist"];
            }
            [VideoArr replaceObjectAtIndex:i withObject:dic];
            break;
        }
    }
    [SavaData writeArrToFile:VideoArr FileName:Video_File];
}

//设置家园模板的存储
-(void)setFaimilyStyleStorage:(NSDictionary *)dic
{
    [StyleListSQL updateDownLoadState:[dic[@"styleId"] integerValue]];
    //在模板页面下载，删除zip压缩文件，并解压
    [[SavaData shareInstance] savadataStr:[NSString stringWithFormat:@"style%d",[dic[@"styleId"] integerValue]] KeyString:@"styleId"];
    //下载完成后再进家园保存选中的风格ID
    [[SavaData shareInstance] savadataStr:dic[@"styleId"] KeyString:[NSString stringWithFormat:@"%@homeStyle",PUBLICUID]];
    //根据返回的style规律来确定几套模板>> zipname = style3;
    NSString *specificStyle = dic[@"zipname"];
    specificStyle = [specificStyle substringToIndex:specificStyle.length - 4];
    [[SavaData shareInstance] savadataStr:specificStyle KeyString:@"specificStyle"];
}

//设置失败数组的字典元素数据
-(void)setFailedarrStyle:(NSString *)style Url:(NSString *)url FileName:(NSString *)fileName FileType:(NSString*)fileType Success:(NSInteger)success Size:(NSString *)size Waiting:(NSInteger)waiting
{
    [self.failedArr addObject:@{@"style": style,@"url":url,@"fileName":fileName,@"fileType":fileType,@"success":[NSNumber numberWithInt:success],@"size":size,@"waiting":[NSNumber numberWithInt:waiting]}];
}

@end
