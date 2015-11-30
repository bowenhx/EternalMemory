//
//  MorePageViewCtrl.h
//  EternalMemory
//
//  Created by Guibing on 13-7-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
@interface MorePageViewCtrl : CustomNavBarController <UIActionSheetDelegate,UIAlertViewDelegate,ASIHTTPRequestDelegate>
@property (retain, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (retain, nonatomic) IBOutlet UILabel *userNameLab;
@property (retain, nonatomic) IBOutlet UIImageView *showRoomImage;
@property (retain, nonatomic) IBOutlet UILabel *versionNumLab;
    @property (retain, nonatomic) IBOutlet UISwitch *kOpenSwitch;
    

- (IBAction)didSetOpenSynchronization:(UISwitch *)sender;


@property (retain, nonatomic) IBOutlet UIProgressView *progress;
@property (retain, nonatomic) IBOutlet UILabel *roomText;

@property (retain, nonatomic) IBOutlet UILabel *updataText;
@property (retain, nonatomic) IBOutlet UILabel *styleLabel;

@property (retain, nonatomic) IBOutlet UILabel *roomSizeLab;
@property (retain, nonatomic) IBOutlet UILabel *updateTimeLab;
@property (retain, nonatomic) IBOutlet UIButton *personBut;
@property (retain, nonatomic) IBOutlet UIButton *musicBut;
@property (retain, nonatomic) IBOutlet UIButton *styleSelectBut;

@property (retain, nonatomic) IBOutlet UIButton *homeStyleBut;
@property (retain, nonatomic) IBOutlet UIButton *privacyBut;
@property (retain, nonatomic) IBOutlet UIButton *passwordBut;

@property (retain, nonatomic) IBOutlet UIButton *uploadingBut;
@property (retain, nonatomic) IBOutlet UIButton *familyBut;
@property (retain, nonatomic) IBOutlet UIButton *versionsBut;
@property (retain, nonatomic) IBOutlet UIButton *aboutBut;

- (IBAction)didSelectPrivacyAction:(UIButton *)sender;
- (IBAction)didSelectPasswordAction:(UIButton *)sender;
- (IBAction)didSelectVersionsUpDataAction:(UIButton *)sender;
- (IBAction)didSelectAboutAppAction:(UIButton *)sender;
- (IBAction)didSelectStyleBoard:(UIButton *)sender;
- (IBAction)didSelectHomeStyleAction:(UIButton *)sender;

- (IBAction)didSelectpersonalFileAction:(UIButton *)sender;
- (IBAction)didSelectMusicAction:(UIButton *)sender;

- (IBAction)didSelectFamilyAction:(UIButton *)sender;
- (IBAction)didSelectUploadingListAction:(UIButton *)sender;
- (IBAction)didSelectResignLoginAction:(UIButton *)sender;

+ (void)clearUploadingInfo;//退出时清除上传的数据信息

@end
