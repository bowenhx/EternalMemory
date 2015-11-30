//
//  VerifyCodeViewController.h
//  EternalMemory
//
//  Created by zhaogl on 13-11-29.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CustomNavBarController.h"


@interface VerifyCodeViewController : CustomNavBarController<
    NavBarDelegate,
    ASIHTTPRequestDelegate,
    UITextFieldDelegate,
    UIAlertViewDelegate>{
    
    UITextField  *_codeTextField;
    UIButton     *_sendBtn;
    NSTimer      *timer;
}
@property (nonatomic,retain) NSString *mobile;
@property (nonatomic,retain) NSDictionary *userInfo;
@property (nonatomic,assign) NSInteger     comeInStyle;//0 表示push  1表示present

@end
