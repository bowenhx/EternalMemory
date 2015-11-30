//
//  DiaryDetailsViewController.h
//  EternalMemory
//
//  Created by sun on 13-6-3.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "DiaryMessageModel.h"
@class ASIFormDataRequest;
@interface DiaryDetailsViewController : CustomNavBarController <NavBarDelegate ,UIActionSheetDelegate,UIAlertViewDelegate,ASIHTTPRequestDelegate>{
     ASIFormDataRequest *_request;
//    UIScrollView        *_containerScrollView;
}
@property (retain, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic, retain) DiaryMessageModel *model;

@end
