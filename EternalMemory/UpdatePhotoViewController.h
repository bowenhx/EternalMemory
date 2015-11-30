//
//  UpdatePhotoViewController.h
//  EternalMemory
//
//  Created by sun on 13-6-5.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "DiaryPictureClassificationModel.h"
#import "PhotoAlbumsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MessageModel.h"
#import "MBProgressHUD.h"

#define kPhotoDescriptionChangedNotification    @"kPhotoDescriptionChangedNotification"

extern NSString * const PhotoGroupChangedNotification;

@interface UpdatePhotoViewController : CustomNavBarController <NavBarDelegate,SelectPhotoCategoriesDelegate,UIAlertViewDelegate>
{
    MessageModel        *_blogmodel;
}
@property (nonatomic, retain)  MessageModel *blogmodel;
@property (nonatomic, copy)    NSString     *groupId;
@property (nonatomic, retain)  UIImage *sphotoImage;//原图
@property (nonatomic, retain)  UIImage *sphotoImg;//缩略图
@property (nonatomic, assign)  NSInteger selectedIndex;
@property (nonatomic, retain)  IBOutlet UIButton *uploadBtn;
@property (nonatomic, retain)  IBOutlet UILabel  *uploadLabel;
@property (nonatomic, retain)  NSString  * uploadLabelText;;
@end
