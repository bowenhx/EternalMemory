//
//  LoginViewController.m
//  EternalMemory
//
//  Created by sun on 13-5-10.
//  Copyright (c) 2013年 sun. All rights reserved.
//


#import "CompleteLoginInfoViewController.h"
#import "LoginSecondViewController.h"
#import "EternalMemoryAppDelegate.h"
#import "NTPrivacyProblemViewCtrl.h"
#import "MyLifeMainViewController.h"
#import "StyleSelectListViewCtrl.h"
#import "RegisterViewController.h"
#import "FailedOfflineDownLoad.h"
#import "RMWFirstTouchHelpView.h"
#import "LoginViewController.h"
#import "EMPhotoSyncEngine.h"
#import "DiaryMessageModel.h"
#import "MorePageViewCtrl.h"
#import "SynDataBackstage.h"
#import "DiaryGroupsModel.h"
#import "OfflineDownLoad.h"
#import "DiaryMessageSQL.h"
#import "DiaryGroupsSQL.h"
#import "ForgotPswordVC.h"
#import "RequestParams.h"
#import "MessageSQL.h"
#import "BaseDatas.h"
#import "Utilities.h"
#import "MyToast.h"
#import "MD5.h"
#import "CommonData.h"

#define REQUEST_FOR_LOGIN 100
#define REQUEST_FOR_AUTOLOGIN 101
#define WARM_ALERT @"友情提示"
@interface LoginViewController ()
{
    NSInteger synDataCount;
    SynDataBackstage *synData;
}

@property(nonatomic, retain) __block IBOutlet UITextField *userNameTextField;
@property(nonatomic, retain) __block IBOutlet UITextField *passWordTextField;
- (IBAction)onLoginBtnClicked;
- (IBAction)onRegisterBtnClicked;
- (IBAction)onGetPassWordBtnClicked;
- (IBAction)textFieldResignFirstResponder;
- (void)loginRequest;
@end

#define failedDownLoad  [FailedOfflineDownLoad shareInstance]
#define offLine         [OfflineDownLoad shareOfflineDownload]


@implementation LoginViewController

@synthesize userNameTextField = _userNameTextField;
@synthesize passWordTextField = _passWordTextField;
@synthesize userNameTextStr = _userNameTextStr;
@synthesize passWordTextStr = _passWordTextStr;
@synthesize changeServer = _changeServer;
#pragma mark - private methods
- (void)loginRequest
{
    
    NSURL *registerUrl = [[RequestParams sharedInstance] log];
    //登陆清除上传的数据信息
    [MorePageViewCtrl clearUploadingInfo];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:registerUrl];
    request.shouldAttemptPersistentConnection = NO;
    request.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_LOGIN],@"tag", nil] ;
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:_userNameTextField.text forKey:@"username"];
    [request setPostValue:[MD5 md5:_passWordTextField.text] forKey:@"password"];
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:10.0];
    __block typeof(self) bself = self;
    [request setCompletionBlock:^{
        [bself requestSuccess:request];
    }];
    [request setFailedBlock:^{
        [bself requestFail:request];
    }];
    [request startAsynchronous];
}

#pragma mark - object lifecycle
- (void)dealloc
{
    [_passWordTextStr release];
    RELEASE_SAFELY(_mb);
    RELEASE_SAFELY(_userNameTextField);
    RELEASE_SAFELY(_passWordTextField);
    [_btnView release];
    [_logoImgV release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_changeServer release];
    [super dealloc];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _passWordTextStr = [NSString stringWithFormat:@""];
        _userNameTextStr = [NSString stringWithFormat:@""];
        [self.view setBackgroundColor:RGBCOLOR(238, 242, 245)];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"RMWFirstTouchHelpView"] ){

    }
}

