//
//  AuthCodeHelpViewController.h
//  EternalMemory
//
//  Created by Guibing on 13-12-24.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
@interface AuthCodeHelpViewController : CustomNavBarController

@property (retain, nonatomic) IBOutlet UIButton *phoneNumBtn;
@property (retain, nonatomic) IBOutlet UILabel *titleLab;

@property (retain, nonatomic) IBOutlet UILabel *phoneNum;
@property (retain, nonatomic) IBOutlet UILabel *titleLab2;

@property (nonatomic , assign) NSInteger index;


- (IBAction)didCallUpPhoneNumberAction:(UIButton *)sender;
@end
