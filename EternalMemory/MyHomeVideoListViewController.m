//
//  MyHomeVideoListViewController.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-8-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MyHomeVideoListViewController.h"
#import "RequestParams.h"
#import "SavaData.h"
#import "ETHomeMoviePlayerController.h"
#import "DirectionMPMoviePlayerViewController.h"
#import "Utilities.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MyToast.h"
#import "EternalMemoryAppDelegate.h"
#import "CommonData.h"
#import "FileModel.h"


#define FileModel  [FileModel sharedInstance]
#define OTHERHOME  [[[SavaData shareInstance]printDataStr:@"JoinOtherHome"] integerValue]//1表示别人，0表示自己

@interface MyHomeVideoListViewController ()

{
    ASIFormDataRequest *request;
}

@end


NSString *pathForSavingVideoEternalcode = nil;


@implementation MyHomeVideoListViewController
@synthesize associateauthcode = _associateauthcode;
@synthesize associatevalue = _associatevalue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)dealloc
{
    
    if (OTHERHOME) {
        [_videoNamesArr release];
    }else{
        
        [_videoList release];
        [_videoNamesArr release];
        [request cancel];
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    _videoList = [[NSMutableArray alloc] initWithCapacity:0];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    _videoIdx = 0;

    [self setupSubviews];
    
    [self createDirForSavingVideo];
    
    BOOL networkAvilible = [Utilities checkNetwork];
    if (!networkAvilible) {//无网络
        
        [self setVideoListAtPath];
        
        if (!OTHERHOME) {//自己的
            
            NSMutableArray *arrDatas = [SavaData parseArrFromFile:Video_File];
            [_videoList addObjectsFromArray:arrDatas];
            if (_videoList.count == 0) {
                _videoTitleLabel.text = @"暂无视频";
                [self disableButton];
            }else{
                NSString *videoTitle = self.videoList[0][@"content"];
                [self enableButton];
                [self setVideoTitle:videoTitle];
            }
        }else{//别人的
            
            BOOL isDownLoad = [self isAssociatedUserDataDownLoad];
            if (isDownLoad) {
                NSString *key = [NSString stringWithFormat:@"UserVideo%@.plist",_currentUserID];
                NSMutableArray *arrDatas = [SavaData parseArrFromFile:key];
                [_videoList addObjectsFromArray:arrDatas];
                if (_videoList.count == 0) {
                    _videoTitleLabel.text = @"暂无视频";
                    [self disableButton];
                }else{
                    NSString *videoTitle = self.videoList[0][@"content"];
                    [self enableButton];
                    [self setVideoTitle:videoTitle];
                }
            }else{
                [MyToast showWithText:@"无网略" :130];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }else{//有网络
        if (OTHERHOME) {
            
            [self requestVidelListByAssociate];//别人的
            
        }else{
            
            if (self.eternalCode.length == 0 || [@"" isEqualToString:self.eternalCode] || !self.eternalCode) {
                
                [self requestForVideoListUsingAuthcode];//自己的
                
            }else{
                
//#warning 授权码登录进来的
                self.pathForSavingVideoEternalcode = [NSString stringWithFormat:@"%@/Library/ETMemory/Videos/%@",NSHomeDirectory(),self.eternalCode];
                
            }
        }
    }
	// Do any additional setup after loading the view.
}
-(BOOL)isAssociatedUserDataDownLoad{
    
    NSString *key = [NSString stringWithFormat:@"%@_AssocaitedInfo.plist",_currentUserID];
    NSArray *associatedArr = [SavaData parseArrFromFile:key];
    for(NSDictionary *obj in associatedArr){
        if ([_currentUserID isEqualToString:obj[@"userId"]]) {
            return YES;
        }
    }
    return NO;
    
}
- (void)setupSubviews
{
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = CGRectMake(SCREEN_WIDTH - 40, 10, 30, 30);
    
    _closeButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [_closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    
    _videoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 95, SCREEN_WIDTH - 40, 50)];
    _videoTitleLabel.backgroundColor = [UIColor clearColor];
    
    _videoTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    
    _videoTitleLabel.textColor = [UIColor whiteColor];
    _videoTitleLabel.textAlignment = NSTextAlignmentCenter;
    _videoTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    _videoTitleLabel.text = @"正在加载...";
    [self.view addSubview:_videoTitleLabel];
    [_videoTitleLabel release];
    
    _videoThumnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 150, SCREEN_WIDTH, 228)];
    _videoThumnailImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_videoThumnailImageView setImage:[UIImage imageNamed:@"spbg.png"]];
    [self.view addSubview:_videoThumnailImageView];
    [_videoThumnailImageView release];
    
    _playVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _playVideoButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    _playVideoButton.frame = CGRectMake(0, 0, 100, 100);
    _playVideoButton.center = self.view.center;
    [_playVideoButton setImage:[UIImage imageNamed:@"spbf.png"] forState:UIControlStateNormal];
    [_playVideoButton setBackgroundColor:[UIColor clearColor]];
    _playVideoButton.enabled = NO;
    [_playVideoButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playVideoButton];
    
    
    _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _nextButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    _nextButton.frame = CGRectMake(SCREEN_WIDTH - 27 - 40, CGRectGetMidY(self.view.frame) - 5, 27, 20);
    _nextButton.enabled = NO;
    [_nextButton setImage:[UIImage imageNamed:@"spqh2.png"] forState:UIControlStateNormal];
    [_nextButton setBackgroundColor:[UIColor clearColor]];
    [_nextButton addTarget:self action:@selector(nextVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextButton];
    
    
    _preButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _preButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    _preButton.frame = CGRectMake(40, CGRectGetMidY(self.view.frame) - 5, 27, 20);
    _preButton.enabled = NO;
    [_preButton setImage:[UIImage imageNamed:@"spqh1.png"] forState:UIControlStateNormal];
    [_preButton setBackgroundColor:[UIColor clearColor]];
    [_preButton addTarget:self action:@selector(preVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_preButton];
    
    [self.view bringSubviewToFront:_videoTitleLabel];
}

- (void)preVideo:(id)sender
{
    _videoIdx --;
    if (_videoIdx < 0) {
        _videoIdx = self.videoList.count - 1;
    }
    [self setVideoTitle:self.videoList[_videoIdx][@"content"]];
}



- (void)playVideo:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if ([self isDocVideoPath:_videoIdx isPlay:YES] == NO) {//本地相册无视频
        NSString *videoUrlStr = [CommonData getMovVideoPath:self.videoList[_videoIdx]];//获取视频路径
        
        NSURL *videoURL = [NSURL URLWithString:videoUrlStr];
        
        NSDictionary *videoDataDic = self.videoList[_videoIdx];
        NSString *videoTitle = videoDataDic[@"content"];
        
        NSArray *tmpArr = [videoUrlStr componentsSeparatedByString:@"."];
        //文件类型
        NSString *videoType = [tmpArr lastObject];
        NSString *videoName  = [NSString stringWithFormat:@"%@.%@",videoTitle,videoType];
        
    //zgl  12.13号注释
        NSString *path = nil;
        NSDictionary *userInfoDic = [SavaData parseDicFromFile:[NSString stringWithFormat:@"%@.plist",_currentUserID]];
        path = [NSString stringWithFormat:@"%@/Library/ETMemory/Videos/%@/",NSHomeDirectory(),userInfoDic[@"userName"]];
        path = [path stringByAppendingPathComponent:videoName];
        
        BOOL isVideoExsist = [[NSFileManager defaultManager] fileExistsAtPath:path];
        if (isVideoExsist) {
            videoURL = [NSURL fileURLWithPath:path];
        }else if(!isVideoExsist && ![Utilities checkNetwork]){
            [MyToast showWithText:@"视频未下载到本地，且无网络" :150];
            return;
        }
        
        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        controller.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        [self presentMoviePlayerViewControllerAnimated:controller];
        [controller release];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finish) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }

}
-(void)finish{
    [self dismissMoviePlayerViewControllerAnimated];
}

