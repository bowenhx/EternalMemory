//
//  AuthCodeHelpViewController.m
//  EternalMemory
//
//  Created by Guibing on 13-12-24.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "AuthCodeHelpViewController.h"

@interface AuthCodeHelpViewController ()<UIAlertViewDelegate>

@end

@implementation AuthCodeHelpViewController

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
    self.rightBtn.hidden = YES;

    
    if (_index ==1) {
        self.titleLabel.text = @"如何获取授权码";
        _titleLab.text = @"     授权码是用户与公司签订协议的一种重要凭据，它会在跟公司签订协议的同时，免费赠予用户。获取授权码的一刻起，即该授权码账号下的内容均与公司有保密协议，永久不会丢失。";
    }else if (_index ==2){
        self.titleLabel.text = @"找回授权码";
        _titleLab.hidden = YES;
        _titleLab2.hidden = NO;
    }else {
        self.titleLabel.text = @"授权码";
        _titleLab.text = @"     授权码是用户与公司签订协议的一种重要凭据，它会在跟公司签订协议的同时，免费赠予用户。获取授权码的一刻起，即该授权码账号下的内容均与公司有保密协议，永久不会丢失。";
    }
    
    
}
- (IBAction)didCallUpPhoneNumberAction:(UIButton *)sender {
    [[[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您确定要拨打该电话吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil]autorelease ]show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://1008611"]];
    }
}
- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_titleLab release];
    [_phoneNum release];
    [_titleLab2 release];
    [_phoneNumBtn release];
    [super dealloc];
}

@end
