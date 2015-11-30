//
//  FindBackIDViewController.m
//  EternalMemory
//
//  Created by zhaogl on 13-12-12.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "FindBackIDViewController.h"


#define FIND_ID_COMPLETE__URL_HOME [NSString stringWithFormat:@"%@wap/user/home",INLAND_SERVER_HOME]

#define FIND_ID_COMPLETE__URL_LOGIN [NSString stringWithFormat:@"%@wap/user/login",INLAND_SERVER_HOME]

#define FIND_ID_COMPLETE__URL_WHITE [NSString stringWithFormat:@"%@mobile_page/loading.jsp",INLAND_SERVER_HOME]


@interface FindBackIDViewController ()

@end

@implementation FindBackIDViewController

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
    self.titleLabel.text = @"申诉找回身份证";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    UIWebView *aWebView = [[UIWebView alloc]init];
    if (iOS7) {
        aWebView.frame = CGRectMake(0, 64, 320, SCREEN_HEIGHT - 64);
    }else{
        aWebView.frame = CGRectMake(0, 44, 320, SCREEN_HEIGHT - 64);
    }
    aWebView.delegate = self;
    aWebView.scalesPageToFit = YES;
    [self.view addSubview:aWebView];
    [aWebView release];
    
    [aWebView loadRequest:[NSURLRequest requestWithURL:_url]];
    
	// Do any additional setup after loading the view.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    NSString *current = webView.request.URL.absoluteString;
//    if ([current isEqualToString:FIND_ID_COMPLETE__URL_HOME] || [current isEqualToString:FIND_ID_COMPLETE__URL_LOGIN]) {
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"findID" object:nil];
//        [self.navigationController popViewControllerAnimated:YES];
//        return NO;
//    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *current = webView.request.URL.absoluteString;
    if ([current isEqualToString:FIND_ID_COMPLETE__URL_WHITE]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"findID" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}
-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
