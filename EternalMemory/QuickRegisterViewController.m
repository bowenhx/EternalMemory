//
//  QuickRegisterViewController.m
//  EternalMemory
//
//  Created by zhaogl on 13-11-25.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "QuickRegisterViewController.h"
#import "MyToast.h"
#import "MD5.h"
#import "RequestParams.h"
#import "PassWordTextField.h"
@interface QuickRegisterViewController ()

@end

@implementation QuickRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc{
    
    [_request clearDelegatesAndCancel];
    [_request release];
    [_mb release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = @"快速注册";
    self.rightBtn.hidden = YES;
    self.middleBtn.hidden = YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    BOOL network = [Utilities checkNetwork];
    if (!network) {
        [MyToast showWithText:@"请检查网络" :150];
    }
    
    _scrollView = [[UIScrollView alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        _scrollView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    }else{
        _scrollView.frame = CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    }
    _scrollView.backgroundColor = [UIColor colorWithRed:238/255. green:242/255. blue:245/255. alpha:1.0];
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    UITapGestureRecognizer *recoginer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstresponder)];
    [_scrollView addGestureRecognizer:recoginer1];
    [recoginer1 release];
    
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 300, 20)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = @"账号为5-18位，汉字、字母或数字";
    nameLabel.textColor = [UIColor colorWithRed:118/255. green:131/255. blue:141/255. alpha:1.0];
    nameLabel.font = [UIFont systemFontOfSize:15.0f];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    [_scrollView addSubview:nameLabel];
    [nameLabel release];
    
    UIImageView *userNameImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 50, 300, 45)];
    userNameImg.image = [UIImage imageNamed:@"public_table_fullBg"];
    [_scrollView addSubview:userNameImg];
    [userNameImg release];
    
    _userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 50, 295, 45)];
    _userNameTextField.placeholder = @"账号";
    _userNameTextField.borderStyle = UITextBorderStyleNone;
    _userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _userNameTextField.textAlignment = NSTextAlignmentLeft;
    _userNameTextField.textColor = [UIColor blackColor];
    _userNameTextField.font = [UIFont systemFontOfSize:15.0f];
    _userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _userNameTextField.returnKeyType = UIReturnKeyNext;
    _userNameTextField.delegate = self;
    _userNameTextField.tag = 1;
    [_scrollView addSubview:_userNameTextField];
    [_userNameTextField release];
    
