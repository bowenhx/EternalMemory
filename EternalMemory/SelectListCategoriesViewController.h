//
//  SelectListCategoriesViewController.h
//  EternalMemory
//
//  Created by sun on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.

//撰记分类页面

#import "CustomNavBarController.h"
#import "DiaryGroupsModel.h"
#import <UIKit/UIKit.h>
@protocol SelectListCategoriesDelegate;
@interface SelectListCategoriesViewController :CustomNavBarController <NavBarDelegate ,UITableViewDelegate, UITableViewDataSource,ASIHTTPRequestDelegate>
{
    NSObject<SelectListCategoriesDelegate> *_selectListCategoriesDelegate;
    
}
@property (nonatomic, assign) NSObject<SelectListCategoriesDelegate> *selectListCategoriesDelegate;
@property (nonatomic, assign) NSInteger currentIndex;
@end
@protocol SelectListCategoriesDelegate
- (void)EditCategories:(BOOL)isEditGroup selectedGroup:(DiaryGroupsModel *)Model selectedIndex:(NSInteger)selectedIndex;

@end
