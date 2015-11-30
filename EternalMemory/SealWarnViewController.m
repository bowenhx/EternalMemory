//
//  SealWarnViewController.m
//  EternalMemory
//
//  Created by Guibing on 13-12-18.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "SealWarnViewController.h"
#import "LoginSecondViewController.h"
#import "CommonData.h"
#import "AuthCodeHelpViewController.h"
@interface SealWarnViewController ()

@end

@implementation SealWarnViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOS7) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.middleBtn.hidden = YES;
    self.backBtn.hidden = YES;
    self.titleLabel.text = @"封存提醒";
    [self.rightBtn setTitle:@"跳过" forState:UIControlStateNormal];

    
//    //把天数转换成毫秒
//    _authLimitTime = [NSString stringWithFormat:@"%lld",[_authLimitTime longLongValue] * 24 * 60 * 60 * 1000 + [_authStartTime longLongValue]];
//    
//    _beginTime.text = [CommonData getTimeransitionBirthDataPath:_authStartTime];
//    _endTime.text = [NSString stringWithFormat:@"------  %@",[CommonData getTimeransitionBirthDataPath:_authLimitTime]];
//
//    //获取当前时间戳
//    NSDate *date = [NSDate date];
//    NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
//    NSString *timeStr =[NSString stringWithFormat:@"%f",timestamp];
    
    if (iPhone5) {
        CGRect helpBtnFrmae = _helpBtn.frame;
        helpBtnFrmae.origin.y +=70;
        _helpBtn.frame = helpBtnFrmae;
    }
    
    //开始时间
    _beginTime.text = [CommonData getTimeransitionBirthDataPath:_authStartTime];
    
    //结束时间
    _endTime.text   = [NSString stringWithFormat:@"------  %@",[CommonData getTimeransitionBirthDataPath:_authEndTime]];

    NSString *timeStr = [NSString stringWithFormat:@"%lld",[_authLeftTime longLongValue]/1000/60/60/24];
    //计算剩余天数
    if (timeStr.length ==3) {
        _time1.text = [timeStr substringWithRange:NSMakeRange(timeStr.length-3, 1)];
        _time2.text = [timeStr substringWithRange:NSMakeRange(timeStr.length-2, 1)];
        _time3.text = [timeStr substringWithRange:NSMakeRange(timeStr.length-1, 1)];
    }else if (timeStr.length ==2){
        _time1.text = @"0";
        _time2.text = [timeStr substringWithRange:NSMakeRange(timeStr.length-2, 1)];
        _time3.text = [timeStr substringWithRange:NSMakeRange(timeStr.length-1, 1)];
    }else if (timeStr.length ==1)
    {
        _time1.text = @"0";
        _time2.text = @"0";
        _time3.text = [timeStr substringWithRange:NSMakeRange(timeStr.length-1, 1)];
    }
}
- (void)rightBtnPressed
{
    LoginSecondViewController *loginSecondVC = [[LoginSecondViewController alloc] initWithNibName:@"LoginSecondViewController" bundle:nil];
    [self.navigationController pushViewController:loginSecondVC animated:YES];
    [loginSecondVC release];
}
-(void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_beginTime release];
    [_endTime release];
    [_time1 release];
    [_time2 release];
    [_time3 release];
    [_helpBtn release];
    [super dealloc];
}
- (IBAction)didSelectHelpBtnAction:(UIButton *)sender {
    AuthCodeHelpViewController *authcodeHelp = [[AuthCodeHelpViewController alloc] initWithNibName:@"AuthCodeHelpViewController" bundle:nil];
    authcodeHelp.index = 3;
    [self.navigationController pushViewController:authcodeHelp animated:YES];
    [authcodeHelp release];
}
@end
