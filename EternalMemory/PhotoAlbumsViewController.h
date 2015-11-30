//
//  PhotoAlbumsViewController.h
//  EternalMemory
//
//  Created by sun on 13-5-21.
//  Copyright (c) 2013年 sun. All rights reserved.
//




#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "DiaryPictureClassificationModel.h"
#import "MyAlbumClassifiedListingDetailsViewController.h"

#define kChangePhotoGroupNotification      @"kChangePhotoGroupNotification"

@class MyAlbumClassifiedListingDetailsViewController;
@protocol SelectPhotoCategoriesDelegate
@optional
- (void)selectedIndex:(NSInteger)selectedIndex;
@end


@interface PhotoAlbumsViewController : CustomNavBarController <NavBarDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ASIHTTPRequestDelegate>
{
     NSObject<SelectPhotoCategoriesDelegate> *_selectListCategoriesDelegate;
    ASIFormDataRequest *_formReq;

}
@property (nonatomic, assign) NSObject<SelectPhotoCategoriesDelegate>*selectListCategoriesDelegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) ASIFormDataRequest *formReq;

@property(nonatomic,copy)NSString *fromView;
@property (nonatomic, assign) BOOL isSeletedStyle;
@end
