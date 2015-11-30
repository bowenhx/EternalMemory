//
//  MyAlbumClassifiedListingDetailsViewController.h
//  EternalMemory
//
BOOL fromPhotoList;
NSString *groupIdToSendTO;
//  Created by sun on 13-6-6.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoViewController.h"
#import "CustomNavBarController.h"
#import "PhotoAlbumsViewController.h"
#import "EditPhotoAlbumsViewController.h"
#import "ThumbImageButton.h"
#import "MyPhotoDetailsViewController.h"


@class ASIFormDataRequest;
@class DiaryPictureClassificationModel;

@protocol MyAlbumClassifiedListingDetailsDelegate;

@interface MyAlbumClassifiedListingDetailsViewController : CustomNavBarController <NavBarDelegate,PhotoViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,popToFrontView,MyPhotoDetailsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,popToFrontView>{
    
    __block NSString            *_groupId;
    __block ASIFormDataRequest  *_formRequest;
    
    NSString *_selectGroupInt;
    NSString *_selectGroupId;
}

@property (nonatomic, assign) NSInteger blogCount;       //该相册内有几张图片。
@property (nonatomic, retain) NSString  *selectGroupInt;
@property (nonatomic, retain) NSString  *selectGroupId;
@property (nonatomic, copy)   NSString  *groupId;

@property (nonatomic, retain) DiaryPictureClassificationModel *model;

@end

@protocol MyAlbumClassifiedListingDetailsDelegate
@optional
- (void)reloadPhotoes:(BOOL)isReloadPhotoes;

@end