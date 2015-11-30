//
//  MemberIdentityViewController.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-17.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"

static NSString * const DidSelectIdentityNotification = @"DidSelectIdentityNotification";

static NSString * const kMotherInfo = @"kMotherInfo";
static NSString * const kIdentity = @"kIdentity";

@interface MemberIdentityViewController : CustomNavBarController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, copy) NSDictionary *infoDic;
@property (nonatomic, assign) BOOL isPartner;

@end
