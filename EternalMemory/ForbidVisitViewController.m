//
//  ForbidVisitViewController.m
//  EternalMemory
//
//  Created by sun on 13-6-30.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "ForbidVisitViewController.h"
#import "RequestParams.h"
#import "Config.h"
#import "EternalMemoryAppDelegate.h"
#import "PrivacySetViewController.h"
#import "AssoiatedFailureView.h"
#import "RNBlurModalView.h"
#import "ForbidApplyInfoView.h"
#import "ForbidInfo.h"
#import "ForbidApplySuccessView.h"
#import "EternalMemoryAppDelegate.h"

static NSString * const ForbidApplyStr = @"生成记忆码后您所有的信息将不能再添加修改，只可以通过记忆码访问查看您的家园。请确认您的申请信息：";
static NSString * const ForbidSuccessStr = @"记忆码生成成功，妥善保管此记忆码，以方便您登陆家园使用。";

@interface ForbidVisitViewController ()

@end

@implementation ForbidVisitViewController
//@synthesize formatReq = _formatReq;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        _formatReq = [[ASIFormDataRequest alloc]init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"封存申请";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;

    CGRect bgViewFrame = _bgView.frame;
    bgViewFrame.size.height = 150;
    _bgView.frame = bgViewFrame;

    // Do any additional setup after loading the view from its nib.
}

-(void)backBtnPressed{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnPressed{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)currentDate{
    
    NSDate *curDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate: curDate];
    [formatter release];
    return dateStr;
}

- (IBAction)applyForbidVisit:(UIButton *)sender {
    
    [_nameTextField resignFirstResponder];
    [_mailAddrTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
    if ([_nameTextField.text length] != 0 && [_phoneTextField.text length] != 0 && [_mailAddrTextField.text length] != 0)
    {
        ForbidInfo *info = [ForbidInfo new];

        info.name = _nameTextField.text;
        info.mobile = _phoneTextField.text;
        info.address = _mailAddrTextField.text;
        
        ForbidApplyInfoView *applyInfoView = [[ForbidApplyInfoView alloc] initWithFrame:CGRectZero];
        applyInfoView.info = info;
        
        AssoiatedFailureView *promptView = [[AssoiatedFailureView alloc] initWithTitle:@"生成记忆码" promptMessage:ForbidApplyStr canelButton:@"取消" containerView:applyInfoView];
        
        __block RNBlurModalView *blurView = [[RNBlurModalView alloc] initWithViewController:self view:promptView viewCenter:self.view.center];
        [blurView show];
        
        [promptView setCancelBlock:^{
            [blurView hide];
        }];
        
        __block typeof(self) bself = self;
        [promptView setConfirmBlock:^{
            [blurView hide];
            [bself appleForbidVisitRequest];
        }];
        
        [promptView release];
        [blurView release];
        [applyInfoView release];
        
        [info release];

    }else{
        
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.labelText = @"信息不能为空";
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];

        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(1);
        } completionBlock:^{
            [HUD removeFromSuperview];
            [HUD release];
        }];  //    [promptMB setHidden:YES];
   
    }
   
}

#pragma mark ------
#pragma mark --request

-(void)appleForbidVisitRequest{
    
    NSString *currenDate = [self currentDate];
    NSURL *reqUrl = [[RequestParams sharedInstance]forbidVisitUrl];
   ASIFormDataRequest *_formatReq = [ASIFormDataRequest requestWithURL:reqUrl];
    [_formatReq setPostValue:USER_TOKEN_GETOUT forKey:TOKEN_PARAM];
    [_formatReq setPostValue:USER_AUTH_GETOUT forKey:AUTH_CODE];
    [_formatReq setPostValue:_nameTextField.text forKey:@"fullname"];
    [_formatReq setPostValue:_phoneTextField.text forKey:@"telephone"];
    [_formatReq setPostValue:_mailAddrTextField.text forKey:@"address"];
    [_formatReq setPostValue:currenDate forKey:@"applytime"];
    [_formatReq setRequestMethod:@"POST"];
    [_formatReq setDelegate:self];
    [_formatReq retain];
    [_formatReq setTimeOutSeconds:10];
    [_formatReq startAsynchronous];
  
}



