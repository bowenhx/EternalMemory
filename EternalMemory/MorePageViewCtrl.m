//
//  MorePageViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 13-7-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import "ResumeVedioSendOperation.h"
#import "PrivacySetViewController.h"
#import "EternalMemoryAppDelegate.h"
#import "StyleSelectListViewCtrl.h"
#import "BackgroundMusicViewCtrl.h"
#import "ChangePasswordViewCtrl.h"
#import "AboutMemoryViewCtrl.h"
#import "UploadingDebugging.h"
#import "MusicSendOperation.h"
#import "VedioSendOperation.h"
#import "SetPrivacyViewCtrl.h"
#import "StyleSendOperation.h"
#import "UserDetailViewCtrl.h"
#import "UploadingDebugging.h"
#import "MoreinputViewCell.h"
#import "EMPhotoSyncEngine.h"
#import "MorePageViewCtrl.h"
#import "DownloadViewCtrl.h"
#import "StyleListSQL.h"
#import "MyFamilySQL.h"
#import "CommonData.h"
#import "FileModel.h"
#import "Config.h"
#import "MD5.h"


#define FileModel  [FileModel sharedInstance]

@interface MorePageViewCtrl ()
{
    NSDictionary *_dicFileData;
    NSString *_strVersion;
   
}



@end

@implementation MorePageViewCtrl

- (void)dealloc {
    [_myScrollView release];
    [_progress release];
    [_roomSizeLab release];
    [_updateTimeLab release];
    [_personBut release];
    [_musicBut release];
    [_uploadingBut release];
    [_familyBut release];
    [_updataText release];
    [_roomText release];
    [_userNameLab release];
    [_dicFileData release],_dicFileData = nil;
    [_privacyBut release];
    [_passwordBut release];
    [_versionsBut release];
    [_strVersion release];
    [_aboutBut release];
    [_homeStyleBut release];
    [_showRoomImage release];
    [_styleSelectBut release];
    [_versionNumLab release];
    [_kOpenSwitch release];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"更多功能";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    self.myScrollView.backgroundColor = RGBCOLOR(238, 242, 245);
    self.myScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 550);
    self.myScrollView.showsVerticalScrollIndicator = NO;
    [self.showRoomImage setImage:[[UIImage imageNamed:@"public_table_fullBg"] stretchableImageWithLeftCapWidth:5 topCapHeight:10]];
    
