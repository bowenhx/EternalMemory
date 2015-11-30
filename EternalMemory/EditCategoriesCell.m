//
//  EditCategoriesCell.m
//  EternalMemory
//
//  Created by sun on 13-6-1.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "EditCategoriesCell.h"
#import "RequestParams.h"
#define REQUEST_FOR_DELETGROUP 200
#define TEXTTYPE @"0"
@implementation EditCategoriesCell

@synthesize deleteBtn = _deleteBtn;
@synthesize titleTF = _titleTF;
@synthesize delegate = _delegate;
@synthesize deleteAble = _deleteAble;
- (void)dealloc{
    RELEASE_SAFELY(_deleteBtn);
    RELEASE_SAFELY(_titleTF);
    [super dealloc];
}

+(EditCategoriesCell *)viewForNib
{
    UIViewController *_cellController = [[UIViewController alloc] initWithNibName:@"EditCategoriesCell" bundle:nil];
    EditCategoriesCell *_cell = (EditCategoriesCell *)_cellController.view;
    [_cellController release];
    return _cell;
}
- (IBAction)onDeleteBtnClicked:(EditCategoriesCell *)cell
{
    [_delegate editCategories:_deleteBtn.btnIndex];
}

-(void)setDeleteAble:(BOOL)deleteAble
{
    self.deleteBtn.userInteractionEnabled = !deleteAble;
}

@end
