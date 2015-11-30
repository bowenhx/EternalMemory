//
//  EditDetailViewCtrl.h
//  EternalMemory
//
//  Created by Guibing on 13-7-10.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
@class LimitePasteTextView;

@interface EditDetailViewCtrl : CustomNavBarController<UIAlertViewDelegate,ASIHTTPRequestDelegate,UITextFieldDelegate,UIScrollViewDelegate,UITextViewDelegate>
@property (retain, nonatomic) IBOutlet UILabel *nameLab;    //身份证号
@property (retain, nonatomic) IBOutlet UILabel *addressLab;
@property (retain, nonatomic) IBOutlet UILabel *phoneLab;
@property (retain, nonatomic) IBOutlet UILabel *birthLab;
@property (retain, nonatomic) IBOutlet UITextField *idTextField;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;


@property (retain, nonatomic) IBOutlet UIImageView *nameBgImage;
@property (retain, nonatomic) IBOutlet UIImageView *cardBgImage;
@property (retain, nonatomic) IBOutlet UIImageView *birthImage;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollBgView;
@property (retain, nonatomic) IBOutlet LimitePasteTextView *addressTextView;
@property (retain, nonatomic) IBOutlet UIButton *birthBut;
- (IBAction)didSelectBirthAction:(UIButton *)sender;

@property (retain, nonatomic) IBOutlet UIImageView *addressBgImage;
@property (nonatomic , retain) NSMutableDictionary *dicDatas;
@property (retain, nonatomic) IBOutlet UIView *myPickerView;
- (IBAction)didSelectChangeDateTime:(UIDatePicker *)sender;

@property (retain, nonatomic) IBOutlet UIDatePicker *pickerDate;
- (IBAction)didSelectFinishAction:(UIBarButtonItem *)sender;


@end
