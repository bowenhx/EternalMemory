//
//  ErrorCodeHandle.m
//  EternalMemory
//
//  Created by zhaogl on 14-3-24.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "ErrorCodeHandle.h"
#import "SavaData.h"
#import "EternalMemoryAppDelegate.h"
#import "MyToast.h"

#define ServerError    1
#define NoUserName     2
#define UserNameHaved  3
#define ChangedPsw     4
#define ErrorPsw       5
#define ReLogin        6
#define NullAccount    7
#define FailRegist     8
#define illegalName    9
#define NullName       10
#define NUllPsw        11
#define NullNewPsw     12
#define NullToken      13
#define illegalToken   14
#define NullAuth       15
#define FailChangePsw  16
#define absentAccount  17
#define NullAuthCode   18
#define NotID          19
#define IDNull         20
#define IDHaveUsed     21


@implementation ErrorCodeHandle



+(instancetype)sharedInstance
{
    static ErrorCodeHandle *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ErrorCodeHandle alloc] init];
    });
    return _sharedInstance;
}


-(void)showAlertViewWithTag:(NSInteger)tag AndMessage:(NSString *)msg{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg
                          
                                                   delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alert.delegate = self;
    alert.tag = tag;
    [alert show];
    [alert release];
}
+(void)handleErrorCode:(NSString *)errorCode AndMsg:(NSString *)msg{
    
    [[ErrorCodeHandle sharedInstance] handleCode:errorCode AndMsg:msg];
}
-(void)handleCode:(NSString *)errorCode AndMsg:(NSString *)msg{
    
    NSInteger code = [errorCode integerValue];
    switch (code) {
        case 0001:{
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:ServerError AndMessage:msg];
        }
            break;
        case 1001:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:NoUserName AndMessage:msg];
            break;
        case 1002:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:UserNameHaved AndMessage:msg];
            break;
        case 1003:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:ChangedPsw AndMessage:msg];
            break;
        case 1004:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:ErrorPsw AndMessage:msg];
            break;
        case 1005:
            msg = @"您的账号已在其他地方登录，请重新登录";
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:ReLogin AndMessage:msg];
            break;
        case 1006:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:NullAccount AndMessage:msg];
            break;
        case 1007:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:FailRegist AndMessage:msg];
            break;
        case 1008:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:illegalName AndMessage:msg];
            break;
        case 1009:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:NullName AndMessage:msg];
            break;
        case 1010:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:NUllPsw AndMessage:msg];
            break;
        case 1011:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:NullNewPsw AndMessage:msg];
            break;
        case 1013:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:NullToken AndMessage:msg];
            break;
        case 1014:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:illegalToken AndMessage:msg];
            break;
        case 1015:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:NullAuth AndMessage:msg];
            break;
        case 1016:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:FailChangePsw AndMessage:msg];
            break;
        case 1017:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:absentAccount AndMessage:msg];
            break;
        case 1018:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:NullAuthCode AndMessage:msg];
            break;
        case 2001:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:NotID AndMessage:msg];
            break;
        case 2002:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:IDHaveUsed AndMessage:msg];
            break;
        case 2003:
            [[ErrorCodeHandle sharedInstance] showAlertViewWithTag:IDNull AndMessage:msg];
            break;
        default:
            [MyToast showWithText:msg :150];
            break;
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (alertView.tag) {
        case ReLogin:
        {
            BOOL isLogin = NO;
            [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
        }
            break;
            
        default:
            break;
    }
}
@end
