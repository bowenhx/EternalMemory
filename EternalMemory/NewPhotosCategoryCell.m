//
//  NewPhotosCategoryCell.m
//  EternalMemory
//
//  Created by sun on 13-5-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "NewPhotosCategoryCell.h"

@implementation NewPhotosCategoryCell
@synthesize lable = _lable;
@synthesize textView = _textView;
@synthesize textViewText = _textViewText;

+(NewPhotosCategoryCell *)viewForNib
{
    UIViewController *_cellController = [[UIViewController alloc] initWithNibName:@"NewPhotosCategoryCell" bundle:nil];
    NewPhotosCategoryCell *_cell = (NewPhotosCategoryCell *)_cellController.view;
    [_cellController release];
    return _cell;
}

- (void)dealloc{
    RELEASE_SAFELY(_lable);
    RELEASE_SAFELY(_textView);
    RELEASE_SAFELY(_textViewText);
    [super dealloc];
}
@end
