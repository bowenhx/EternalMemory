//
//  SavedRequests.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-8-1.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "SavedRequests.h"
#import "FileModel.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "SavaData.h"
#import "DiaryPictureClassificationSQL.h"
#import "MessageSQL.h"
#import "EternalMemoryAppDelegate.h"
#import "MBProgressHUD.h"

#define PHOTOTEXT @"0"
#define REQUEST_FOR_LOGIN 100
#define REQUEST_FOR_GETGROUPS 200
#define REQUEST_FOR_ADDDIARY 1000
#define REQUEST_FOR_DELETBLOG 2000
#define REQUEST_FOR_UPDATADIARY 3000
#define REQUEST_FOR_ADDPHOTO 4000
#define REQUEST_FOR_DELETEPHOTO 5000
#define REQUEST_FOR_UPDATAPHOTO 6000




@implementation SavedRequests


+ (id)sharedSavedRequests
{
    
    
    static SavedRequests *savedRequets = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        savedRequets = [[SavedRequests alloc] init];
    });
    
    return savedRequets;
}

- (void)setUpReqeustQueueDelegate:(id)delegate
{
    _requestQueue = [[ASINetworkQueue alloc] init];
    [_requestQueue setDelegate:self];
    [_requestQueue setRequestDidStartSelector:@selector(reqeustStart:)];
    [_requestQueue setRequestDidFinishSelector:@selector(requestSuccess:)];
    [_requestQueue setRequestDidFailSelector:@selector(requestFail:)];
}

- (void)reqeustStart:(ASIFormDataRequest *)request
{
    NSLog(@"请求开始了 ，，，， adr   %@",[request url]);
}

-(void)requestSuccess:(ASIFormDataRequest *)request
{
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    self.errorcodeStr = [NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"errorcode"]];
    if (tag == REQUEST_FOR_LOGIN)
    {
        if ([resultStr isEqualToString:@"0"])
        {
            
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:nil otherButtonTitles:ALERT_OK, nil];
            alter.tag = 1000;
            [alter show];
            [alter release];
#warning mark --处理自动登录返回来的信息
        }
        else{
            //            NSLog(@"自动登陆返回数据～～～%@",resultDictionary);
            NSDictionary *dataDic = [resultDictionary objectForKey:@"data"];
            NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
            NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:User_File];
            NSMutableDictionary *userDataDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
            if (dataDic.count >0) {
                [userDataDic setObject:[dataDic objectForKey:@"SID"] forKey:@"SID"];
                [userDataDic setObject:[dataDic objectForKey:@"addressdetail"] forKey:@"addressdetail"];
                [userDataDic setObject:[dataDic objectForKey:@"clientToken"] forKey:@"clientToken"];
                [userDataDic setObject:[dataDic objectForKey:@"email"] forKey:@"email"];
                [userDataDic setObject:[dataDic objectForKey:@"favoriteMusic"] forKey:@"favoriteMusic"];
                [userDataDic setObject:[dataDic objectForKey:@"favoriteStyle"] forKey:@"favoriteStyle"];
                [userDataDic setObject:[dataDic objectForKey:@"intro"] forKey:@"intro"];
                [userDataDic setObject:[dataDic objectForKey:@"lastLoginTime"] forKey:@"lastLoginTime"];
                [userDataDic setObject:[dataDic objectForKey:@"latestVersion"] forKey:@"latestVersion"];
                [userDataDic setObject:[dataDic objectForKey:@"memoryCode"] forKey:@"memoryCode"];
                [userDataDic setObject:[dataDic objectForKey:@"mobile"] forKey:@"mobile"];
                [userDataDic setObject:[dataDic objectForKey:@"openStatus"] forKey:@"openStatus"];
                [userDataDic setObject:[dataDic objectForKey:@"realName"] forKey:@"realName"];
                [userDataDic setObject:[dataDic objectForKey:@"serverAuth"] forKey:@"serverAuth"];
                [userDataDic setObject:[dataDic objectForKey:@"sex"] forKey:@"sex"];
                [userDataDic setObject:[dataDic objectForKey:@"spaceTotal"] forKey:@"spaceTotal"];
                [userDataDic setObject:[dataDic objectForKey:@"spaceUsed"] forKey:@"spaceUsed"];
                [userDataDic setObject:[dataDic objectForKey:@"userId"] forKey:@"userId"];
                [userDataDic setObject:[dataDic objectForKey:@"userName"] forKey:@"userName"];
                [userDataDic writeToFile:plistPath atomically:YES];
                
            }
            [userDataDic release];
//            __block typeof (self) bself=self;
            
