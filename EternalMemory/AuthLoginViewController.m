//
//  AuthLoginViewController.m
//  EternalMemory
//
//  Created by Guibing Li on 13-12-18.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "AuthLoginViewController.h"
#import "SealWarnViewController.h"
#import "MD5.h"
#import "BaseDatas.h"
#import "OfflineDownLoad.h"
#import "FailedOfflineDownLoad.h"
#import "AuthCodeHelpViewController.h"
#import "LoginSecondViewController.h"
#import "EMPhotoSyncEngine.h"

#define failedDownLoad  [FailedOfflineDownLoad shareInstance]
#define offLine         [OfflineDownLoad shareOfflineDownload]

@interface AuthLoginViewController ()
{
    UIScrollView *_scrollView;
    UITextField  *_authCodeTextField;
    UITextField  *_verifycodeTextField;
    UIWebView    *_verifyCodeWebView;
    
    UIButton    *_webViewBtn;
    
    MBProgressHUD *_MUM_PROGRESS;
    BOOL        isSucceed;
}
@end

@implementation AuthLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc{
    [_authCodeTextField release];
    [_verifycodeTextField release];
    [_verifyCodeWebView release];
    [_scrollView release];
    [_MUM_PROGRESS release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"授权码登录";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    isSucceed = NO;
    
    _scrollView = [[UIScrollView alloc] init];
    if (iOS7) {
        _scrollView.frame = CGRectMake(0, 64, 320, SCREEN_HEIGHT - 64);
    }else{
        _scrollView.frame = CGRectMake(0, 44, 320, SCREEN_HEIGHT - 44);
    }
   
    if (iPhone5) {
        _scrollView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"authLoginBg-568"] stretchableImageWithLeftCapWidth:5 topCapHeight:10]];
    }else{
        _scrollView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"authLoginBg"] stretchableImageWithLeftCapWidth:5 topCapHeight:10]];
    }
//    _scrollView.layer.borderWidth = 2;
//    _scrollView.layer.borderColor = [UIColor redColor].CGColor;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelKeyboard)];
    [_scrollView addGestureRecognizer:recognizer];
    [recognizer release];
    
    
    //永恒记忆logo
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-166)/2, 15, 166, 58)];
    logo.image = [UIImage imageNamed:@"authLogin_logo"];
    [_scrollView addSubview:logo];
    [logo release];
    
    //输入框
    UIImageView  *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 300, 100)];
    img.image = [[UIImage imageNamed:@"more_tow_kuang"] stretchableImageWithLeftCapWidth:2 topCapHeight:5];
    [_scrollView addSubview:img];
    [img release];
    
    _authCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, img.frame.origin.y, 295, 50)];
    _authCodeTextField.borderStyle = UITextBorderStyleNone;
    _authCodeTextField.placeholder = @"授权码";
    _authCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _authCodeTextField.textAlignment = NSTextAlignmentLeft;
    _authCodeTextField.textColor = [UIColor blackColor];
    _authCodeTextField.font = [UIFont systemFontOfSize:14.0f];
    _authCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _authCodeTextField.returnKeyType = UIReturnKeyNext;
    _authCodeTextField.delegate = self;
    _authCodeTextField.text = @"1983042500487904A511702";
//    _authCodeTextField.text = @"510725198705177837006A0064006E";
//#if DEBUG
//    _authCodeTextField.text = @"3709231978012065945218";
//#else
//    _authCodeTextField.text = @"";
//#endif
    
    _authCodeTextField.tag = 1;
    [_scrollView addSubview:_authCodeTextField];
   
    
    _verifycodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_authCodeTextField.frame), 195, 50)];
    _verifycodeTextField.borderStyle = UITextBorderStyleNone;
    _verifycodeTextField.placeholder = @"验证码";
    _verifycodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _verifycodeTextField.textAlignment = NSTextAlignmentLeft;
    _verifycodeTextField.textColor = [UIColor blackColor];
    _verifycodeTextField.font = [UIFont systemFontOfSize:14.0f];
    _verifycodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _verifycodeTextField.returnKeyType = UIReturnKeyNext;
    _verifycodeTextField.delegate = self;
    _verifycodeTextField.tag = 2;
    [_scrollView addSubview:_verifycodeTextField];

    
    _verifyCodeWebView = [[UIWebView alloc] initWithFrame:CGRectMake(208, CGRectGetMaxY(_authCodeTextField.frame)+2, 100, 45)];
    _verifyCodeWebView.backgroundColor = [UIColor redColor];
    _verifyCodeWebView.delegate = self;
