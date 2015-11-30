//
//  MemberIdentityCell.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-17.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MemberIdentityCell.h"

@implementation MemberIdentityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _checked = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
