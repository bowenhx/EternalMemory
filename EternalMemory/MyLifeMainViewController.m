//
//  MyLifeMainViewController.m
//  EternalMemory
//
//  Created by sun on 13-5-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "UploadingDebugging.h"
#import "MyLifeMainViewController.h"
#import "UIButton+RMWAdditions.h"
#import "MyVideoPageViewCtrl.h"
#import "WriteWordsViewController.h"
#import "PhotoAlbumsViewController.h"
#import "MyBlogListViewController.h"
#import "EternalMemoryAppDelegate.h"
#import "DiaryPictureClassificationSQL.h"
#import "PhotoCategoryViewController.h"
#import "MorePageViewCtrl.h"
#import "MyHomeViewController.h"
#import "MyToast.h"
#import "StatusIndicatorView.h"
#import "UIImage+Retina4.h"
#import "ASINetworkQueue.h"
#import "MD5.h"
#import "FileModel.h"
#import "UIImage+UIImageExt.h"
#import "EternalMemoryAppDelegate.h"
#import "UserDetailViewCtrl.h"
#import "BackgroundMusicViewCtrl.h"
#import "StyleSelectListViewCtrl.h"
#import "FamliyTreeViewController2.h"
#import "AboutMemoryViewCtrl.h"
#import "FileModel.h"
#import "CompleteLoginInfoViewController.h"
#import "FileModel.h"
#import "MylifeDetailViewController.h"
#import "StaticTools.h"
#import "CheckAppVersion.h"

#define PHOTOTEXT @"0"
#define REQUEST_FOR_LOGIN 100
#define REQUEST_FOR_GETGROUPS 200
#define REQUEST_FOR_ADDDIARY 1000
#define REQUEST_FOR_DELETBLOG 2000
#define REQUEST_FOR_UPDATADIARY 3000
#define REQUEST_FOR_ADDPHOTO 4000
#define REQUEST_FOR_DELETEPHOTO 5000
#define REQUEST_FOR_UPDATAPHOTO 6000
#define REQUEST_FOR_USERINFO    7000



#define FileModel  [FileModel sharedInstance]


@interface MyLifeMainViewController ()
{
    NSInteger                comeInTime;
    UIImage                 *_imageVideo;
    NSString                *_videoPath;
    IBOutlet UIImageView    *bgImgView;
//    NSString                *_strVersion;
    NSInteger              completInfoStyle;//1表示我的资料 2表示我的家谱 3表示点击条
}

@property (nonatomic, retain) NSString *errorcodeStr ;
@property (nonatomic, retain) IBOutlet UIButton *MyPictureBtn;
@property (nonatomic, retain) IBOutlet UIButton *MyDiaryBtn;
@property (nonatomic, retain) IBOutlet UIButton *MyVideoBtn;
@property (nonatomic, retain) IBOutlet UILabel  *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *myMusicBtn;
@property (retain, nonatomic) IBOutlet UIButton *choseStyleBtn;
@property (retain, nonatomic) IBOutlet UIButton *myGenBtn;
@property (retain, nonatomic) IBOutlet UIButton *rookieHelpBtn;
@property (retain, nonatomic) IBOutlet UIButton *moreOperaBtn;
@property (retain, nonatomic) IBOutlet UIButton *myProfileBtn;


- (IBAction)onMyPictureBtnClicked;
- (IBAction)onMyVideoBtnClicked;
- (IBAction)onMyDiaryBtnClicked;
- (IBAction)onMoreBtnClicked;
- (IBAction)onMyHomeBtnClicked;
// new added by lzz
- (IBAction)onPersenalFileBtnClicked:(id)sender;
- (IBAction)onMyMusicBtnClicked:(id)sender;
- (IBAction)onChooseStyleBtnClicked:(id)sender;
- (IBAction)onMyGenealogyBtnClicked:(UIButton *)sender;
- (IBAction)onRookieHelpBtnClicked:(id)sender;

@end

#define COME_FIRST      1
#define COME_SECOND     2


