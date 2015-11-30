//
//  CreatePhotosCategoryViewController.h
//  EternalMemory
//
//  Created by sun on 13-5-22.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "NewPhotosCategoryCell.h"
#import "MBProgressHUD.h"
@interface CreatePhotosCategoryViewController : CustomNavBarController <NavBarDelegate,UITableViewDataSource, UITableViewDelegate,UITextViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate,UITextFieldDelegate>
{
}

@end