-(void)relodLoginView:(NSDictionary *)dict{
    
    self.userNameTextField.text=[NSString stringWithFormat:@"%@",dict[@"userName"]];
    self.passWordTextField.text=[NSString stringWithFormat:@"%@",dict[@"passWord"]];
    registToLogin = [dict[@"registToLogin"] boolValue];
    
    [self onLoginBtnClicked];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self textFieldResignFirstResponder];
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    
}
-(void)pushToSecondWay{
    
    [self pushSecondLoginLineOperation];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = @"登录";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    
    self.btnView.backgroundColor = RGBCOLOR(238, 242, 245);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToSecondWay) name:@"ToSecondWay" object:nil];
    BOOL networks = CHECK_NETWORK;
    BOOL isLogin = USER_IS_LOGIN;
    
    NSDictionary *dic=[SavaData  parseDicFromFile:User_File];
    [[SavaData shareInstance] savaDataBool:NO  KeyString:First_Regist];

    
    if (networks) {
        
        if (!isLogin) {
            [_userNameTextField becomeFirstResponder];
            NSDictionary *dic = [[SavaData shareInstance] printDataDic:@"registerToLogin"];
            if (dic.count != 0) {
                [self relodLoginView:dic];
                [[SavaData shareInstance] savaDictionary:[NSDictionary dictionary] keyString:@"registerToLogin"];
            }
        }else{
            
            NSString *forbidenStatu = [[NSUserDefaults standardUserDefaults]objectForKey:@"forbidenStatu"];
            if ([forbidenStatu isEqualToString:@"100"]) {//家园已封存
                
                _userNameTextStr = [dic objectForKey:@"userName"];
                [_userNameTextField setText:_userNameTextStr];
                _passWordTextField.text = @"";
                [_passWordTextField becomeFirstResponder];

            }else{
            
            _userNameTextStr = [dic objectForKey:@"userName"];
            [_userNameTextField setText:_userNameTextStr];
            _passWordTextField.text = @"11111111";
            [self AutologinRequest];
            }
        }
        
    }else if(!networks && isLogin){
        
        _userNameTextStr = [dic objectForKey:@"userName"];
        [_userNameTextField setText:_userNameTextStr];
        _passWordTextField.text = @"11111111";
        
        LoginSecondViewController *loginSecond = [[LoginSecondViewController alloc] initWithNibName:@"LoginSecondViewController" bundle:nil];
        double delayInSeconds = 0.05;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self firstOpenAppAfterUpdateApp];
            [self.navigationController pushViewController:loginSecond animated:NO];
        });
        [loginSecond release];
    }
}
- (void)AutologinRequest
{
    [self.logoImgV setHidden:NO];
    BOOL isNetwork = [Utilities checkNetwork];
    if (!isNetwork) {
        
    }else{
        
        _mb = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:_mb];
        _mb.detailsLabelText = @"正在登录中...";
        _mb.delegate = self;
        [_mb show:YES];
        
        NSURL *registerUrl = [[RequestParams sharedInstance] authlogin];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:registerUrl];
        request.delegate = self;
        request.shouldAttemptPersistentConnection = NO;
        request.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_AUTOLOGIN],@"tag", nil] ;
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:TOKEN];
        NSString *tokenStr = [NSString stringWithFormat:@"%@",str];
        [request setPostValue:tokenStr forKey:@"clienttoken"];
        [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
        [request setRequestMethod:@"POST"];
        [request setTimeOutSeconds:10.0];
        __block typeof (self) bself=self;
        
        [request setCompletionBlock:^{
            [bself requestSuccessAutoLogin:request];
        }];
        [request setFailedBlock:^{
            [bself requestFail:request];
        }];
        [request startAsynchronous];
    }
}

