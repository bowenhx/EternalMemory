//
//  RookieHelpViewController.m
//  EternalMemory
//
//  Created by FFF on 13-11-22.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "RookieHelpViewController.h"
#import "MBProgressHUD.h"
#import "MyToast.h"
#import "WebViewBackAndForward.h"

#define URL_OF_ROOKIE_HELP [NSString stringWithFormat:@"%@wap/guide?platform=ios",PUBLIC_INLAND]

//TODO: 实现工具栏对webView进行操作。

@interface RookieHelpViewController ()<UIWebViewDelegate>

@property (nonatomic, retain) UIActivityIndicatorView *indicatorView;

@end

@implementation RookieHelpViewController

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
    [_indicatorView release];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rightBtn.hidden = YES;
    self.middleBtn.hidden = YES;
    self.titleLabel.text = @"使用指南";
    
    float h = iOS7 ? 64 : 44;
    WebViewBackAndForward *webViewBackAndForward = [[WebViewBackAndForward alloc] initWithFrame:CGRectMake(0, h, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    webViewBackAndForward.backgroundColor = [UIColor cyanColor];
    webViewBackAndForward.webView.delegate = self;
    [webViewBackAndForward.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL_OF_ROOKIE_HELP]]];
    [self.view addSubview:webViewBackAndForward];
    [webViewBackAndForward release];
    
    /*helpWebView = [[UIWebView alloc] initWithFrame:(CGRect){
        .origin.x = 0,
        .origin.y = self.navBarView.frame.size.height,
        .size.width  = Screen_Width,
        .size.height = Screen_Height - (iOS7 ? 64 : 44)
    }];
    helpWebView.tag = 101;
    helpWebView.scrollView.showsVerticalScrollIndicator = NO;
    helpWebView.scrollView.showsHorizontalScrollIndicator = NO;
    helpWebView.delegate = self;
    [helpWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL_OF_ROOKIE_HELP]]];
    [self.view addSubview:helpWebView];
    [helpWebView release];*/
    
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _indicatorView.center = self.view.center;
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _indicatorView.hidesWhenStopped = YES;
        [self.view addSubview:_indicatorView];
        [_indicatorView startAnimating];
    }
    
}

- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_indicatorView stopAnimating];
    if (error.code == -1009) {
        [MyToast showWithText:@"请检查网络设置" :130];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
