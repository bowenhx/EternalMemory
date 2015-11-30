//
//  PhotoCategoryCell.m
//  EternalMemory
//
//  Created by FFF on 13-12-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "PhotoCategoryCell.h"

@import QuartzCore;

@interface PhotoCategoryCell ()

@property (nonatomic, copy) NSString *photoCountStr;

- (IBAction)folderBtnPressed:(id)sender;

@end

@implementation PhotoCategoryCell

- (void)dealloc
{
    [_catagoryNameLabel release];
    [_photoCountLabel   release];
    [_photoCountStr     release];
    
    [_folderBtnPressedBlock release];
    [super dealloc];
}

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setPhotoCount:(NSInteger )photoCount
{
    _photoCount = photoCount;
    _photoCountLabel.text = [NSString stringWithFormat:@"共%d张",_photoCount];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)folderBtnPressed:(id)sender
{
    if (_folderBtnPressedBlock) {
        _folderBtnPressedBlock();
    }
}

@end
