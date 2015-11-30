//
//  MyHomeViewController.m
//  EternalMemory
//
//  Created by sun on 13-7-1.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MyHomeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MessageSQL.h"
#import "ErrorCodeHandle.h"
#import "RequestParams.h"
#import "MessageModel.h"
#import "SavaData.h"
#import "Config.h"
#import "EternalMemoryAppDelegate.h"
#import "FileModel.h"
#import "CommonData.h"
#import "MyToast.h"
#import "MyHomeVideoListViewController.h"
#import "StyleSendOperation.h"
#import "MomeryCodeViewController.h"
#import "FileModel.h"
#import "LeaveMessageViewController.h"
#import "Utilities.h"
#import "MessageModel.h"
#import "DiaryPictureClassificationModel.h"
#import "DiaryPictureClassificationSQL.h"
#import "MessageSQL.h"
#import "MyFamilySQL.h"
#import "MyPhotoDetailsViewController.h"
#import "MD5.h"
#import "BaseDatas.h"
#import "EMPhotoAlbumRequestEngine.h"
#import "MylifeDetailViewController.h"
#import "DiaryGroupsSQL.h"
#import "DiaryMessageSQL.h"
#import "StaticTools.h"
#import "EMAllLifeMemoDAO.h"
#import "PhotoAlbumNavigationViewController.h"

#define OTHERHOME  [[[SavaData shareInstance]printDataStr:@"JoinOtherHome"] integerValue]//1表示别人，0表示自己
#define LoadOtherHomeUrl  [NSString stringWithFormat:@"%@home/redirectfamily?",INLAND_SERVER_HOME]
#define LeaveMessageUrl   [NSString stringWithFormat:@"%@home/leavemessage.js",INLAND_SERVER_HOME]
#define VideoUrl          [NSString stringWithFormat:@"%@home/video.js.cache",INLAND_SERVER_HOME]
#define PhotoUrl          [NSString stringWithFormat:@"%@home/photo.js.cache",INLAND_SERVER_HOME]
#define HomeUrl           [NSString stringWithFormat:@"%@wap/user/home",INLAND_SERVER_HOME]

#define VideoJS           @"window.iosUseVideoCache=true;"
#define LockJS            @"window.userHadLocked=true;"
#define PhotoJS           @"window.usePhotoCache=true;"

@interface MyHomeViewController ()

@end

@implementation MyHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//检测手机设备类型
-(NSString*)checkIphone{
    
    NSString*
    machineName();
    {
        struct utsname systemInfo;
        uname(&systemInfo);
        return [NSString stringWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
    }
}
-(void)appWillEnterBackground:(NSNotification *)obj{
    
    NSString *str = @"window.stopPlayMusic();";
    [_homeWebView stringByEvaluatingJavaScriptFromString:str];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    _currentUserID = USERID;
    _currentUserIDOriginal = USERID_ORIGINAL;
    [_currentUserID retain];
    [_currentUserIDOriginal retain];
    [[SavaData shareInstance]savadataStr:@"0" KeyString:@"JoinOtherHome"];
    _otherDict = [[NSDictionary alloc]init];
    _homeWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if ([self.comeFrom isEqualToString:@"onLine"]) {
        _addView = [[UIView alloc]init];
        _addView.frame = CGRectMake(0, 0, _homeWebView.frame.size.width, _homeWebView.frame.size.height);
        _addView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_addView];
        [_addView release];
        _homeWebView.hidden = YES;
    }
    
    _homeWebView.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        _homeWebView.paginationMode = UIWebPaginationModeBottomToTop;
    }
    [_homeWebView setUserInteractionEnabled: YES ];
    _homeWebView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_homeWebView];
    [self loadWebview];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

