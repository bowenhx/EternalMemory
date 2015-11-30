//
//  WriteWordsViewController.h
//  EternalMemory
//
//  Created by sun on 13-5-24.
//  Copyright (c) 2013年 sun. All rights reserved.

//写日记界面

#import "CustomNavBarController.h"
#import "DiaryMessageModel.h"
#import <UIKit/UIKit.h>
@class ASIFormDataRequest;
@class MBProgressHUD;
@interface WriteWordsViewController : CustomNavBarController <NavBarDelegate , UITextViewDelegate,UIAlertViewDelegate>
{
    NSInteger           netType;//用于标记无网络本地存储和服务器存储,1为本地，2为服务器
    NSString            *updateOradd;//用于标记断网情况下存本地，修改时先上传
    ASIFormDataRequest  *_request;
    MBProgressHUD       *_mb;
}
@property (nonatomic, assign) NSInteger          selectedIndex;
@property (nonatomic, copy)   NSString          *groupId;
@property (nonatomic, copy)   NSString          *groupName;
@property (nonatomic, retain) DiaryMessageModel *blogModel;


@end