-(void)requestSuccessAutoLogin:(ASIHTTPRequest *)request{
    
    [_mb setHidden:YES];
    
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSString *resultStr = [NSString stringWithFormat:@"%@",resultDictionary[@"success"]];
    NSInteger tag = [request.userInfo[@"tag"] integerValue];
    self.errorCodeStr = resultDictionary[@"errorcode"];
    if (tag == REQUEST_FOR_AUTOLOGIN) {
        if ([resultStr isEqualToString:@"1"]) {
            
            //更新app后首次登录应用
            [self firstOpenAppAfterUpdateApp];
            
            [[SavaData shareInstance] savaDataBool:NO KeyString:ISHANDLOGIN];
            NSDictionary *dataDic = [resultDictionary objectForKey:@"data"];
            
            NSString *plistPath =[PATH_OF_DOCUMENT stringByAppendingPathComponent:User_File];
            NSMutableDictionary *userDataDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
            if (dataDic.count >0) {
                //保存当前登录用户服务器地址配置
                [[SavaData shareInstance] savadataStr:dataDic[@"specifiedhost"] KeyString:@"specifiedhost"];
                [[SavaData shareInstance] savadataStr:dataDic[@"specifiedport"] KeyString:@"specifiedport"];
                
                [userDataDic setObject:[dataDic objectForKey:@"SID"] forKey:@"SID"];
                [userDataDic setObject:[dataDic objectForKey:@"addressdetail"] forKey:@"addressdetail"];
                [userDataDic setObject:[dataDic objectForKey:@"clientToken"] forKey:@"clientToken"];
                [userDataDic setObject:[dataDic objectForKey:@"email"] forKey:@"email"];
                [userDataDic setObject:[dataDic objectForKey:@"favoriteMusic"] forKey:@"favoriteMusic"];
                [userDataDic setObject:[dataDic objectForKey:@"favoriteStyle"] forKey:@"favoriteStyle"];
                [userDataDic setObject:[dataDic objectForKey:@"intro"] forKey:@"intro"];
                [userDataDic setObject:[dataDic objectForKey:@"lastLoginTime"] forKey:@"lastLoginTime"];
                [userDataDic setObject:[dataDic objectForKey:@"latestVersion"] forKey:@"latestVersion"];
                [userDataDic setObject:[dataDic objectForKey:@"memoryCode"] forKey:@"memoryCode"];
                [userDataDic setObject:[dataDic objectForKey:@"mobile"] forKey:@"mobile"];
                [userDataDic setObject:[dataDic objectForKey:@"openStatus"] forKey:@"openStatus"];
                [userDataDic setObject:[dataDic objectForKey:@"realName"] forKey:@"realName"];
                [userDataDic setObject:[dataDic objectForKey:@"serverAuth"] forKey:@"serverAuth"];
                [userDataDic setObject:[dataDic objectForKey:@"sex"] forKey:@"sex"];
                [userDataDic setObject:[dataDic objectForKey:@"spaceTotal"] forKey:@"spaceTotal"];
                [userDataDic setObject:[dataDic objectForKey:@"spaceUsed"] forKey:@"spaceUsed"];
                [userDataDic setObject:[dataDic objectForKey:@"userId"] forKey:@"userId"];
                [[SavaData shareInstance] savadataStr:[dataDic objectForKey:@"userId"] KeyString:USER_ID_ORIGINAL];
                [userDataDic setObject:[dataDic objectForKey:@"userName"] forKey:@"userName"];
                
                [[SavaData shareInstance] saveStrValue:[dataDic objectForKey:@"userName"] andKey:USER_NAME_SAVE];

                [userDataDic writeToFile:plistPath atomically:YES];
                
            }
            [userDataDic release];
            [self pushSecondLoginLineOperation];
            
            if ([Utilities checkNetwork]) {
                [[EMPhotoSyncEngine sharedEngine] SyncOperation];
            }
            
        }else if ([_errorCodeStr isEqualToString:@"1005"])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1000;
            [alert show];
            [alert release];
            
        }else if ([_errorCodeStr isEqualToString:@"9000"]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"账号已封存，请使用授权版" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载授权版", nil];
            alert.tag = 2000;
            [alert show];
            [alert release];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - public methods
- (IBAction)onLoginBtnClicked
{
    
    if ([_userNameTextField.text isEqualToString:@""]) {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        [HUD release];
        HUD.labelText = @"请输入您的用户名";
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(2);
        } completionBlock:^{
            [HUD removeFromSuperview];
            [_userNameTextField becomeFirstResponder];
        }];
        return;
    }
    else if (_userNameTextField.text.length != 0)
    {
        NSInteger length = _userNameTextField.text.length;
        for (int i = 0; i < length; i ++)
        {
            unichar blank = [_userNameTextField.text characterAtIndex:i];
            if (blank == ' ')
            {
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                [HUD release];
                HUD.labelText = @"您的用户名包含空格，请重新输入";
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
                [HUD showAnimated:YES whileExecutingBlock:^{
                    sleep(2);
                } completionBlock:^{
                    [HUD removeFromSuperview];
                    [_userNameTextField becomeFirstResponder];
                }];
                return;
            }
        }
    }
    
    else if ([_passWordTextField.text isEqualToString:@""])
    {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        [HUD release];
        HUD.labelText = @"请输入您的密码";
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(2);
        } completionBlock:^{
            [HUD removeFromSuperview];
            [_passWordTextField becomeFirstResponder];
            
        }];
        return;
    }
    [self textFieldResignFirstResponder];

    if (_passWordTextField.text.length < 8) {
        
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        [HUD release];
        HUD.labelText = @"请填写正确密码";
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(2);
        } completionBlock:^{
            [HUD removeFromSuperview];

        }];

    }
    else{
       
        if (CHECK_NETWORK) {
           
            _mb = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:_mb];
            _mb.detailsLabelText = @"正在登录中...";
            _mb.delegate = self;
            [_mb show:YES];
            [self loginRequest];
        }else{
            
            [Utilities noNetworkAlert];
        }
        
       
    }

    
}
- (IBAction)onRegisterBtnClicked
{
    RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:iPhone5 ?  @"RegisterViewController-5":@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerViewController animated:YES];
    [registerViewController release];
    
}
- (IBAction)onGetPassWordBtnClicked
{
    BOOL isHaveNetwork = [Utilities checkNetwork];
    
    if (isHaveNetwork) {
        
        ForgotPswordVC *_forgotPasswordViewController = [[ForgotPswordVC alloc] init];
        [self.navigationController pushViewController:_forgotPasswordViewController animated:YES];
        [_forgotPasswordViewController release];
        
    }else{
        
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        [HUD release];
        HUD.labelText = @"请检查网络";
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(2);
        } completionBlock:^{
            [HUD removeFromSuperview];
        }];
    }
}
- (IBAction)textFieldResignFirstResponder
{
    [self.logoImgV setHidden:NO];
    [_passWordTextField becomeFirstResponder];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    //修改点击view不让键盘消失，原视图保持不变
    if (iOS7)
    {
        [_btnView setFrame:CGRectMake(0, -30, self.view.bounds.size.width, self.view.bounds.size.height)];
    }
    else
    {
        [_btnView setFrame:CGRectMake(0, -90, self.view.bounds.size.width, self.view.bounds.size.height)];
    }
    [UIView commitAnimations];
}
#pragma mark - request
-(void)requestSuccess:(ASIFormDataRequest *)request
{
    [_mb hide:YES];
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSInteger result = [resultDictionary[@"success"] integerValue];
    NSString *message = resultDictionary[@"message"];
    self.errorCodeStr = resultDictionary[@"errorcode"];
    
    switch (result) {
        case 0:
            [self showPromptMessage:message];
            

            if ([_errorCodeStr isEqualToString:@"9000"]) {
                
                [self needAuthVersion];
                
            }
            break;
        case 1:
            
            //用户基本信息的存储一定要放在最前面，其他处理会使用到用户信息
            
            [self saveUserInfoData:resultDictionary];
            
            [self addBirthAndDeathRemindToLocal:resultDictionary];
            
            [BaseDatas openBaseDatas:USERID];
            [BaseDatas closeBaseDatas:USERID];
            
            //更新app后首次登录应用
            [self firstOpenAppAfterUpdateApp];
            
            if (registToLogin) {
                [[SavaData shareInstance] savaDataBool:registToLogin  KeyString:First_Regist];
                [self jumpToCompeleteVC];
                
            }else{
                
                [self handleSync];
                
                [Utilities resetCommonData];
                
                [self pushSecondLoginLineOperation];
            }
            break;
            
        default:
            break;
    }
}
//离线数据同步
-(void)synchronizeDataOver:(NSNotification *)sender
{
    NSInteger count = [sender.object intValue];
    if (synDataCount == count)
    {
        [synData cleanRequest];
        [synData release];
        synData = nil;
        synDataCount = 0;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"synDataOver" object:nil];
    }
}