//
    UILabel *pswLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, 300, 20)];
    pswLabel.backgroundColor = [UIColor clearColor];
    pswLabel.font = [UIFont systemFontOfSize:15.0f];
    pswLabel.text = @"登录密码最少8位，区分大小写，不支持汉字";
    pswLabel.textColor = [UIColor colorWithRed:118/255. green:131/255. blue:141/255. alpha:1.0];
    [_scrollView addSubview:pswLabel];
    [pswLabel release];
    
    UIImageView *pswImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 130, 300, 45)];
    pswImg.image = [UIImage imageNamed:@"public_table_fullBg"];
    [_scrollView addSubview:pswImg];
    [pswImg release];
    
    _passwordTextField = [[PassWordTextField alloc] initWithFrame:CGRectMake(15, 130, 295, 45)];
    _passwordTextField.placeholder = @" 密 码";
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.borderStyle = UITextBorderStyleNone;
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordTextField.textAlignment = NSTextAlignmentLeft;
    _passwordTextField.textColor = [UIColor blackColor];
    _passwordTextField.font = [UIFont systemFontOfSize:15.0f];
    _passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordTextField.returnKeyType = UIReturnKeyNext;
    _passwordTextField.delegate = self;
    _passwordTextField.tag = 2;
    [_scrollView addSubview:_passwordTextField];
    [_passwordTextField release];
    
    
    UIImageView *confirmPswImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 185, 300, 45)];
    confirmPswImg.image = [UIImage imageNamed:@"public_table_fullBg"];
    [_scrollView addSubview:confirmPswImg];
    [confirmPswImg release];
    
    _confirmPswTextField = [[PassWordTextField alloc] initWithFrame:CGRectMake(15, 185, 295, 45)];
    _confirmPswTextField.placeholder = @" 确认密码";
    _confirmPswTextField.secureTextEntry = YES;
    _confirmPswTextField.borderStyle = UITextBorderStyleNone;
    _confirmPswTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _confirmPswTextField.textAlignment = NSTextAlignmentLeft;
    _confirmPswTextField.textColor = [UIColor blackColor];
    _confirmPswTextField.font = [UIFont systemFontOfSize:15.0f];
    _confirmPswTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _confirmPswTextField.returnKeyType = UIReturnKeyNext;
    _confirmPswTextField.delegate = self;
    _confirmPswTextField.tag = 3;
    [_scrollView addSubview:_confirmPswTextField];
    [_confirmPswTextField release];
    
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 240, 300, 20)];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.font = [UIFont systemFontOfSize:15.0f];
    aLabel.text = @"请输入右图验证码（点击图片更换）";
    aLabel.textColor = [UIColor colorWithRed:118/255. green:131/255. blue:141/255. alpha:1.0];
    [_scrollView addSubview:aLabel];
    [aLabel release];
    
    UIImageView *verifyCodeImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 265, 185, 45)];
    verifyCodeImg.image = [UIImage imageNamed:@"public_table_fullBg"];
    [_scrollView addSubview:verifyCodeImg];
    [verifyCodeImg release];
    
    _verifyCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 265, 180, 45)];
    _verifyCodeTextField.borderStyle = UITextBorderStyleNone;
    _verifyCodeTextField.placeholder = @" 验证码";
    _verifyCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _verifyCodeTextField.textAlignment = NSTextAlignmentLeft;
    _verifyCodeTextField.textColor = [UIColor blackColor];
    _verifyCodeTextField.font = [UIFont systemFontOfSize:14.0f];
    _verifyCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _verifyCodeTextField.returnKeyType = UIReturnKeyDone;
    _verifyCodeTextField.delegate = self;
    _verifyCodeTextField.tag = 4;
    [_scrollView addSubview:_verifyCodeTextField];
    [_verifyCodeTextField release];
    
    
    _verifyCodeWebView = [[UIWebView alloc] initWithFrame:CGRectMake(200, 265, 100, 45)];
    _verifyCodeWebView.backgroundColor = [UIColor clearColor];
    _verifyCodeWebView.delegate = self;
    _verifyCodeWebView.userInteractionEnabled = NO;
    [_scrollView addSubview:_verifyCodeWebView];
    [_verifyCodeWebView release];
    
    
    _failBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _failBtn.frame = CGRectMake(200, 265, 105, 45);
    _failBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_failBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_failBtn addTarget:self action:@selector(getVerifyCode1) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_failBtn];
    
    _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _registerBtn.backgroundColor = [UIColor colorWithRed:32/255. green:156/255. blue:215/255. alpha:1.0];
    _registerBtn.frame = CGRectMake(10, 345, 300, 45);
    _registerBtn.tintColor = [UIColor whiteColor];
    [_registerBtn setTitle:@"立即注册" forState:UIControlStateNormal];
    _registerBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [_registerBtn addTarget:self action:@selector(registerRequest) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_registerBtn];
    
    [self getVerifyCode1];
    
    
	// Do any additional setup after loading the view.
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_failBtn setTitle:@"" forState:UIControlStateNormal];
    _failBtn.backgroundColor = [UIColor clearColor];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_failBtn setTitle:@"点击重新加载" forState:UIControlStateNormal];
    _failBtn.backgroundColor = [UIColor whiteColor];
}
-(void)resignFirstresponder{
    
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_confirmPswTextField resignFirstResponder];
    [_verifyCodeTextField resignFirstResponder];
    _scrollView.contentSize = CGSizeMake(320, SCREEN_HEIGHT - 64);
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.contentOffset = CGPointMake(0, 0);
    }];
}

