//
//  AssociatedDownLoadController.m
//  EternalMemory
//
//  Created by xiaoxiao on 1/13/14.
//  Copyright (c) 2014 sun. All rights reserved.
//
#import "DiaryPictureClassificationSQL.h"
#import "AssociatedDownLoadController.h"
#import "DownlaodDebugging.h"
#import "DiaryMessageModel.h"
#import "ASINetworkQueue.h"
#import "AssociatedModel.h"
#import "DiaryMessageSQL.h"
#import "OfflineDownLoad.h"
#import "DiaryGroupsSQL.h"
#import "AssociatedCell.h"
#import "RequestParams.h"
#import "MessageModel.h"
#import "StyleListSQL.h"
#import "MyFamilySQL.h"
#import "StaticTools.h"
#import "MessageSQL.h"
#import "CommonData.h"
#import "ZipArchive.h"
#import "Utilities.h"
#import "MyToast.h"
#import "EMAudio.h"
#import "MD5.h"
@interface AssociatedDownLoadController ()
{
    UILabel                 *warningNameLabel;
    UITableView             *associatedTableView;
    ASIFormDataRequest      *formDataRequest;
    ASIHTTPRequest          *httpRequest;
    NSString                *originUserID;//用户的真实ID
    NSString                *_dataUserID;//存数据库使用的dataUserId
    
    NSMutableArray          *_photoArray;//存放所有图片的url地址
    NSMutableArray          *_audioArray;//存放用户的录音文件
    NSMutableArray          *_musicArr;//音频、视频信息
    NSMutableArray          *_vedioArr;//音频、视频信息
    ASINetworkQueue         *_downloadQueue;//图片下载序列
    
    
    __block NSInteger        downloadPhotoNum;//图片不断下载完成个数
    __block NSInteger        photoTotalNum;   //图片总个数
    long long int            totalCapacity;
    long long int            successCapacity;
    long long int            progressCapacity;
    NSInteger                downloadingIndex;//正在下载的cell
    NSInteger                downLoadStep;//停止后继续时开始的接口位置
    NSMutableArray          *bytesArr;//防止失败数据的错误
    NSDictionary            *styleDic;//风格模板
}

@property(nonatomic,copy)  NSString        *tempPath;
@property(nonatomic,copy)  NSString        *dataUserID;

-(void)initWarningView;


//开始下载
-(void)startDownloading:(int)index;
//开启等待下载
-(void)startWaitingDondload;

//开始音频、视频下载
-(void)starMusicOrVideoDownload;

//暂停后继续下载
-(void)resumeDownloading;
//下载中进度条控制
-(void)setProgressAtIndex:(int)index Recieved:(long long int)receiveData TotalData:(long long int)totalData;

//删除关联人员的相关数据
-(void)removeAssocaitedMemberData;

//将下载完成的关联人员信息存储到本地
-(void)saveAssociatedInfo:(AssociatedModel *)data;
//取消下载删除之前关联过的成员的信息
-(void)removeAssocaitedInfo:(AssociatedModel *)data;
//设置关联成员下载状态
-(void)setDownloadState:(int)index;
//取消下载
-(void)cancelDownload:(int)index;
//下载音乐模块设置
-(void)setMusicInfo;
//下载录音模块设置
-(void)setAudioInfo;
//下载视频模块设置
-(void)setVedioInfo;
//设置家园模板下载
-(void)startStyledownload;
//开始音频下载
-(void)startMusicdownload;
//开始录音下载
-(void)startAudiodownload;
//开始视频下载
-(void)startVediodownload;
@end


#define ASSOCIATED_USER_ALL_INFO    10000
#define REQUEST_FOR_VEDIO_INFO      20000
#define REQUEST_FOR_MUSIC_INFO      30000
#define REQUEST_FOR_STYLE_MODEL     40000
#define REQUEST_FOR_AUDIO           80000


#define ALERT_TAG_CANCEL_DOWNLOAD   50000
#define ALERT_TAG_SKIP              50001

#define offLine         [OfflineDownLoad shareOfflineDownload]



@implementation AssociatedDownLoadController

@synthesize associatedArray = _associatedArray;
@synthesize dataUserID = _dataUserID;