@implementation MyLifeMainViewController
@synthesize errorcodeStr = _errorcodeStr ;
#pragma mark - object lifecycle
- (void)dealloc
{
    [_imageVideo release];
    [_videoPath release];
    [_titleLabel release];
    [_errorcodeStr release];
    [_MyDiaryBtn release];
    [_MyVideoBtn release];
    [_myMusicBtn release];
    [_choseStyleBtn release];
    [_myGenBtn release];
    [_rookieHelpBtn release];
    [_moreOperaBtn release];
    [_myProfileBtn release];
    [_request clearDelegatesAndCancel];
    [_request release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeNoteView" object:nil];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        comeInTime = COME_FIRST;
    }
    return self;
}
-(void)pushToComplete{
    
    completInfoStyle = 3;
    CompleteLoginInfoViewController *completeVC = [[CompleteLoginInfoViewController alloc] initWithNibName:@"CompleteLoginInfoViewController" bundle:nil];
    
    completeVC.comeInStyle = 1;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:completeVC];

    [self presentViewController:nav animated:YES completion:nil];
    [completeVC release];
    [nav release];
}
-(void)addCompleteInfo{
    
    UIImageView  *img = [[UIImageView alloc] init];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        img.frame = CGRectMake(0, 64, 320, 50);
    }else{
        img.frame = CGRectMake(0, 44, 320, 50);
    }
    img.userInteractionEnabled = YES;
    img.tag = 345;
    img.backgroundColor = [UIColor colorWithRed:225/255. green:200/255. blue:160/255. alpha:1];
    img.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToComplete)];
    [img addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    [self.view addSubview:img];
    [img release];
    
    UIImageView *tanhaoImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 14, 23, 23)];
    tanhaoImg.image = [UIImage imageNamed:@"taohao"];
    [img addSubview:tanhaoImg];
    [tanhaoImg release];
    
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(34, 5, 185, 40)];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.numberOfLines = 2;
    [aLabel setText:@"资料未完善，安全系数低，请尽快完善资料"];
    aLabel.font = [UIFont systemFontOfSize:15.0f];
    [img addSubview:aLabel];
    [aLabel release];
    
    
    UIImageView *completeImg = [[UIImageView alloc] initWithFrame:CGRectMake(240, 13, 60, 24)];
    completeImg.image = [UIImage imageNamed:@"completeBtn"];
    [img addSubview:completeImg];
    [completeImg release];
    
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if(version >= 7.0){
        _scrollView.frame = CGRectMake(0, 114, 320, SCREEN_HEIGHT - 64);
    }
    if(version < 7.0){
        _scrollView.frame = CGRectMake(0, 94, 320, SCREEN_HEIGHT - 64);
    }
    if (SCREEN_HEIGHT == 480) {
        
        _scrollView.contentSize = CGSizeMake(320, 460 - 44);
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.scrollEnabled = YES;
    }else{
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.scrollEnabled = NO;
    }

}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    if (comeInTime == COME_FIRST)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        ////////完善资料
        NSDictionary *userInfoDic = [SavaData parseDicFromFile:User_File];
        
        if (!([userInfoDic[@"mobile"] length] == 11 && [userInfoDic[@"verified"] intValue] == 1))
        {
            [self ifUserInfoComplete:@"mainview"];
            
        }else{
            
            [self removeRemindNote];
        }
        //断点续传使用
        [UploadingDebugging updateDataWhenBeginOrComeBack];
 
        comeInTime = COME_SECOND;
        //书籍分组接口
