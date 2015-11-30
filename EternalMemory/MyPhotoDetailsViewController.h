//
//  MyPhotoDetailsViewController.h
//  EternalMemory
//
//  Created by sun on 13-6-7.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "CycleScrollView.h"

@class MessageModel;
@protocol MyPhotoDetailsDelegate;
@interface MyPhotoDetailsViewController : CustomNavBarController <NavBarDelegate,CycleScrollViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
     NSString       *_selectGroupInt;
     NSString       *_groupId;
    
     NSObject<MyPhotoDetailsDelegate> *_myPhotoDetailsDelegate;
}
@property (nonatomic, copy)   NSString           *selectGroupInt;
@property (nonatomic, assign) NSInteger          selectPhotoIndex;
@property (nonatomic, retain) NSMutableArray     *blogs;
@property (nonatomic, copy)   NSString           *groupId;
@property (nonatomic, assign) BOOL               shouldRightButtonHidden;
@property (nonatomic, retain) NSString           *comeFrom;
@property (nonatomic, assign) NSObject<MyPhotoDetailsDelegate> *myPhotoDetailsDelegate;
@property (nonatomic, retain)MessageModel *currentMessageModel;

@property (nonatomic, assign) BOOL hideRecordButtonForNoAudio;

- (void)reloadScrollView;

@end

@protocol MyPhotoDetailsDelegate
@optional
- (void)reloadPhotoes:(BOOL)isReloadPhotoes;
-(void)my_emit_message;
@end