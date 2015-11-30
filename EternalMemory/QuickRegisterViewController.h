//
//  QuickRegisterViewController.h
//  EternalMemory
//
//  Created by zhaogl on 13-11-25.
//  Copyright (c) 2013年 sun. All rights reserved.
//


#import "CustomNavBarController.h"
#import "MBProgressHUD.h"

@protocol turnToLogoPro <NSObject>

-(void)turnViewtoLogo;

@end
@interface QuickRegisterViewController : CustomNavBarController<
    NavBarDelegate,
    UITextFieldDelegate,
    ASIHTTPRequestDelegate,
    UIAlertViewDelegate,
    UIWebViewDelegate>{
        UIScrollView *_scrollView;
        UITextField  *_userNameTextField;
        UITextField  *_passwordTextField;
        UITextField  *_confirmPswTextField;
        UITextField  *_verifyCodeTextField;
        UIWebView    *_verifyCodeWebView;
        UIButton     *_registerBtn;
        ASIFormDataRequest *_request;
        MBProgressHUD *_mb;
        
        UILabel      *_failLabel;
        UIButton     *_failBtn;
}
@property(assign) id<turnToLogoPro>quickRegistDelegate;
@end
