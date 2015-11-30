//
//  ChangePasswordViewCtrl.m
//  EternalMemory
//
//  Created by Guibing Li on 13-5-29.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "EternalMemoryAppDelegate.h"
#import "ChangePasswordViewCtrl.h"
#import "UploadingDebugging.h"
#import "ChangePasViewCell.h"
#import "EMPhotoSyncEngine.h"
#import "MorePageViewCtrl.h"
#import "StyleListSQL.h"
#import "CommonData.h"
#import "FileModel.h"
#import "MD5.h"
#define FileModel  [FileModel sharedInstance]

@interface ChangePasswordViewCtrl ()

{
    BOOL showScret;//YES 显示密码 NO 不显示密码
}

-(void)askNetworkToChangeSecret;

@end

@implementation ChangePasswordViewCtrl
@synthesize MnewPassw = _MnewPassw;

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
    self.titleLabel.text = @"密码修改";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = NO;
    showScret = NO;
    [self.rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    self.view.userInteractionEnabled = YES;
    
    [self.oldPassw becomeFirstResponder];
    self.oldPassw.secureTextEntry = YES;
    self.MnewPassw.secureTextEntry = YES;
    self.reNewPass.secureTextEntry = YES;

    // Do any additional setup after loading the view.
}
- (IBAction)didSelectShowSecretAction:(UIButton *)sender {
    [_reNewPass resignFirstResponder];
    [_oldPassw resignFirstResponder];
    [_MnewPassw resignFirstResponder];
    self.oldPassw.secureTextEntry = showScret;
    self.MnewPassw.secureTextEntry = showScret;
    self.reNewPass.secureTextEntry = showScret;
    showScret = !showScret;
    
    if (showScret) {
        [_showBut setImage:[UIImage imageNamed:@"public_select_but@2x"] forState:UIControlStateNormal];
    }else
    {
        [_showBut setImage:[UIImage imageNamed:@"public_noselect_but@2x"] forState:UIControlStateNormal];
    }
    
}

#pragma mark - UITouchEvent

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_reNewPass isFirstResponder])
    {
        [_reNewPass resignFirstResponder];
        return;
    }
    else if ([_oldPassw isFirstResponder])
    {
        [_oldPassw resignFirstResponder];
        return;
    }
    else if ([_MnewPassw isFirstResponder])
    {
        [_MnewPassw resignFirstResponder];
        return;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField == _oldPassw){
        [_MnewPassw becomeFirstResponder];
    }else if(textField == _MnewPassw)
    {
        [_reNewPass becomeFirstResponder];
    }else
    {
        [textField resignFirstResponder];
    }
    return YES;
}
-(void)rightBtnPressed
{
    if ([CommonData isTitleBlank:_oldPassw.text] ||[CommonData isTitleBlank:_MnewPassw.text]||[CommonData isTitleBlank:_reNewPass.text])
    {
        [self networkPromptMessage:@"密码不能为空"];
        return;
    }
    else
    {
        BOOL isUplaoding = [UploadingDebugging isUploading];
        if (_MnewPassw.text.length<8) {
             [self networkPromptMessage:@"新密码至少八个字符"];
            return;
        }else if (![_MnewPassw.text isEqualToString:_reNewPass.text]) {
            [self networkPromptMessage:@"两次密码输入不一样,请重新输入"];
            return;
        }
        else if (FileModel.isUpVideo || FileModel.isDownVideo || isUplaoding == YES ||FileModel.styleOperation.count>0)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"监测到您目前还在文件传输,是否确定退出" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 300;
            
            [alert show];
            [alert release];
            return;
        }
        [self askNetworkToChangeSecret];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 300)
    {
        if (buttonIndex ==1)
        {
            [[EMPhotoSyncEngine sharedEngine] stopSync];
            //修改密码成功进行的操作-----和退出登录进行相同的操作
            {
                [UploadingDebugging setupUploadingInfo];
                //TODO:删除数据库中处于正在下载状态的数据
                [StyleListSQL deleteDownLoadByIsDownLoad:2];
                //退出的时候取消日志的同步
                {
                    EternalMemoryAppDelegate *appDelegate = (EternalMemoryAppDelegate*)[UIApplication sharedApplication].delegate;
                    [appDelegate.synData cleanRequest];
                    [appDelegate.synData release];
                    appDelegate.synDataCount = 0;
                    appDelegate.synData = nil;
                    [[NSNotificationCenter defaultCenter] removeObserver:appDelegate name:@"synDataOver" object:nil];
                }
                [MorePageViewCtrl clearUploadingInfo];
                [FileModel cancleRequestDelegate];
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                NSString *style = [[SavaData shareInstance] printDataStr:offLineStyle];
                if (style.length >0) {
                    [[SavaData shareInstance] savadataStr:@"off" KeyString:offLineStyle];
                }
            }
            [self askNetworkToChangeSecret];
        }
    }
    else
    {
        BOOL isLogin = NO;
        
        //退出登录时重置公用的数据
        [Utilities resetCommonData];
        [[ResumeVedioSendOperation shareInstance] setSuspendWhenNetworkNoReachible];
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
    }
}
-(void)askNetworkToChangeSecret
{
    __block typeof (self) bSelf = self;
    NSURL *url = [[RequestParams sharedInstance] changePassword];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:[MD5 md5:_oldPassw.text] forKey:@"password"];
    [request setPostValue:[MD5 md5:_MnewPassw.text] forKey:@"newpassword"];
    [request setPostValue:[MD5 md5:_reNewPass.text] forKey:@"newpassword2"];
    [request setTimeOutSeconds:10];
    [request startAsynchronous];
    
    [request setFailedBlock:^(void){
        [bSelf networkPromptMessage:@"网络连接异常"];
    }];
    [request setCompletionBlock:^(void){
        NSData *data = [request responseData];
        NSDictionary *dic = [data objectFromJSONData];
        NSString *message = [dic objectForKey:@"message"];
        
        if ([dic[@"success"] integerValue] == 1) {
            [bSelf networkPromptMessage:@"修改成功"];
            BOOL isLogin = NO;
            [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            
            
            [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
        }else if ([dic[@"errorcode"] integerValue] == 1005)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:bSelf cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else if ([dic[@"errorcode"] intValue] ==9000)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:bSelf cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else if ([dic[@"errorcode"] integerValue] == 1016)
        {
            [bSelf networkPromptMessage:message];
        }
    }];
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
    [_oldPassw release];
    [_reNewPass release];
    [_MnewPassw release];
    [_myImageView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setMnewPassw:nil];
    [self setMnewPassw:nil];
    [super viewDidUnload];
}
@end
