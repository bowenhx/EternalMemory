//
//  CheckAppVersion.m
//  EternalMemory
//
//  Created by zhaogl on 14-3-27.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "CheckAppVersion.h"
#import "RequestParams.h"
#import "SavaData.h"
#import "ErrorCodeHandle.h"
#import "MorePageViewCtrl.h"
#import "MBProgressHUD.h"
#import "MyToast.h"

@implementation CheckAppVersion


+(void)checkAppVersionFromWhere:(UIViewController *)where{

    //版本更新提示
    NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    NSURL *url =  [[RequestParams sharedInstance] getClientVersion];
    ASIFormDataRequest *requestUpData = [ASIFormDataRequest requestWithURL:url];
    [requestUpData setRequestMethod:@"POST"];
    [requestUpData addPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [requestUpData addPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [requestUpData setPostValue:@"ios" forKey:@"platform"];
    [requestUpData setPostValue:localVersion forKey:@"versions"];
    [requestUpData setTimeOutSeconds:10];
    requestUpData.failedBlock = ^(void)
    {
        if ([where isKindOfClass:[MorePageViewCtrl class]]) {
            [MyToast showWithText:@"请检查网络" :150];
        }
    };
    requestUpData.completionBlock = ^(void)
    {
        NSData *data = [requestUpData responseData];
        NSDictionary *dataDic = [data objectFromJSONData];
        NSInteger success = [[dataDic objectForKey:@"success"] integerValue];
        
        if (success==1) {
            
            if (![dataDic[@"data"] isEqual:@""]) {
                
                NSString *serverVersion = dataDic[@"data"][@"versions"];
                int serverVersInt = [[serverVersion stringByReplacingOccurrencesOfString:@"." withString:@""]integerValue];
                if ([[NSString stringWithFormat:@"%d",serverVersInt] length] == 2) {
                    serverVersInt = [[NSString stringWithFormat:@"%d0",serverVersInt] integerValue];
                }
                int localVersionInt = [[localVersion stringByReplacingOccurrencesOfString:@"." withString:@""]integerValue];
                if ([[NSString stringWithFormat:@"%d",localVersionInt] length] == 2) {
                    localVersionInt = [[NSString stringWithFormat:@"%d0",localVersionInt] integerValue];
                }
                if (serverVersInt > localVersionInt) {
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"版本升级提示" message:[NSString stringWithFormat:@"最新版本为:%@",serverVersion] delegate:where cancelButtonTitle:@"取消" otherButtonTitles:@"立即升级", nil];
                    alert.tag = 200;
                    [alert show];
                    [alert release];
                }else if (serverVersInt == localVersionInt && [where isKindOfClass:[MorePageViewCtrl class]]){
                    
                    NSString *verNew = [NSString stringWithFormat:@"已经是最新版本:%@",localVersion];
                    [MyToast showWithText:verNew :160];
                }
            }
        }else {
            [ErrorCodeHandle handleErrorCode:dataDic[@"errorcode"] AndMsg:dataDic[@"message"]];
        }
    };
    [requestUpData startAsynchronous];
 
}


@end
