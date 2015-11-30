//
//  WebViewBackAndForward.h
//  EternalMemory
//
//  Created by zhaogl on 14-2-25.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewBackAndForward : UIView<UIWebViewDelegate>{
    UIWebView  *_webView;
}
@property (nonatomic,retain) UIWebView *webView;
@end
