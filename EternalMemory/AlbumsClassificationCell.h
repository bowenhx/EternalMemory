//
//  AlbumsClassificationCell.h
//  EternalMemory
//
//  Created by sun on 13-5-22.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiaryPictureClassificationModel.h"

@interface AlbumsClassificationCell : UITableViewCell
@property (nonatomic , retain) IBOutlet UIImageView *albumsImg;
@property (nonatomic , retain) IBOutlet UILabel *albumNameLb;
@property (nonatomic , retain) IBOutlet UIImageView *accessoryImg;
+(AlbumsClassificationCell *)viewForNib;
- (void)setData:(DiaryPictureClassificationModel *)groupModel;
@end