- (void)dealloc
{
    if (_associatedArray) {
        [_associatedArray release];
        _associatedArray = nil;
    }
    RELEASE_SAFELY(_photoArray);
    RELEASE_SAFELY(_musicArr);
    RELEASE_SAFELY(_vedioArr);
    RELEASE_SAFELY(_audioArray);
    if (bytesArr)
    {
        RELEASE_SAFELY(bytesArr);
    }
    if (styleDic)
    {
        RELEASE_SAFELY(styleDic);
    }
    RELEASE_SAFELY(originUserID);
    CLEAR_REQUEST(formDataRequest);
    CLEAR_REQUEST(httpRequest);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    UIView *whiteBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 225)];
    whiteBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteBgView];
    [whiteBgView release];
    [self initWarningView];
    CGFloat originY = iPhone5 ? 194 : 180;
    warningNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,originY, 320, 20)];
    warningNameLabel.text = [NSString stringWithFormat:@"共有7项，请选择关联人员开始下载"];
    warningNameLabel.textColor = [UIColor grayColor];
    warningNameLabel.backgroundColor = [UIColor clearColor];
    warningNameLabel.textAlignment = NSTextAlignmentCenter;
    warningNameLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.view addSubview:warningNameLabel];
    [warningNameLabel release];
    
    associatedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 235, 320, SCREEN_HEIGHT - 235) style:UITableViewStylePlain];
    associatedTableView.delegate =self;
    associatedTableView.dataSource = self;
    associatedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    associatedTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:associatedTableView];
    [associatedTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backBtn.hidden = YES;
    self.middleBtn.hidden = YES;
    self.titleLabel.text = @"关联用户资料";
    self.rightBtn.frame=CGRectMake(SCREEN_WIDTH - 72, 6, 60, 31);
    if (iOS7) {
        self.rightBtn.frame=CGRectMake(SCREEN_WIDTH - 72, 26, 60, 31);
    }
    [self.rightBtn setTitle:@"我的家园" forState:UIControlStateNormal];
	// Do any additional setup after loading the view.
}

-(void)initWarningView
{
    CGFloat originY = iPhone5? 95 : 75;

    UIView *showBgView = [[UIView alloc] initWithFrame:CGRectMake(0, originY, 320, 90)];
    showBgView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake(30, 5, 60, 42)];
    imageView.image = [UIImage imageNamed:@"yuncai@2x"];
    [showBgView addSubview:imageView];
    [imageView release];
    
    UILabel *downLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 210, 20)];
    downLabel.backgroundColor = [UIColor clearColor];
    downLabel.textColor = [UIColor colorWithRed:52.0f/255.0f green:130.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
    downLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
    downLabel.text = @"以下是您家谱中关联的用户";
    [showBgView addSubview:downLabel];
    [downLabel release];
    
    UILabel *warningLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 27, 200, 15)];
    warningLabel1.backgroundColor = [UIColor clearColor];
    warningLabel1.textColor = [UIColor colorWithRed:52.0f/255.0f green:130.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
    warningLabel1.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0f];
    warningLabel1.text = @"点击下载他们的全部资料";
    [showBgView addSubview:warningLabel1];
    [warningLabel1 release];
    
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 45, 200, 15)];
    warningLabel.backgroundColor = [UIColor clearColor];
    warningLabel.textColor = [UIColor colorWithRed:108.0f/255.0f green:108.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
    warningLabel.font = [UIFont systemFontOfSize:13.0f];
    warningLabel.text = @"所有内容下载到本地后观看";
    [showBgView addSubview:warningLabel];
    [warningLabel release];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 320, 15)];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = [UIColor colorWithRed:108.0f/255.0f green:108.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
    contentLabel.text = @"(文献、家谱、相册、家园风格、音频、录音、视频)";
    contentLabel.font = [UIFont systemFontOfSize:13.0f];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    [showBgView addSubview:contentLabel];
    [contentLabel release];
    [self.view addSubview:showBgView];
    [showBgView release];
    
    UIImageView *separateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 225, 320, 10)];
    separateImageView.image = [UIImage imageNamed:@"offline_separator_bg@2x"];
    [self.view addSubview:separateImageView];
    [separateImageView release];
}
- (void)rightBtnPressed
{
    if (offLine.associateDownload == YES)
    {
        CLEAR_REQUEST(formDataRequest);
        CLEAR_REQUEST(httpRequest);
        if (_downloadQueue)
        {
            [_downloadQueue setSuspended:YES];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"检测到有正在下载的资料，是否取消下载进入家园？" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        alertView.tag = ALERT_TAG_SKIP;
        [alertView show];
        [alertView release];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"assocaitedDownloadSuccess" object:nil];
    }
}

