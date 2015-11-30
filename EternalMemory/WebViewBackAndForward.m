//
//  WebViewBackAndForward.m
//  EternalMemory
//
//  Created by zhaogl on 14-2-25.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "WebViewBackAndForward.h"

@implementation WebViewBackAndForward

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.frame = frame;
//        _webView = [[UIWebView alloc] init];
//        _webView.frame = frame;
        _webView = [[UIWebView alloc] initWithFrame:(CGRect){
            .origin.x = 0,
            .origin.y = 0,
            .size.width  = SCREEN_WIDTH,
            .size.height = frame.size.height - 44
        }];
        _webView.tag = 101;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_webView];
        [_webView release];
        
        UIView *toolView = [[UIView alloc] init];
        toolView.frame = CGRectMake(0,_webView.frame.size.height, SCREEN_WIDTH, 44);
        toolView.backgroundColor = [UIColor grayColor];
        
        UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 14, 15, 15)];
        backImage.image = [UIImage imageNamed:@"webview_back"];
        [toolView addSubview:backImage];
        [backImage release];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 45, 44);
        backBtn.showsTouchWhenHighlighted = YES;
        [backBtn addTarget:self action:@selector(backBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:backBtn];
        
        UIImageView *forwardImage = [[UIImageView alloc] initWithFrame:CGRectMake(65, 14, 15, 15)];
        forwardImage.image = [UIImage imageNamed:@"webview_forward"];
        [toolView addSubview:forwardImage];
        [forwardImage release];
        
        UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        forwardBtn.frame = CGRectMake(45, 0, 45, 44);
        forwardBtn.showsTouchWhenHighlighted = YES;
        [forwardBtn addTarget:self action:@selector(forwardBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:forwardBtn];
        
        UIImageView *refreshImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, 14, 15, 15)];
        refreshImage.image = [UIImage imageNamed:@"webview_refresh"];
        [toolView addSubview:refreshImage];
        [refreshImage release];
        
        UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        refreshBtn.frame = CGRectMake(275, 0, 35, 44);
        refreshBtn.showsTouchWhenHighlighted = YES;
        [refreshBtn addTarget:self action:@selector(refreshBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:refreshBtn];
        
        [self addSubview:toolView];
        [toolView release];
    }
    return self;
}

-(void)backBtnPressed{
    [_webView goBack];
}

-(void)forwardBtnPressed{
    [_webView goForward];
}
-(void)refreshBtnPressed{
    [_webView reload];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
