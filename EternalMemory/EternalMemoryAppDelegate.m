 //
//  EternalMemoryAppDelegate.m
//  EternalMemory
//
//  Created by sun on 13-5-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//



#import "RegisterSecondStepViewController.h"
#import "OffLineDownLoadViewController.h"
#import "FirstVisitMoviewPlayViewCtl.h"
#import "NdUncaughtExceptionHandler.h"
#import "ResumeVedioSendOperation.h"
#import "EternalMemoryAppDelegate.h"
#import "MyLifeMainViewController.h"
#import "LogoMPMoviewPlayViewCtl.h"
#import "AuthLoginViewController.h"
#import "StyleSelectListViewCtrl.h"
#import "FailedOfflineDownLoad.h"
#import "RMWFirstTouchHelpView.h"
#import "LoginViewController.h"
#import "UploadingDebugging.h"
#import "EMPhotoSyncEngine.h"
#import "DownloadViewCtrl.h"
#import "OfflineDownLoad.h"
#import "DiaryMessageSQL.h"
#import "RequestParams.h"
#import "StyleListSQL.h"
#import "Reachability.h"
#import "MessageSQL.h"
#import "BaseDatas.h"
#import "Utilities.h"
#import "FileModel.h"
#import "SavaData.h"
#import "MyToast.h"
#import "Config.h"
#import "NdUncaughtExceptionHandler.h"
#import "ExceptionBugSQL.h"
//#import "UncaughtExceptionHandler.h"


#define REQUEST_FOR_LOGIN 100
#define OTHERPLACE_LOGIN  200

@interface EternalMemoryAppDelegate()
{
    Reachability     *hostReach;
    BOOL              onBackGround;
    BOOL              firstOnBack;
    AVAudioPlayer    *backPlayer;
}

@end


#define FileModel  [FileModel sharedInstance]
#define ResumeUploading [ResumeVedioSendOperation shareInstance]


@implementation EternalMemoryAppDelegate
static EternalMemoryAppDelegate *_appDelegate;
- (void)dealloc
{
    [_window release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [playerViewController release];
    [_configAry release];
    [super dealloc];
    
}
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize photoNumberInt = _photoNumberInt;
@synthesize synDataCount = _synDataCount;
@synthesize synData = _synData;
@synthesize enterDownload;

//- (void)installUncaughtExceptionHandler
//{
//	InstallUncaughtExceptionHandler();
//}
//- (void)badAccess
//{
//    void (*nullFunction)() = NULL;
//    
//    nullFunction();
//}

- (NSString *)getBugExceptionPath{
    
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [filePath stringByAppendingPathComponent:@"Exception.txt"];
    return path;
    
}
-(void)saveBugInfoOnServer:(NSArray *)array{
    
    ASINetworkQueue *queue = [[ASINetworkQueue alloc] init];    // 初始化
    
    for (int i = 0; i < array.count; i ++) {
        
        NSDictionary *dic = array[i];
        NSURL *url = [[RequestParams sharedInstance] uploadBugInfo];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        request.shouldAttemptPersistentConnection = NO;
        [request setPostValue:dic[@"content"] forKey:@"content"];
        [request setPostValue:dic[@"osversion"] forKey:@"osversion"];
        [request setPostValue:dic[@"appversion"] forKey:@"appversion"];
        [request setPostValue:@"ios" forKey:@"platform"];
        [request setPostValue:dic[@"happentime"] forKey:@"happentime"];
        [request setPostValue:dic[@"devicemodel"] forKey:@"phonemodel"];
        [request setPostValue:dic[@"internet"] forKey:@"internet"];
        request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"bugID", nil];
        [request setRequestMethod:@"POST"];
        [request setTimeOutSeconds:10.0];
        [request setCompletionBlock:^{
            [self requestBugSuccess:request];
        }];
        [request setFailedBlock:^{
            [self requestFailed:request];
        }];
        [queue addOperation:request];
    }
    [queue go];        // 开始下载网络数据
    [queue release];

}
-(void)requestBugSuccess:(ASIFormDataRequest *)request{
    
    NSNumber *bugID = request.userInfo[@"bugID"];
    [ExceptionBugSQL deleteExceptionBugInfo:[bugID integerValue]];
}
-(void)requestBugFail:(ASIFormDataRequest *)request{
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //http://dev3.ieternal.com/home/redirectfamily?associatekey=eternalnum&associatevalue=10006&associateauthcode=01epuayq&eternalcode=&associateuserid=ce733646-f8b4-11e2-853e-00163e0202ca
    //TODO:风格不支持断点续传，所以数据库中处于正在下载的状态的数据要删除
    [StyleListSQL deleteDownLoadByIsDownLoad:2];
    _appDelegate = self;
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
//    [self performSelector:@selector(installUncaughtExceptionHandler) withObject:nil afterDelay:0];
//	[self performSelector:@selector(string) withObject:nil afterDelay:4.0];
//	[self performSelector:@selector(badAccess) withObject:nil afterDelay:10.0];
    [NdUncaughtExceptionHandler setDefaultHandler];
    
//    NSString *content = [NSString stringWithContentsOfFile:[self getBugExceptionPath] encoding:NSUTF8StringEncoding error:nil];
//    if (content.length > 0) {
//        bugContent = content;
//    }
    if ([Utilities checkNetwork]) {
        NSArray *bugArray = [ExceptionBugSQL getAllExceptionBugInfo];
        [self saveBugInfoOnServer:bugArray];
    }
    
//取值
    
    //ZGL:记录是否首次开启应用
    BOOL noFirstUse = [[SavaData shareInstance] printBoolData:@"noFirstUse"];
    if (!noFirstUse) {
        
        [self showLogoVideo];
        
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_async(queue, ^{
            [BaseDatas moveToDBFile];
        });

    }else{
       
        [self showLogoView];
    }
    _isLogin = USER_IS_LOGIN;
    enterDownload = NO;
    _photoNumberInt = 0;
    NSString *isFirst = @"1";
    NSString *first = NOT_NOTIFY;
    if ([first isEqualToString:@"2"]) {
       //不再提示 不变～
    }else{
        [[SavaData shareInstance]savadataStr:isFirst KeyString:NO_NOTICE];
    }
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge)];