#pragma mark -UITableViewDelegate And DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _associatedArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *associatedString = @"associtedString";
    AssociatedCell *associatedCell = [tableView dequeueReusableCellWithIdentifier:associatedString];
    if (associatedCell == nil)
    {
        associatedCell = [[AssociatedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:associatedString];
    }
    AssociatedModel *data = self.associatedArray[indexPath.row];
    associatedCell.nameLabel.text = data.name;
    associatedCell.nameLabel.tag = indexPath.row;
    [associatedCell setWaitingLoad:data.downloadState];
    associatedCell.numberLabel.text = [NSString stringWithFormat:@"%d",(indexPath.row + 1)];
    associatedCell.progressView.percentageLabel.tag = indexPath.row;
    associatedCell.relationLabel.text = [NSString stringWithFormat:@"与您的关系是:%@",data.relation];
    __block typeof(self) this = self;
    associatedCell.progressView.cancelDownload = ^(int index){
        [this cancelDownload:index];
    };
    
    associatedCell.downloadEvent = ^(int index){
        [this setDownloadState:index];
    };
    associatedCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return associatedCell;
}
//取消下载
-(void)cancelDownload:(int)index
{
    downloadingIndex = index;
    CLEAR_REQUEST(formDataRequest);
    CLEAR_REQUEST(httpRequest);
    if (_downloadQueue)
    {
        [_downloadQueue setSuspended:YES];
    }

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"取消下载将删除正在下载的成员资料" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = ALERT_TAG_CANCEL_DOWNLOAD;
    [alertView show];
    [alertView release];
}

//设置关联成员下载状态
-(void)setDownloadState:(int)index
{
    AssociatedModel *data = _associatedArray[index];
    if (data.downloadState == 3)
    {
        [MyToast showWithText:@"该用户信息已下载完成" :200];
        return;
    }
    else if (data.downloadState == 2)
    {
        data.downloadState = 0;
        [associatedTableView reloadData];
        return;
    }
    [BaseDatas createAssocaitedDB:data.associateUserId];
    if (offLine.associateDownload == YES)
    {
        if (data.downloadState == 0)
        {
            data.downloadState = 2;
        }
        else if (data.downloadState == 1)
        {
        }
        else if (data.downloadState == 3)
        {
            data.downloadState = 0;
        }
    }
    else
    {
        if (data.downloadState == 0)
        {
            if ([Utilities checkNetwork])
            {
                [self startDownloading:index];
            }
            else
            {
                [MyToast showWithText:@"网络异常请检查网络" :200];
            }
        }
        if (data.downloadState == 2)
        {
            data.downloadState = 0;
        }
    }
    [associatedTableView reloadData];
}

//开始下载
-(void)startDownloading:(int)index
{
    AssociatedModel *data = _associatedArray[index];
    downloadingIndex = index;
    if (_photoArray == nil)
    {
        _photoArray = [[NSMutableArray alloc] init];
    }
    [_photoArray removeAllObjects];
    if (_musicArr == nil)
    {
        _musicArr = [[NSMutableArray alloc] init];
    }
    [_musicArr removeAllObjects];
    if (_vedioArr == nil)
    {
        _vedioArr = [[NSMutableArray alloc] init];
    }
    [_vedioArr removeAllObjects];
    if (_audioArray == nil)
    {
        _audioArray = [[NSMutableArray alloc] init];
    }
    [_audioArray removeAllObjects];
    warningNameLabel.text = [NSString stringWithFormat:@"共有7项，正在下载第1项(文献)"];
    self.dataUserID = data.associateUserId;
    data.downloadState = 1;
    formDataRequest = [ASIFormDataRequest requestWithURL:[[RequestParams sharedInstance] getAssociatedData]];
    [formDataRequest setRequestMethod:@"POST"];
    [formDataRequest setShouldAttemptPersistentConnection:NO];
    [formDataRequest setPostValue:@"ios" forKey:@"platform"];
    [formDataRequest setPostValue:data.authCode forKey:@"authcode"];
    [formDataRequest setPostValue:@"1" forKey:@"grouptype"];
    [formDataRequest setPostValue:@"level" forKey:@"struct"];//家谱数据使用
    formDataRequest.delegate = self;
    formDataRequest.userInfo = @{@"tag":[NSString stringWithFormat:@"%d",ASSOCIATED_USER_ALL_INFO]};
    [formDataRequest startAsynchronous];
    offLine.associateDownload = YES;
    offLine.associateStop = NO;
}

