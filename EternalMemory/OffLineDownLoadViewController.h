//
//  OffLineDownLoadViewController.h
//  EternalMemory
//
//  Created by xiaoxiao on 12/6/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import "CustomNavBarController.h"
@interface OffLineDownLoadViewController : CustomNavBarController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{

}
@property(nonatomic,retain)__block UIButton *cancelButton;

//离线下载结束调用
-(void)offlineDownLoadSuccess;
//自动启动自动下载
-(void)startFailedListDownload;

@end
