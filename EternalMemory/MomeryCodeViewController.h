//
//  MomeryCodeViewController.h
//  EternalMemory
//
//  Created by jiangxl on 13-9-13.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "MBProgressHUD.h"
#import <sys/utsname.h>

@interface MomeryCodeViewController : UIViewController<UIWebViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate,ASIHTTPRequestDelegate>{
    
    UIWebView *_homeWebView;
    int countVisit;
    MBProgressHUD *_mb;
    UIView *_addView;
    
}
@property(nonatomic, retain)NSDictionary *dictData;
@property(nonatomic,retain) NSString *eterCode;
@property(nonatomic, retain)NSString *visitStyle;
@property(nonatomic, retain)NSString *ieternalNum;


@property(nonatomic, retain)NSString *associatekey;
@property(nonatomic, retain)NSString *associatevalue;
@property(nonatomic, retain)NSString *associateauthcode;
@property(nonatomic, retain)NSString *whichStyle;
@end
