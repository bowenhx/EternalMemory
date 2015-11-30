//
//  NTPrivacyProblemViewCtrl.h
//  EternalMemory
//
//  Created by Guibing on 13-6-4.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "MBProgressHUD.h"
@interface NTPrivacyProblemViewCtrl : CustomNavBarController<UIWebViewDelegate>{
    
    MBProgressHUD *_mb;
    UIWebView *_webView;
}

@property (nonatomic, retain)MBProgressHUD *mb;
@end
