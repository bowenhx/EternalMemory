//
//  LogoMPMoviewPlayViewCtl.m
//  EternalMemory
//
//  Created by Guibing on 13-8-22.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "LogoMPMoviewPlayViewCtl.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AuthLoginViewController.h"
#import "MD5.h"
#import "SweepNotourViewController.h"
#import "SavaData.h"
#import "NSString+Base64.h"
#import "MyToast.h"
#import "LoginSecondViewController.h"
#import "SealWarnViewController.h"
#import "BaseDatas.h"
#import "FailedOfflineDownLoad.h"
#import "OfflineDownLoad.h"
#import "SweepNotourViewController.h"
#import "CodeLoginViewController.h"
#import "EMPhotoSyncEngine.h"
#import "CommonData.h"

#define failedDownLoad  [FailedOfflineDownLoad shareInstance]
#define offLine         [OfflineDownLoad shareOfflineDownload]
#define NotCode         100

@implementation LogoMPMoviewPlayViewCtl


-(id)init{
    
    self = [super init];
    if (self) {
        isHidden = YES;
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"logoVideo" ofType:@"mp4"];
        NSURL *url = [NSURL fileURLWithPath:path] ;
        player = [[MPMoviePlayerController alloc] initWithContentURL:url];
        player.controlStyle = MPMovieControlStyleNone;
        player.scalingMode = MPMovieScalingModeAspectFill;
        [player.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];//自动适应屏幕大小；
        [player.view setFrame:self.view.bounds];
        [self.view addSubview:player.view];
        [player play];
        [self initLoadView];
        
    }
    return self;
}
-(void)deCompressStyleZip{
    
    [CommonData beginDecompressionFile:[NSDictionary dictionaryWithObjectsAndKeys:@"bundle",@"sourceFrom", nil]];
}
/*- (id)initWithContentURL:(NSURL *)contentURL
{
    self = [super initWithContentURL:contentURL];
    if (self) {
        isHidden = YES;
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;//设置样式
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;//
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self initLoadView];
        
    }
    return self;
}*/