//开启等待下载
-(void)startWaitingDondload
{
    downLoadStep = 0;
    AssociatedModel *data = _associatedArray[downloadingIndex];
    data.downloadState = 3;
    [associatedTableView reloadData];
    [self saveAssociatedInfo:data];
    offLine.associateDownload = NO;
    warningNameLabel.text = [NSString stringWithFormat:@"共有7项，已下载第7项(视频)"];
    BOOL haveWaiting = NO;
    NSInteger index = -1;
    NSInteger count = _associatedArray.count;
    for (int i = 0;  i < count; i++)
    {
        AssociatedModel *data = _associatedArray[i];
        if (data.downloadState == 2)
        {
            data.downloadState = 0;
            index = i;
            haveWaiting = YES;
            break;
        }
    }
    if (haveWaiting == YES)
    {
        [self setDownloadState:index];
        return;
    }
    else
    {
        offLine.associateStop = YES;
        [MyToast showWithText:@"下载完成，请选择其它下载或进入家园观看" :200];
    }
}
//将下载完成的关联人员信息存储到本地
-(void)saveAssociatedInfo:(AssociatedModel *)data
{
    NSDictionary *associatedDic = [NSDictionary dictionaryWithObjects:@[data.associateUserId,data.authCode] forKeys:@[@"userId",@"authCode"]];
    NSMutableArray *associatedArr = [SavaData parseArrFromFile:User_AssocaitedInfo_File];
    if (associatedArr.count == 0)
    {
        [SavaData writeArrToFile:[NSArray arrayWithObject:associatedDic] FileName:User_AssocaitedInfo_File];
    }
    else
    {
        BOOL have = NO;
        for (NSDictionary *dic in associatedArr)
        {
            if ([dic[@"userId"] isEqualToString:associatedDic[@"userId"]])
            {
                have = YES;
                break;
            }
        }
        if (have == NO)
        {
            [associatedArr addObject:associatedDic];
        }
        [SavaData writeArrToFile:associatedArr FileName:User_AssocaitedInfo_File];
    }
}
//开始音频、视频下载
-(void)starMusicOrVideoDownload
{
    if (_musicArr.count != 0)
    {
        [self setMusicInfo];
    }
    else if (_audioArray.count != 0)
    {
        [self setAudioInfo];
    }
    else if (_vedioArr.count != 0)
    {
        [self setVedioInfo];
    }
    else
    {
        [self startWaitingDondload];
    }
}
//暂停后继续下载
-(void)resumeDownloading
{
    if (downLoadStep == AssocaitedLocationPhoto)
    {
        [self startPhotoDownLoad];
    }
    else if (downLoadStep == AssocaitedLocationStyleModel)
    {
        [self startStyledownload];
    }
    else if (downLoadStep == AssocaitedLocationMusic)
    {
        [self startMusicdownload];
    }
    else if (downLoadStep == AssocaitedLocationVedio)
    {
        [self startVediodownload];
    }
    else if (downLoadStep == AssocaitedLocationAudio)
    {
        [self startAudiodownload];
    }
}
//下载中进度条控制
-(void)setProgressAtIndex:(int)index Recieved:(long long int)receiveData TotalData:(long long int)totalData
{
    AssociatedCell *downloadingCell = (AssociatedCell *)[associatedTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    downloadingCell.progressView.progressView.progress = ((float)receiveData)/totalData;
    downloadingCell.progressView.percentageLabel.text = [NSString stringWithFormat:@"%.0f%%",
                                                         (downloadingCell.progressView.progressView.progress * 100)];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_TAG_CANCEL_DOWNLOAD)
    {
        if (buttonIndex == 0)
        {
            [self resumeDownloading];
        }
        else
        {
            if (_downloadQueue)
            {
                [_downloadQueue reset];
                [_downloadQueue release];
                _downloadQueue = nil;
            }
            [self removeAssocaitedMemberData];
            [self setProgressAtIndex:downloadingIndex Recieved:0 TotalData:1];

            AssociatedModel *data = (AssociatedModel *)_associatedArray[downloadingIndex];
            data.downloadState = 0;
            [associatedTableView reloadData];
            [self removeAssocaitedInfo:data];
            downloadingIndex = -1;
            BOOL haveWaiting = NO;
            NSInteger index = -1;
            NSInteger count = _associatedArray.count;
            for (int i = 0;  i < count; i++)
            {
                AssociatedModel *data = _associatedArray[i];
                if (data.downloadState == 2)
                {
                    data.downloadState = 0;
                    index = i;
                    haveWaiting = YES;
                    break;
                }
            }
            if (haveWaiting == YES)
            {
                [self startDownloading:index];
            }
            else
            {
                offLine.associateStop = YES;
                offLine.associateDownload = NO;
            }
        }
    }
    else if (alertView.tag == ALERT_TAG_SKIP)
    {
        if (buttonIndex == 1)
        {
            [self resumeDownloading];
        }
        else
        {
            [self removeAssocaitedMemberData];
            offLine.associateStop = YES;
            offLine.associateDownload = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"assocaitedDownloadSuccess" object:nil];
        }
    }
}

//取消下载删除之前关联过的成员的信息
-(void)removeAssocaitedInfo:(AssociatedModel *)data
{
    NSMutableArray *associatedArr = [SavaData parseArrFromFile:User_AssocaitedInfo_File];
    if (associatedArr.count != 0)
    {
        for (int i = 0; i < associatedArr.count ; i++)
        {
            if ([associatedArr[i][@"userId"] isEqualToString:data.associateUserId])
            {
                [associatedArr removeObjectAtIndex:i];
                [SavaData writeArrToFile:associatedArr FileName:User_AssocaitedInfo_File];
                break;
            }
        }
    }
}

