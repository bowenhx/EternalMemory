//
//  EMPhotoAlbumTopView.h
//  EternalMemory
//
//  Created by FFF on 14-3-10.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMPhotoAlbumViewItem.h"
@class DiaryPictureClassificationModel,MessageModel;

static NSString * const kChildhoodItem;
static NSString * const kYongsterItem;
static NSString * const kYouthItem;
static NSString * const kMiddleAgedItem;
static NSString * const kElderAgedItem;


typedef void(^EMPhotoItemSelectBlock)(NSArray *items, DiaryPictureClassificationModel *model, NSInteger idx);
typedef void(^EMPhotoItemDeleteBlock)(NSInteger idx);

@interface EMPhotoAlbumTopView : UIView

//一生回忆中照片的数量
@property (nonatomic, assign) NSInteger itemCount;
//编辑模式
@property (nonatomic, assign) BOOL      editMode;
@property (nonatomic, retain) NSArray *templateImage;
@property (nonatomic, retain) NSArray *templateModels;

//一生回忆中的全部照片，保存在EMPhotoAlbumViewItem中
@property (nonatomic, readonly) NSArray *photoItems;
@property (nonatomic, readonly) NSArray *photos;
@property (nonatomic, retain)   DiaryPictureClassificationModel *diaryModel;

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, copy) EMPhotoItemDeleteBlock deleteBlock;

/**
 *  获得指定位置的照片
 *
 *  @param position 指定位置，详见EMPhotoAlbumViewItem.h
 *
 *  @return 指定位置的照片
 */
- (EMPhotoAlbumViewItem *)itemAtPosition:(ItemPosition)position;


- (void)setPhotos:(NSArray *)photos;

- (void)removeItemAtPosition:(ItemPosition)position;
- (void)setImage:(UIImage *)image ForPosition:(ItemPosition)position;
- (void)setTemplateImage:(UIImage *)image forPosition:(ItemPosition)position;
- (void)setPhoto:(MessageModel *)model atPosition:(ItemPosition)position;
- (void)setSelectBlock:(EMPhotoItemSelectBlock)selectBlock;
@end