-(void)getVerifyCode1{
    
    [_failBtn setTitle:@"" forState:UIControlStateNormal];
    _failBtn.backgroundColor = [UIColor clearColor];
    
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

-(void)registerRequest{
    
    BOOL result = [self checkUserNameAndPassword];
    if (!result) {
        return;
    }
    _mb = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:_mb];
    _mb.detailsLabelText = @"正在注册...";
    _mb.delegate = self;
    [_mb show:YES];
    
    NSURL *registerUrl = [[RequestParams sharedInstance] userRegister1];
    _request = [[ASIFormDataRequest alloc] initWithURL:registerUrl];
    _request.delegate = self;
    _request.shouldAttemptPersistentConnection = NO;
    
    [_request setPostValue:@"fast" forKey:@"flag"];
    [_request setPostValue:@"ios" forKey:@"platform"];

    [_request setPostValue:_userNameTextField.text forKey:@"username"];
    [_request setPostValue:[MD5 md5:_passwordTextField.text] forKey:@"password"];
    [_request setPostValue:_verifyCodeTextField.text forKey:@"regrandomcode"];
    [_request setPostValue:[[SavaData shareInstance] printToken:TOKEN] forKey:@"clienttoken"];
    [_request setRequestMethod:@"POST"];
    [_request setTimeOutSeconds:10.0];
    [_request startAsynchronous];

}
-(BOOL)checkUserNameAndPassword{
    
    if (_userNameTextField.text.length == 0) {
        [MyToast showWithText:@"账号不能为空" :150];
        return NO;
    }
    if(_passwordTextField.text.length == 0){
        [MyToast showWithText:@"密码不能为空" :150];
        return NO;
    }
    if (_verifyCodeTextField.text.length == 0){
        [MyToast showWithText:@"验证码不能为空" :150];
        return NO;
    }
    if (_passwordTextField.text.length > 15) {
        [MyToast showWithText:@"密码不能大于15位" :150];
        return NO;
    }
    if (![_passwordTextField.text isEqualToString:_confirmPswTextField.text]) {
        [MyToast showWithText:@"密码和确认密码不一致" :150];
        return NO;
    }
    NSString *regex2 = @"^[0-9]+$";
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    BOOL isMatch2 = [predicate2 evaluateWithObject:_userNameTextField.text];
    if (isMatch2) {
        [MyToast showWithText:@"账号不能为纯数字" :150];
        return NO;
    }
    
    NSString *regex = @"^[^\\s]{8,}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [predicate evaluateWithObject:_passwordTextField.text];
    if (!isMatch) {
        [MyToast showWithText:@"密码不能少于8位且不能包含空格" :150];
        return NO;
    }
    
    NSString *regex1 = @"^[^\\s]{5,18}$";
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    BOOL isMatch1 = [predicate1 evaluateWithObject:_userNameTextField.text];
    if (!isMatch1) {
        [MyToast showWithText:@"账号在5-18位之间且不能包含空格" :150];
        return NO;
    }
    
    NSString *regex3 = @"^[\\u4E00-\\u9FA5\\uF900-\\uFA2D\\w]{5,18}$";
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex3];
    BOOL isMatch3 = [predicate3 evaluateWithObject:_userNameTextField.text];
    if (!isMatch3) {
        [MyToast showWithText:@"账号5-18位，只能为汉字、字母和数字" :150];
        return NO;
    }
    return YES;
}
-(void)requestFinished:(ASIHTTPRequest *)request{
    
    [_mb setHidden:YES];
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSString *success=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    if ([success isEqualToString:@"0"]) {
        
        NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
        UIAlertView *alter =[[UIAlertView alloc] initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        [alter release];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"恭喜" message:@"注册成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.delegate = self;
        alert.tag = 1000;
        [alert show];
        [alert release];
    }

}
-(void)requestFailed:(ASIHTTPRequest *)request{
    
    [_mb setHidden:YES];
    [MyToast showWithText:@"请检查网络连接" :150];
    
}
#pragma mark  UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (SCREEN_HEIGHT == 480) {
        _scrollView.contentSize = CGSizeMake(320, SCREEN_HEIGHT - 64 + 200);
    }else if (SCREEN_HEIGHT == 568){
        _scrollView.contentSize = CGSizeMake(320, SCREEN_HEIGHT - 64 + 110);
    }
    if (textField.tag == 4) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [UIView animateWithDuration:0.3 animations:^{
            if (SCREEN_HEIGHT == 480) {
                _scrollView.contentOffset = CGPointMake(0, 200);
            }else{
                _scrollView.contentOffset = CGPointMake(0, 110);
            }
        }];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.tag == 1) {
        [_passwordTextField becomeFirstResponder];
    }else if (textField.tag == 2){
        [_confirmPswTextField becomeFirstResponder];
    }else if (textField.tag == 3)
    {
        [_verifyCodeTextField becomeFirstResponder];
    }
    else if(textField.tag == 4){
        
        [_verifyCodeTextField resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            _scrollView.contentOffset = CGPointMake(0, 0);
        }];
    }
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1000) {
        //注册新账号成功后要自动登录的，之前的账号要标记为未登录
        [[SavaData shareInstance]savaDataBool:NO KeyString:ISLOGIN];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logoViewToLogin" object:[NSDictionary dictionaryWithObjectsAndKeys:_userNameTextField.text,@"userName",_passwordTextField.text,@"passWord",@"YES",@"registToLogin",nil]];
        
    }else{
        [_mb show:NO];
        [self getVerifyCode1];
    }
}
-(void)backBtnPressed{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if (_quickRegistDelegate && [_quickRegistDelegate respondsToSelector:@selector(turnViewtoLogo)]) {
        [_quickRegistDelegate turnViewtoLogo];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
