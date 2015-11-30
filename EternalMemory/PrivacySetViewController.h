//
//  PrivacySetViewController.h
//  EternalMemory
//
//  Created by sun on 13-6-30.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "MBProgressHUD.h"

@interface PrivacySetViewController : CustomNavBarController<NavBarDelegate,ASIHTTPRequestDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
@property (retain, nonatomic) IBOutlet UIButton *forbidenVisitBtn;
@property (retain, nonatomic) IBOutlet UIView *fourTabView;
@property (retain, nonatomic) IBOutlet UIImageView *bgImgView;
@property (retain, nonatomic) IBOutlet UILabel *displayLab;
@property (retain, nonatomic) IBOutlet UIImageView *forbidImg;
@property (retain, nonatomic) IBOutlet UIButton *forbidVisitBtn;
@property (retain, nonatomic) IBOutlet UIView *bgView;
@property (retain, nonatomic) IBOutlet UILabel *fourLab;
@property (retain, nonatomic) IBOutlet UITextView *fourTextV;

- (IBAction)clickSecretQ:(UIButton *)sender;
- (IBAction)clickForbidVisit:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIButton *memoryBut;
//- (IBAction)memoryButton:(id)sender;

@end