//登陆后选择是否是离线和在线操作
- (void)pushSecondLoginLineOperation
{
    LoginSecondViewController *loginSecond = [[LoginSecondViewController alloc] initWithNibName:@"LoginSecondViewController" bundle:nil];
    [self.navigationController pushViewController:loginSecond animated:YES];
    [loginSecond release];
}
-(void)requestFail:(ASIFormDataRequest *)request
{
    [_mb hide:YES];
    NSInteger tag = [[request.userInfo objectForKey:@"tag"] integerValue];
    if (tag == REQUEST_FOR_LOGIN) {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        [HUD release];
        HUD.labelText = @"网络连接异常";
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(2);
        } completionBlock:^{
            [HUD removeFromSuperview];
            
        }];
    }
    if (tag == REQUEST_FOR_AUTOLOGIN) {
        BOOL network = [Utilities checkNetwork];
        if (network) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"友情提示" message:@"网络请求失败，点击确定重新登录" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            alert.tag = 1001;
            [alert show];
            [alert release];
        }else{
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            [HUD release];
            HUD.labelText = @"网络连接异常";
            [HUD showAnimated:YES whileExecutingBlock:^{
                sleep(2);
            } completionBlock:^{
                [HUD removeFromSuperview];
                
            }];
            _passWordTextField.text = @"";
        }
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
        [self settingLocalRemind:date andType:@"忌日" andMemberId:dict[@"memberId"] andName:dict[@"name"] andTime:@"明天"];
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == _userNameTextField) {
        
        [_passWordTextField becomeFirstResponder];
        
    }
    if (textField == _passWordTextField) {
        
        [self.logoImgV setHidden:NO];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.3f];
        if (iOS7)
        {
            [_btnView setFrame:CGRectMake(0, -30, self.view.bounds.size.width, self.view.bounds.size.height)];

        }
        else
        {
        [_btnView setFrame:CGRectMake(0, -90, self.view.bounds.size.width, self.view.bounds.size.height)];
        }

        [UIView commitAnimations];
        
    }
    return YES;
}

