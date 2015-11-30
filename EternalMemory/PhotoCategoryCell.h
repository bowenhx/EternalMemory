//
//  PhotoCategoryCell.h
//  EternalMemory
//
//  Created by FFF on 13-12-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FolderBtnPressedBlock)(void);

@interface PhotoCategoryCell : UITableViewCell

@property (nonatomic, assign) NSInteger photoCount;

@property (nonatomic, retain) IBOutlet UILabel *catagoryNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *photoCountLabel;

@property (nonatomic, copy) FolderBtnPressedBlock folderBtnPressedBlock;


@end
