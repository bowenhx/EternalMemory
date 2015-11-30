//
//  MoreViewCtrl.m
//  EternalMemory
//
//  Created by Guibing Li on 13-5-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomNavBarController.h"


@interface BaseTableController : CustomNavBarController <UITableViewDataSource,UITableViewDelegate ,NavBarDelegate>

@property (nonatomic , retain)UITableView *myTableView;
@property (nonatomic , retain)NSMutableArray *myDatasArr;
@property (nonatomic , assign)UITableViewStyle myTableViewStype;

@end