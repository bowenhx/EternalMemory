//
//  AlbumsTableViewCell.h
//  EternalMemory
//
//  Created by sun on 13-5-21.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumsTableViewCell : UITableViewCell

@property (nonatomic , retain) UIButton *addpictureBtn;
@property (nonatomic , retain) UILabel *albumNameLb;

+(AlbumsTableViewCell *)viewForNib;
@end