//    NSString *openStr = [NSString stringWithFormat:@"%@",[[SavaData shareInstance] printDataStr:kOpenSynchr]];
//    if ([openStr isEqualToString:@"(null)"]) {
//        _kOpenSwitch.on = YES;
//    }else{
//        _kOpenSwitch.on = [openStr boolValue];
//    }
    CGRect openSwitchFrame = _kOpenSwitch.frame;
    openSwitchFrame.origin.x = iOS7 ? _kOpenSwitch.frame.origin.x : self.view.frame.size.width-100;
    _kOpenSwitch.frame = openSwitchFrame;
    
    
    [self.userNameLab setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.roomText setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.updataText setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.roomSizeLab setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.updateTimeLab setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    
    [self.personBut setTitleColor:RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.privacyBut setTitleColor:RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.passwordBut setTitleColor:RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.musicBut setTitleColor:RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.styleSelectBut setTitleColor:RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.homeStyleBut setTitleColor:RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.uploadingBut setTitleColor:RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.familyBut setTitleColor:RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.versionsBut setTitleColor:RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.aboutBut setTitleColor:RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    self.versionNumLab.text = [NSString stringWithFormat:@"当前版本:%@",version];
    [self initUpData];
    
#if TARGET_VERSION_LITE ==1//免费版
#elif TARGET_VERSION_LITE ==2//授权版
    _passwordBut.hidden = YES;
    CGRect scrollViewFrmae = _myScrollView.frame;
    scrollViewFrmae.origin.y -= 60;
    _myScrollView.frame = scrollViewFrmae;
#endif

    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initUpData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}
- (void)initUpData
{
    _dicFileData = [[NSDictionary dictionaryWithDictionary:[SavaData parseDicFromFile:User_File]] retain];
    
    self.userNameLab.text = [NSString stringWithFormat:@"%@",[_dicFileData objectForKey:@"userName"]];
    
    NSString *spaceTotal = [NSString stringWithFormat:@"%@",[_dicFileData objectForKey:@"spaceTotal"]];
    NSString *spaceUsed = [NSString stringWithFormat:@"%@",[_dicFileData objectForKey:@"spaceUsed"]];
    NSString *lastTime = [NSString stringWithFormat:@"%@",[_dicFileData objectForKey:@"lastLoginTime"]];
    self.progress.progress = [CommonData getProgress:[spaceTotal floatValue] currentSize:[spaceUsed floatValue]];
    
    self.progress.progressTintColor = RGBCOLOR(46, 154, 222);
    self.roomSizeLab.text = [NSString stringWithFormat:@"%@ / %@",[CommonData getFileSizeString:spaceUsed],[CommonData getFileSizeString:spaceTotal]];
    //R46 G154 B222
    self.updateTimeLab.text = [CommonData getTimeransitionPath:lastTime];
//    NSInteger selectedStyle = [[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@homeStyle",USERID]] intValue];
    if ([[SavaData shareInstance] printDataStr:@"homeStyle"] == nil || [[[SavaData shareInstance] printDataStr:@"homeStyle"] isEqualToString:@"(null)"])
    {
        self.styleLabel.text = @"美式风格";
    }
    else
    {
        self.styleLabel.text = [[SavaData shareInstance] printDataStr:@"homeStyle"];//selectedStyle == 0 ?@"美式风格":@"欧式风格";
    }
}
//是否开启同步设置
- (IBAction)didSetOpenSynchronization:(UISwitch *)sender
{
    [[SavaData shareInstance] savadataStr:[NSString stringWithFormat:@"%d",sender.on] KeyString:kOpenSynchr];
}
//清除缓存btn
- (IBAction)didSelectPrivacyAction:(UIButton *)sender {
    UIActionSheet *action = [[[UIActionSheet alloc] initWithTitle:@"清除缓存，节省空间" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清除" otherButtonTitles:nil, nil] autorelease];
    action.tag = 101;
    [action showInView:self.view];
}

- (IBAction)didSelectPasswordAction:(UIButton *)sender {
    ChangePasswordViewCtrl *changeVC = [[ChangePasswordViewCtrl alloc]init];
    [self.navigationController pushViewController:changeVC animated:YES];
    [changeVC release];
}

- (IBAction)didSelectVersionsUpDataAction:(UIButton *)sender {
    self.versionsBut.enabled = NO;
    [self versionUpdata];
}

- (IBAction)didSelectAboutAppAction:(UIButton *)sender {
    AboutMemoryViewCtrl *aboutMemory = [AboutMemoryViewCtrl new];
    [self.navigationController pushViewController:aboutMemory animated:YES];
    [aboutMemory release];
}

- (IBAction)didSelectStyleBoard:(UIButton *)sender
{
    StyleSelectListViewCtrl *styleSelect = [[StyleSelectListViewCtrl alloc] init];
    [self.navigationController pushViewController:styleSelect animated:YES];
    [styleSelect release];
}

- (IBAction)didSelectHomeStyleAction:(UIButton *)sender {
   
}

- (IBAction)didSelectpersonalFileAction:(UIButton *)sender {

    UserDetailViewCtrl *editPersonal = [UserDetailViewCtrl new];
    [self.navigationController pushViewController:editPersonal animated:YES];
    [editPersonal release];
    
}

- (IBAction)didSelectMusicAction:(UIButton *)sender {
    BackgroundMusicViewCtrl *backgroundMusic = [[BackgroundMusicViewCtrl alloc] init];
    [self.navigationController pushViewController:backgroundMusic animated:YES];
    [backgroundMusic release];
}
- (IBAction)didSelectFamilyAction:(UIButton *)sender {
//    FamilyTreeViewController *familyVC = [[FamilyTreeViewController alloc]init];
//    [self.navigationController pushViewController:familyVC animated:YES];
//    [familyVC release];
}

- (IBAction)didSelectUploadingListAction:(UIButton *)sender {
    DownloadViewCtrl *upentry = [DownloadViewCtrl new];
    [self.navigationController pushViewController:upentry animated:YES];
    [upentry release];
}

- (IBAction)didSelectResignLoginAction:(UIButton *)sender {
    UIActionSheet *actionSheet = [[[UIActionSheet alloc]initWithTitle:@"退出后不会删除数据" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil, nil]autorelease];
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag ==100) {
        if (buttonIndex == 0) {
            
            [[EMPhotoSyncEngine sharedEngine] stopSync];
            BOOL isUplaoding = [UploadingDebugging isUploading];
            if (FileModel.isUpVideo || FileModel.isDownVideo || isUplaoding == YES ||FileModel.styleOperation.count>0)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"监测到您目前还在文件传输,是否确定退出" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alert.tag = 300;
                
                [alert show];
                [alert release];
            }else
            {
                [UploadingDebugging setupUploadingInfo];
                NSString *style = [[SavaData shareInstance] printDataStr:offLineStyle];
                if (style.length >0) {
                    [[SavaData shareInstance] savadataStr:@"off" KeyString:offLineStyle];
                }
                [self showLoginViction];
            }
        }
    }else{//清除缓存
        if (buttonIndex ==0) {
            NSError *error;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSArray *styleArrs = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];

           //删除风格模板文件
            for (NSString *style2 in styleArrs) {
                if (![style2 isEqualToString:@"style2"]) {
                    NSString *styleID = [style2 substringWithRange:NSMakeRange(style2.length-1, 1)];
                    [StyleListSQL isDelectdateDownLoadState:0 styleID:[styleID integerValue]];
                    NSString *deletePath = [documentsDirectory stringByAppendingPathComponent:style2];
                    
                    [fileManager removeItemAtPath:deletePath error:&error];
                    if (!error) {
                    }
                }
            }
            //删除音乐，视频，相册，等
            NSString *restPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"ETMemory"];
            NSArray *restArrs = [fileManager contentsOfDirectoryAtPath:restPath error:nil];
             NSString *downFileName = [NSString stringWithFormat:@"%@",[SavaData parseDicFromFile:[NSString stringWithFormat:@"%@.plist",USERID]][@"userName"]];
            
            for (NSString *restName in restArrs) {
                if ([restName isEqualToString:@"Photos"]) {
                    NSString *deletePath = [[restPath stringByAppendingPathComponent:restName]stringByAppendingPathComponent:USERID];
                    [fileManager removeItemAtPath:deletePath error:&error];
                    if (!error) {
                    }
                }else{//删除音乐和视频
                    NSString *deletePath = [[restPath stringByAppendingPathComponent:restName]stringByAppendingPathComponent:downFileName];
                    [fileManager removeItemAtPath:deletePath error:&error];
                    if (!error) {
                    }
                }
            }
            
            //删除用户家谱图片
            NSString *imageCache = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library" ]stringByAppendingPathComponent:@"Caches"] stringByAppendingPathComponent:@"ImageCache"];
            NSArray *familyArr = [MyFamilySQL getMembersHeadPortrait:USERID];
            for (NSString *urlImage in familyArr) {
                NSString *imagePath = [MD5 md5:urlImage];
                NSString *imagePath2 = [imageCache stringByAppendingPathComponent:imagePath];
                BOOL isError = [fileManager removeItemAtPath:imagePath2 error:&error];
                if (!error) {
                }
            }
            
            //清除照片数据库
            [Utilities deleteAllPhotoDataOfCurrentUser];
            [Utilities deleteAllAudioOfCurrentUser];
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:PHOTOVERSION];
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:VEDIOVERSION];

            [self networkPromptMessage:@"缓存清除成功"];
        }
    }
    
}
//退出登陆清除上传的数据信息
+ (void)clearUploadingInfo
{
    if (FileModel.musicNumber ||FileModel.videoNumber ||FileModel.download_videoNum || FileModel.uploadingArr.count >0)
    {
        if ([FileModel.operation isKindOfClass:[MusicSendOperation class]])
        {
            MusicSendOperation *musicOperation = (MusicSendOperation *)FileModel.operation;
            [musicOperation.dataRequest clearDelegatesAndCancel];
            musicOperation.dataRequest = nil;
            [musicOperation isCancelled];
        }
        else
        {
            VedioSendOperation *vedioOperation = (VedioSendOperation *)FileModel.operation;
            [vedioOperation.dataRequest clearDelegatesAndCancel];
            vedioOperation.dataRequest = nil;
            [vedioOperation isCancelled];
        }
        [FileModel.uploadingArr removeAllObjects];
        FileModel.operation = nil;
        FileModel.isUploading = NO;
        if (FileModel.arrDownloadList.count>0) {
            id request = FileModel.arrDownloadList[0];
            [request cancel];
            [request clearDelegatesAndCancel];
        }
        
        [FileModel.arrDownloadList removeAllObjects];
        [FileModel.downloadArr removeAllObjects];
        
        FileModel.isDownVideo = NO;
        FileModel.upReceivedSize = @"0";
        FileModel.download_videoNum = 0;
        FileModel.musicNumber = 0;
        FileModel.videoNumber = 0;
        FileModel.downReceivedSize = @"0";
        FileModel.downFileSize = @"0";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeVideoList" object:[NSNumber numberWithBool:NO]];
    }
    
    if( FileModel.styleOperation.count>0){
        StyleSendOperation *styleOperation = (StyleSendOperation *)[FileModel.styleOperation objectAtIndex:0];
        [styleOperation.styleRequest clearDelegatesAndCancel];
        styleOperation.styleRequest = nil;
        [styleOperation isCancelled];
        [FileModel.styleOperation removeAllObjects];
        [FileModel.downStyleIDArr removeAllObjects];
    }
}
//退出登陆
- (void)showLoginViction
{
    BOOL islogin = NO;
    //by jxl
    [[SavaData shareInstance]savaDataBool:islogin KeyString:ISLOGIN];
    //清除保存的验证码
    [[SavaData shareInstance]savadataStr:nil KeyString:USER_AUTH_SAVA];
    [(EternalMemoryAppDelegate *)([UIApplication sharedApplication].delegate)showLoginVC];
}
- (void)versionUpdata
{
    //版本更新提示
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    NSURL *url =  [[RequestParams sharedInstance] getClientVersion];
    ASIFormDataRequest *requestUpData = [ASIFormDataRequest requestWithURL:url];
    [requestUpData setRequestMethod:@"POST"];
    [requestUpData addPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [requestUpData addPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [requestUpData setPostValue:@"ios" forKey:@"platform"];
    [requestUpData setPostValue:version forKey:@"versions"];
    [requestUpData setTimeOutSeconds:10];
    requestUpData.failedBlock = [^(void)
                                 {
                                     self.versionsBut.enabled = YES;
                                     [self networkPromptMessage:@"网络连接异常"];
                                 } copy];
    requestUpData.completionBlock = [^(void){
                                         self.versionsBut.enabled = YES;
                                         NSData *data = [requestUpData responseData];
                                         NSDictionary *dataDic = [data objectFromJSONData];
                                         NSInteger success = [[dataDic objectForKey:@"success"] integerValue];
                                         
                                         if (success==1) {
                                             NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
                                             if (![dataDic[@"data"] isEqual:@""]) {
                                                 NSString *vers = [[dataDic objectForKey:@"data"]objectForKey:@"versions"];
                                                int versInt = [[vers stringByReplacingOccurrencesOfString:@"." withString:@""]integerValue];
                                                 if ([[NSString stringWithFormat:@"%d",versInt] length] == 2) {
                                                     versInt = [[NSString stringWithFormat:@"%d0",versInt] integerValue];
                                                 }
                                                 
                                                 int versionInt = [[version stringByReplacingOccurrencesOfString:@"." withString:@""]integerValue];
                                                 if ([[NSString stringWithFormat:@"%d",versionInt] length] == 2) {
                                                     versionInt = [[NSString stringWithFormat:@"%d0",versionInt] integerValue];
                                                 }
                                                 if (versInt == versionInt) {
                                                     
                                                     NSString *verNew = [NSString stringWithFormat:@"已经是最新版本:%@",version];
                                                     [self networkPromptMessage:verNew];
                                                     
                                                 }else{
                                                     _strVersion = [dataDic[@"data"][@"fullURL"] retain];
                                                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"版本升级提示" message:[NSString stringWithFormat:@"最新版本为:%@",vers] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即升级", nil];
                                                     alert.tag = 200;
                                                     [alert show];
                                                     [alert release];
                                                     
                                                 }
                                                 
                                             }else{
                                        
                                                 NSString *verNew = [NSString stringWithFormat:@"已经是最新版本:%@",version];
                                                 [self networkPromptMessage:verNew];
                                             }
                                             
                                         }else if ([dataDic[@"errorcode"] integerValue] == 1005)
                                         {
                                             [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
                                         }
                                     } copy];
    
    [requestUpData startAsynchronous];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 200) {
        if (buttonIndex == 1) {
            NSString *updateStr = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@",APPLE_ID];
            NSURL *url = [NSURL URLWithString:updateStr];
            [[UIApplication sharedApplication]openURL:url];
        }
    }else if(alertView.tag == 300)
    {
        if (buttonIndex == 1)
        {
            [UploadingDebugging setupUploadingInfo];
            //TODO:删除数据库中处于正在下载状态的数据
            [StyleListSQL deleteDownLoadByIsDownLoad:2];
            //退出的时候取消日志的同步
            {
                EternalMemoryAppDelegate *appDelegate = (EternalMemoryAppDelegate*)[UIApplication sharedApplication].delegate;
                [appDelegate.synData cleanRequest];
                [appDelegate.synData release];
                appDelegate.synDataCount = 0;
                appDelegate.synData = nil;
                [[NSNotificationCenter defaultCenter] removeObserver:appDelegate name:@"synDataOver" object:nil];

            }

            [MorePageViewCtrl clearUploadingInfo];
            [FileModel cancleRequestDelegate];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            NSString *style = [[SavaData shareInstance] printDataStr:offLineStyle];
            if (style.length >0) {
                [[SavaData shareInstance] savadataStr:@"off" KeyString:offLineStyle];
            }
            [self showLoginViction];
            
//#warning 退出登录待定
//            [self loginOutRequest];
        }
    }
    else
    {
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
    }
}
-(void)loginOutRequest{
    
    NSURL * url = [[RequestParams sharedInstance] loginOut];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    request.timeOutSeconds = 10;
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setPostValue:TOKEN forKey:@"clienttoken"];
    [request setPostValue:AUTH_CODE forKey:@"serverauth"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        
    }];
    [request setFailedBlock:^{
        
    }];
    
}
-(void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setShowRoomImage:nil];
    [self setStyleSelectBut:nil];
    [self setVersionNumLab:nil];
    [super viewDidUnload];
}

@end
