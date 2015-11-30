//
//  PrivacySetViewController.m
//  EternalMemory
//
//  Created by sun on 13-6-30.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "PrivacySetViewController.h"
#import "NTPrivacyProblemViewCtrl.h"
#import "ForbidVisitViewController.h"
#import "Config.h"
#import "Utilities.h"
@interface PrivacySetViewController ()
{
    ASIFormDataRequest    *_formatReq;
}

@end

@implementation PrivacySetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
/**
 *  请求封存状态
 */
-(void)getApplyStatues{
    
  //  http://m.ieternal.com:80/api/user/getApply
    NSString *applyStr = [NSString stringWithFormat:@"%@api/user/getApply",INLAND_SERVER];
    NSURL *applyUrl = [NSURL URLWithString:applyStr];
    _formatReq = [[ASIFormDataRequest alloc] initWithURL:applyUrl];
    _formatReq.shouldAttemptPersistentConnection = NO;
    [_formatReq addPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_formatReq addPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_formatReq setDelegate:self];
    [_formatReq setRequestMethod:@"POST"];
    [_formatReq setTimeOutSeconds:3.0];
    __block typeof(self) bself=self;
    [_formatReq setCompletionBlock:^{
        [bself requestFinishedd:_formatReq];
    }];
    [_formatReq setFailedBlock:^{
        [bself requestFailedd:_formatReq];
    }];
    [_formatReq startAsynchronous];

}
//public_tables_4@2x 
-(void)requestFinishedd:(ASIHTTPRequest *)request{
    
    NSData *reqData = [request responseData];
    NSDictionary *reqDict = [reqData objectFromJSONData];
    int successInt = [[reqDict valueForKey:@"success"]intValue];
    NSString *mesgStr = [reqDict valueForKey:@"message"];
    NSDictionary *dataDict = [reqDict valueForKey:@"data"];
//申请封存次数
    NSInteger applyyId = [[dataDict valueForKey:@"applyId"]integerValue];

//封存状态
    NSInteger status = [[dataDict valueForKey:@"status"]integerValue];
//reason
    NSString *reason = [dataDict valueForKey:@"reason"];
//申请时间
    NSString *applyTime = [dataDict valueForKey:@"applytime"];
    NSString *applytime = [Utilities convertTimestempToDateWithString2:applyTime];
    if (successInt == 1) {
        
        if (applyyId == 0) {
           //处理lable显示
            _fourTabView.hidden = YES;
            _displayLab.text = @"未申请";
            
        }
        if (applyyId > 0) {
            switch (status) {
                case 0:
                    _fourTabView.hidden = YES;
                    _displayLab.text = @"待审核";
                    _forbidenVisitBtn.enabled = NO;
                    break;
                case 1:{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alert.tag = 9000;
                    [alert show];
                    [alert release];
                }
                    //直接跳出界面 提示已经封存了。
                    break;
                case 2:
                    _fourTabView.hidden = NO;
                    _fourLab.text = @"拒绝封存";
                    //显示拒绝理由、原因
                    _fourTextV.text = [NSString stringWithFormat:@"您%@的申请%@",applytime,reason];
                    break;
                case 3:
                    _fourTabView.hidden = NO;
                    _fourLab.text = @"已解封";
                    _fourTextV.text = @"";
                    //显示解封理由、原因
                    _fourTextV.text = [NSString stringWithFormat:@"您%@的申请%@",applytime,reason];
                    break;
                default:
                    break;
            }
            
        }
        
    }else{
        
        if ([mesgStr isEqualToString:@"请重新登录!"]) {
            
            //退出登录
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1005;
            [alert show];
            [alert release];
            
        }else{
            
            [self networkPromptMessage:mesgStr];
        }
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 9000 || alertView.tag == 1005) {
        
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
    }
   
}


-(void)requestFailedd:(ASIHTTPRequest *)request{
    
    MBProgressHUD *_mb = [[MBProgressHUD alloc]initWithView:self.view];
    
    [self.view addSubview:_mb];
    _mb.labelText = @"请求失败！";
    _mb.mode = MBProgressHUDModeCustomView;
    _mb.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
    [_mb showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [_mb removeFromSuperview];
        [_mb release];
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _memoryBut.enabled = NO;
    _fourTabView.hidden = YES;
    self.titleLabel.text = @"隐私设置";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    self.bgView.backgroundColor = RGBCOLOR(238, 242, 245);
//    if (iPhone5) {
//        
//        self.bgView.frame = CGRectMake(0, 0, 320, 516);
//        self.bgView.hidden = NO;
//        
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changForbidderBtn) name:@"changeBtnState" object:nil];
    
    
//    NSDictionary *personDict = [NSDictionary dictionaryWithDictionary:[SavaData parseDicFromFile:User_File]];
//    NSInteger appleState = [[personDict objectForKey:@"lockstate"]integerValue];
//    if (appleState == 1) {
//        
//        _forbidVisitBtn.enabled = NO;
//        _forbidImg.hidden = YES;
//        _displayLab.text = @"审核中";
//        
//    }else if(appleState == 0){        
//        _forbidVisitBtn.enabled = YES;
//        _forbidImg.hidden = NO;
//        _displayLab.hidden = YES;
//        
//    }else{
//        
//        _forbidVisitBtn.enabled = NO;
//        _forbidImg.hidden = YES;
//        _displayLab.text = @"已封存";
//    }
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    
    if (![Utilities checkNetwork])
    {
        [self networkPromptMessage:@"网络连接异常"];
    }else
    {
        [self getApplyStatues];
    }
}

-(void)changForbidderBtn{
    
    _forbidVisitBtn.enabled = NO;
    _forbidImg.hidden = YES;
    _displayLab.hidden = NO;
    _displayLab.text = @"审核中";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)backBtnPressed{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)clickSecretQ:(UIButton *)sender {
    
    BOOL haveNetwork = [Utilities checkNetwork];
    if (haveNetwork) {
        NTPrivacyProblemViewCtrl *privacyProblem = [NTPrivacyProblemViewCtrl new];
        [self.navigationController pushViewController:privacyProblem animated:YES];
        [privacyProblem release];
        
    }else{
        
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.labelText = @"请检查网络";
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

- (IBAction)clickForbidVisit:(UIButton *)sender {
    
    ForbidVisitViewController *forVC = [[ForbidVisitViewController alloc]initWithNibName:iPhone5 ? @"ForbidVisitViewController-5" : @"ForbidVisitViewController" bundle:nil];
    [self.navigationController  pushViewController:forVC animated:YES];
    [forVC release];
}
- (void)dealloc {
    if (_formatReq) {
        [_formatReq cancel];
        [_formatReq clearDelegatesAndCancel];
    }
    [_bgView release];
    [_forbidVisitBtn release];
    [_forbidImg release];
    [_displayLab release];
    [_memoryBut release];
    [_bgImgView release];
    [_fourTabView release];
    [_fourLab release];
    [_fourTextV release];
    [_forbidVisitBtn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBgView:nil];
    [self setForbidVisitBtn:nil];
    [self setForbidImg:nil];
    [self setDisplayLab:nil];
    [self setMemoryBut:nil];
    [self setBgImgView:nil];
    [self setFourTabView:nil];
    [self setFourLab:nil];
    [self setFourTextV:nil];
    [self setForbidVisitBtn:nil];
    [super viewDidUnload];
}
@end