//    [self setServerConfig];
//判断是否是首次登录 by jxl
    if (!_isLogin) {
        
        //注册推送服务
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        if (launchOptions) {
            NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (pushNotificationKey) {
                application.applicationIconBadgeNumber = 0;
            }
        }
        //创建数据库
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_async(queue, ^{
            [BaseDatas getBaseDatasInstance];

        });
    }

    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(reachabilityChanged:)
                                                      name:kReachabilityChangedNotification
                                                    object:nil];
        hostReach = [[Reachability  reachabilityWithHostName:@"www.google.com"] retain];
        [hostReach  startNotifier];
    }
    application.applicationIconBadgeNumber = 0;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)reachabilityChanged: (NSNotification *)note {
    BOOL isInFirstVC = [[[(UINavigationController *)self.window.rootViewController viewControllers] lastObject] isKindOfClass:[LogoMPMoviewPlayViewCtl class]];
    Reachability  *curReach = [note object];
    NSParameterAssert([curReach  isKindOfClass:[Reachability class]]);
    NetworkStatus  status = [curReach  currentReachabilityStatus];
    if (status == ReachableViaWiFi || status == ReachableViaWWAN || status == ReachableVia2G)
    {
        if (USER_IS_LOGIN)
        {
            NSArray *diatyArray = [DiaryMessageSQL getMessagesBySyn:@"0"];
            if (diatyArray && [diatyArray count] > 0)
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizeDataOver:) name:@"synDataOver" object:nil];
                _synDataCount = diatyArray.count;
                _synData = [[SynDataBackstage alloc] init];
                [_synData synchronousDBData];
            }
            NSString *offLineStyleString = [[SavaData shareInstance] printDataStr:offLineStyle];
            if ([offLineStyleString isEqualToString:@"off"]) {
            }else{
                if (offLineStyleString.length>0){
                    [MyToast showWithText:@"正在同步风格设置" :200];
                    [StyleSelectListViewCtrl offLineStyleSelect:offLineStyleString];
                    [[SavaData shareInstance] savadataStr:@"" KeyString:offLineStyle];
                }
            }
            
            
            if (!isInFirstVC) [[EMPhotoSyncEngine sharedEngine] SyncOperation];

            if (status == ReachableViaWWAN || status == ReachableVia2G)
            {
                 OfflineDownLoad *offline = [OfflineDownLoad shareOfflineDownload];
                 FailedOfflineDownLoad *failedOffline = [FailedOfflineDownLoad shareInstance];
                if (offline.downloading == YES || failedOffline.downloading == YES)
                {
                    [offline setsupendOfflineDownLoad];
                    [failedOffline setsupendOfflineDownLoad];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"网络切换是否继续下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
                    alertView.tag = 1000;
                    [alertView show];
                    [alertView release];
                }

            }
            else if (status == ReachableViaWiFi)
            {
                if (enterDownload == YES)
                {
                    OfflineDownLoad *offline = [OfflineDownLoad shareOfflineDownload];
                    __block FailedOfflineDownLoad *failedOffline = [FailedOfflineDownLoad shareInstance];
                    if ((offline.downloadFinished == NO || failedOffline.downloadFinished == NO) && enterDownload == YES)
                    {
                        [offline resumeOfflineDownLoad];
                        offline.downloadFinish = ^(){
                            [failedOffline startOfflineDownLoad];
                        };
                    }
                }
            }
        }
    }
    else if (status == NotReachable)
    {
        OfflineDownLoad *offline = [OfflineDownLoad shareOfflineDownload];
        FailedOfflineDownLoad *failedOffline = [FailedOfflineDownLoad shareInstance];
        if (offline.downloading == YES || failedOffline.downloading == YES)
        {
            [offline setsupendOfflineDownLoad];
            [failedOffline setsupendOfflineDownLoad];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"网络链接失败，请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertView.tag = 1000;
            [alertView show];
            [alertView release];
        }
        ResumeVedioSendOperation *resumeVedioSend = [ResumeVedioSendOperation shareInstance];
        if (resumeVedioSend.isUploading == YES)
        {
            [resumeVedioSend stopUploading];
        }
        [resumeVedioSend setSuspendWhenNetworkNoReachible];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"resumeSuspendWhenNetworkNoReachible" object:nil];
    }
}
-(void)synchronizeDataOver:(NSNotification *)sender
{
    NSInteger count = [sender.object intValue];
    if (_synDataCount == count)
    {
        [_synData cleanRequest];
        [_synData release];
        _synData = nil;
        _synDataCount = 0;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"synDataOver" object:nil];
    }
}
-(void)setServerConfig{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    _configAry = [[NSMutableArray alloc] initWithCapacity:0];
    [_configAry addObjectsFromArray:[userDefault objectForKey:@"config"]];
    if (_configAry.count == 0) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"m.iyhjy.com",@"host",@"http",@"protocol",@"80",@"port",@"1",@"theorder",nil];
        NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"m.ieternal.com",@"host",@"http",@"protocol",@"80",@"port",@"2",@"theorder", nil];
        NSArray *ary = [NSArray arrayWithObjects:dic,dic1,nil];
        [_configAry addObjectsFromArray:ary];
        [userDefault setObject:_configAry forKey:@"config"];
    }
    //*************存储服务端配置;
    _index = 0;
    if ([Utilities checkNetwork]) {
        [self sendRequest:_index];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    //**************
}
-(void)requestFinished:(ASIHTTPRequest *)request{
    
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSString *success=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    NSString *host = resultDictionary[@"meta"][@"servers"][0][@"host"];
    if ([success integerValue] == 1) {
        for (int i = 0; i < _configAry.count; i ++ ) {
            if ([host isEqualToString:_configAry[i][@"host"]]) {
                [_configAry removeObjectAtIndex:i];
                [_configAry insertObject:resultDictionary[@"meta"][@"servers"][0] atIndex:0];
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:_configAry forKey:@"config"];
                [userDefault synchronize];
                return;
            }
        }
        [_configAry insertObject:resultDictionary[@"meta"][@"servers"][0] atIndex:0];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:_configAry forKey:@"config"];
        [userDefault synchronize];
    }
}
-(void)requestFailed:(ASIHTTPRequest *)request{
    
    if (![Utilities checkNetwork]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    _index ++;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if (_index < [[userDefault objectForKey:@"config"] count]) {
        [self sendRequest:_index];
    }
}
-(void)sendRequest:(NSInteger)index{
    
    NSString *str = [NSString stringWithFormat:@"http://%@:%@/",_configAry[index][@"host"],_configAry[index][@"port"]];
    NSURL *url = [[RequestParams sharedInstance] getServerConfig:str];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    request.delegate = self;
    request.shouldAttemptPersistentConnection = NO;
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    [request setPostValue:version forKey:@"appversion"];
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:10.0];
    [request startAsynchronous];
    [request release];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    firstOnBack = YES;
    onBackGround = YES;
    
    ResumeVedioSendOperation *resumeVedioSend = [ResumeVedioSendOperation shareInstance];
    [resumeVedioSend suspendUploadingInBackIndex];
    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:
     ^{
         if (resumeVedioSend.isUploading == YES)
         {
             [self backgroundHandler];
         }
     }];
    [self backgroundHandler];
    
}