-(void)upLoginVC{
    [self.logoImgV setHidden:YES];
    if (iPhone5) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.3f];
        if (iOS7)
        {
            [_btnView setFrame:CGRectMake(0, -30, self.view.bounds.size.width, self.view.bounds.size.height)];
            
        }
        else
        {
            [_btnView setFrame:CGRectMake(0, -90, self.view.bounds.size.width, self.view.bounds.size.height)];
        }
        [UIView commitAnimations];
        
        
    }else{
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.3f];
        if (iOS7)
        {
            [_btnView setFrame:CGRectMake(0, -30, self.view.bounds.size.width, self.view.bounds.size.height)];
            
        }
        else
        {
            [_btnView setFrame:CGRectMake(0, -90, self.view.bounds.size.width, self.view.bounds.size.height)];
        }
        [UIView commitAnimations];
        
    }
}
#pragma mark - textFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self upLoginVC];
   
}

-(void)saveUserInfoData:(NSDictionary *)resultDictionary{
    
    NSDictionary *dataDic = resultDictionary[@"data"];
    
    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithCapacity:10];
    [userInfoDic setDictionary:dataDic];
    
    NSString *userName = [dataDic objectForKey:@"userName"];
    NSString *userIDString = [dataDic objectForKey:@"userId"];
    NSString *userID = [userIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [[SavaData shareInstance] savadataStr:userID KeyString:USER_ID_SAVA];
    [[SavaData shareInstance] savadataStr:userIDString KeyString:USER_ID_ORIGINAL];
    [[SavaData shareInstance] saveStrValue:userName andKey:USER_NAME_SAVE];
    
    
    //保存验证码
    NSString *serverAuth = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"serverAuth"]];
    [[SavaData shareInstance] savadataStr:[serverAuth retain] KeyString:USER_AUTH_SAVA];
    [serverAuth release];
    //数据写入plist
    [SavaData writeDicToFile:[userInfoDic retain] FileName:User_File];
    [userInfoDic release];
    
    //保存当前登录用户服务器地址配置
    [[SavaData shareInstance] savadataStr:dataDic[@"specifiedhost"] KeyString:@"specifiedhost"];
    [[SavaData shareInstance] savadataStr:dataDic[@"specifiedport"] KeyString:@"specifiedport"];
    
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"forbidenStatu"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [[SavaData shareInstance] savaDataBool:YES KeyString:ISHANDLOGIN];
    [[SavaData shareInstance]savaDataBool:YES KeyString:ISLOGIN];
    
    //设置是否开启同步
    [[SavaData shareInstance] savadataStr:@"1" KeyString:kOpenSynchr];
    
    NSDictionary *metaDic = [NSDictionary dictionaryWithDictionary:resultDictionary[@"meta"]];
    if (metaDic.count>0 && [metaDic isKindOfClass:[NSDictionary class]]) {
        [[SavaData shareInstance] savaDictionary:metaDic[@"favoriteStyle"] keyString:@"favoriteStyleDic"];
    }
    
}
-(void)addBirthAndDeathRemindToLocal:(NSDictionary *)dic{
    
    //生日、忌日加入本地提醒
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSArray *familymembers = dic[@"meta"][@"familymembers"];
    for(NSDictionary *obj in familymembers){
        [self addLocalRemindToShedule:obj];
    }
    
}
-(void)jumpToCompeleteVC{
    
    CompleteLoginInfoViewController *completeVC = [[CompleteLoginInfoViewController alloc] initWithNibName:@"CompleteLoginInfoViewController" bundle:nil];
    completeVC.registToLogin = YES;
    completeVC.comeInStyle = 0;
    [self.navigationController pushViewController:completeVC animated:YES];
    [completeVC release];
    
}

