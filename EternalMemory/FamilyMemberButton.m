//
//  FamilyMemberButton.m
//  EternalMemory
//
//  Created by kiri on 13-9-16.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "FamilyMemberButton.h"

@implementation FamilyMemberButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [UIColor cyanColor];
        _headerImg = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 2.5, 35, 35)];
        _headerImg.backgroundColor = [UIColor clearColor];
        [self addSubview:_headerImg];
        [_headerImg release];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 5, 53, 15)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:14.0f];
        _nameLabel.text = @"";
        [self addSubview:_nameLabel];
        [_nameLabel release];
        
        _birthLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 20, 53, 15)];
        _birthLabel.backgroundColor = [UIColor clearColor];
        _birthLabel.textAlignment = NSTextAlignmentLeft;
        _birthLabel.font = [UIFont systemFontOfSize:9.0f];
        _birthLabel.text = @"";
        [self addSubview:_birthLabel];
        [_birthLabel release];        
    }
    return self;
}

-(void)addGuanlian{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 12, -3.5, 13, 13)];
    imageView.image = [UIImage imageNamed:@"guanlian"];
    [self addSubview:imageView];
    [imageView release];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
