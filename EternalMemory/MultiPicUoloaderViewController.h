//
//  MultiPicUoloaderViewController.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-8-20.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "ThumImageContainerView.h"
#import "MultiPicEditView.h"

#define kNewPhotoAddedNotification          @"kNewPhotoAddedNotification"

typedef void(^UploadDidBeginBlock)(NSString *, NSString *);

@class DiaryPictureClassificationModel;
@interface MultiPicUoloaderViewController : CustomNavBarController<UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>
{
    NSMutableArray          *_assets;
    NSMutableArray          *_thumbnails;
    
    BOOL                    _choseGroupButtonHidden;
    
    ThumImageContainerView  *_containerView;
    MultiPicEditView        *_mutiPicEditView;
    
}

@property (nonatomic, retain) MultiPicEditView *mutiPicEditView;

@property (nonatomic, copy)   UploadDidBeginBlock       uploadDidBeginBlock;
@property (nonatomic, retain) NSMutableArray            *assets;
@property (nonatomic, retain) NSMutableArray            *thumbnails;
@property (nonatomic, copy)   NSString          *chosenPhotoGroupID;
@property (nonatomic, copy)   NSString          *blogCountForGroup;
@property (nonatomic, copy)   NSString          *selectGroupInt;
@property (nonatomic, copy)   NSString          *photoDesStr;

- (id)initWithImageFromAssets:(NSArray *)assets;

- (void)setChoseButtonHidden:(BOOL)flag;

@end