//访问他人家园.拦截and截取
-(void)visitOtherHome:(NSString*)originalUrl{
    //拦截url
//    NSString *original = @"http://m.ieternal.com/home/redirectfamily?associatekey=eternalnum&associatevalue=10006&associateauthcode=01epuayq&eternalcode=&associateuserid=ce733646-f8b4-11e2-853e-00163e0202ca";
    _associatedUserInfoDownLoad = NO;
    NSString *str = [originalUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@home/redirectfamily?",INLAND_SERVER_HOME] withString:@""];
    NSArray *ary = [str componentsSeparatedByString:@"&"];
    //关联的方式
    NSString *associatekey = [[ary objectAtIndex:0]stringByReplacingOccurrencesOfString:@"associatekey=" withString:@""];
    //访问家园的用户ID
    _iassociateuserid = [[ary objectAtIndex:4]stringByReplacingOccurrencesOfString:@"associateuserid=" withString:@""];
    if ([associatekey isEqualToString:@"eternalcode"]) {
        //记忆码
        _ieternalcode = [[ary objectAtIndex:3]stringByReplacingOccurrencesOfString:@"eternalcode=" withString:@""];
        [_ieternalcode retain];
        NSString *uid = [_iassociateuserid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        NSString *key = [NSString stringWithFormat:@"%@_AssocaitedInfo.plist",_currentUserID];
        NSArray *associatedArr = [SavaData parseArrFromFile:key];
        for(NSDictionary *obj in associatedArr){
            if ([uid isEqualToString:obj[@"userId"]]) {
                _associatedUserInfoDownLoad = YES;
                [self enterOtherHomeByLocalData];
                return;
            }
        }
        [self getOtherUserInfoByAssociateUserid:_iassociateuserid AndEternalcode:_ieternalcode];
    }
}

//根据授权码获取关联用户信息
-(void)getOtherUserInfoByAssociateUserid:(NSString *)userId AndEternalcode:(NSString *)eternalcode{
    
    NSString *strUrl = [NSString stringWithFormat:@"%@api/family/getUserinfo",INLAND_SERVER_HOME];
    NSURL *url = [NSURL URLWithString:strUrl];
    ASIFormDataRequest *forReq = [ASIFormDataRequest requestWithURL:url];
    forReq.shouldAttemptPersistentConnection = NO;
    [forReq addPostValue:@"ios" forKey:@"platform"];
    [forReq addPostValue:@"eternalcode" forKey:@"associatekey"];
    [forReq addPostValue:userId forKey:@"associateuserid"];
    [forReq addPostValue:eternalcode forKey:@"eternalcode"];
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"100" forKey:@"tag"];
    forReq.userInfo = userDict;
    [forReq setRequestMethod:@"POST"];
    [forReq setTimeOutSeconds:10.];
    __block typeof (self) bself=self;
    [forReq setCompletionBlock:^{
        [bself requestSuccess:forReq];
    }];
    
    [forReq setFailedBlock:^{
        [bself requestFail:forReq];
    }];
    
    [forReq startAsynchronous];
}
//根据授权码获取关联人信息
-(void)requestSuccess:(ASIFormDataRequest*)request{
    
    NSString *tagStr = [request.userInfo objectForKey:@"tag"];
    NSData *reqData = [request responseData];
    NSDictionary *dictData = [reqData objectFromJSONData];
    _otherDict = [[[dictData objectForKey:@"meta"]objectForKey:@"favoriteStyle"] retain];
    NSInteger success = [[dictData objectForKey:@"success"]integerValue];
    NSInteger errorcode = [[dictData objectForKey:@"errorcode"]integerValue];
    NSString *styleStr = [[dictData objectForKey:@"data"]objectForKey:@"favoriteStyle"];
    _otherHomeStyle = styleStr;
    if (success == 0) {
        if (errorcode == 1005) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1005;
            [alert show];
            [alert release];
        }
        return;
    }
//加载别人家园获取信息
    if ([tagStr isEqualToString:@"100"]) {
        
        [_homeWebView stopLoading];
        [_homeWebView setHidden:YES];
        if ([self.comeFrom isEqualToString:@"onLine"]) {
            _mb = [[MBProgressHUD alloc]initWithView:_addView];
            [_addView addSubview:_mb];
        }else if([self.comeFrom isEqualToString:@"offLine"]){
            _mb = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:_mb];
        }
        _mb.detailsLabelText = @"正在加载中...";
        _mb.delegate = self;
        [_mb show:YES];
        countVisit = 1;
 
        _currentUserIDOriginal = _iassociateuserid;
        _currentUserID = _iassociateuserid;
        _currentUserID = [_currentUserID stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [_currentUserID retain];
        
        NSURL *url = [[RequestParams sharedInstance]memoryVisitHomeUrl:_ieternalcode];
        NSURLRequest *request =[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        [_homeWebView loadRequest:request];
        //查看模板下载新模板
     }
}
-(void)requestFail:(ASIFormDataRequest *)request{
    
    NSString *tagStr = [request.userInfo objectForKey:@"tag"];
    if ([tagStr isEqualToString:@"100"]) {
        [MyToast showWithText:@"请检查网络" :150];
    }
}
-(void)enterOtherHomeByLocalData{
    
    _currentUserIDOriginal = _iassociateuserid;
    _currentUserID = _iassociateuserid;
    _currentUserID = [_iassociateuserid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [_currentUserID retain];
    NSDictionary *dic = [[SavaData shareInstance] printDataDic:[NSString stringWithFormat:@"favoriteStyleDic_%@",_currentUserID]];
    _otherHomeStyle = dic[@"styleId"];

    [_homeWebView stopLoading];
    [_homeWebView setHidden:YES];
    if ([self.comeFrom isEqualToString:@"onLine"]) {
        _mb = [[MBProgressHUD alloc]initWithView:_addView];
        [_addView addSubview:_mb];
    }else if([self.comeFrom isEqualToString:@"offLine"]){
        _mb = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:_mb];
    }
    _mb.detailsLabelText = @"正在加载中...";
    _mb.delegate = self;
    [_mb show:YES];
    [_mb release];
    countVisit = 2;
    
    NSString *filePath = [self getOtherHomeLocalStylePath:dic];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [_homeWebView loadRequest:request];
    
}
-(NSString *)getOtherHomeLocalStylePath:(NSDictionary *)dic{
    
    NSString *filePath = nil;
    NSString *str = [CommonData getZipFilePathManager];
    NSString *styleId = dic[@"styleId"];
    NSString *specificStyle = [NSString stringWithFormat:@"style%@",styleId];
    filePath = [NSString stringWithFormat:@"%@_offline.html",[[str stringByAppendingPathComponent:specificStyle] stringByAppendingPathComponent:specificStyle]];
    return filePath;
    
}
-(NSString *)getHomeStylePath1:(NSString *)styleId{
    
    NSString *filePath = nil;
    NSString *str = [CommonData getZipFilePathManager];
//    NSFileManager *manager = [NSFileManager defaultManager];
//    NSArray *directoryAry = [manager contentsOfDirectoryAtPath:str error:nil];
    NSString *specificStyle = [NSString stringWithFormat:@"style%@",styleId];
    filePath = [NSString stringWithFormat:@"%@.html",[[str stringByAppendingPathComponent:specificStyle] stringByAppendingPathComponent:specificStyle]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NO]) {
        filePath = [self strFilePathStyle:2];
        [MyToast homeStyleTimeDelayText:@"本地没有下载之前设置的模板,需要同步后才能观看":[UIScreen mainScreen].bounds.size.height/2-80 :2.f];
        NSDictionary *dic = nil;
        if (OTHERHOME) {
            dic = [_otherDict copy];
            [_otherDict release];
        }else{
            dic = [[SavaData shareInstance] printDataDic:@"favoriteStyleDic"];
        }
        if (dic.count>0 &&[dic isKindOfClass:[NSDictionary class]]) {
            [self loadRequestStyleBoadUrl:dic];
        }
    }
    return filePath;
}