//        {
//            NSURL *registerUrl = [[RequestParams sharedInstance] manageGroup] ;
//            ASIFormDataRequest *_formReq = [[ASIFormDataRequest requestWithURL:registerUrl]retain];
//            _formReq.shouldAttemptPersistentConnection = NO;
//            _formReq.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_GETGROUPS],@"tag", nil] ;
//            [_formReq setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
//            
//            [_formReq setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
//            [_formReq setPostValue:@"list" forKey:@"operation"];
//            [_formReq setPostValue:@"0" forKey:@"type"];
//            [_formReq setRequestMethod:@"POST"];
//            [_formReq setDelegate:self];
//            [_formReq setTimeOutSeconds:30.0];
//            __block typeof(self) bself = self;
//            [_formReq setCompletionBlock:^{
//                [bself requestSuccess:_formReq];
//            }];
//            [_formReq setFailedBlock:^{
//                [bself requestFail:_formReq];
//            }];
//            [_formReq startAsynchronous];
//        }
    }
}
-(void)removeRemindNote{
    
    if ([self.view viewWithTag:345]) {
        [[self.view viewWithTag:345] removeFromSuperview];
    }
    float  version = [[[UIDevice currentDevice] systemVersion] floatValue];

    if (SCREEN_HEIGHT == 480) {
        if(version >= 7.0){
            _scrollView.frame = CGRectMake(0, 84, 320, 416);
        }
        if(version < 7.0){
            _scrollView.frame = CGRectMake(0, 64, 320, 416);
        }
    }else{
        if(version >= 7.0){
            _scrollView.frame = CGRectMake(0, 94, 320, 504);
        }
        if(version < 7.0){
            _scrollView.frame = CGRectMake(0, 74, 320, 504);
        }
    }
    
    _scrollView.scrollEnabled = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (iOS7) {
        CGRect frame = _titleLabel.frame;
        frame.origin.y += 20;
        _titleLabel.frame = frame;
    } else {
        NSArray *btns = @[_choseStyleBtn,_moreOperaBtn,_myGenBtn,_myMusicBtn,_MyVideoBtn,_myProfileBtn,_rookieHelpBtn,_MyDiaryBtn,_MyPictureBtn];
        
        for (UIButton *button  in btns) {
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 25, 20, 0);
        };
    }
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMyVideoPageViewCtrl:) name:@"showMyVideoPageViewCtrl" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfoSuccessSecond:) name:@"updateInfoSuccessSecond" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRemindNote) name:@"removeNoteView" object:nil];

    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //自动登录和重新登录都要检查新版本
    if (self.isNewVersion) {
        self.isNewVersion = NO;
        [self monitorNewVersion];
    }
    
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction methods
- (IBAction)onMyPictureBtnClicked
{
//    PhotoAlbumsViewController *photoAlbumsViewController = [[PhotoAlbumsViewController alloc] init];
//    [self.navigationController pushViewController:photoAlbumsViewController animated:YES];
//    //    [photoAlbumsViewController release];
//    [photoAlbumsViewController release];
    
    PhotoCategoryViewController *pcvc = [[PhotoCategoryViewController alloc] init];
    [self.navigationController pushViewController:pcvc animated:YES];
    [pcvc release];
}
- (IBAction)onMyVideoBtnClicked
{
    MyVideoPageViewCtrl *myVideo = [[MyVideoPageViewCtrl alloc] init];
    [self.navigationController pushViewController:myVideo animated:YES];
    [myVideo release];
}

- (IBAction)onMyDiaryBtnClicked
{
    MyBlogListViewController *_myBlogListViewController = [[MyBlogListViewController alloc]init];
    [self.navigationController pushViewController:_myBlogListViewController animated:YES];
    [_myBlogListViewController release];
    
}
- (IBAction)onMoreBtnClicked
{
    MorePageViewCtrl *moreCtrl = [[MorePageViewCtrl alloc] initWithNibName:@"MorePageViewCtrl" bundle:nil];
    [self.navigationController pushViewController:moreCtrl animated:YES];
    [moreCtrl release];
}
- (IBAction)onMyHomeBtnClicked
{
    NSString *type = [[SavaData shareInstance] printDataStr:@"HomeType"];
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (id obj in windows) {
        if ([obj isKindOfClass:[StatusIndicatorView class]]) {
            StatusIndicatorView *view = (StatusIndicatorView *)obj;
            [view dismiss];
            break;
        }
    }
    BOOL network = [Utilities checkNetwork];
    if ([type isEqualToString:@"onLine"]) {
        if (network) {
            MyHomeViewController *homeVC = [[MyHomeViewController alloc]init];
            homeVC.comeFrom = @"onLine";
            [self.navigationController pushViewController:homeVC animated:YES];
            [homeVC release];
        }else{
            MyHomeViewController *homeVC = [[MyHomeViewController alloc]init];
            homeVC.comeFrom = @"offLine";
            [self.navigationController pushViewController:homeVC animated:YES];
            [homeVC release];
        }
    }else if ([type isEqualToString:@"offLine"]){
        MyHomeViewController *homeVC = [[MyHomeViewController alloc]init];
        homeVC.comeFrom = @"offLine";
        [self.navigationController pushViewController:homeVC animated:YES];
        [homeVC release];
    }
}


