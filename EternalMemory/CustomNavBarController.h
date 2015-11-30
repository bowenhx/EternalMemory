//
//  CustomNavBarController.h
//  PeopleBaseNetwork
//
//  Created by kiri on 13-3-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RequestParams.h"
#import "SavaData.h"
#import "MBProgressHUD.h"
#import "EternalMemoryAppDelegate.h"
//#import "UIImageView+DispatchLoad.h"

@protocol NavBarDelegate
@optional
-(void)backBtnPressed;
-(void)rightBtnPressed;
-(void)middleBtnPressed;
@end
@interface CustomNavBarController : UIViewController <MBProgressHUDDelegate,UIAlertViewDelegate>
{
    id<NavBarDelegate>delegate;
}
@property(nonatomic,retain) UIButton     *backBtn;
@property(nonatomic,retain) UIButton     *rightBtn;
@property(nonatomic,retain) UILabel      *titleLabel;
@property(nonatomic,retain) UIButton     *middleBtn;
@property(nonatomic,retain) UIImageView  *middleImage;
@property(nonatomic,retain) UIImageView  *navBarView;
@property(assign)id<NavBarDelegate>delegate;
- (void)networkPromptMessage:(NSString *)message;
@end
