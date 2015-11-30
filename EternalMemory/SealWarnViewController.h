//
//  SealWarnViewController.h
//  EternalMemory
//
//  Created by Guibing on 13-12-18.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
@interface SealWarnViewController : CustomNavBarController

@property (retain, nonatomic) IBOutlet UILabel *beginTime;
@property (retain, nonatomic) IBOutlet UILabel *endTime;
@property (retain, nonatomic) IBOutlet UILabel *time1;
@property (retain, nonatomic) IBOutlet UILabel *time2;
@property (retain, nonatomic) IBOutlet UILabel *time3;
@property (retain, nonatomic) IBOutlet UIButton *helpBtn;


@property (nonatomic , retain) NSString *authLeftTime;//倒计时天数
@property (nonatomic , retain) NSString *authStartTime; //授权开始时间
@property (nonatomic , retain) NSString *authEndTime;  //倒计时结束时间

- (IBAction)didSelectHelpBtnAction:(UIButton *)sender;


@end
