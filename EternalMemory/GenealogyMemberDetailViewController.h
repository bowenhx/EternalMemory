//
//  GenealogyMemberDetailViewController.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "GenealogyMetaData.h"

static NSString * const ReviewGenealogyFromAssociatedMemberNotication = @"ReviewGenealogyFromAssociatedMemberNotication";


@interface GenealogyMemberDetailViewController : CustomNavBarController<UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic, retain) NSMutableDictionary *memberInfoDic;
@property (nonatomic, assign) BOOL  isOthersGenealogy;
@property (nonatomic, assign) NSDictionary *motherDic;

@end