#pragma mark--
#pragma mark--UIAlertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            
            [self loadWebview];
            
        }else{
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else if(alertView.tag == 1000){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (buttonIndex == 0) {
            BOOL isLogin = NO;
            [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
        }
    }
}
- (void)loadRequestStyleBoadUrl:(NSDictionary *)dic
{
    //取出模板字典,并下载(重新登录有模板才会再下)
    //之前判断过，这里不再做判断
    StyleSendOperation *operation = [[StyleSendOperation alloc] initWithStyleSendOperation:dic];
    [[FileModel sharedInstance].downStyleIDArr addObject:dic[@"styleId"]];
    operation.indexHome = 1;
    [operation main];
    [[FileModel sharedInstance].styleOperation addObject:operation];
}

-(void)addJStoWebview{
    NSString *str = @"window.videoToContinueMusic();";
    [_homeWebView stringByEvaluatingJavaScriptFromString:str];
}
-(void)addJSToWebviewPhoto{
    
    NSString *str = @"window.photoToContinueMusic();";
    [_homeWebView stringByEvaluatingJavaScriptFromString:str];
}

-(void)loadWebview{
    
    if ([self.comeFrom isEqualToString:@"onLine"]) {
        _mb = [[MBProgressHUD alloc]initWithView:_addView];
        [_addView addSubview:_mb];
        _mb.detailsLabelText = @"正在加载中...";
        _mb.delegate = self;
        [_mb show:YES];
        countVisit = 1;
        NSURL *url =[[RequestParams sharedInstance]visitHomeUrl];
        NSURLRequest *request =[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
        [_homeWebView loadRequest:request];
        
    }else if ([self.comeFrom isEqualToString:@"offLine"]){
        _mb = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:_mb];
        _mb.detailsLabelText = @"正在加载中...";
        _mb.delegate = self;
        [_mb show:YES];
        countVisit = 2;
        NSString *strStyleId = nil;
        if (OTHERHOME) {
            strStyleId = _otherHomeStyle;
        }else{
            strStyleId = [NSString stringWithFormat:@"%@",[SavaData parseDicFromFile:User_File][@"favoriteStyle"]];
        }
        NSString *filePath = [self getHomeStylePath:strStyleId];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        [_homeWebView loadRequest:request];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSString *urlStr = webView.request.URL.absoluteString;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *currentUrl = request.URL.absoluteString;
    BOOL result = [self interceptUrl:currentUrl];
    return result;
 
}
-(BOOL)interceptUrl:(NSString *)currentUrl{
    
    //判断该url是否是跳转他人家园url
    NSString *homeStrUrl = [NSString stringWithFormat:@"%@home/redirectfamily?",INLAND_SERVER_HOME];
    NSLog(@"homeStrUrl = %@",homeStrUrl);
    NSLog(@"LoadOtherHomeUrl = %@",LoadOtherHomeUrl);
    NSRange foundObj=[currentUrl rangeOfString:homeStrUrl options:NSCaseInsensitiveSearch];//str被搜索的字符串，homeStrUrl要搜索的字符
    if(foundObj.length>0) {
        //进入他人家园中
        [self enterOtherHome:currentUrl];
        return NO;
    }
    if ([currentUrl isEqualToString:MEMORY_SUCCESS_URL])
    {
        [self certificationIdentifySuccess];
        return NO;
        
    }else if([currentUrl isEqualToString:MEMORY_FAILURE_URL]){
        
        [self certificationIdentifyFail];
        return NO;
    }
    
    if ([currentUrl isEqualToString:LeaveMessageUrl]) {
        
        [self interceptLeaveMessage];
        return NO;
    }
    if ([currentUrl isEqualToString:HomeUrl]) {
        
        NSString *str = @"window.stopPlayMusic();";
        [_homeWebView stringByEvaluatingJavaScriptFromString:str];
        [_homeWebView setHidden:YES];
        [self.navigationController popViewControllerAnimated:NO];
        return NO;
    }
    if ([currentUrl isEqualToString:VideoUrl]) {
        [self interceptVideo];
        return NO;
    }
    if ([currentUrl isEqualToString:PhotoUrl]) {
        [self interceptPhoto];
        return NO;
    }
    return YES;
}
//进入他人家园
-(void)enterOtherHome:(NSString *)currentUrl{
    
    [[SavaData shareInstance]savadataStr:@"1" KeyString:@"JoinOtherHome"];
    [self visitOtherHome:currentUrl];
}
//在线身份认证成功
-(void)certificationIdentifySuccess{
    
    countVisit = countVisit + 1;
    
    NSString *strStyleId = nil;
    
    //判断是否访问别人家园
    if (OTHERHOME) {
        strStyleId = _otherHomeStyle;
    }else{
        strStyleId = [NSString stringWithFormat:@"%@",[SavaData parseDicFromFile:User_File][@"favoriteStyle"]];
    }
    NSString *filePath = [self getHomeStylePath1:strStyleId];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [_homeWebView loadRequest:request];
    
}
//在线身份认证失败
-(void)certificationIdentifyFail{
    
    _homeWebView.hidden = YES;
    _mb.hidden = YES;
    UIAlertView *_alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:nil otherButtonTitles:ALERT_OK, nil];
    [_alter show];
    [_alter release];
}
//拦截视频
-(void)interceptVideo{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addJStoWebview) name:@"addJStoWebviewsss" object:nil];
    if (OTHERHOME) {
        MyHomeVideoListViewController *videoListVC = [[MyHomeVideoListViewController alloc] init];
        videoListVC.associateauthcode = _ieternalcode;
        videoListVC.currentUserID = _currentUserID;
        [self presentViewController:videoListVC animated:YES completion:nil];
        [videoListVC release];
        [_ieternalcode release];
    }else{
        
        MyHomeVideoListViewController *videoListVC = [[MyHomeVideoListViewController alloc] init];
        videoListVC.currentUserID = _currentUserID;
        [self presentViewController:videoListVC animated:YES completion:nil];
        [videoListVC release];
    }
}
//拦截照片
-(void)interceptPhoto {
    
    BOOL connected = [Utilities checkNetwork];
    if (connected) {
        __block typeof(self) bself = self;
        EMPhotoAlbumRequestEngine *engine = [EMPhotoAlbumRequestEngine sharedEngine];
        [engine startRequest];
        [engine setSuccessBlock:^(NSDictionary *albums) {
            
            DiaryPictureClassificationModel *categories = albums[kEMAlbumRequestEngineResultLifeTimeAlbum];
            [DiaryPictureClassificationSQL addDiaryPictureClassificationes:@[categories]];
            NSMutableArray *array = [NSMutableArray arrayWithArray:albums[kEMAlubmRequestEngineResultMemoPhotoArray]];
            [EMAllLifeMemoDAO insertMemoModels:array];
            
            if (array.count > 1)
            {
                [array insertObject:[array lastObject] atIndex:0];
                [array addObject:[array objectAtIndex:1]];
            }
            MylifeDetailViewController *mylifeDetailViewController = [[MylifeDetailViewController alloc]initWithDataArray:array withPage:1 withModel:categories comeInStyle:1 albumArray:albums[kEMAlbumRequestEngineResultAlbumArray]];
            [bself presentViewController:mylifeDetailViewController animated:YES completion:NULL];
            [mylifeDetailViewController release];
        }];
        [engine setFailureBlock:^(id errorCode, id errorMsg) {
            [ErrorCodeHandle handleErrorCode:errorCode AndMsg:errorMsg];
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addJSToWebviewPhoto) name:@"HomeContinueMusic" object:nil];
        
    } else {
        NSArray *items = [EMAllLifeMemoDAO allMemoModels];
        NSMutableArray *array = [NSMutableArray arrayWithArray:items];
        if (items.count > 1)
        {
            [array insertObject:[array lastObject] atIndex:0];
            [array addObject:[array objectAtIndex:1]];
        }
        DiaryPictureClassificationModel *model = [DiaryPictureClassificationSQL getAllLifeAudio];
        MylifeDetailViewController *mylifeDetailViewController = [[MylifeDetailViewController alloc]initWithDataArray:array withPage: 1 withModel:model comeInStyle:1 albumArray:nil];
        [self presentViewController:mylifeDetailViewController animated:YES completion:NULL];
        [mylifeDetailViewController release];
    }
}

