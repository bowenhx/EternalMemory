//
//  PhotoListViewController.h
//  EternalMemory
//
//  Created by FFF on 13-12-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//


#import "CustomNavBarController.h"
@class DiaryPictureClassificationModel;

extern NSString * const PhotoListHasChangedNotification;
//相册下面列表类
@interface PhotoListViewController : CustomNavBarController<UICollectionViewDelegate, UICollectionViewDataSource>
{
    UICollectionView *_collectionView;
}

@property (nonatomic,readonly) UICollectionView *collectionView;
//TODO: 加载指定相册的图片。
- (instancetype)initWithAlbumID:(NSString *)groupID;
- (instancetype)initWithDiaryModel:(DiaryPictureClassificationModel *)diaryModel;


@end
