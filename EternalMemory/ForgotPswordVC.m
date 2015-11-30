//
//  ForgotPasswordViewController.m
//  EternalMemory
//
//  Created by sun on 13-5-14.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "ForgotPswordVC.h"
#import "WebViewBackAndForward.h"
#import "MyToast.h"

#define PSW_URL [NSString stringWithFormat:@"%@wap/findpw/forgotPassWord?platform=ios",PUBLIC_INLAND]
@interface ForgotPswordVC ()
{
    NSInteger  index;//url链接，判断返回界面
}

@end

@implementation ForgotPswordVC
@synthesize mb = _mb;

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
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"找回密码";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    index = 0;
    [self alertLoading];
    NSURL *url = [[RequestParams sharedInstance]getSecurityquestion];
//    NSURL *url = [NSURL URLWithString:@"http://m.ieternal.com/wap/findpw/forgotPassWord?platform=ios"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _webviewBackAndForward = [[WebViewBackAndForward alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT - 44)];
    if (iOS7)
    {
        _webviewBackAndForward.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 44);
    }
    _webviewBackAndForward.webView.delegate = self;
//    _webviewBackAndForward.webView.hidden = YES;
    
    [_webviewBackAndForward.webView loadRequest:request];
    [self.view addSubview:_webviewBackAndForward];
    [_webviewBackAndForward release];
    
    
    // Do any additional setup after loading the view from its nib.
}
-(void)alertLoading{
    
    if (CHECK_NETWORK) {
        _mb = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:_mb];
        _mb.detailsLabelText = @"正在加载...";
        _mb.delegate = self;
        [_mb show:YES];
    }else{
        
        [Utilities noNetworkAlert];
    }
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *current = webView.request.URL.absoluteString;
    if ([current hasSuffix:@"login?tologin=tologin"])
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    else if ([current hasSuffix:@"forgotPassWord?platform=ios"])
    {
        index = 1;
    }
    else
    {
        index = 2;
    }
    if ([current isEqualToString:PSW_URL]) {
        [_mb setHidden:YES];
        _webviewBackAndForward.webView.hidden = NO;
        
    }else if([current isEqualToString:PSW_FAILURE_URL]){
        
        _webviewBackAndForward.webView.hidden = YES;
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"友情提示" message:@"网络链接异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        alert.tag = 1000;
//        [alert show];
//        [alert release];
        [MyToast showWithText:@"网络链接异常" :150];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [self backBtnPressed];
}
- (void)backBtnPressed
{
    if (index == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSURL *url = [[RequestParams sharedInstance]getSecurityquestion];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webviewBackAndForward.webView loadRequest:request];
    }
    
}
//加载错误
- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error{
    
    [_mb setHidden:YES];
    [MyToast showWithText:@"网络链接异常" :150];

//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"友情提示" message:@"网络链接异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    alert.tag = 100;
//    [alert show];
//    [alert release];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public methods

@end