//    _verifyCodeWebView.layer.borderWidth = 2;
//    _verifyCodeWebView.layer.borderColor = [UIColor redColor].CGColor;
    _verifyCodeWebView.userInteractionEnabled = NO;
    [_scrollView addSubview:_verifyCodeWebView];
    
    _webViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _webViewBtn.frame = CGRectMake(208, CGRectGetMaxY(_authCodeTextField.frame)+2, 100, 45);
    [_webViewBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_webViewBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_webViewBtn addTarget:self action:@selector(getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_webViewBtn];
    
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(10, CGRectGetMaxY(_verifycodeTextField.frame)+20, 300, 45);
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"complete_info_btn"] forState:UIControlStateNormal];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [loginBtn addTarget:self action:@selector(didBeginSelectLogin) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:loginBtn];
    
    UIButton  *howgetAuthcodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    howgetAuthcodeBtn.frame = CGRectMake(55, _scrollView.frame.size.height - 60, 110, 30);
    [howgetAuthcodeBtn setTitle:@"如何获取授权码" forState:UIControlStateNormal];
    [howgetAuthcodeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:howgetAuthcodeBtn];
    
    UIButton  *findAuthCode = [UIButton buttonWithType:UIButtonTypeCustom];
    findAuthCode.frame = CGRectMake(175, _scrollView.frame.size.height - 60,80, 30);
    [findAuthCode setTitle:@"找回授权码" forState:UIControlStateNormal];
    [findAuthCode.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:findAuthCode];
    
    [self.view addSubview:_scrollView];
  
    [self.view bringSubviewToFront:_verifyCodeWebView];
    
    [howgetAuthcodeBtn addTarget:self action:@selector(didSelectHowGetAuthCode) forControlEvents:UIControlEventTouchUpInside];
    [findAuthCode addTarget:self action:@selector(didSelectFindAuthCodeAction) forControlEvents:UIControlEventTouchUpInside];
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getVerifyCode];
}
-(void)getVerifyCode{
    
    NSString *platformStr = [MD5 md5:@"ios"];
    NSString *tokenStr = [MD5 md5:[[SavaData shareInstance] printToken:TOKEN]];
    NSString *str = [tokenStr stringByAppendingString:platformStr];
    NSString *str1 = [MD5 md5:str];
    str1 = [str1 substringWithRange:NSMakeRange(8, 16)];
    NSString *str2 = [MD5 md5:str1];
    NSString *urlStr = [NSString stringWithFormat:@"%@user/codeImage?platform=ios&clienttoken=%@&checkstr=%@",PUBLIC_SERVER_URL,[[SavaData shareInstance] printToken:TOKEN],str2];
    NSURL *url = [NSURL URLWithString:urlStr];
    [_verifyCodeWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
}
//如何获取授权码
- (void)didSelectHowGetAuthCode
{
    [self pushAuthCodeHelpVC:1];
}
//找回授权码
- (void)didSelectFindAuthCodeAction
{
    [self pushAuthCodeHelpVC:2];
}
- (void)pushAuthCodeHelpVC:(NSInteger)index
{
    AuthCodeHelpViewController *authcodeHelp = [[AuthCodeHelpViewController alloc] initWithNibName:@"AuthCodeHelpViewController" bundle:nil];
    authcodeHelp.index = index;
    [self.navigationController pushViewController:authcodeHelp animated:YES];
    [authcodeHelp release];
}
-(void)didBeginSelectLogin
{
    
    _MUM_PROGRESS = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:_MUM_PROGRESS];
    _MUM_PROGRESS.detailsLabelText = @"正在登录中...";
    [_MUM_PROGRESS show:YES];
    
    NSURL *url = [[RequestParams sharedInstance] getAuthCodeLogin];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:_authCodeTextField.text forKey:@"authcode"];
    [request setPostValue:_verifycodeTextField.text forKey:@"authcodeloginrandomcode"];
    [request setTimeOutSeconds:20];
    [request startAsynchronous];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [_MUM_PROGRESS setHidden:YES];
    NSData *data = [request responseData];
    NSDictionary *dic = [data objectFromJSONData];
    
    if ([dic[@"success"] integerValue] ==1) {
        
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
            
            
            if ([Utilities checkNetwork]) {
                [[EMPhotoSyncEngine sharedEngine] SyncOperation];
            }

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
    }else if ([dic[@"errorcode"] integerValue] == 1005)
    {
        //提示异地登陆
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
    }else if ([dic[@"success"] integerValue] ==0 && [dic[@"errorcode"] integerValue] != 4006)
    {
        //刷新验证码
        [self networkPromptMessage:dic[@"message"]];
        [self getVerifyCode];
    }else{
        [self networkPromptMessage:dic[@"message"]];
    }
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
    
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_MUM_PROGRESS setHidden:YES];
    [self networkPromptMessage:@"网络连接异常"];
}

-(void)cancelKeyboard{
    
    [_authCodeTextField resignFirstResponder];
    [_verifycodeTextField resignFirstResponder];
    self.navBarView.hidden = NO;
    self.titleLabel.hidden = NO;
    self.backBtn.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        if (iOS7) {
            _scrollView.frame = CGRectMake(0, 64, 320, SCREEN_HEIGHT - 64);
        }else{
            _scrollView.frame = CGRectMake(0, 44, 320, SCREEN_HEIGHT - 44);
        }
        
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    } completion:^(BOOL finished) {
        
    }];
    
}
#pragma mark  UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect scrollViewFrame = _scrollView.frame;
        scrollViewFrame.origin.y = 0;
        _scrollView.frame = scrollViewFrame;
        [_scrollView setContentOffset:CGPointMake(0, 20) animated:YES];
        self.navBarView.hidden = YES;
        self.titleLabel.hidden = YES;
        self.backBtn.hidden = YES;
        
    } completion:^(BOOL finished) {
        
    }];
   
    
    if (textField.tag ==2) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag == 1) {
        [_verifycodeTextField becomeFirstResponder];
    }else if (textField.tag ==2){
        
        [textField resignFirstResponder];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    return YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self networkPromptMessage:@"网络连接异常"];
    if (!isSucceed) {
        [_webViewBtn setTitle:@"点击重新获取" forState:UIControlStateNormal];
    }
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_webViewBtn setTitle:@"" forState:UIControlStateNormal];
    isSucceed = YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL isLogin = NO;
    [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
    [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
}
-(void)backBtnPressed{
    
    [self dismissViewControllerAnimated:YES completion:NO];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
