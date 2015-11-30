//
//  LoginSecondViewController.m
//  EternalMemory
//
//  Created by Guibing on 13-12-5.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import "OffLineDownLoadViewController.h"
#import "AssociatedDownLoadController.h"
#import "LoginSecondViewController.h"
#import "MyLifeMainViewController.h"
#import "FailedOfflineDownLoad.h"
#import "MyHomeViewController.h"
#import "CheckAppVersion.h"
#import "OfflineDownLoad.h"
#import "MyFamilySQL.h"
#import "MyToast.h"


#define NONET_ALERT_TAG  100

#define failedDownLoad  [FailedOfflineDownLoad shareInstance]
#define offLine         [OfflineDownLoad shareOfflineDownload]


@interface LoginSecondViewController ()
{
    BOOL        isSecond;
}
@end

@implementation LoginSecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    
    _guideImg = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    self.middleBtn.hidden = YES;
    self.titleLabel.hidden = YES;
    self.navBarView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewInterFace:) name:@"offLineDownloadSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewInterFace:) name:@"assocaitedDownloadSuccess" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAssociatedMembers:) name:@"showAssociatedMembers" object:nil];

    isSecond = NO;
    
    BOOL regist = [[SavaData shareInstance] printBoolData:First_Regist];
    if (regist) {
        [[SavaData shareInstance] savaDataBool:NO KeyString:First_Regist];
        [self addGuideView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (iOS7) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //判断是否需要进入家园，首次进来不会进，第二次加载会进入家园

    if (isSecond) {
        [self didPush];
    }
    isSecond = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self monitorNewVersion];
}
-(void)addGuideView{
    
    _guideImg = [[UIImageView alloc] init];
    _guideImg.contentMode = UIViewContentModeScaleAspectFit;
    if (SCREEN_HEIGHT == 568) {
        _guideImg.image = [UIImage imageNamed:@"home_guide1136"];
    }else{
        _guideImg.image = [UIImage imageNamed:@"home_guide960"];
    }
    _guideImg.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _guideImg.userInteractionEnabled = YES;
    [self.view addSubview:_guideImg];
    [_guideImg release];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeGuideView)];
    [_guideImg addGestureRecognizer:recognizer];
    [recognizer release];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(53, 167, 214, 82);
    [btn addTarget:self action:@selector(didTapOnLineTouchInside:) forControlEvents:UIControlEventTouchUpInside];
    [_guideImg addSubview:btn];
    
}