//判断上视频是否是存在本地，继而无需请求网络
- (BOOL)isDocVideoPath:(NSInteger)index isPlay:(BOOL)play
{
    NSString *strName = self.videoList[index][@"content"];//视频名字
    NSMutableArray *arrPath = [[SavaData shareInstance] printDataAry:@"videoPath"];
    if (arrPath.count >0) {
        for (NSDictionary *dic in arrPath) {
            NSString *pathName = dic[@"videoName"];
            NSString *strPath = dic[@"videoPath"];
            if ([pathName isEqualToString:strName]) {
                if (play) {
                    NSURL *rul = [NSURL fileURLWithPath:strPath];
                   [self didplayVideoFileAction:rul];
                }
                return YES;
            }
        }
    }
    return NO;
}

- (void)didplayVideoFileAction:(NSURL *)videoURL
{
    MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [self presentMoviePlayerViewControllerAnimated:controller];
    [controller release];
}
- (void)nextVideo:(id)sender
{
    _videoIdx ++;
    if (_videoIdx > (self.videoList.count - 1)) {
        _videoIdx = 0;
    }
    
    [self setVideoTitle:self.videoList[_videoIdx][@"content"]];
}

- (void)setVideoTitle:(NSString *)title
{
    _videoTitleLabel.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _videoTitleLabel.alpha = 1;
        _videoTitleLabel.text = title;
    }];
}

