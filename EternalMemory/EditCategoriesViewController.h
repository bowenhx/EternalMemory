//
//  EditCategoriesViewController.h
//  EternalMemory
//
//  Created by sun on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "EditCategoriesCell.h"
@interface EditCategoriesViewController : CustomNavBarController <NavBarDelegate ,UITableViewDelegate, UITableViewDataSource,EditCategoriesCellDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    NSString                *_categoryName;
}

@property (nonatomic, copy)  NSString *categoryName;

@end
