//
//  EditPhotoAlbumsViewController.h
//  EternalMemory
//
//  Created by sun on 13-6-6.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "NewPhotosCategoryCell.h"

@protocol popToFrontView <NSObject>

@optional
-(void)popToPhotoAlbumVC;
-(void)reloadPhotoes1:(BOOL)isReloadPhotoes;
@end

@interface EditPhotoAlbumsViewController : CustomNavBarController <NavBarDelegate,UITableViewDataSource, UITableViewDelegate,UITextViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIScrollViewDelegate>
{
    NSString *_selectGroupInt;
    UITextField *_titleTextField;
}
@property (nonatomic, retain)NSString *selectGroupInt;
@property (nonatomic, assign)id<popToFrontView>editDelegate;
@end