- (void)closeButtonPressed:(id)sender
{

    [self dismissViewControllerAnimated:YES completion:^{[[NSNotificationCenter defaultCenter]postNotificationName:@"addJStoWebviewsss" object:nil];}];
    
}

- (void)setVideoListAtPath
{
    NSString *path = nil;
    NSDictionary *userInfoDic = [SavaData parseDicFromFile:[NSString stringWithFormat:@"%@.plist",_currentUserID]];
    path = [NSString stringWithFormat:@"%@/Library/ETMemory/Videos/%@/",NSHomeDirectory(),userInfoDic[@"userName"]];
    
    _videoNamesArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *pname;
    NSEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    while (pname = [enumerator nextObject]) {
        [_videoNamesArr addObject:pname];
    }
}

- (void)enableButton
{
    _preButton.enabled = YES;
    _nextButton.enabled = YES;
    _playVideoButton.enabled = YES;
}
- (void)disableButton
{
    _preButton.enabled = NO;
    _nextButton.enabled = NO;
    _playVideoButton.enabled = NO;

}
//授权码请求视频列表
-(void)requestVidelListByAssociate{
    
    NSURL *url = [[RequestParams sharedInstance] ListVideoInHome];
    request = [ASIFormDataRequest requestWithURL:url];
    request.shouldAttemptPersistentConnection = NO;
    [request setPostValue:_associateauthcode forKey:@"authcode"];
    [request setPostValue:@"video" forKey:@"userdata"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:10.];
    __block typeof(self) this = self;
    
    [request setCompletionBlock:^{
        
        [this handleResponseData:[request responseData]];
    }];
    [request setFailedBlock:^{
        [MyToast showWithText:@"获取视频列表失败" :130];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];

    [request startAsynchronous];
   
}

- (void)requestForVideoListUsingAuthcode
{
    NSURL *url = [[RequestParams sharedInstance] listVideoLockAction];
    request = [[ASIFormDataRequest alloc]initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT  forKey:@"serverauth"];
    [request setTimeOutSeconds:20];
    [request setShouldAttemptPersistentConnection:NO];
    [request setDelegate:self];
    [request startAsynchronous];
    
    __block typeof(self) this = self;
    
    [request setCompletionBlock:^{
        
        [this handleResponseDataMyself:[request responseData]];
    }];
    [request setFailedBlock:^{
        [MyToast showWithText:@"获取视频列表失败" :130];
        [self dismissViewControllerAnimated:YES completion:nil];

    }];
    
}
- (void)handleResponseDataMyself:(NSData *)data
{
    
    NSDictionary *dic = [data objectFromJSONData];
    NSInteger success = [dic[@"success"] integerValue];
    if (success == 1)
    {
        NSArray *arrVideo = [NSArray arrayWithArray:dic[@"data"]];
        
        [SavaData writeArrToFile:arrVideo FileName:Video_File];
        
        self.videoList = (NSMutableArray *)arrVideo;
        if (_videoList.count == 0) {
            _videoTitleLabel.text = @"暂无视频";
            [self disableButton];
            return;
        }
        
        NSString *videoTitle = self.videoList[0][@"content"];
        [self enableButton];
        [self setVideoTitle:videoTitle];
        
    }
    else if(success == 0)
    {
        [MyToast showWithText:@"获取视频列表失败" :130];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)handleResponseData:(NSData *)data
{
    NSDictionary *dic = [data objectFromJSONData];
    NSInteger success = [dic[@"success"] integerValue];
    if (success == 1)
    {
        NSArray *arrVideo = [NSArray arrayWithArray:dic[@"meta"][@"videos"]];
        NSString *key = [NSString stringWithFormat:@"UserVideo%@.plist",_currentUserID];
        [SavaData writeArrToFile:arrVideo FileName:key];
        
        self.videoList = (NSMutableArray *)arrVideo;
        if (_videoList.count == 0) {
            _videoTitleLabel.text = @"暂无视频";
            [self disableButton];
            return;
        }
        
        NSString *videoTitle = self.videoList[0][@"content"];
        [self enableButton];
        [self setVideoTitle:videoTitle];
        
    }
    else if(success == 0)
    {
        [MyToast showWithText:@"获取视频列表失败" :130];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)downloadVidowAtURL:(NSURL*)url andVidowName:(NSString *)videoName
{
    NSString *tempName  = [NSString stringWithFormat:@"%@.temp",videoName];
    NSString *desPath = [Utilities dataPath:[NSString stringWithFormat:@"%@",videoName] FileType:@"Videos" UserID:_currentUserID];

    NSString *tempPath  = nil;
    NSString *path = nil;
    NSDictionary *userInfoDic = [SavaData parseDicFromFile:[NSString stringWithFormat:@"%@.plist",_currentUserID]];
    path = [NSString stringWithFormat:@"%@/Library/ETMemory/Videos/%@/",NSHomeDirectory(),userInfoDic[@"userName"]];
    tempPath = [path stringByAppendingPathComponent:tempName];
    
    if (self.eternalCode.length != 0) {
        tempPath = [self.pathForSavingVideoEternalcode stringByAppendingPathComponent:tempName];
        path = self.pathForSavingVideoEternalcode;
        [self createDirForSavingVideo];
    }
    
    ASIHTTPRequest *downloadRequest = [ASIHTTPRequest requestWithURL:url];
    [downloadRequest setTemporaryFileDownloadPath:tempPath];
    [downloadRequest setDownloadDestinationPath:desPath];
    [downloadRequest setAllowResumeForFileDownloads:YES];
    [downloadRequest startAsynchronous];
    
    [downloadRequest setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
    }];
    
    [downloadRequest setStartedBlock:^{
        [MyToast showWithText:@"开始下载视频" :130];
    }];
    
    [downloadRequest setCompletionBlock:^{
        //把下载完成的视频路劲存入本地
        NSString *videoPath = [CommonData strPathGetTargetFloderTranscodingPath:self.videoList[_videoIdx]];
        NSDictionary *dicPath = @{@"videoPath":videoPath,@"videoName":self.videoList[_videoIdx][@"content"]};
        [FileModel.videoPathArr addObject:dicPath];
        //把本地视频路劲存入本地
        [[SavaData shareInstance] savaArray:FileModel.videoPathArr KeyString:@"videoPath"];
        [MyToast showWithText:@"视频下载完成" :130];
        _isDownloading[_videoIdx] = NO;
    }];
    
    [downloadRequest setFailedBlock:^{
        [MyToast showWithText:@"视频下载失败" :130];
        _isDownloading[_videoIdx] = NO;
    }];
}

- (BOOL)createDirForSavingVideo
{
    static NSString *path = nil;
    
    NSDictionary *userInfoDic = [SavaData parseDicFromFile:[NSString stringWithFormat:@"%@.plist",_currentUserID]];
    path = [NSString stringWithFormat:@"%@/Library/ETMemory/Videos/%@/",NSHomeDirectory(),userInfoDic[@"userName"]];
    
    BOOL isDir ;
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir])
    {
        return YES;
    }
    else
    {
        NSError *error  = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        return success;
    }
    return NO;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)backBtnPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
