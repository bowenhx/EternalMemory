//
//  EMPhotoAlbumCollectionCell.h
//  EternalMemory
//
//  Created by FFF on 14-3-10.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiaryPictureClassificationModel;

@interface EMPhotoAlbumCollectionCell : UICollectionViewCell

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, copy)   NSString *title;

- (void)configCellWithDiaryModel:(DiaryPictureClassificationModel *)model;

@end