//删除关联人员的相关数据
-(void)removeAssocaitedMemberData
{
    //图片文件
    [BaseDatas deleteAssocaitedDB:self.dataUserID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"favoriteStyleDic_%@",self.dataUserID]];
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"ETMemory"] stringByAppendingPathComponent:@"Photoes"];
    NSString *picturePath = [path stringByAppendingPathComponent:self.dataUserID] ;
    [[NSFileManager defaultManager] removeItemAtPath:picturePath error:nil];
    //录音文件
    NSString *audioPath = [Utilities FileFolder:@"Audioes" UserID:self.dataUserID];
    [[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
    //音频文件
    NSString *musicPath = [Utilities FileFolder:@"Music" UserID:self.dataUserID];
    [[NSFileManager defaultManager] removeItemAtPath:musicPath error:nil];
    //视频文件
    NSString *vedioPath = [Utilities FileFolder:@"Videos" UserID:self.dataUserID];

    [[NSFileManager defaultManager] removeItemAtPath:vedioPath error:nil];
    //plist文件
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path2=[paths objectAtIndex:0];
    NSString *plistPath=[path2 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",self.dataUserID]];
    NSString *musicPlistPath = [path2 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",self.dataUserID]];
    NSString *vedioPlistPath = [path2 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",self.dataUserID]];
    [[NSFileManager defaultManager] removeItemAtPath:musicPlistPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:vedioPlistPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
}

#pragma mark - ASIHTTPRequestDelegate

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData][@"meta"];
    NSInteger tag = [request.userInfo[@"tag"] intValue];
    offLine.associateDownload = YES;
    if (tag == ASSOCIATED_USER_ALL_INFO)
    {
        formDataRequest = nil;
        
        [SavaData writeDicToFile:resultDictionary[@"userinfo"] FileName:[NSString stringWithFormat:@"%@.plist",self.dataUserID]];

        NSArray *groupArr = (NSArray *)resultDictionary[@"groups"];

        if (groupArr.count != 0)
        {
//            [DiaryPictureClassificationSQL  refershDiaryPictureClassificationes:groupArr WithUserID:self.dataUserID];
            [StaticTools updateDiaryAndPhotoGroup:groupArr WithUserID:self.dataUserID];

        }
        NSArray *blogsArr = (NSArray *)resultDictionary[@"blogs"];

        if (blogsArr.count != 0)
        {
            [DiaryMessageSQL synchronizeBlog:blogsArr WithUserID:self.dataUserID];
        }
        warningNameLabel.text = [NSString stringWithFormat:@"共有7项，正在下载第3项(家谱)"];
        NSArray *familyArr = (NSArray *)resultDictionary[@"familymembers"];
        if (familyArr.count != 0)
        {
            [MyFamilySQL addFamilyMembers:familyArr AndType:@"reAdd" WithUserID:self.dataUserID];
            NSMutableArray *portraitArr = [NSMutableArray array];
            
            for (int i = 0;  i < familyArr.count; i++)
            {
                NSDictionary *dic = familyArr[i];
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
            [_photoArray addObjectsFromArray:[DownlaodDebugging enumeratorHeadPortrait:portraitArr PortraitPathsWithBOOL:^BOOL(NSString *path){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL result = [fileManager fileExistsAtPath:path];
                return result;
            }]];
        }
        NSArray *photoArr = (NSArray *)resultDictionary[@"photos"];
        if (photoArr.count != 0)
        {
            [MessageSQL synchronizeBlog:photoArr WithUserID:self.dataUserID];
            NSMutableArray *thumbnail = [NSMutableArray array];
            NSMutableArray *attachURL = [NSMutableArray array];
            NSInteger count = photoArr.count;
            
            for (int i = 0; i < count; i++)
            {
                [attachURL addObject:@[photoArr[i][@"attachURL"],photoArr[i][@"blogId"],@"attach",photoArr[i][@"photowall"]]];
                [thumbnail addObject:@[photoArr[i][@"thumbnail"],photoArr[i][@"blogId"],@"thumb",photoArr[i][@"photowall"]]];
                if ([photoArr[i][@"voiceURL"] length] != 0)
                {
                    NSString *url = photoArr[i][@"voiceURL"];
                    NSString *filename = [[url componentsSeparatedByString:@"/"] lastObject];
                    NSString *path = [Utilities dataPath:filename FileType:@"Audioes" UserID:_dataUserID];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO])
                    {
                        EMAudio *audio = [[EMAudio alloc] init];
                        audio.duration = [photoArr[i][@"duration"] intValue];
                        audio.size = [photoArr[i][@"voiceSize"] intValue];
                        audio.amrPath = path;
                        audio.audioURL = url;
                        audio.blogId = photoArr[i][@"blogId"];
                        audio.audioStatus = EMAudioSyncStatusNone;
                        [_audioArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:url,@"fullURL",[NSNumber numberWithLongLong:[photoArr[i][@"voiceSize"] longLongValue]],@"attachSize",filename,@"musicName",audio,@"audio" , nil]];
                        [audio release];
                    }
                }
            }
            [_photoArray addObjectsFromArray:[DownlaodDebugging enumeratorthumbnail:thumbnail AttachURL:attachURL UserID:_dataUserID imagePathsWithBOOL:^BOOL(NSString *path)
                                              {
                                                  NSFileManager *fileManager = [NSFileManager defaultManager];
                                                  BOOL result = [fileManager  fileExistsAtPath:path isDirectory:NO];
                                                  return result;
                                              }]];
        }
        RELEASE_SAFELY(styleDic);
        styleDic = [[NSDictionary alloc] initWithDictionary:resultDictionary[@"favoriteStyle"]];
        [[SavaData shareInstance] savaDictionary:styleDic keyString:[NSString stringWithFormat:@"favoriteStyleDic_%@",self.dataUserID]];

        NSArray *musicArr = (NSArray *)resultDictionary[@"musics"];
        if (musicArr.count != 0)
        {
            [_musicArr addObjectsFromArray:[DownlaodDebugging enumerator:musicArr UserID:self.dataUserID musicPathsWithBOOL:^BOOL(NSString *path){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL result = [fileManager  fileExistsAtPath:path isDirectory:NO];
                return result;
            }]];
        }
        NSArray *vedioArr = (NSArray *)resultDictionary[@"videos"];
        if (vedioArr.count != 0)
        {
            [_vedioArr addObjectsFromArray:[DownlaodDebugging enumerator:vedioArr UserID:self.dataUserID VedioPathsWithBOOL:^BOOL(NSString *path){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL result = [fileManager  fileExistsAtPath:path];
                return result;
            }]];
            
        }
        [SavaData writeArrToFile:vedioArr FileName:[NSString stringWithFormat:@"UserVideo%@.plist",self.dataUserID]];
        [SavaData writeArrToFile:musicArr FileName:[NSString stringWithFormat:@"UserMusic%@.plist",self.dataUserID]];
        if (_photoArray.count != 0)
        {
            [self startPhotoDownLoad];
        }
        else
        {
            [self startStyledownload];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    if (bytes >= successCapacity)
    {
        progressCapacity += (bytes - successCapacity);
        successCapacity = bytes;
    }
    else
    {
        progressCapacity += bytes;
        successCapacity += bytes;
    }
    [self setProgressAtIndex:downloadingIndex Recieved:progressCapacity TotalData:totalCapacity];

}


-(void)httpRequestSucess:(ASIHTTPRequest *)request
{
    successCapacity = 0;
    NSInteger tag = [request.userInfo[@"tag"] intValue];
    httpRequest = nil;
    if (tag == REQUEST_FOR_STYLE_MODEL)
    {
        [CommonData beginDecompressionFile:request.userInfo];
        [self starMusicOrVideoDownload];
    }
    if (tag == REQUEST_FOR_VEDIO_INFO)
    {
        [_vedioArr removeObjectAtIndex:0];
        [bytesArr removeObjectAtIndex:0];
        [self startVediodownload];
    }
    if (tag == REQUEST_FOR_MUSIC_INFO)
    {
        [_musicArr removeObjectAtIndex:0];
        [bytesArr removeObjectAtIndex:0];
        [self startMusicdownload];
    }
    if (tag == REQUEST_FOR_AUDIO)
    {
        //数据库方法添加userID
//        EMAudio *audio = request.userInfo[@"audio"];
//        [MessageSQL updateAudio:audio forBlogid:audio.blogId];
        [_audioArray removeObjectAtIndex:0];
        [bytesArr removeObjectAtIndex:0];
        [self startAudiodownload];
    }
}

-(void)httpRequestFail:(ASIHTTPRequest *)request
{
    if ([Utilities checkNetwork] == NO)
    {
    }
    else
    {
        [_tempPath release];
        _tempPath = nil;
        successCapacity = 0;
    }
    
    NSInteger tag = [request.userInfo[@"tag"] intValue];
    if (tag == REQUEST_FOR_STYLE_MODEL)
    {
        [self starMusicOrVideoDownload];
    }
    if(tag == REQUEST_FOR_MUSIC_INFO)
    {
        totalCapacity -= [_musicArr[0][@"attachSize"] longLongValue];
        progressCapacity -= successCapacity;
        [_musicArr removeObjectAtIndex:0];
        [bytesArr removeObjectAtIndex:0];
        httpRequest = nil;
        [self startMusicdownload];
    }
    if (tag == REQUEST_FOR_AUDIO)
    {
        totalCapacity -= [_audioArray[0][@"attachSize"] longLongValue];
        progressCapacity -= successCapacity;
        [_audioArray removeObjectAtIndex:0];
        [bytesArr removeObjectAtIndex:0];
        httpRequest = nil;
        [self startAudiodownload];
    }
    if (tag == REQUEST_FOR_VEDIO_INFO)
    {
        //文件类型
        progressCapacity -= successCapacity;
        [_vedioArr removeObjectAtIndex:0];
        [bytesArr removeObjectAtIndex:0];
        httpRequest = nil;
        [self startVediodownload];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//启动图片下载
-(void)startPhotoDownLoad
{
    downLoadStep = AssocaitedLocationPhoto;
    if (_downloadQueue != nil)
    {
        if (_downloadQueue.operations.count > 0)
        {
            [_downloadQueue go];
        }
        else
        {
            [self startStyledownload];
        }
        return;
    }
    else
    {
        warningNameLabel.text = [NSString stringWithFormat:@"共有7项，正在下载第3项(相册)"];
        NSInteger count = _photoArray.count;
        downloadPhotoNum = 0;
        photoTotalNum = count;
        if (_downloadQueue == nil)
        {
            _downloadQueue =[DownlaodDebugging initQueueFinish:@selector(imageFatchComplete:) Failed:@selector(imageFatchFailed:) Delegte:self];
        }
        [DownlaodDebugging setQueue:_downloadQueue PhotosArray:_photoArray];
        [_downloadQueue go];
    }
}
#pragma mark - Download Picture Finish or Fail
- (void)imageFatchComplete:(ASIHTTPRequest *)request
{
    if ([request.userInfo[@"type"] isEqualToString:@"photo"])
    {
        if ([request.userInfo[@"kind"] isEqualToString:@"attach"])
        {
            [MessageSQL updataPathForImageURL:request.userInfo[@"attachURL"] withPath:request.userInfo[@"path"] WithUserID:self.dataUserID];
        }
        else if ([request.userInfo[@"kind"] isEqualToString:@"thumb"])
        {
            [MessageSQL updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
                NSString *u_sql = [NSString stringWithFormat:@"update %@ set spaths = ? where blogId = ?", tableName];
                [db executeUpdate:u_sql, request.userInfo[@"path"], request.userInfo[@"blogId"]];
            } WithUserID:self.dataUserID] ;
        }
    }
    downloadPhotoNum ++;
    [_photoArray removeObject:request.userInfo[@"object"]];

    [self setProgressAtIndex:downloadingIndex Recieved:downloadPhotoNum TotalData:photoTotalNum];

    if (_photoArray.count == 0)
    {
        if (_downloadQueue)
        {
            [_downloadQueue reset];
            [_downloadQueue release];
            _downloadQueue = nil;
        }
        [self startStyledownload];
    }
}
- (void)imageFatchFailed:(ASIHTTPRequest *)request
{
    downloadPhotoNum ++;
    [_photoArray removeObject:request.userInfo[@"object"]];
    [self setProgressAtIndex:downloadingIndex Recieved:downloadPhotoNum TotalData:photoTotalNum];
    if (_photoArray.count == 0)
    {
        if (_downloadQueue)
        {
            [_downloadQueue reset];
            [_downloadQueue release];
            _downloadQueue = nil;
        }
        [self startStyledownload];
    }
}

//下载音乐模块设置
-(void)setMusicInfo
{
    warningNameLabel.text = [NSString stringWithFormat:@"共有7项，正在下载第5项(音频)"];
    if (bytesArr == nil)
    {
        bytesArr = [[NSMutableArray alloc] init];
    }
    [bytesArr removeAllObjects];
    totalCapacity = 0;
    successCapacity = 0;
    progressCapacity = 0;
    totalCapacity = [DownlaodDebugging setMusicDownLoadDataWithConfigurationArr:_musicArr BytesArr:bytesArr];
    [self startMusicdownload];
}

//下载录音模块设置
-(void)setAudioInfo
{
    warningNameLabel.text = [NSString stringWithFormat:@"共有7项，正在下载第6项(录音)"];
    if (bytesArr == nil)
    {
        bytesArr = [[NSMutableArray alloc] init];
    }
    [bytesArr removeAllObjects];
    totalCapacity = 0;
    successCapacity = 0;
    progressCapacity = 0;
    totalCapacity = [DownlaodDebugging setMusicDownLoadDataWithConfigurationArr:_audioArray BytesArr:bytesArr];
    [self startAudiodownload];
}

//下载视频模块设置
-(void)setVedioInfo
{
    warningNameLabel.text = [NSString stringWithFormat:@"共有7项，正在下载第7项(视频)"];
    if (bytesArr == nil)
    {
        bytesArr = [[NSMutableArray alloc] init];
    }
    [bytesArr removeAllObjects];
    totalCapacity = 0;
    successCapacity = 0;
    progressCapacity = 0;
    totalCapacity = [DownlaodDebugging setVedioDownLoadDataWithConfigurationArr:_vedioArr BytesArr:bytesArr];
    [self startVediodownload];
}

//设置家园模板下载
-(void)startStyledownload
{
    successCapacity = 0;
    progressCapacity = 0;
    totalCapacity = [styleDic[@"filesize"] longLongValue];
    warningNameLabel.text = [NSString stringWithFormat:@"共有7项，正在下载第4项(家园风格)"];
    NSString *homeUrl = styleDic[@"zippath"];
    NSString *typeStr = [[homeUrl componentsSeparatedByString:@"."] lastObject];
//    NSString *styleName = styleDic[@"styleName"];
    NSString *styleName = [NSString stringWithFormat:@"style%d",[styleDic[@"styleId"] intValue]];
    NSString *judgeStr = [NSString stringWithFormat:@"style%d.html",[styleDic[@"styleId"] intValue]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[[CommonData getZipFilePathManager] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",styleName]] stringByAppendingPathComponent:judgeStr]])
    {
        NSFileManager *fileHome = [NSFileManager defaultManager];
        NSError *error;
        //创建下载临时文件
        if(![fileHome fileExistsAtPath:[CommonData getTempFolderPath]])
        {
            [fileHome createDirectoryAtPath:[CommonData getTempFolderPath] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        CLEAR_REQUEST(httpRequest);
        httpRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:homeUrl]];
        [DownlaodDebugging setRequest:httpRequest userInfo:styleDic UserID:USERID fileName:styleName fileType:typeStr Tag:REQUEST_FOR_STYLE_MODEL Type:FileTypeStyle];
        self.tempPath = httpRequest.temporaryFileDownloadPath;
        [DownlaodDebugging setHttpRequestConfigure:httpRequest Handler:self];
        [httpRequest startAsynchronous];
        downLoadStep = AssocaitedLocationStyleModel;
    }
    else
    {
        [self starMusicOrVideoDownload];
    }
}
//开始音频下载
-(void)startMusicdownload
{
    downLoadStep = AssocaitedLocationMusic;

    if (_musicArr.count !=0 )
    {
        NSDictionary *dic = _musicArr[0];
        NSString *fileType = [[dic[@"fullURL"] componentsSeparatedByString:@"."] lastObject];
        NSString *fileName = dic[@"musicName"];
        //开启下载
        CLEAR_REQUEST(httpRequest);
        httpRequest=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:dic[@"fullURL"]]];
        [DownlaodDebugging setRequest:httpRequest userInfo:dic UserID:_dataUserID fileName:fileName fileType:fileType Tag:REQUEST_FOR_MUSIC_INFO Type:FileTypeMusic];
        self.tempPath = httpRequest.temporaryFileDownloadPath;
        [DownlaodDebugging setHttpRequestConfigure:httpRequest Handler:self];
        [httpRequest startAsynchronous];
    }
    else
    {
        if (_audioArray.count != 0)
        {
            [self setAudioInfo];
        }
        else if (_vedioArr.count != 0)
        {
            [self setVedioInfo];
        }
        else
        {
            [self startWaitingDondload];
        }
    }
}
//开始录音下载
-(void)startAudiodownload
{
    downLoadStep = AssocaitedLocationAudio;
    if (_audioArray.count !=0 )
    {
        NSDictionary *dic = _audioArray[0];
        NSString *fileType = [[dic[@"fullURL"] componentsSeparatedByString:@"."] lastObject];
        NSString *fileName = [[dic[@"musicName"] componentsSeparatedByString:@"."] firstObject];

        //开启下载
        CLEAR_REQUEST(httpRequest);
        httpRequest=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:dic[@"fullURL"]]];
        [DownlaodDebugging setRequest:httpRequest userInfo:dic UserID:_dataUserID fileName:fileName fileType:fileType Tag:REQUEST_FOR_AUDIO Type:FileTypeAudio];
        self.tempPath = httpRequest.temporaryFileDownloadPath;
        [DownlaodDebugging setHttpRequestConfigure:httpRequest Handler:self];
        [httpRequest startAsynchronous];
    }
    else
    {
        if (_vedioArr.count != 0)
        {
            [self setVedioInfo];
        }
        else
        {
            [self startWaitingDondload];
        }
    }
}

//开始视频下载
-(void)startVediodownload
{
    downLoadStep = AssocaitedLocationVedio;
    if (_vedioArr.count != 0)
    {
        NSDictionary *dic = _vedioArr[0];
        
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
        [DownlaodDebugging setRequest:httpRequest userInfo:dic UserID:_dataUserID fileName:fileName fileType:fileType Tag:REQUEST_FOR_VEDIO_INFO Type:FileTypeVedio];
        self.tempPath = httpRequest.temporaryFileDownloadPath;
        [DownlaodDebugging setHttpRequestConfigure:httpRequest Handler:self];
        [httpRequest startAsynchronous];
    }
    else
    {
        [self startWaitingDondload];
    }
}
@end