-(void)viewDidLoad{
    
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *versionLocal = [defaults objectForKey:@"publicVersion"];
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[CommonData getZipFilePathManager] error:nil];
    BOOL isDownload = NO;
    if (versionLocal == nil)
    {
        [CommonData deleteStylePath:@"style2"];
        isDownload = YES;
        for (NSString *style in items)
        {
            if (![style isEqualToString:@"style2"])
            {
                [StyleListSQL isDelectdateDownLoadState:3 styleID:[[style substringFromIndex:style.length - 1] intValue]];
            }
        }
        [[NSFileManager defaultManager] removeItemAtPath:[CommonData getZipFilePathManager] error:nil];
        [defaults setObject:version forKey:@"publicVersion"];
    }
    else
    {
    if (![version isEqualToString:versionLocal])
    {
        [CommonData deleteStylePath:@"style2"];
        if ([versionLocal isEqualToString:OLDERVERSION])
        {
            NSArray *styleArray = CHANGEDSTYLES;
            if (styleArray.count != 0)
            {
                for (NSString *style in styleArray)
                {
                    if ([items containsObject:style])
                    {
                        isDownload = YES;
                        [CommonData deleteStylePath:style];
                        [StyleListSQL isDelectdateDownLoadState:3 styleID:[[style substringFromIndex:style.length - 1] intValue]];
                    }
                }
            }
        }
        else
        {
            isDownload = YES;
            for (NSString *style in items)
            {
                if (![style isEqualToString:@"style2"])
                {
                    [StyleListSQL isDelectdateDownLoadState:3 styleID:[[style substringFromIndex:style.length - 1] intValue]];
                }
            }
            [[NSFileManager defaultManager] removeItemAtPath:[CommonData getZipFilePathManager] error:nil];
        }
        [defaults setObject:version forKey:@"publicVersion"];
    }
    if (isDownload == YES)
    {
        [MyToast showWithText:@"家园模板有新的更新，请重新下载" :200];
    }
    }
    
    [self performSelectorInBackground:@selector(deCompressStyleZip) withObject:nil];
}
-(id)initWithView{
    
    self = [super init];
    if (self) {
        [self initLoadView];
    }
    return self;
}
-(void)appWillEnterForegroundNotification:(NSNotification *)obj{
    
    if (videoTime != 10.0) {//视频播放完了，进入前台，不应该再播放
        NSString *path = [[NSBundle mainBundle] pathForResource:@"logoVideo" ofType:@"mp4"];
        NSURL *url = [NSURL fileURLWithPath:path] ;
        player.contentURL = url;
        [player setCurrentPlaybackTime:videoTime];
        [player setInitialPlaybackTime:videoTime];
        [player play];
    }
}
-(void)appWillEnterBackgroundNotification:(NSNotification *)obj{

    videoTime = player.currentPlaybackTime;
    [player pause];
}
- (void) playVideoFinished:(NSNotification *)theNotification
{

    [[SavaData shareInstance] savaDataBool:YES KeyString:@"noFirstUse"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self setDeviceToken];
   //播放视频之后显示操作button
    [UIView animateWithDuration:0.3 animations:^{
        self.loginBut.alpha = 0;
        self.loginBut.hidden = NO;
        self.loginBut.alpha = 1;
        self.memoryBut.alpha = 0;
        self.memoryBut.hidden = NO;
        self.memoryBut.alpha = 1;
        self.firstVisitBut.alpha = 0;
        self.firstVisitBut.hidden = NO;
        self.firstVisitBut.alpha = 1;
    }];
//    [player release];
}
-(void)setDeviceToken{
    
    if ([[SavaData shareInstance] printToken:TOKEN]) {
        return;
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"UUID"]==nil) {
        
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        
        CFStringRef uuidstring = CFUUIDCreateString(NULL, uuid);
        
        NSString *identifierNumber = [NSString stringWithFormat:@"_%@",uuidstring];
        
        [[NSUserDefaults standardUserDefaults] setObject:identifierNumber forKey:@"UUID"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        CFRelease(uuidstring);
        
        CFRelease(uuid);
    }
    NSString *uuid = [[NSUserDefaults standardUserDefaults]objectForKey:@"UUID"];
    [[SavaData shareInstance]savaToken:uuid KeyString:TOKEN];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    if (isHidden) {
        _imageBg.hidden = YES;
        isHidden = NO;
    }else{
        _imageBg.hidden = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
//    if (player) {
//        [player release];
//        player = nil;
//    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)initLoadView
{
    _imageBg = [[UIImageView alloc] initWithFrame:self.view.frame];
    if (iPhone5) {
        _imageBg.image = [[UIImage imageNamed:@"lastLogo-568h"] stretchableImageWithLeftCapWidth:1 topCapHeight:2];
    }else{
        _imageBg.image = [[UIImage imageNamed:@"lastLogo"] stretchableImageWithLeftCapWidth:1 topCapHeight:2];
    }
    _imageBg.userInteractionEnabled = YES;
    _imageBg.hidden = YES;
    [self.view addSubview:_imageBg];
    [_imageBg release];
    
//    _memoryBut = [UIButton buttonWithType:UIButtonTypeCustom];
//    _memoryBut.frame = CGRectMake((self.view.bounds.size.width-232)/2, self.view.bounds.size.height-70, 232, 42);
//    [_memoryBut setBackgroundImage:[UIImage imageNamed:@"visitHome"] forState:UIControlStateNormal];
//    _memoryBut.hidden = YES;
//    [self.view addSubview:_memoryBut];
    
    _loginBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBut.frame = CGRectMake((self.view.bounds.size.width-232)/2, self.view.bounds.size.height-100, 232, 42);
    _loginBut.hidden = YES;
    [self.view addSubview:_loginBut];
    
    _firstVisitBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _firstVisitBut.frame = CGRectOffset(_loginBut.frame,0,-_loginBut.frame.size.height-20);

    _firstVisitBut.hidden = YES;
    [self.view addSubview:_firstVisitBut];
    
#if TARGET_VERSION_LITE ==1//免费版
    [_loginBut setBackgroundImage:[UIImage imageNamed:@"logoLogin"] forState:UIControlStateNormal];
    [_firstVisitBut setBackgroundImage:[UIImage imageNamed:@"firstVisit"] forState:UIControlStateNormal];
#elif TARGET_VERSION_LITE ==2//授权版
    [_loginBut setBackgroundImage:[UIImage imageNamed:@"tow_code_login"] forState:UIControlStateNormal];
    [_firstVisitBut setBackgroundImage:[UIImage imageNamed:@"auth_code_login"] forState:UIControlStateNormal];

#endif
    
    [_firstVisitBut addTarget:self action:@selector(didSelectFirstVisit) forControlEvents:UIControlEventTouchUpInside];
    [_loginBut addTarget:self action:@selector(didSelectLogin) forControlEvents:UIControlEventTouchUpInside];
    [_memoryBut addTarget:self action:@selector(didMemoryCode) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)dealloc
{
    [_authDecode release];
    [HUD release];
    [super dealloc];
}
-(void)didDismiss:(NSNotification *)notify{
    
    NSDictionary *dic = [notify object];
    [self dismissViewControllerAnimated:NO completion:^{
        
        [self didSelectLoginFromRegister:dic];

    }];
}
-(void)didSelectLoginFromRegister:(NSDictionary *)dic{
    
    [[SavaData shareInstance] savaDictionary:dic keyString:@"registerToLogin"];
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:loginViewController animated:NO];
    [loginViewController release];
}
//首次访问
- (void)didSelectFirstVisit
{
#if TARGET_VERSION_LITE ==1//免费版
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDismiss:) name:@"logoViewToLogin" object:nil];
    FirstVisitMoviewPlayViewCtl    *playerViewController = [[FirstVisitMoviewPlayViewCtl alloc] init];
    playerViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    playerViewController.registerBut.hidden = YES;
    playerViewController.imageBg.hidden = YES;
    [playerViewController.view setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [self presentViewController:playerViewController animated:YES completion:nil];//横屏只能用present
    
    [playerViewController release];
#elif TARGET_VERSION_LITE ==2//授权版
    //授权码登陆
    AuthLoginViewController *authLogin = [[AuthLoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:authLogin];
    [self presentViewController:nav animated:YES completion:nil];
    [authLogin release];
    [nav release];
#endif
    
}

//登陆页面
- (void)didSelectLogin
{
#if TARGET_VERSION_LITE ==1//免费版
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginViewController animated:NO];
    [loginViewController release];
#elif TARGET_VERSION_LITE ==2//授权版
    
    [self twoDimLogin];

#endif
    
}
-(void)twoDimLogin{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectShowOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    num = 0;
    upOrdown = NO;
    _VerticalScreen = YES;
    //判断设备类型
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    _reader = [ZBarReaderViewController new];
    _reader.readerDelegate = self;
    _reader.sourceType = UIImagePickerControllerSourceTypeCamera;
    _reader.supportedOrientationsMask = ZBarOrientationMask(UIDeviceOrientationPortrait);
    UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height-49)];
    if (SCREEN_HEIGHT == 568 && version >= 7.0) {
        aView.frame = CGRectMake(0, 0, 320, self.view.bounds.size.height + 30);
    }
    
    aView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_sweep_backg"]];
    aView.alpha=0.7;
    UIImageView *aImageView=[[UIImageView alloc] initWithFrame:CGRectMake(44, self.view.bounds.size.height-49-75, 232, 45)];
    [aImageView setImage:[UIImage imageNamed:@"ic_sweep_lay"]];
    [aView addSubview:aImageView];
    
    _line=[[UIImageView alloc] initWithFrame:CGRectMake(49, 100, 221, 10)];
    [_line setImage:[UIImage imageNamed:@"ic_sweep_line"]];
    [aView addSubview:_line];
    
    
    _reader.cameraOverlayView=aView;
    [aImageView release];
    [_line release];
    [aView release];
    
    [self handletheToolBar:_reader];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    ZBarImageScanner *scanner = _reader.scanner;
    
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [self presentViewController:_reader animated:YES completion:nil];
    [_reader release];

}
-(void)detectShowOrientation{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];

    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||[UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)     {
        
        _selectPhotoBtn.frame = CGRectMake(self.view.frame.size.height - 70, 7, 60, 25);
        _selectPhotoBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_selectPhotoBtn setBackgroundImage:[UIImage imageNamed:@"ic_sweep_selectPhotoBtn25"] forState:UIControlStateNormal];
        _VerticalScreen = NO;
        UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 320-30)];
        if (SCREEN_HEIGHT == 568) {
            aView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_sweep_horizontal1136"]];
        }else if (SCREEN_HEIGHT == 480){
            aView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_sweep_horizontal960"]];
        }
        aView.alpha=0.7;
        _line = [[UIImageView alloc] init];
        _line.frame = CGRectMake((self.view.frame.size.height - 221)/2, 20, 221, 10);
        [_line setImage:[UIImage imageNamed:@"ic_sweep_line"]];
        [aView addSubview:_line];
        [_line release];
        _reader.cameraOverlayView = aView;
        [aView release];
        _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];

    }else{//
        _selectPhotoBtn.frame = CGRectMake(250, 10, 60, 31);
        _selectPhotoBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_selectPhotoBtn setBackgroundImage:[UIImage imageNamed:@"ic_sweep_selectPhotoBtn25"] forState:UIControlStateNormal];
        _VerticalScreen = YES;
        UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height-49)];
        if (SCREEN_HEIGHT == 568 && version >= 7.0) {
            aView.frame = CGRectMake(0, 0, 320, self.view.bounds.size.height + 30);
        }
        
        aView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_sweep_backg"]];
        aView.alpha=0.7;
        _line=[[UIImageView alloc] initWithFrame:CGRectMake(49, 100, 221, 10)];
        [_line setImage:[UIImage imageNamed:@"ic_sweep_line"]];
        [aView addSubview:_line];
        [_line release];
        UIImageView *aImageView=[[UIImageView alloc] initWithFrame:CGRectMake(44, self.view.bounds.size.height-49-75, 232, 45)];
        [aImageView setImage:[UIImage imageNamed:@"ic_sweep_lay"]];
        [aView addSubview:aImageView];
        [aImageView release];
        _reader.cameraOverlayView = aView;
        [aView release];
        num = 0;
        upOrdown = NO;
        _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    }
}

