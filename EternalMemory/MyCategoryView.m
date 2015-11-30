//
//  MyCategoryView.m
//  BookShelf
//
//  Created by SuperAdmin on 13-11-7.
//  Copyright (c) 2013年 FoOTOo. All rights reserved.
//

#import "MyCategoryView.h"

@implementation MyCategoryView

@synthesize reuseIdentifier;
@synthesize edit  = _edit;
@synthesize index = _index;
@synthesize selected = _selected;
@synthesize delegate = _delegate;
@synthesize hideCategoryInfo = _hideCategoryInfo;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
//        [self addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClicked:)];
        [self addGestureRecognizer:tapGesture];
        
        
        //删除按钮
        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.hidden = YES;
        deleteButton.frame = CGRectMake(-20, -20, 40, 40);
        [deleteButton setImage:[UIImage imageNamed:@"del.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteCategory:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteButton];
        
        //分类名称
        nameTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 55, 50, 10)];
        nameTextView.delegate = self;
        nameTextView.text = @"分类名称";
//        nameTextView.textAlignment = UITextAlignmentCenter;
//        nameTextView.font = [UIFont systemFontOfSize:10.0f];
        nameTextView.userInteractionEnabled = NO;
        [self addSubview:nameTextView];
        
        //分类内容的个数
        numLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 65, 30, 10)];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.backgroundColor = [UIColor clearColor];
        numLabel.font = [UIFont systemFontOfSize:10.0f];
        numLabel.text = @"5个";
        [self addSubview:numLabel];
        
    }
    return self;
}


//书架第一个分类为添加分类功能 不显示分类内容
-(void)setHideCategoryInfo:(BOOL)hideCategoryInfo
{
    nameTextView.hidden = YES;
    numLabel.hidden = YES;
}

-(void)setEdit:(BOOL)edit
{
    if (edit)
    {
        deleteButton.hidden = NO;
        nameTextView.userInteractionEnabled = YES;
    }
    else
    {
        deleteButton.hidden = YES;
        nameTextView.userInteractionEnabled = NO;
    }
}

//- (void)setSelected:(BOOL)selected {
//    _selected = selected;
//    if (_selected) {
//        [_checkedImageView setHidden:NO];
//    }
//    else {
//    }
//}

-(void)deleteCategory:(id)sender
{
    [_delegate deleteCategoryAtIndex:_index];
}

- (void)buttonClicked:(id)sender {
    if (_index == 0)
    {
        [_delegate addNewCategory];
    }
    else
    {
        [_delegate showCategoryInfo];
    }
//    [self setSelected:_selected ? NO : YES];
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