- (void)backgroundHandler {
    
    UIApplication *app = [UIApplication sharedApplication];
    __block typeof(self) this = self;
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    __block ResumeVedioSendOperation *resumeVedioSend = [ResumeVedioSendOperation shareInstance];
    __block OfflineDownLoad *offline = [OfflineDownLoad shareOfflineDownload];
    __block FailedOfflineDownLoad *failedOffline = [FailedOfflineDownLoad shareInstance];
    resumeVedioSend.delegate = this;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (((ResumeUploading.isUploading == YES && FileModel.uploadingArr.count != 0) ||(offline.failedArr.count != 0 || offline.downloading == YES)) && onBackGround == YES)
        {
            
            
            //后台下载相关
            if (offline.failedArr.count != 0 || offline.downloading == YES)
            {
                for (UIView *view in self.window.subviews)
                {
                    UIResponder *responder = [view nextResponder];
                    if ([responder isKindOfClass:[UINavigationController class]])
                    {
                        __block OffLineDownLoadViewController *offlineDownLoadViewCtrl = (OffLineDownLoadViewController *) [[(UINavigationController *)responder viewControllers] lastObject];
                        offline.downloadFinish = ^(){
                            offlineDownLoadViewCtrl.cancelButton.userInteractionEnabled = NO;
                            [failedOffline startOfflineDownLoad];
                        };
                    }
                }
                
                failedOffline.didDownLoadFinishedSuccess = ^(BOOL success){
                    if (success == YES)
                    {
                        [offline.failedArr removeObjectAtIndex:failedOffline.downloadIndex];
                    }
                    else
                    {
                        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:offline.failedArr[failedOffline.downloadIndex]];
                        [offline.failedArr removeObjectAtIndex:failedOffline.downloadIndex];
                        [offline.failedArr addObject:dic];
                    }
                };
            }

            
            //后台上传相关
            if (firstOnBack == YES)
            {
                [resumeVedioSend resumeUploading];
                
                firstOnBack = NO;
            }
            resumeVedioSend.uploadSuccess = ^(int index){
                [this uploadingSuccess:index];
            };
            resumeVedioSend.uploadFialed = ^( NSString *identifier,int index){
                [this uploadingFailed:index];
            };
            resumeVedioSend.spaceNotEnough = ^()
            {
                [this spaceIsNotEnough];
            };
            sleep(1);
        }
    });
}

