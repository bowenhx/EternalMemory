//
//  EMPhotoAlbumViewItem.h
//  EternalMemory
//
//  Created by FFF on 14-3-10.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EMMemorizeMessageModel;

/**
 *  照片位置
 */
typedef NS_ENUM(NSInteger, ItemPosition) {
    /**
     *  童年
     */
    ItemPositionChildhood = 0,
    /**
     *  少年
     */
    ItemPositionYongster,
    /**
     *  青年
     */
    ItemPositionYouth,
    /**
     *  中年
     */
    ItemPositionMiddleAged,
    /**
     *  老年
     */
    ItemPositionElder
};

@interface EMPhotoAlbumViewItem : UIView

@property (nonatomic, assign) ItemPosition  itemPosition;
@property (nonatomic, retain) UIImage       *image;
@property (nonatomic, retain) UIImage       *templateImage;
@property (nonatomic, retain) EMMemorizeMessageModel *model;
@property (nonatomic, assign) BOOL          showDeleteIcon;

@property (nonatomic, readonly) CGSize      itemImageSize;

@end