-(void)requestFinished:(ASIHTTPRequest *)request{
    
    NSData *reqData = [request responseData];
    NSDictionary *dict = [reqData objectFromJSONData];
    NSInteger success = [[dict objectForKey:@"success"]integerValue];
    NSString *messg = [dict objectForKey:@"message"];
    if (success == 1) {
        
//        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
//        [self.view addSubview:HUD];
//        HUD.labelText = messg;
//        HUD.mode = MBProgressHUDModeCustomView;
//        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
//        [HUD showAnimated:YES whileExecutingBlock:^{
//            sleep(1);
//        } completionBlock:^{
//            [HUD removeFromSuperview];
//            [HUD release];
//        }];
        
        ForbidApplySuccessView *successView = [[ForbidApplySuccessView alloc] initWithFrame:(CGRect){
            .origin.x = 0,
            .origin.y = 0,
            .size.width  = 215,
            .size.height = 50
        }];
        
        ForbidInfo *info = [ForbidInfo new];
        //    info.ieternalNum = dict[@"meta"][@"memoryCode"];
        info.ieternalNum = dict[@"meta"][@"memoryCode"];
        
        successView.info = info;
        
        AssoiatedFailureView *promptView = [[AssoiatedFailureView alloc] initWithTitle:@"生成成功" promptMessage:ForbidSuccessStr canelButton:nil containerView:successView];
        [promptView setConfirmBlock:^{
            EternalMemoryAppDelegate *appDelegate = (EternalMemoryAppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate showEternalViewController];
        }];
        
        RNBlurModalView *blurView = [[RNBlurModalView alloc] initWithViewController:self view:promptView viewCenter:self.view.center];
        
        [blurView show];
        
        [info release];
        [promptView release];
        [successView release];
        [blurView release];
        
        
        NSString *statues = @"1";
        NSDictionary *personDict = [SavaData parseDicFromFile:User_File];
        
        [personDict setValue:statues forKey:@"lockstate"];
        NSDictionary *changeDict = [[NSDictionary alloc]initWithDictionary:personDict];
        personDict = nil;
        [SavaData writeDicToFile:changeDict FileName:User_File];
        [changeDict release];
        changeDict = nil;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"changeBtnState" object:nil];
//        [self performSelector:@selector(backBtnPressed) withObject:nil afterDelay:1];
//        [self.navigationController popViewControllerAnimated:YES];
    }else if([dict[@"errorcode"] intValue] == 1005){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
    }
    else if ([dict[@"errorcode"] intValue] ==9000)
    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
        
    }else{
        
        NSString *statues = @"1";
        NSDictionary *personDict = [SavaData parseDicFromFile:User_File];
        
        [personDict setValue:statues forKey:@"lockstate"];
        NSDictionary *changeDict = [[NSDictionary alloc]initWithDictionary:personDict];
        personDict = nil;
        [SavaData writeDicToFile:changeDict FileName:User_File];
        [changeDict release];
        changeDict = nil;
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.labelText = messg;
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(1);
        } completionBlock:^{
            [HUD removeFromSuperview];
            [HUD release];
        }];  //    [promptMB setHidden:YES];

    }
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"网络连接异常";
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        [HUD release];
    }];  //    [promptMB setHidden:YES];

    
}

#pragma mark
#pragma mark- alertDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    BOOL isLogin = NO;
    [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
    [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == _nameTextField) {
        
        [_phoneTextField becomeFirstResponder];
    }else if(textField == _phoneTextField){
        
        [_mailAddrTextField becomeFirstResponder];
    }else if(textField == _mailAddrTextField){
        
        [_nameTextField resignFirstResponder];
        [_phoneTextField resignFirstResponder];
        [_mailAddrTextField resignFirstResponder];
        
    }
    [_nameTextField bringSubviewToFront:self.view];
    return YES;
}
- (void)dealloc {
//    [_formatReq clearDelegatesAndCancel];
//    [_formatReq release];
//    _formatReq = nil;
    [_nameTextField release];
    _nameTextField = nil;
    [_phoneTextField release];
    _phoneTextField = nil;
    [_mailAddrTextField release];
    _mailAddrTextField = nil;
    [_bgView release];
    _bgView = nil;
    [_applyBtn release];
    _applyBtn = nil;
    [super dealloc];
}
- (void)viewDidUnload {
    [self setNameTextField:nil];
    [self setPhoneTextField:nil];
    [self setMailAddrTextField:nil];
    [self setBgView:nil];
    [self setApplyBtn:nil];
    [super viewDidUnload];
}
@end
