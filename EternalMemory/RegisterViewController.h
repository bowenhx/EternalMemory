//
//  RegisterViewController.h
//  EternalMemory
//
//  Created by sun on 13-5-10.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "MBProgressHUD.h"

@protocol turnToLogo <NSObject>
@optional
-(void)turnViewtoLogo;
//-(void)pushToLoginView;

@end
@interface RegisterViewController : CustomNavBarController<UITextFieldDelegate,NavBarDelegate,MBProgressHUDDelegate,UIScrollViewDelegate>
//信息展示


@property (retain, nonatomic) IBOutlet UILabel *identifierLab;
@property (retain, nonatomic) IBOutlet UILabel *realNameLab;
@property (retain, nonatomic) IBOutlet UILabel *pswLab;
@property (retain, nonatomic) IBOutlet UILabel *nameLab;
@property (nonatomic, retain) NSDictionary *dataDic;
@property (retain, nonatomic) IBOutlet UIButton *sexMan;
@property (retain, nonatomic) IBOutlet UIButton *sexWoman;
- (IBAction)didSelectSexMan:(UIButton *)sender;
- (IBAction)didSelectSexWoman:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIButton *birthBut;
- (IBAction)didSelectBirthTimeData:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)didSelectFinishBirthDateAction:(UIBarButtonItem *)sender;
@property (retain, nonatomic) IBOutlet UIView *myPickerDateView;
- (IBAction)didSelectChangeBirthDate:(UIDatePicker *)sender;
@property (retain, nonatomic) IBOutlet UIScrollView *myScrollView;




@property (retain, nonatomic) IBOutlet UIImageView *regisFirstImgV;

@property (retain, nonatomic) IBOutlet UIView *bgView;

@property (retain, nonatomic) IBOutlet UIButton *cancelBtn;
@property (retain, nonatomic) IBOutlet UITextView *RtextView;
@property(assign)id <turnToLogo>registDelegate;
@property (retain, nonatomic) IBOutlet UIButton *sureBtn;
- (IBAction)clickSureBtn:(id)sender;
- (IBAction)clickCancelBtn:(id)sender;
@end