//拦截留言
-(void)interceptLeaveMessage{
    
    LeaveMessageViewController *leaveMessageVC = [[LeaveMessageViewController alloc] initWithNibName:@"LeaveMessageViewController" bundle:nil];
    [self presentViewController:leaveMessageVC animated:YES completion:nil];
    [leaveMessageVC release];
}

//家园离线注入各种JS
-(void)addAllKindJStoWebview:(UIWebView *)webView{
    
    //音乐－－－注入js
    [self addMusicJSToWebView:webView];
    //图片－－－注入js
//    [self addPhotoJSToWebView:webView];
    //文献－－－注入js
    [self addTextJSToWebView:webView];
    //家谱注入－－注入js
    [self addFamilyJSToWebView:webView];
    
    if ([self.comeFrom isEqualToString:@"offLine"]) {
        
#if TARGET_VERSION_LITE ==1//免费版
#elif TARGET_VERSION_LITE ==2//授权版
        //关联的人的家谱－－注入js
        [self addOtherFamilyJSToWebView:webView];
#endif
    }
}
-(void)addFamilyJSToWebView:(UIWebView *)webView{
    
    NSArray *familyAry = [MyFamilySQL getFamilyMembersWithUserId:_currentUserID];
    NSString *familyJS = @"";
    int a = 0;
    for (int i = 0; i < familyAry.count; i++) {
        NSArray *ary = familyAry[i][@"members"];
        for (int j = 0; j < ary.count; j++) {
            
            a++;
            NSMutableDictionary *perDic = [[NSMutableDictionary alloc] initWithDictionary:ary[j]];
            NSString *headPath = [Utilities portraitImagePath:perDic[@"headPortrait"]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:headPath]) {
                [perDic setObject:headPath forKey:@"headPortrait"];
            }
            NSString *jsStr = [NSString stringWithFormat:@"%@",[perDic JSONString]];
            if(a == 1){
                familyJS = [familyJS stringByAppendingString:[NSString stringWithFormat:@"%@",jsStr]];
            }else{
                familyJS = [familyJS stringByAppendingString:[NSString stringWithFormat:@",%@",jsStr]];
            }
            [perDic release];
        }
    }
    NSString *str = [NSString stringWithFormat:@"( function() {"
                     "var families = [%@];window.loadfamily(families);"
                     "}());",familyJS];
    [webView stringByEvaluatingJavaScriptFromString:str];
}
-(void)addMusicJSToWebView:(UIWebView *)webView{
    
    NSString *key = [NSString stringWithFormat:@"UserMusic%@.plist",_currentUserID];
    NSMutableArray *arrData = [SavaData parseArrFromFile:key];//音乐列表
    NSString *music_jsStr = @"";
    for(int i = 0; i < arrData.count; i ++){
        
        NSString *path = [self ifMusicIsLocal:arrData[i]];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"attachSize",@"0",@"duration",path,@"fullURL",@"",@"musicName",nil];
        NSString *jsStr = [dict JSONString];
        music_jsStr = [music_jsStr stringByAppendingString:[NSString stringWithFormat:@",%@",jsStr]];
    }
    NSString *str = [NSString stringWithFormat:@"(function() {"
                     "var musics = [%@];window.loadmusic(musics);}());",music_jsStr];
    str = [str stringByReplacingOccurrencesOfString:@"[," withString:@"["];
    [webView stringByEvaluatingJavaScriptFromString:str];
}

