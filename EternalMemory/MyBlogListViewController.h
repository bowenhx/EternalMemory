//
//  MyBlogListViewController.h
//  EternalMemory
//
//  Created by sun on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.

//日记列表界面

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "SelectListCategoriesViewController.h"
#import "EGORefreshTableHeaderView.h"
@interface MyBlogListViewController : CustomNavBarController <NavBarDelegate ,UITableViewDataSource, UITableViewDelegate,SelectListCategoriesDelegate,EGORefreshTableHeaderDelegate,UIAlertViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate,ASIHTTPRequestDelegate>

@property(nonatomic,retain)NSString *fromView;
@end