//            BOOL network = [Utilities checkNetwork];
//            if (network) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    [bself  synchronousDBData];
//                });
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    [bself getGroupsRequest];
//                });
//                //            [self  synchronousDBData];
//                //            [self getGroupsRequest];
//            }
        }
    }
    if (tag == REQUEST_FOR_GETGROUPS) {
        if ([resultStr isEqualToString:@"0"]) {
            
            UIAlertView *_alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [_alter show];
            [_alter release];
            
        }else{
            NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:10];
            [dataArray setArray:[resultDictionary objectForKey:@"data"]];
            [DiaryPictureClassificationSQL  refershDiaryPictureClassificationes:dataArray];
        }
        
    }
    //同步
    if (tag == REQUEST_FOR_ADDDIARY) {
        
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:@"同步结果" message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            NSDictionary *dataDic =[resultDictionary objectForKey:@"data"];
            NSArray *blogArray = [NSArray arrayWithObject:dataDic];
            [MessageSQL synchronizeBlog:blogArray];
        }
    }
    if (tag == REQUEST_FOR_DELETBLOG) {
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:@"同步结果" message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            NSString *blogId = [resultDictionary objectForKey:@"data"];
            MessageModel *blogModel = [MessageSQL getBlogByBlogId:blogId];
            NSMutableArray *refershMessagesArray = [NSMutableArray arrayWithObject:blogModel];
            [MessageSQL deletePhoto:refershMessagesArray];
        }
        
    }
    if (tag == REQUEST_FOR_UPDATADIARY) {
        
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            NSDictionary *dataDic =[resultDictionary objectForKey:@"data"];
            NSArray *blogArray = [NSArray arrayWithObject:dataDic];
            [MessageSQL synchronizeBlog:blogArray];
            
        }
    }
    
    //上传图片
    if (tag == REQUEST_FOR_ADDPHOTO) {
        
        NSLog(@"同步机制， 上传图片");
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }
        else
        {
            
            
            NSString *deleteSpath = request.userInfo[@"spaths"];
            NSString *deletePaths = request.userInfo[@"paths"];
            
            NSError *sError;
            NSError *bError;
            [[NSFileManager defaultManager] removeItemAtPath:deletePaths error:&bError];
            [[NSFileManager defaultManager] removeItemAtPath:deleteSpath error:&sError];
            
            if (sError) {
                [MessageSQL deleteTempDataWithPath:deleteSpath];
                NSLog(@"小图删除成功");
            } else {
                NSLog(@"error : %@", sError);
            }
            
            if (bError) {
                NSLog(@"大图删除成功");
            } else {
                NSLog(@"大图删除失败   error : %@",bError);
            }
            
            
            //            NSLog(@"%@",resultDictionary);
            NSDictionary *dataDic =[resultDictionary objectForKey:@"data"];
            NSDictionary *metaDic =[resultDictionary objectForKey:@"meta"];
            NSArray *blogArray = [NSArray arrayWithObject:dataDic];
            
            [MessageSQL synchronizeBlog:blogArray];
            
            //更新使用空间
            NSString *spaceusedStr = [metaDic objectForKey:@"spaceused"];
            NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
            NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:User_File];
            NSMutableDictionary *userDataDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
            //            NSLog(@"User_File~~~~~~~%@",plistPath);
            //            NSLog(@"userDataDic~~~%@",userDataDic);
            [userDataDic setObject:spaceusedStr forKey:@"spaceUsed"];
            [userDataDic writeToFile:plistPath atomically:YES];
        }
    }
    if (tag == REQUEST_FOR_DELETEPHOTO) {
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            
            NSLog(@"同步删除成功！");
            NSString *blogId = [resultDictionary objectForKey:@"data"];
            NSDictionary *metaDic = [resultDictionary objectForKey:@"meta"];
            MessageModel *blogModel = [MessageSQL getBlogByBlogId:blogId];
            NSArray *blogArray = [NSArray arrayWithObject:blogModel];
            [MessageSQL deletePhoto:blogArray];
            
            //更新使用空间
            NSString *spaceusedStr = [metaDic objectForKey:@"spaceused"];
            NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
            NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:User_File];
            NSMutableDictionary *userDataDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
            //            NSLog(@"User_File~~~~~~~%@",plistPath);
            //            NSLog(@"userDataDic~~~%@",userDataDic);
            [userDataDic setObject:spaceusedStr forKey:@"spaceUsed"];
            [userDataDic writeToFile:plistPath atomically:YES];
            
        }
    }
    if (tag == REQUEST_FOR_UPDATAPHOTO) {
        
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            NSLog(@"同步修改报错 %@",errorStr);
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            //            NSDictionary *dataDic =[resultDictionary objectForKey:@"data"];
            //            NSArray *blogArray = [NSArray arrayWithObject:dataDic];
            //            [MessageSQL refershMessages:blogArray clientId:nil];
            NSDictionary *dataDic =[resultDictionary objectForKey:@"data"];
            NSArray *blogArray = [NSArray arrayWithObject:dataDic];
            [MessageSQL synchronizeBlog:blogArray];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 500) {
        
        if (buttonIndex == 0) {
            
            [[SavaData shareInstance]savadataStr:@"2" KeyString:NO_NOTICE];
            //处理不再提示的alert
        }else{
            [[SavaData shareInstance]savadataStr:@"1" KeyString:NO_NOTICE];
        }
    }else {
        if ([self.errorcodeStr isEqualToString:@"1005"]) {
            
            BOOL isLogin = NO;
            [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
            
        }
    }
    
}
-(void)requestFail:(ASIFormDataRequest *)request
{
    if ([Utilities checkNetwork]) {
//        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
//        [self.view addSubview:HUD];
//        HUD.labelText = @"网络连接异常";
//        HUD.mode = MBProgressHUDModeCustomView;
//        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
//        
//        [HUD showAnimated:YES whileExecutingBlock:^{
//            sleep(1);
//        } completionBlock:^{
//            [HUD removeFromSuperview];
//            [HUD release];
//        }];  //    [promptMB setHidden:YES];
    }
}

- (id)init
{
    if (self = [super init]) {
        _reqeusts = [NSMutableArray new];

    }
    
    return self;
}

- (void)dealloc
{
    [_reqeusts release];
    [_requestQueue release];
    
    [super dealloc];
}

@end
