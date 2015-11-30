//
//  LoginViewController.h
//  EternalMemory
//
//  Created by sun on 13-5-10.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CustomNavBarController.h"
@interface LoginViewController : CustomNavBarController<UITextFieldDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
{
    NSString       *_userNameTextStr;
    NSString       *_passWordTextStr;
    MBProgressHUD  * _mb;
    
    BOOL           registToLogin;
     
}
@property (retain, nonatomic) IBOutlet UIImageView *logoImgV;
@property (nonatomic , copy) NSString *userNameTextStr , *passWordTextStr;
@property (retain, nonatomic) IBOutlet UIButton *btnView;
@property (retain, nonatomic) IBOutlet UIButton *changeServer;
@property (nonatomic,retain)  NSString *errorCodeStr;

//- (IBAction)InputMemoryCode:(UIButton *)sender;
@end