-(NSString *)ifMusicIsLocal:(NSDictionary *)dic{
    
    NSString *musicName = [NSString stringWithFormat:@"%@.m4a",dic[@"musicName"]];
    NSString *exportFile = [PATH_OF_DOCUMENT stringByAppendingPathComponent:musicName];
    NSString *playingName = [[NSString stringWithFormat:@"%@",exportFile] mutableCopy];
    if ([CommonData isExistFile:exportFile]) {//判断音乐是否是本地上传的
        return [playingName autorelease];
    }else{
        
        NSString *fileType = [[dic[@"fullURL"] componentsSeparatedByString:@"."] lastObject];
        NSString *musicName = dic[@"musicName"];
        NSString *musicPath = [Utilities dataPath:[NSString stringWithFormat:@"%@.%@",musicName,fileType] FileType:@"Music" UserID:_currentUserID];
        if ([[NSFileManager defaultManager] fileExistsAtPath:musicPath isDirectory:NO])//判断音乐是否是下载到本地的
        {
            return musicPath;
        }
    }
    return nil;
}

-(void)addPhotoJSToWebView:(UIWebView *)webView{
    
    NSMutableArray *photosAry = [MessageSQL getMessages:@"1" AndUserId:_currentUserID];
    NSString *photoJS = @"";
    for (int i = 0; i < photosAry.count; i ++) {
        
        MessageModel *model = photosAry[i];
        [model.content stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if (model.paths) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:model.paths,@"attachURL",model.content,@"content",model.title,@"title",model.blogId,@"blogId",nil];
            NSString *jsStr = [dict JSONString];
            jsStr = [NSString stringWithFormat:@",%@",jsStr];
            photoJS = [photoJS stringByAppendingString:jsStr];
        }
    }
    NSString *photoJSStr = [NSString stringWithFormat:@"( function() {"
                            "var photos = [%@];window.loadphoto(photos);}());",photoJS];
    
    photoJSStr = [photoJSStr stringByReplacingOccurrencesOfString:@"[," withString:@"["];
    [webView stringByEvaluatingJavaScriptFromString:photoJSStr];
    
}
-(NSString *)isPhotoLocal:(NSString *)imgpath{
    
    NSString *imgName = [NSString stringWithFormat:@"img_%@.png",imgpath];
    NSString *localImageName = [MD5 md5:imgName];
    NSString *photoLocalPath = [self dataPath:localImageName];
    if (photoLocalPath) {
        return photoLocalPath;
    }
    return nil;
}
- (NSString *)dataPath:(NSString *)file
{
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"ETMemory"] stringByAppendingPathComponent:@"Photos"];
    NSString *usernameStr = _currentUserID;
    NSString *fullPath = [path stringByAppendingPathComponent:usernameStr] ;
    NSString *result = [fullPath stringByAppendingPathComponent:file];
    UIImage *image = [UIImage imageWithContentsOfFile:result];
    if (image) {
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:result isDirectory:NO]){
        return result;
    }
    return nil;
}

