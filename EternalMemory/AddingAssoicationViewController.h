//
//  AddingAssoicationViewController.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-21.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CustomNavBarController.h"
#import "ZBarSDK.h"
#import "MBProgressHUD.h"

static NSString * const GenealogyAssociatedSuccessNotification = @"GenealogyAssociatedSuccessNotification";

@interface AddingAssoicationViewController : CustomNavBarController<UITableViewDataSource,
    UITableViewDelegate,
    UIAlertViewDelegate,
    ASIHTTPRequestDelegate,
    UIActionSheetDelegate,
    ZBarReaderDelegate>{
        
        NSTimer                  *_timer;
        BOOL                     upOrdown;
        UIImageView              *_line;
        int                      num;
        ZBarReaderViewController *_reader;
        MBProgressHUD            *HUD;
        NSString                 *_authDecode;
        NSString                 *_assciotedType;
        BOOL                     _fromPhotoLibrary;
        BOOL                     _VerticalScreen;
        UIButton                 *_selectPhotoBtn;
        
}

@property (nonatomic, retain) NSDictionary *memberInfoDic;

@end
