//
//  MyBlogListCell.h
//  EternalMemory
//
//  Created by sun on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiaryMessageModel.h"
@interface MyBlogListCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UILabel *dateLb;
@property (nonatomic, retain) IBOutlet UILabel *titleLb;
@property (nonatomic, retain) IBOutlet UITextView *bodyTextView;
@property (nonatomic, retain) IBOutlet UIImageView *m_checkImageView;
@property (nonatomic, assign) BOOL          m_checked;
@property (nonatomic, retain) IBOutlet UIView *line;

+(MyBlogListCell *)viewForNib;
- (void)setData:(DiaryMessageModel *)model;
- (void)setChecked:(BOOL)checked;
@end