/**
 *	个人资料
 *
 *	@param	sender
 */
- (IBAction)onPersenalFileBtnClicked:(UIButton *)sender
{//个人资料页面
    completInfoStyle = 1;
    NSDictionary *userInfoDic = [SavaData parseDicFromFile:User_File];
    if (!([userInfoDic[@"mobile"] length] == 11 && [userInfoDic[@"verified"] intValue] == 1))
    {
        sender.userInteractionEnabled = NO;
        [self ifUserInfoComplete:@"personal"];
    }
    else
    {
    UserDetailViewCtrl *backgroundMusic = [[UserDetailViewCtrl alloc] init];
    [self.navigationController pushViewController:backgroundMusic animated:YES];
    [backgroundMusic release];
    }
}
/**
 *	我的音乐
 *
 *	@param	sender
 */
- (IBAction)onMyMusicBtnClicked:(id)sender
{
    BackgroundMusicViewCtrl *backgroundMusic = [[BackgroundMusicViewCtrl alloc] init];
    [self.navigationController pushViewController:backgroundMusic animated:YES];
    [backgroundMusic release];
}
/**
 *	风格选择
 *
 *	@param	sender
 */
- (IBAction)onChooseStyleBtnClicked:(id)sender
{
    StyleSelectListViewCtrl *styleSelect = [[StyleSelectListViewCtrl alloc] init];
    [self.navigationController pushViewController:styleSelect animated:YES];
    [styleSelect release];
}
/**
 *	我的家谱
 *
 *	@param	sender
 *
 *  genealogy n. 家谱
 */
- (IBAction)onMyGenealogyBtnClicked:(UIButton *)sender
{
    completInfoStyle = 2;
    NSDictionary *userInfoDic = [SavaData parseDicFromFile:User_File];
    if (!([userInfoDic[@"mobile"] length] == 11 && [userInfoDic[@"verified"] intValue] == 1))
    {
        sender.userInteractionEnabled = NO;
        [self ifUserInfoComplete:@"family"];
    }
    else
    {
        FamliyTreeViewController2 *familyVC = [[FamliyTreeViewController2 alloc]init];
        familyVC.comeFirst = YES;
        [self.navigationController pushViewController:familyVC animated:YES];
        [familyVC release];
    }
}

-(void)ifUserInfoComplete:(NSString *)where{
    
    if ([Utilities checkNetwork] == NO) {
        [MyToast showWithText:@"网络连接失败，请检查网络" :200];
        return;
    }
    
    NSURL *url = [[RequestParams sharedInstance] userDatasInquire];
    _request = [[ASIFormDataRequest alloc] initWithURL:url];
    _request.userInfo = @{@"tag": [NSNumber numberWithInt:REQUEST_FOR_USERINFO],@"next":where};
    [_request setRequestMethod:@"POST"];
    [_request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_request setPostValue:@"show" forKey:@"operation"];
    [_request setTimeOutSeconds:10];
    _request.delegate = self;
    __block typeof (self) bself=self;
    
    [_request setCompletionBlock:^{
        [bself requestSuccess:_request];
    }];
    [_request setFailedBlock:^{
        [bself requestFail:_request];
    }];
    [_request startAsynchronous];

}
/**
 *	新手帮助
 *
 *	@param	sender
 */
- (IBAction)onRookieHelpBtnClicked:(id)sender
{
    AboutMemoryViewCtrl *aboutMemory = [AboutMemoryViewCtrl new];
    [self.navigationController pushViewController:aboutMemory animated:YES];
    [aboutMemory release];
}