-(void)removeGuideView{
    
    [_guideImg removeFromSuperview];
    
}
- (void)didPush
{
    
    MyLifeMainViewController *next = [[MyLifeMainViewController alloc]initWithNibName:iPhone5?@"MyLifeMainViewController-5":@"MyLifeMainViewController" bundle:nil];
    next.isNewVersion = YES;
    [self.navigationController pushViewController:next animated:YES];
    [next release];
    
}
- (void)monitorNewVersion
{
    //版本更新提示
//    [CheckAppVersion checkAppVersionFromWhere:self];
    NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    NSURL *url =  [[RequestParams sharedInstance] getClientVersion];
    ASIFormDataRequest *requestUpData = [ASIFormDataRequest requestWithURL:url];
    [requestUpData setRequestMethod:@"POST"];
    [requestUpData addPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [requestUpData addPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [requestUpData setPostValue:@"ios" forKey:@"platform"];
    [requestUpData setPostValue:localVersion forKey:@"versions"];
    [requestUpData setTimeOutSeconds:10];
    requestUpData.failedBlock = ^(void)
    {
    };
    requestUpData.completionBlock = ^(void)
    {
        NSData *data = [requestUpData responseData];
        NSDictionary *dataDic = [data objectFromJSONData];
        NSInteger success = [[dataDic objectForKey:@"success"] integerValue];
        
        if (success==1) {
            
            if (![dataDic[@"data"] isEqual:@""]) {
                NSString *serverVersion = dataDic[@"data"][@"versions"];
                int serverVersInt = [[serverVersion stringByReplacingOccurrencesOfString:@"." withString:@""]integerValue];
                if ([[NSString stringWithFormat:@"%d",serverVersInt] length] == 2) {
                    serverVersInt = [[NSString stringWithFormat:@"%d0",serverVersInt] integerValue];
                }
                int localVersionInt = [[localVersion stringByReplacingOccurrencesOfString:@"." withString:@""]integerValue];
                if ([[NSString stringWithFormat:@"%d",localVersionInt] length] == 2) {
                    localVersionInt = [[NSString stringWithFormat:@"%d0",localVersionInt] integerValue];
                }
                if (serverVersInt > localVersionInt) {
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"版本升级提示" message:[NSString stringWithFormat:@"最新版本为:%@",serverVersion] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即升级", nil];
                    alert.tag = 200;
                    [alert show];
                    [alert release];
                }
            }
        }else if ([dataDic[@"errorcode"] integerValue] == 1005)
        {
            self.errorcodeStr = dataDic[@"errorcode"];
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }
    };
    [requestUpData startAsynchronous];

}

- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapOnLineTouchInside:(UIButton *)sender
{
    [[SavaData shareInstance] savadataStr:@"onLine" KeyString:@"HomeType"];
    BOOL network = [Utilities checkNetwork];
    if (network) {
        [self pushHomeViewCtrl:@"onLine"];
    }else{
        [self pushHomeViewCtrl:@"offLine"];
    }
}

- (IBAction)didTapOffLineTouchInside:(UIButton *)sender
{
    [[SavaData shareInstance] savadataStr:@"offLine" KeyString:@"HomeType"];
    if ([Utilities checkNetwork])
    {
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    if ([reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您现在处在3G网络中，是否继续下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
        [alertView show];
        [alertView release];
    }
    else if ([reachability currentReachabilityStatus] == ReachableVia2G)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您现在处在2G网络中，是否继续下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
        [alertView show];
        [alertView release];
    }
    else if ([reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        isSecond = NO;
//        OfflineDownLoad *offline = [OfflineDownLoad shareOfflineDownload];
//        FailedOfflineDownLoad *failedOffline = [FailedOfflineDownLoad shareInstance];
        if (offLine.downloadFinished == YES && failedDownLoad.downloadFinished == YES)
        {
            [MyToast showWithText:@"离线下载成功，请在线使用浏览" :200];
            return;
        }
        else
        {
            OffLineDownLoadViewController *offlineDownloadCtrl = [[OffLineDownLoadViewController alloc] init];
            [self.navigationController pushViewController:offlineDownloadCtrl animated:YES];
            [offlineDownloadCtrl release];
        }
    }
    }else if(![Utilities checkNetwork]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请检查网络" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"进家园", nil];
        alert.tag = NONET_ALERT_TAG;
        [alert show];
        [alert release];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == NONET_ALERT_TAG) {
        if (buttonIndex == 1) {
            [self pushHomeViewCtrl:@"offLine"];
        }
    }else if (alertView.tag == 200){
        //监测新版本
        if (buttonIndex ==1) {
            NSString *updateStr = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@",APPLE_ID];
            NSURL *url = [NSURL URLWithString:updateStr];
            [[UIApplication sharedApplication]openURL:url];
        }
    }else if ([self.errorcodeStr isEqualToString:@"1005"]){
        
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
    }else{
        if (buttonIndex == 1)
        {
            isSecond = NO;
            OffLineDownLoadViewController *offlineDownloadCtrl = [[OffLineDownLoadViewController alloc] init];
            [self.navigationController pushViewController:offlineDownloadCtrl animated:YES];
            [offlineDownloadCtrl release];
        }
    }
}
-(void)didPushSetting{
    
    MyLifeMainViewController *next = [[MyLifeMainViewController alloc]initWithNibName:iPhone5?@"MyLifeMainViewController-5":@"MyLifeMainViewController" bundle:nil];
    next.isNewVersion = YES;
    [self.navigationController pushViewController:next animated:YES];
    [next release];
}
//进入家园
- (void)pushHomeViewCtrl:(NSString *)str
{
    
    isSecond = YES;
    if ([str isEqualToString:@"onLine"]) {
        MyHomeViewController *homeViewCtrl = [[MyHomeViewController alloc] init];
        homeViewCtrl.comeFrom = @"onLine";
        [self.navigationController pushViewController:homeViewCtrl animated:YES];
        [homeViewCtrl release];
    }else if([str isEqualToString:@"offLine"]){
        
        MyHomeViewController *homeViewCtrl = [[MyHomeViewController alloc] init];
        homeViewCtrl.comeFrom = @"offLine";
        [self.navigationController pushViewController:homeViewCtrl animated:YES];
        [homeViewCtrl release];
    }
}

//进入关联人界面
-(void)showAssociatedMembers:(NSNotification *)sender
{
//    [self.navigationController popViewControllerAnimated:NO];
    AssociatedDownLoadController *associatedCtrl = [[AssociatedDownLoadController alloc] init];
    associatedCtrl.associatedArray = [MyFamilySQL getAssociatedMembers];
    [self.navigationController pushViewController:associatedCtrl animated:YES];
    [associatedCtrl release];

}

-(void)showNewInterFace:(NSNotification *)sender
{
    [self.navigationController popViewControllerAnimated:NO];
    isSecond = YES;
    MyHomeViewController *homeViewCtrl = [[MyHomeViewController alloc] init];
    homeViewCtrl.comeFrom = @"offLine";
    [self.navigationController pushViewController:homeViewCtrl animated:YES];
    [homeViewCtrl release];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