-(void)addTextJSToWebView:(UIWebView *)webView{
    
    NSArray *diaryGroupAry = [DiaryGroupsSQL getDiaryGroups:@"0" AndUserId:_currentUserID];
    NSString *JSStr = @"";
    for (int i = 0; i < diaryGroupAry.count ; i ++) {
        DiaryGroupsModel *model = diaryGroupAry[i];
        NSArray *diaryAry = [DiaryMessageSQL getGroupIDMessages:model.groupId AndUserId:_currentUserID];
        NSMutableArray *diaryJSAry = [[NSMutableArray alloc] initWithCapacity:0];
        for (int j = 0; j < diaryAry.count; j++) {
            
            DiaryMessageModel *model1 = diaryAry[j];
            if (model1.content.length == 0) {
                model1.content = @" ";
            }
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:model1.blogType,@"blogType",model1.createTime,@"createTime",model1.groupId,@"groupId",model1.remark,@"remark",@"0",@"theorder",model1.title,@"title",model1.content,@"content",model1.blogId,@"blogId",nil];//blogId要放在最后，因为无网络操作的日记没有blogId
            [diaryJSAry addObject:dic];
        }
        NSDictionary *groupDic = [NSDictionary dictionaryWithObjectsAndKeys:model.blogType,@"blogType",model.blogcount,@"blogcount",diaryJSAry,@"blogs",model.groupId,@"groupId",model.remark,@"remark",@"0",@"theorder",model.title,@"title",nil];
        JSStr = [JSStr stringByAppendingString:[NSString stringWithFormat:@",%@",[groupDic JSONString]]];
        
    }
    JSStr = [NSString stringWithFormat:@"( function() {"
             "var blogs = [%@];window.loadblog(blogs);}());",JSStr];
    JSStr = [JSStr stringByReplacingOccurrencesOfString:@"[," withString:@"["];
    
    [webView stringByEvaluatingJavaScriptFromString:JSStr];
}
-(void)addOtherFamilyJSToWebView:(UIWebView *)webView{
    
    NSString *key = [NSString stringWithFormat:@"%@_AssocaitedInfo.plist",_currentUserID];
    NSArray *associatedArr = [SavaData parseArrFromFile:key];
    
    for (NSDictionary *dic in associatedArr) {
        
        NSString *authCode = dic[@"authCode"];
        NSString *userId = dic[@"userId"];
        NSArray  *familyAry = [MyFamilySQL getFamilyMembersWithUserId:userId];
        NSString *familyJS = @"";
        int a = 0;
        for (int i = 0; i < familyAry.count; i++) {
            
            NSArray *ary = familyAry[i][@"members"];
            for (int j = 0; j < ary.count; j++) {
                
                a++;
                NSMutableDictionary *perDic = [[NSMutableDictionary alloc] initWithDictionary:ary[j]];
                NSString *headPath = [Utilities portraitImagePath:perDic[@"headPortrait"]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:headPath]) {
                    [perDic setObject:headPath forKey:@"headPortrait"];
                }
                NSString *jsStr = [NSString stringWithFormat:@"%@",[perDic JSONString]];
                if(a == 1){
                    familyJS = [familyJS stringByAppendingString:[NSString stringWithFormat:@"%@",jsStr]];
                }else{
                    familyJS = [familyJS stringByAppendingString:[NSString stringWithFormat:@",%@",jsStr]];
                }
                [perDic release];
            }
        }
        familyJS = [NSString stringWithFormat:@"appendfamilies[\"%@\"]=[%@];",authCode,familyJS];
        NSString *str = [NSString stringWithFormat:@"(function(){"
                         "var appendfamilies = {};%@window.appendfamily(appendfamilies);}());",familyJS];
        [webView stringByEvaluatingJavaScriptFromString:str];
    }
}

