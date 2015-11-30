//
//  UploadingVideoViewCtrl.h
//  EternalMemory
//
//  Created by Guibing on 13-6-6.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>
#import "CustomNavBarController.h"
//引入队列请求头文件
#import "ASINetworkQueue.h"

@interface UploadingVideoViewCtrl : CustomNavBarController<UITextFieldDelegate,ASIHTTPRequestDelegate,ASIProgressDelegate,UIAlertViewDelegate,NSStreamDelegate>
@property (nonatomic ,retain) UIImage *imageVideo;
@property (nonatomic ,copy)   NSString *strVideoPath;
@property (nonatomic ,assign) NSInteger upType;
@property (nonatomic)          CFSocketRef _socket;
@property (nonatomic)        BOOL isHome;
@property (nonatomic,assign) long allSize;

@end
