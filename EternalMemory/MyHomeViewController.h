//
//  MyHomeViewController.h
//  EternalMemory
//
//  Created by sun on 13-7-1.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "MBProgressHUD.h"
#import <sys/utsname.h>
@interface MyHomeViewController : UIViewController<UIWebViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate,ASIHTTPRequestDelegate>{
    
    UIWebView     *_homeWebView;
    int           countVisit;
    MBProgressHUD *_mb;
    UIView        *_addView;
    NSString      * _otherHomeStyle;
    NSDictionary  *_otherDict;
    BOOL          _associatedUserInfoDownLoad;
    NSString      *_currentUserID;//去掉－
    NSString      *_currentUserIDOriginal;

    
}
@property (nonatomic, retain)NSString *iassociateuserid;
@property (nonatomic, retain)NSString *iassociatevalue;
@property (nonatomic, retain)NSString *iassociateauthcode;
@property (nonatomic, retain)NSString *ieternalcode;
@property (nonatomic, retain)NSString *ieternalStyle;
@property (nonatomic, retain)NSString *homeStyle;
@property (nonatomic, retain)NSString *otherHomeStyle;
@property (nonatomic, retain)NSString *otherHomeStyleName;
@property (nonatomic, retain)NSDictionary *otherDict;
@property (nonatomic, retain)NSString *comeFrom;
@end