-(NSString *)getHomeStylePath:(NSString *)strStyleId{
    
    NSString *filePath = nil;
    NSString *str = [CommonData getZipFilePathManager];
    NSString *specificStyle = [NSString stringWithFormat:@"style%@",strStyleId];
    filePath = [NSString stringWithFormat:@"%@_offline.html",[[str stringByAppendingPathComponent:specificStyle] stringByAppendingPathComponent:specificStyle]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NO]) {
        filePath = [self strFilePathStyle:2 andType:@"offLine"];
        [MyToast homeStyleTimeDelayText:@"本地没有下载之前设置的模板,需要同步后才能观看":[UIScreen mainScreen].bounds.size.height/2-80 :2.f];
        NSDictionary *dic = nil;
        if (OTHERHOME) {
            dic = [_otherDict copy];
            [_otherDict release];
        }else{
            dic = [[SavaData shareInstance] printDataDic:@"favoriteStyleDic"];
        }
        if (dic.count>0 &&[dic isKindOfClass:[NSDictionary class]]) {
            [self loadRequestStyleBoadUrl:dic];
        }
    }
    return filePath;
}
- (NSString *)strFilePathStyle:(NSInteger)index andType:(NSString *)type
{
    NSString *filePath = nil;
    NSString *str = [CommonData getZipFilePathManager];
    NSString *styleName = @"style2";
    NSString *specificStyle = [NSString stringWithFormat:@"style%d",index];
    if ([type isEqualToString:@"onLine"]) {
        filePath = [NSString stringWithFormat:@"%@.html",[[str stringByAppendingPathComponent:styleName] stringByAppendingPathComponent:specificStyle]];
    }else if([type isEqualToString:@"offLine"]){
        filePath = [NSString stringWithFormat:@"%@_offline.html",[[str stringByAppendingPathComponent:styleName] stringByAppendingPathComponent:specificStyle]];
    }
    return filePath;
}