- (void)isNotworkConnect:(NSString *)netStr
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = netStr;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        [HUD release];
    }];
}
- (void)networkPromptMessage:(NSString *)message
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [[EternalMemoryAppDelegate getAppDelegate].window addSubview:HUD];
    HUD.labelText = message;
    HUD.mode = MBProgressHUDModeText;
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [HUD removeFromSuperview];
        [HUD release];
    }];
    
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=2) {
    }
}
#pragma mark - request
-(void)requestSuccess:(ASIFormDataRequest *)request
{
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSInteger result=[[resultDictionary objectForKey:@"success"] integerValue];
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    self.errorcodeStr = [NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"errorcode"]];
    _myProfileBtn.userInteractionEnabled = YES;
    _myGenBtn.userInteractionEnabled = YES;
    if (tag == REQUEST_FOR_USERINFO)
    {
        if (result == 1) {
            if (!([resultDictionary[@"mobile"] length] == 11 && [resultDictionary[@"verified"] intValue] == 1))
            {
                if ([request.userInfo[@"next"] isEqualToString:@"mainview"]) {
                    [self addCompleteInfo];
                }else{
                    
                    CompleteLoginInfoViewController *completeLoginInfoCtrl = [[CompleteLoginInfoViewController alloc] init];
                    completeLoginInfoCtrl.comeInStyle = 1;
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:completeLoginInfoCtrl];
                    [self presentViewController:nav animated:YES completion:nil];
                    [completeLoginInfoCtrl release];
                    [nav release];
                }
                
            }else{
                
                //数据写入plist
                
                [SavaData writeDicToFile:resultDictionary[@"data"] FileName:User_File];
                
                if ([request.userInfo[@"next"] isEqualToString:@"family"])
                {
                    FamliyTreeViewController2 *familyVC = [[FamliyTreeViewController2 alloc]init];
                    familyVC.comeFirst = YES;
                    [self.navigationController pushViewController:familyVC animated:YES];
                    [familyVC release];
                    
                }
                else if ([request.userInfo[@"next"] isEqualToString:@"personal"])
                {
                    UserDetailViewCtrl *backgroundMusic = [[UserDetailViewCtrl alloc] init];
                    [self.navigationController pushViewController:backgroundMusic animated:YES];
                    [backgroundMusic release];
                }else if ([request.userInfo[@"next"] isEqualToString:@"mainview"]){
                    
                    [self removeRemindNote];
                }
            }
        }
    }
    if (tag == REQUEST_FOR_GETGROUPS)
    {
        if (result == 1)
        {
            
            NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:10];
            [dataArray setArray:[resultDictionary objectForKey:@"data"]];
//            [DiaryPictureClassificationSQL  refershDiaryPictureClassificationes:dataArray WithUserID:USERID];
            [StaticTools updateDiaryAndPhotoGroup:dataArray WithUserID:USERID];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 200)
    {//监测新版本
        if (buttonIndex ==1) {
            NSString *updateStr = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@",APPLE_ID];
            NSURL *url = [NSURL URLWithString:updateStr];
            [[UIApplication sharedApplication]openURL:url];
        }
    }else {
        if ([self.errorcodeStr isEqualToString:@"1005"]) {
            
            BOOL isLogin = NO;
            [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
        }
    }
    
}
-(void)requestFail:(ASIFormDataRequest *)request
{
    _myProfileBtn.userInteractionEnabled = YES;
    _myGenBtn.userInteractionEnabled = YES;
    if ([Utilities checkNetwork]) {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.labelText = @"网络连接异常";
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
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - NSNotificationCenter

-(void)showMyVideoPageViewCtrl:(NSNotification *)sender
{
    [self onMyVideoBtnClicked];
}

-(void)updateInfoSuccessSecond:(NSNotification *)sender
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    if (completInfoStyle == 1)
    {
        UserDetailViewCtrl *backgroundMusic = [[UserDetailViewCtrl alloc] init];
        [self.navigationController pushViewController:backgroundMusic animated:YES];
        [backgroundMusic release];
    }
    else if (completInfoStyle == 2)
    {
        FamliyTreeViewController2 *familyVC = [[FamliyTreeViewController2 alloc]init];
        familyVC.comeFirst = YES;
        [self.navigationController pushViewController:familyVC animated:YES];
        [familyVC release];
    }
}

@end





