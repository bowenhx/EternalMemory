//
//  ForgotPswordVC.h
//  EternalMemory
//
//  Created by apple on 13-7-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "MBProgressHUD.h"

@class WebViewBackAndForward;
@interface ForgotPswordVC : CustomNavBarController<UIWebViewDelegate>{
    
    MBProgressHUD           *_mb;
    WebViewBackAndForward   *_webviewBackAndForward;
}
@property (nonatomic, retain)MBProgressHUD *mb;
@property (nonatomic, retain)WebViewBackAndForward *webviewBackAndForward;
@end