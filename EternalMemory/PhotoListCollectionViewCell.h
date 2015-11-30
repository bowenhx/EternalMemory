//
//  PhotoListCollectionViewCell.h
//  EternalMemory
//
//  Created by FFF on 13-12-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageModel;

@interface PhotoListCollectionViewCell : UICollectionViewCell

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) BOOL    editing;
@property (nonatomic, assign) BOOL    checked;
@property (nonatomic, assign, readonly) BOOL hasAudio;
@property (nonatomic, retain) UIImageView *imageView;

- (BOOL)configCellWithModel:(MessageModel *)model;

@end