//后台上传失败
-(void)uploadingFailed:(NSInteger)index
{
    [UploadingDebugging setFailedState:index FailedIdentifier:nil];
    [UploadingDebugging goOnUploadingAfterSuccessOrFailed];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadFailedNotification" object:nil];
}

//后台上传成功
-(void)uploadingSuccess:(NSInteger)index
{
    [UploadingDebugging setBackgroundOperation:1 Index:index];
}
//内存空间不足提醒
-(void)spaceIsNotEnough
{
    [UploadingDebugging setBackgroundOperation:2 Index:0];
}
-(void)unexceptedCrash:(NSDictionary *)dic
{
    if ([dic[@"3077"] length] != 0)
    {
        [UploadingDebugging setBackgroundOperation:3 Index:0];
    }
}

//by jxl
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    BOOL network = [Utilities checkNetwork];
    if (!network)
    {
        if ([NOT_NOTIFY isEqualToString:@"1"])
        {
            for (UIView *view in self.window.subviews)
            {
                UIResponder *responder = [view nextResponder];
                if ([responder isKindOfClass:[UINavigationController class]])
                {
                    if (!([[[(UINavigationController *)responder viewControllers] lastObject] isKindOfClass:[LoginViewController class]] ||[[[(UINavigationController *)responder viewControllers] lastObject] isKindOfClass:[RegisterViewController class]] ||[[[(UINavigationController *)responder viewControllers] lastObject] isKindOfClass:[RegisterSecondStepViewController class]] ||[[[(UINavigationController *)responder viewControllers] lastObject] isKindOfClass:[LogoMPMoviewPlayViewCtl class]]||[[[(UINavigationController *)responder viewControllers] lastObject] isKindOfClass:[FirstVisitMoviewPlayViewCtl class]]))
                    {
                        [Utilities addHelpAlert:500 AndDelegate:self];
                        break;
                    }
                }
            }
        }
        else
        {
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithWindow:self.window];
            [self.window addSubview:HUD];
            HUD.labelText = @"请检查网络";
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
            [HUD showAnimated:YES whileExecutingBlock:^{
                sleep(1);
            } completionBlock:^{
                [HUD removeFromSuperview];
                [HUD release];
            }];
        }
    }
    else
    {
//        [UploadingDebugging updateDataWhenBeginOrComeBack];
        [UploadingDebugging dealWithUploadedData];
        [SavaData writeArrToFile:FileModel.uploadingArr FileName:User_Uploading_File];
        for (UIView *view in self.window.subviews)
        {
            UIResponder *responder = [view nextResponder];
            if ([responder isKindOfClass:[UINavigationController class]])
            {
                if ([[[(UINavigationController *)responder viewControllers] lastObject] isKindOfClass:[DownloadViewCtrl class]])
                {
                    __block DownloadViewCtrl *downloadViewCtrl = (DownloadViewCtrl *) [[(UINavigationController *)responder viewControllers] lastObject];
                    [downloadViewCtrl.myTableView reloadData];
                    ResumeUploading.uploadProgress = ^(CGFloat progress,int index,NSString *name){
                        [downloadViewCtrl uploadProgress:progress UploadIndex:index UploadFileName:name];
                    };
                    ResumeUploading.uploadSuccess = ^(int index){
                        [downloadViewCtrl uploadSuccess:index];
                    };
                    ResumeUploading.spaceNotEnough = ^(){
                        [downloadViewCtrl spaceIsNotEnough];
                    };
                }
            }
        }
    }
    onBackGround = NO;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 500) {
        
        if (buttonIndex == 0) {
            
            [[SavaData shareInstance]savadataStr:@"2" KeyString:NO_NOTICE];
            //处理不再提示的alert
        }else{
            [[SavaData shareInstance]savadataStr:@"1" KeyString:NO_NOTICE];
        }
    }else if (alertView.tag == OTHERPLACE_LOGIN){
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [self showLoginVC];
    }
    else if (alertView.tag == 1000)
    {
        OfflineDownLoad *offline = [OfflineDownLoad shareOfflineDownload];
        __block FailedOfflineDownLoad *failedOffline = [FailedOfflineDownLoad shareInstance];
        [offline resumeOfflineDownLoad];
        offline.downloadFinish = ^(){
            [failedOffline startOfflineDownLoad];
        };
    }
    else{
    if (buttonIndex == 1) {
     
        [self showLoginVC];
    }
    }
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
 
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}
- (void)showLogoVideo
{
    playerViewController = [[LogoMPMoviewPlayViewCtl alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:playerViewController];
    nav.navigationBarHidden = YES;
    [playerViewController.view setFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = nav;
    [nav release];
}
-(void)showLogoView{
    
    playerViewController = [[LogoMPMoviewPlayViewCtl alloc] initWithView];
    [UIView animateWithDuration:0.3 animations:^{
        playerViewController.loginBut.hidden = NO;
        playerViewController.memoryBut.hidden = NO;
        playerViewController.firstVisitBut.hidden = NO;
        playerViewController.imageBg.hidden = NO;
    }];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:playerViewController];
    nav.navigationBarHidden = YES;
    self.window.rootViewController = nav;
    [nav release];
//    [playerViewController release];
}

- (void) playVideoFinished:(NSNotification *)theNotification
{
    [[SavaData shareInstance] savaDataBool:YES KeyString:@"noFirstUse"];
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    //播放视频之后显示操作button
    [UIView animateWithDuration:0.3 animations:^{
        playerViewController.loginBut.hidden = NO;
        playerViewController.memoryBut.hidden = NO;
        playerViewController.firstVisitBut.hidden = NO;
        playerViewController.imageBg.hidden = NO;
    }];
 
}

#pragma mark- 退出登录调用，或者首次登录调用 by jxl
-(void)showLoginVC{
   
    [[SavaData shareInstance]savaDataBool:NO KeyString:ISLOGIN];//异地登录，被挤下的账号要标记为未登录

    if (self.window.rootViewController.view != nil) {
        [self.window.rootViewController.view removeFromSuperview];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    
    LogoMPMoviewPlayViewCtl *playerVC = [[LogoMPMoviewPlayViewCtl alloc] initWithView];
    [UIView animateWithDuration:0.3 animations:^{
        playerVC.loginBut.hidden = NO;
        playerVC.memoryBut.hidden = NO;
        playerVC.firstVisitBut.hidden = NO;
        playerVC.imageBg.hidden = NO;
    }];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:playerVC];
    nav.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    self.window.rootViewController = nav;
    #if TARGET_VERSION_LITE ==1//免费版
    [playerVC didSelectLogin];
    #elif TARGET_VERSION_LITE ==2//授权版
    #endif
    [playerVC release];
    [nav release];
    
}

- (void)showEternalViewController
{
    if (self.window.rootViewController.view != nil) {
        //        [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        //        [self.window.rootViewController.navigationController popToRootViewControllerAnimated:NO];
        [self.window.rootViewController.view removeFromSuperview];
        
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    LogoMPMoviewPlayViewCtl *mpVC = [[LogoMPMoviewPlayViewCtl alloc] initWithView];
    mpVC.loginBut.hidden = NO;
    mpVC.memoryBut.hidden = NO;
    mpVC.firstVisitBut.hidden = NO;
    mpVC.imageBg.hidden = NO;
    NSString *isForbiden = @"100";
    [[NSUserDefaults standardUserDefaults] setObject:isForbiden forKey:@"forbidenStatu"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mpVC];
    nav.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    self.window.rootViewController = nav;
//    [mpVC didSelectMemory];
    [mpVC release];
    [nav release];

    
}
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            abort();
        }
    }
}

-(void)alertShow{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithWindow:self.window];
    [self.window addSubview:HUD];
    HUD.labelText = @"信息不能为空";
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        [HUD release];
    }];
}
+ (EternalMemoryAppDelegate *)getAppDelegate{
    
    return _appDelegate;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EternalMemory" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory]
                       URLByAppendingPathComponent:@"EternalMemory.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString* token = [NSString stringWithFormat:@"%@",deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[SavaData shareInstance]savaToken:token KeyString:TOKEN];
    [[SavaData shareInstance]printToken:TOKEN];
    
} 
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    NSString *str = userInfo[@"aps"][@"alert"];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    alert.tag = OTHERPLACE_LOGIN;
//    [alert show];
//    [alert release];
}
//返回获取token错误
-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    
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
    if ([[SavaData shareInstance] printToken:TOKEN]) {
        return;
    }
    [[SavaData shareInstance]savaToken:uuid KeyString:TOKEN];
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"标题" message:notification.alertBody delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
    

}
//- (UIBackgroundTaskIdentifier)beginBackgroundTaskWithExpirationHandler:(void(^)(void))handler{
//    
//}
//为了MPMoviePlayerViewController保持横平
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
@end