//获取加载本地html的路径地址
-(NSString *)getLocalHtmlPath{
    //获取解压后的路径
    NSString *styleId = [[SavaData shareInstance] printDataStr:@"styleId"];
    NSString *specificStyle = [[SavaData shareInstance] printDataStr:@"specificStyle"];
    NSString *unzipPath = [CommonData getZipFilePathManager];
    NSString *stylePath = [NSString stringWithFormat:@"%@/%@/%@.html",unzipPath,styleId,specificStyle];
    NSURL *styleUrl = [NSURL fileURLWithPath:stylePath];
    //将url格式化
    NSString *urlStr = [NSString stringWithFormat:@"%@",styleUrl];
    //当前的url路径
    NSString *currentStr = [urlStr stringByReplacingOccurrencesOfString:@"localhost" withString:@""];
    return currentStr;
}
- (NSString *)strFilePathStyle:(NSInteger)index
{
    NSString *str = [CommonData getZipFilePathManager];
    NSString *styleName = @"style2";
    NSString *specificStyle = [NSString stringWithFormat:@"style%d",index];
    NSString *filePath = [NSString stringWithFormat:@"%@.html",[[str stringByAppendingPathComponent:styleName] stringByAppendingPathComponent:specificStyle]];
//    NSString *str = [[NSBundle mainBundle] pathForResource:@"style2" ofType:@"html"];
    return filePath;
}
- (NSString *)styleFilePath:(NSString *)boadName styleName:(NSString *)styleName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *savePath = [[[CommonData getZipFilePathManager] stringByAppendingPathComponent:boadName] stringByAppendingPathComponent:styleName];
    if ([fileManager fileExistsAtPath:savePath]) {
        return savePath;
    }else
    {
        return @"0";
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
//判断是否显示webview
    NSString *currentURL= _homeWebView.request.URL.absoluteString;
    if (countVisit == 2) {
        [_mb setHidden:YES];
       [_homeWebView setHidden:NO];
    }
    NSArray *ary = [currentURL componentsSeparatedByString:@"."];
    if ([[ary lastObject]  isEqualToString:@"html"]){
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            [storage deleteCookie:cookie];
        }
//加载完成本地html向模板中注入js语句
        [_homeWebView stringByEvaluatingJavaScriptFromString:VideoJS];
        [_homeWebView stringByEvaluatingJavaScriptFromString:PhotoJS];
        NSInteger isclose = [[SavaData shareInstance] printData:@"ISCLOSE"];
        if (isclose == 1) {
            [_homeWebView stringByEvaluatingJavaScriptFromString:LockJS];
        }
        if ([self.comeFrom isEqualToString:@"offLine"]) {
            if (!OTHERHOME) {
                [self addAllKindJStoWebview:webView];
                double delayInSeconds = 1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                });
            }else if (OTHERHOME && _associatedUserInfoDownLoad){
                [self addAllKindJStoWebview:webView];
            }
        }else if([self.comeFrom isEqualToString:@"onLine"]){
            if (_associatedUserInfoDownLoad) {
                [self addAllKindJStoWebview:webView];
            }
        }
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"友情提示" message:@"请检查网络链接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alert.tag = 1000;
    [alert show];
    [alert release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    
    [_homeWebView release];
    _homeWebView = nil;
    [_otherDict release];
    [_currentUserID release];
    [_currentUserIDOriginal release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [super dealloc];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    NSHTTPCookie *cookie;
//    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (cookie in [storage cookies])
//    {
//        [storage deleteCookie:cookie];
//    }
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [UIApplication sharedApplication].statusBarHidden = YES;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate
{
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - private (methods of intercepting photo)

- (void)getPhotoFromServer
{
    NSURL *url = [[RequestParams sharedInstance] getUserData];
    NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
    NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:User_File];
    NSDictionary *userDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString *userID = userDic[@"userId"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:userID forKey:@"userid"];
    [request setPostValue:@"photo" forKey:@"userdata"];
    [request setPostValue:@"1" forKey:@"grouptype"];
    [request setPostValue:@"normal" forKey:@"struct"];
    [request startAsynchronous];
    
    MBProgressHUD *hud = [[self hubWithMessage:@"正在载入..."] retain];
    [hud show:YES];
    
    __block typeof(self) bself = self;
    request.completionBlock = ^{
        NSData *responseData = request.responseData;
        NSError *error = nil;
        NSDictionary *JSONDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if (!error) {
            NSInteger success = [JSONDic[@"success"] integerValue];
            NSString *errorMsg = JSONDic[@"message"];
            if (success == 1) {
                NSArray *blogsData = JSONDic[@"meta"][@"photos"];
                NSMutableArray *photos = [[NSMutableArray alloc] init];
                for (NSDictionary *blog in blogsData) {
                    MessageModel *model = [[MessageModel alloc] initWithDict:blog];
                    MessageModel *loaclModel = [MessageSQL getBlogByBlogId:model.blogId];
                    model.paths = loaclModel.paths;
                    [photos addObject:model];
                    [model release];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.mode = MBProgressHUDModeText;
                    if (!photos || photos.count == 0) {
                        hud.labelText = @"暂无照片";
                    } else {
                        
                        hud.labelText = @"载入成功!";
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addJSToWebviewPhoto) name:@"HomeContinueMusic" object:nil];
                        MyPhotoDetailsViewController *photoDetail = [[MyPhotoDetailsViewController alloc] init];
                        photoDetail.selectPhotoIndex = 0;
                        photoDetail.blogs = photos;
                        photoDetail.hideRecordButtonForNoAudio = YES;
                        photoDetail.shouldRightButtonHidden = YES;
                        photoDetail.comeFrom = @"Home";
                        photoDetail.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                        __block MyPhotoDetailsViewController *b_photoDetail = photoDetail;
                        [bself presentViewController:photoDetail animated:YES completion:^{
                            b_photoDetail.rightBtn.hidden = YES;
                        }];
                        [photoDetail release];
                        [photos release];
                    }
                    
                    [hud hide:YES afterDelay:1.f];
                    [hud release];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.labelText = errorMsg;
                    [hud hide:YES];
                    [hud release];
                });
            }
        } else {
        }
        
    };
    [request setFailedBlock:^{
        [hud hide:YES afterDelay:1.f];
    }];
    
}

- (void)getPhotoFromLocal
{
    NSMutableArray *arr = [MessageSQL getMessages:@"1" AndUserId:USERID];
    if (!arr || arr.count == 0) {
        MBProgressHUD *hud = [self hubWithMessage:@"暂无照片"];
        hud.mode = MBProgressHUDModeText;
        [hud show:YES];
        [hud hide:YES afterDelay:1.0f];
    } else {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addJSToWebviewPhoto) name:@"HomeContinueMusic" object:nil];
        MyPhotoDetailsViewController *photoDetail = [[MyPhotoDetailsViewController alloc] init];
        photoDetail.selectPhotoIndex = 0;
        photoDetail.blogs = arr;
        photoDetail.hideRecordButtonForNoAudio = YES;
        photoDetail.shouldRightButtonHidden = YES;
        photoDetail.comeFrom = @"Home";
        photoDetail.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        __block MyPhotoDetailsViewController *b_photoDetail = photoDetail;
        [self presentViewController:photoDetail animated:YES completion:^{
            b_photoDetail.rightBtn.hidden = YES;
        }];
        [photoDetail release];
    }
}


- (MBProgressHUD *)hubWithMessage:(NSString *)message
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [[EternalMemoryAppDelegate getAppDelegate].window addSubview:HUD];
    HUD.labelText = message;
    HUD.mode = MBProgressHUDModeIndeterminate;
    return [HUD autorelease];
}
@end