-(void)handleSync{
    
    NSArray *diatyArray = [DiaryMessageSQL getMessagesBySyn:@"0"];
    if (diatyArray && [diatyArray count] > 0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizeDataOver:) name:@"synDataOver" object:nil];
        synDataCount = diatyArray.count;
        synData = [[SynDataBackstage alloc] init];
        [synData synchronousDBData];
    }
    NSString *offLineStyleString = [[SavaData shareInstance] printDataStr:offLineStyle];
    if ([offLineStyleString isEqualToString:@"off"]) {
        [MyToast showWithText:@"正在同步风格设置" :200];
        NSString *offLineStyleID = [[SavaData shareInstance] printDataDic:@"OFFLINESTYLE"][@"offStyleHome"];
        [StyleSelectListViewCtrl offLineStyleSelect:offLineStyleID];
        [[SavaData shareInstance] savadataStr:@"" KeyString:offLineStyle];
    }
    
    if ([Utilities checkNetwork]) {
        [[EMPhotoSyncEngine sharedEngine] SyncOperation];
    }
    
}

-(void)needAuthVersion{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"账号已封存，请使用授权版" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载授权版", nil];
    alert.tag = 2000;
    [alert show];
    [alert release];
    
}
-(void)showPromptMessage:(NSString *)message{
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD release];
    HUD.labelText = message;
    HUD.mode = MBProgressHUDModeCustomView;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [HUD removeFromSuperview];
    }];
    
}
//保持编辑状态函数

- (void)viewDidUnload {
    [self setBtnView:nil];
    [self setLogoImgV:nil];
    [self setChangeServer:nil];
    [super viewDidUnload];
}
-(void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:NO];
}
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -- alterview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1000) {
        
        if (buttonIndex == 0) {
            if ([self.errorCodeStr isEqualToString:@"1005"]) {
                BOOL isLogin = NO;
                [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
                _userNameTextField.text = @"";
                _passWordTextField.text = @"";
                [_userNameTextField becomeFirstResponder];
            }
        }
    }
    if (alertView.tag == 1001) {
        if (buttonIndex == 0) {
            //>>>   lgb
            [[SavaData shareInstance]savaDataBool:NO KeyString:ISLOGIN];
            _userNameTextField.text = @"";
            _passWordTextField.text = @"";
            [_userNameTextField becomeFirstResponder];
        }
    }
    if (alertView.tag == 2000) {
//#warning 跳转授权版下载链接
    }
}

#pragma mark 更新版本后首次登录会调用

- (void)firstOpenAppAfterUpdateApp{
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *versionLocal = [[SavaData shareInstance] printDataStr:@"version"];
    
    if (versionLocal == nil && [version isEqualToString:@"1.3"]) {
        [[SavaData shareInstance] savadataStr:version KeyString:@"version"];
    }else if (versionLocal == nil && ![version isEqualToString:@"1.3"])
    {
        [BaseDatas upgradeDB:USERID];

        [[SavaData shareInstance] savadataStr:version KeyString:@"version"];
    }
    else
    {
        if (![version isEqualToString:versionLocal])
        {
            [BaseDatas upgradeDB:USERID];
            
            [[SavaData shareInstance] savadataStr:version KeyString:@"version"];
        }
    }
    
}
@end
