//
//  UserDetailViewCtrl.h
//  EternalMemory
//
//  Created by Guibing on 13-7-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
@interface UserDetailViewCtrl : CustomNavBarController<ASIHTTPRequestDelegate,UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (retain, nonatomic) IBOutlet UIImageView  *introMorkImage;

@property (retain, nonatomic) IBOutlet UIImageView *nameBgImage;
@property (retain, nonatomic) IBOutlet UIImageView *addressBgImage;
@property (retain, nonatomic) IBOutlet UIImageView *hphoneBgImage;
@property (retain, nonatomic) IBOutlet UIImageView *introduceBgImage;
@property (retain, nonatomic) IBOutlet UIImageView *cardBgImage;

@property (retain, nonatomic) IBOutlet UIImageView *lineImage1;
@property (retain, nonatomic) IBOutlet UIImageView *lineImage2;



@property (retain, nonatomic) IBOutlet UIImageView *nameArrImage;
@property (retain, nonatomic) IBOutlet UIImageView *addressArrImage;
@property (retain, nonatomic) IBOutlet UIImageView *cardArrImage;
@property (retain, nonatomic) IBOutlet UIImageView *hphoneArrImage;

@property (retain, nonatomic) IBOutlet UIImageView *introduceArrImage;


@property (retain, nonatomic) IBOutlet UILabel *userNameLab;
@property (retain, nonatomic) IBOutlet UILabel *memoryText;
@property (retain, nonatomic) IBOutlet UILabel *makerText;
@property (retain, nonatomic) IBOutlet UILabel *authCodeLab;



@property (retain, nonatomic) IBOutlet UIView *hiddenCodeViewBg;
@property (retain, nonatomic) IBOutlet UIButton *userNameBut;
@property (retain, nonatomic) IBOutlet UIButton *nameBut;
@property (retain, nonatomic) IBOutlet UILabel *nameLab;
@property (retain, nonatomic) IBOutlet UIButton *sexBut;
@property (retain, nonatomic) IBOutlet UILabel *sexLab;
@property (retain, nonatomic) IBOutlet UIButton *email;
@property (retain, nonatomic) IBOutlet UILabel *emailLab;
@property (retain, nonatomic) IBOutlet UIButton *verifyBtn;
@property (retain, nonatomic) IBOutlet UIButton *changeEmailBtn;
@property (retain, nonatomic) IBOutlet UIButton *changePhoneBtn;
@property (retain, nonatomic) IBOutlet UIButton *birthBut;
@property (retain, nonatomic) IBOutlet UILabel *birthLab;
@property (retain, nonatomic) IBOutlet UIButton *addressBut;
@property (retain, nonatomic) IBOutlet UILabel *addressLab;
@property (retain, nonatomic) IBOutlet UIButton *cardNumberBut;
@property (retain, nonatomic) IBOutlet UILabel *cardNumberLab;
@property (retain, nonatomic) IBOutlet UIButton *hphoneNumberBut;
@property (retain, nonatomic) IBOutlet UILabel *hphoneNumberLab;
@property (retain, nonatomic) IBOutlet UIButton *introBut;
@property (retain, nonatomic) IBOutlet UILabel *introLab;
@property (retain, nonatomic) IBOutlet UILabel *memoryCodeText;
@property (retain, nonatomic) IBOutlet UIButton *authCode;
@property (retain, nonatomic) IBOutlet UIButton *towCodeBtn;
@property (retain, nonatomic) IBOutlet UIImageView *twoCodeImg;
@property (retain, nonatomic) IBOutlet UILabel *letterLab;
@property (retain, nonatomic) IBOutlet UITextView *myTextView;


- (IBAction)didSelectInTowCodeActio:(UIButton *)sender;
- (IBAction)didSelectIntroDetailAction:(UIButton *)sender;
- (IBAction)didAuthorizationCode:(UIButton *)sender;
- (IBAction)didSelectSexAction:(UIButton *)sender;
- (IBAction)didSelectBirthAction:(UIButton *)sender;

//进入编辑邮箱操作
- (IBAction)didSelectEmailAction:(UIButton *)sender;

//修改电话号码操作
- (IBAction)didSelectUserDetailAction:(UIButton *)sender;



//验证邮箱
- (IBAction)didSelectVerifyEmailAction:(UIButton *)sender;

//更换邮箱
- (IBAction)didSelectChangeEmailAction:(UIButton *)sender;

//确定修改操作
- (IBAction)didSelectConfrimChangeAction:(UIButton *)sender;

//获取手机验证码操作
- (IBAction)didGetVerifyCodePhoneAction:(UIButton *)sender;



@end
