//
//  NTPrivacyProblemViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 13-6-4.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "NTPrivacyProblemViewCtrl.h"
#import "Config.h"
@interface NTPrivacyProblemViewCtrl ()

@end

@implementation NTPrivacyProblemViewCtrl
@synthesize mb = _mb;

- (void)dealloc {
    [_mb release];
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
    self.titleLabel.text = @"密保问题";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;

    NSURL *url = [[RequestParams sharedInstance] setPrivacyProblemAction];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.bounds.size.height)];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.tag  = 100;
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    
    [Utilities adjustUIForiOS7WithViews:@[_webView]];
    
    [_webView release];
    
   

	// Do any additional setup after loading the view.
}
//开始加载的时候
- (void)webViewDidStartLoad:(UIWebView*)webView{
//    NSLog(@"-2222--@@@@----$$$$$$$$######");
    _mb = [[MBProgressHUD alloc]initWithCurrentView:_webView];
    [_webView addSubview:_mb];
    _mb.detailsLabelText = @"正在加载中...";
    _mb.delegate = self;
    [_mb show:YES];
    
}
//加载完成
- (void)webViewDidFinishLoad:(UIWebView*)webView{
    _mb.hidden = YES;
//    NSLog(@"--333--@@@@---$$$$$$$$######");
    NSString *currentURL= _webView.request.URL.absoluteString;
    if ([currentURL isEqualToString:PSW_FAILURE_URL]) {
        _webView.hidden = YES;
        UIAlertView *_alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [_alter show];
        [_alter release];
    }
    else if ([currentURL isEqualToString:[NSString stringWithFormat:@"%@clientweb/operatesuccess",INLAND_SERVER]])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
/*
//捕获所有的请求
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType{

    NSLog(@"---1111----$$$$$$$$######");
    return YES;
}

开始加载的时候
- (void)webViewDidStartLoad:(UIWebView*)webView{
     NSLog(@"-2222--@@@@----$$$$$$$$######");
}
加载完成
- (void)webViewDidFinishLoad:(UIWebView*)webView{
    
     NSLog(@"--333--@@@@---$$$$$$$$######");
}
*/
//加载错误
- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error{
   
    [self networkPromptMessage:[error localizedDescription]];
    [_mb setHidden:YES];
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

@end