-(void)handletheToolBar:(ZBarReaderViewController *)reader{
    
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    if (version>=6.0) {
        int i = 0;
        for (UIView *temp in [reader.view subviews]) {
            for (UIView *v in [temp subviews]) {
                if ([v isKindOfClass:[UIToolbar class]]) {
                    UIToolbar *toolBar = (UIToolbar *)v;
                    _selectPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [_selectPhotoBtn setBackgroundImage:[UIImage imageNamed:@"ic_sweep_selectPhotoBtn35"] forState:UIControlStateNormal];
                    [_selectPhotoBtn setTitle:@"选择图片" forState:UIControlStateNormal];
                    _selectPhotoBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
                    _selectPhotoBtn.frame = CGRectMake(250, 10, 60, 31);
                    [_selectPhotoBtn addTarget:self action:@selector(scanPhotoImage) forControlEvents:UIControlEventTouchUpInside];
                    [toolBar addSubview:_selectPhotoBtn];
                    for (UIView *ev in [v subviews]) {
                        if (i== 3) {
                            [ev removeFromSuperview];
                        }
                        i++;
                    }
                }
            }
        }
    }else{
        int i = 0;
        for (UIView *temp in [reader.view subviews]) {
            for (UIView *v in [temp subviews]) {
                if ([v isKindOfClass:[UIToolbar class]]) {
                    for (UIView *ev in [v subviews]) {
                        if (i== 2) {
                            [ev removeFromSuperview];
                        }
                        i++;
                    }
                }
            }
        }
    }
}
-(void)animationLine{
    
    if (_VerticalScreen) {//竖屏
        float begin = 7*self.view.bounds.size.height/48 + 30;
        
        if (upOrdown == NO) {
            num ++;
            _line.frame = CGRectMake(49, begin+2*num, 220,10);
            if (2*num == 184) {
                upOrdown = YES;
            }
        }
        else {
            num --;
            _line.frame = CGRectMake(49, begin+2*num, 220,10);
            if (num == 0) {
                upOrdown = NO;
            }
        }
    }else{//横屏
        float begin = 20;
        float beginX = (self.view.frame.size.height - 221)/2;
        if (upOrdown == NO) {
            num ++;
            _line.frame = CGRectMake(beginX, begin+2*num, 220,10);
            if (2*num == 184) {
                upOrdown = YES;
            }
        }
        else {
            num --;
            _line.frame = CGRectMake(beginX, begin+2*num, 220,10);
            if (num == 0) {
                upOrdown = NO;
            }
        }
    }
}
- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader withRetry: (BOOL) retry
{
    if(retry){
        _fromPhotoLibrary = NO;
        //retry == 1 选择图片为非二维码。
        [reader dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您选择的图片非授权码生成的二维码，需要重新选择吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            alert.tag = NotCode;
            [alert show];
            [alert release];
        }];
    }}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    if (_fromPhotoLibrary) {
        _fromPhotoLibrary = NO;
        [picker dismissViewControllerAnimated:YES completion:^{
            [picker removeFromParentViewController];
        }];
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [_timer invalidate];
    
    num = 0;
    upOrdown = NO;
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
    }];
}
- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _line.frame = CGRectMake(49, 7*self.view.bounds.size.height/48 + 35, 220, 10);
    num = 0;
    upOrdown = NO;

    if (reader.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        id<NSFastEnumeration> results =
        [info objectForKey: ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        NSDictionary *dict=[symbol.data objectFromJSONString];
        [reader dismissViewControllerAnimated:NO completion:^{
            [self networkPromptMessage:@"正在处理"];
            NSString *www = dict[@"ieternal"];
            NSString *authEnCode = dict[@"authcode"];
            if ([www isEqualToString:@"www.ieternal.com"] && authEnCode) {
                _authDecode = [NSString base64Decode:authEnCode];
                [_authDecode retain];
                [self sendReq];
            }else{
                [_reader dismissViewControllerAnimated:NO completion:^{
                    SweepNotourViewController *sweepVC=[[SweepNotourViewController alloc] init];
                    sweepVC.sweepResults=[NSString stringWithFormat:@"%@",symbol.data];
                    [self.navigationController pushViewController:sweepVC animated:YES];
                    [sweepVC release];
                    [HUD removeFromSuperview];
                }];
            }
        }];
        
    }else if (reader.sourceType == UIImagePickerControllerSourceTypeCamera){
        
        id<NSFastEnumeration> results =
        [info objectForKey: ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        NSDictionary *dict=[symbol.data objectFromJSONString];
        NSString *www = dict[@"ieternal"];
        NSString *authEnCode = dict[@"authcode"];
        [self networkPromptMessage:@"正在处理"];
        if ([www isEqualToString:@"www.ieternal.com"] && authEnCode) {
            _authDecode = [NSString base64Decode:authEnCode];
            [_authDecode retain];
            [self sendReq];
        }else{
            
            [_reader dismissViewControllerAnimated:NO completion:^{
                SweepNotourViewController *sweepVC=[[SweepNotourViewController alloc] init];
                sweepVC.sweepResults=[NSString stringWithFormat:@"%@",symbol.data];
                [self.navigationController pushViewController:sweepVC animated:YES];
                [sweepVC release];
                [HUD removeFromSuperview];
            }];
        }
    }
}
-(void)scanPhotoImage{
    
    _fromPhotoLibrary = YES;
    ZBarReaderController *reader = [[ZBarReaderController alloc] init];
    reader.readerDelegate = self;
    reader.showsHelpOnFail = NO;
    reader.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [reader.scanner setSymbology: ZBAR_I25
                          config: ZBAR_CFG_ENABLE
                              to: 0];
    [_reader presentViewController:reader animated:YES completion:nil];
    [reader release];
}
-(void)sendReq{
    
    NSString *platformStr = [MD5 md5:@"ios"];
    NSString *tokenStr = [MD5 md5:[[SavaData shareInstance] printToken:TOKEN]];
    NSString *str = [tokenStr stringByAppendingString:platformStr];
    NSString *str1 = [MD5 md5:str];
    str1 = [str1 substringWithRange:NSMakeRange(8, 16)];
    NSString *str2 = [MD5 md5:str1];
    NSString *str3 = [MD5 md5:_authDecode];
    str3 = [str3 substringWithRange:NSMakeRange(8, 16)];
    NSString *str4 = [str3 stringByAppendingString:str2];
    str4 = [MD5 md5:str4];
    NSURL *url = [[RequestParams sharedInstance] getAuthCodeLogin];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setPostValue:@"scancode" forKey:@"flag"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:_authDecode forKey:@"authcode"];
    [request setPostValue:str4 forKey:@"checkstr"];
    [request setTimeOutSeconds:20];
    [request startAsynchronous];
    
}
-(void)requestFinished:(ASIHTTPRequest *)request{
    
    [HUD removeFromSuperview];
    [_reader dismissViewControllerAnimated:YES completion:nil];
    
    NSData *data = [request responseData];
    NSDictionary *dic = [data objectFromJSONData];
    
    if ([dic[@"success"] integerValue] ==1) {
        
        if ([Utilities checkNetwork]) {
            [[EMPhotoSyncEngine sharedEngine] SyncOperation];
        }
        
        NSDictionary *dataDic = [dic objectForKey:@"data"];
        if ([dataDic isKindOfClass:[NSDictionary class]]) {
            
            //用户基本信息的存储一定要放在最前面，其他处理会使用到用户信息
            NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithCapacity:10];
            [userInfoDic setDictionary:dataDic];
            //保存用户ID
            NSString *userIDString = [userInfoDic objectForKey:@"userId"];
            NSString *userId = [userIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [[SavaData shareInstance] savadataStr:userId KeyString:USER_ID_SAVA];
            [[SavaData shareInstance] savadataStr:userIDString KeyString:USER_ID_ORIGINAL];


            //保存认证码
            NSString *serverAuth = [NSString stringWithFormat:@"%@",[userInfoDic objectForKey:@"serverAuth"]];
            [[SavaData shareInstance] savadataStr:[serverAuth retain] KeyString:USER_AUTH_SAVA];
            
            [serverAuth release];
            //数据写入plist
            [SavaData writeDicToFile:[userInfoDic retain] FileName:User_File];
            [userInfoDic release];
            
            //保存当前登录用户服务器地址配置
            [[SavaData shareInstance] savadataStr:dataDic[@"specifiedhost"] KeyString:@"specifiedhost"];
            [[SavaData shareInstance] savadataStr:dataDic[@"specifiedport"] KeyString:@"specifiedport"];
            
            
            //生日、忌日加入本地提醒
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            NSArray *familymembers = dic[@"meta"][@"familymembers"];
            for(NSDictionary *obj in familymembers){
                [self addLocalRemindToShedule:obj];
            }
            //
            
            [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"forbidenStatu"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [[SavaData shareInstance] savaDataBool:YES KeyString:ISHANDLOGIN];
            [[SavaData shareInstance] savaDataBool:YES KeyString:ISLOGIN];
            
            
            //设置是否开启同步
            //[[SavaData shareInstance] savadataStr:@"1" KeyString:kOpenSynchr];
            
            NSDictionary *metaDic = [NSDictionary dictionaryWithDictionary:dic[@"meta"]];
            if (metaDic.count>0 && [metaDic isKindOfClass:[NSDictionary class]]) {
                [[SavaData shareInstance] savaDictionary:metaDic[@"favoriteStyle"] keyString:@"favoriteStyleDic"];
            }
            
            [BaseDatas openBaseDatas:USERID];
            [BaseDatas closeBaseDatas:USERID];
            
            
        }
        
        //登录时重置离线下载使用的数据
        [offLine stopOfflineDownLoad];
        [offLine reset];
        [failedDownLoad stopOfflineDownLoad];
        [failedDownLoad reset];
        
        //查看是否已封存
        if ([dic[@"errorcode"] integerValue] == 9000) {
            [[SavaData shareInstance] savaData:1 KeyString:@"ISCLOSE"];
            LoginSecondViewController *loginSecondVC = [[LoginSecondViewController alloc] initWithNibName:@"LoginSecondViewController" bundle:nil];
            [self.navigationController pushViewController:loginSecondVC animated:YES];
            [loginSecondVC release];
        }else{
            [[SavaData shareInstance] savaData:0 KeyString:@"ISCLOSE"];
            SealWarnViewController *sealWarn = [[SealWarnViewController alloc] initWithNibName:@"SealWarnViewController" bundle:nil];
            NSString *authLeftTime = dataDic[@"authLeftTime"];
            sealWarn.authLeftTime = authLeftTime;
            
            sealWarn.authStartTime = dataDic[@"authStartTime"];
            sealWarn.authEndTime   = dataDic[@"authEndTime"];
            
            [[SavaData shareInstance] savadataStr:authLeftTime KeyString:@"authLeftTime"];
            
            [self.navigationController pushViewController:sealWarn animated:YES];
            [sealWarn release];
        }
    }else{
        [MyToast showWithText:dic[@"message"] :150];
    }
}
-(void)requestFailed:(ASIHTTPRequest *)request{
    
    [HUD removeFromSuperview];
    [_reader dismissViewControllerAnimated:YES completion:nil];
    [MyToast showWithText:@"请检查网络" :150];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancalCodeView" object:nil];
}
-(void)addLocalRemindToShedule:(NSDictionary *)dict{
    
    if ([dict[@"birthWarned"] integerValue] == 1) {
        NSString *dateStr = [NSString stringWithFormat:@"%@ 09:00:00",[Utilities convertTimestempToDateWithString2:dict[@"birthDate"]]];
        NSDate *date = [Utilities transformDateStrToDate:dateStr];
        
        [self settingLocalRemind:date andType:@"生日" andMemberId:dict[@"memberId"] andName:dict[@"name"] andTime:@"今天"];
        NSInteger duration = 24*60*60;
        date = [date dateByAddingTimeInterval:-duration];
        [self settingLocalRemind:date andType:@"生日" andMemberId:dict[@"memberId"] andName:dict[@"name"] andTime:@"明天"];
        
    }
    if ([dict[@"deathWarned"] integerValue] == 1) {
        NSString *dateStr = [NSString stringWithFormat:@"%@ 09:00:00",[Utilities convertTimestempToDateWithString2:dict[@"deathDate"]]];
        NSDate *date = [Utilities transformDateStrToDate:dateStr];
        [self settingLocalRemind:date andType:@"忌日" andMemberId:dict[@"memberId"] andName:dict[@"name"] andTime:@"今天"];
        NSInteger duration = 24*60*60;
        date = [date dateByAddingTimeInterval:-duration];
        [self settingLocalRemind:date andType:@"生日" andMemberId:dict[@"memberId"] andName:dict[@"name"] andTime:@"明天"];
    }
    
}

-(void)settingLocalRemind:(NSDate *)date andType:(NSString *)type andMemberId:(NSString *)memberId andName:(NSString *)name andTime:(NSString *)time{
    
    UILocalNotification *newNotification = [[UILocalNotification alloc] init];
    if (newNotification) {
        
        //时区
        
        newNotification.timeZone=[NSTimeZone defaultTimeZone];
        
        ///
        newNotification.fireDate=date;//[date dateByAddingTimeInterval:120];
        
        //推送内容
        
        newNotification.alertBody = [NSString stringWithFormat:@"永恒记忆提醒您：\n%@是%@的%@",time,name,type];
        
        //应用右上角红色图标数字
        //        newNotification.applicationIconBadgeNumber = 1;
        
        newNotification.soundName = UILocalNotificationDefaultSoundName;
        
        //设置按钮
        
        newNotification.alertAction = @"关闭";
        
        //判断重复与否
        
        newNotification.repeatInterval = NSYearCalendarUnit;
        newNotification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:memberId,@"memberId",type,@"type",time,@"time",nil];
        [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
        [newNotification release];
        
    }
}
- (void)networkPromptMessage:(NSString *)message
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = message;
    HUD.mode = MBProgressHUDModeText;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == NotCode && buttonIndex == 1) {
        [self scanPhotoImage];
    }
}
@end


@implementation UINavigationController (navCtrl)

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
