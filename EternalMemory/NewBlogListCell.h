//
//  NewBlogListCell.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiaryMessageModel;

@interface NewBlogListCell : UITableViewCell

@property (nonatomic, retain)DiaryMessageModel *model;
@property (nonatomic, assign) BOOL          m_checked;

- (void)configCellWithModel:(DiaryMessageModel *)model;
- (void)setIsEditing:(BOOL)isEditing;
- (void)setChecked:(BOOL)checked;


@end
