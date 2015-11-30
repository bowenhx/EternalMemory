//
//  AlbumsTableViewCell.m
//  EternalMemory
//
//  Created by sun on 13-5-21.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "AlbumsTableViewCell.h"

@implementation AlbumsTableViewCell
@synthesize  addpictureBtn =_addpictureBtn;
@synthesize albumNameLb = _albumNameLb;
+(AlbumsTableViewCell *)viewForNib{
    UIViewController *cellController = [[UIViewController alloc] initWithNibName:@"AlbumsTableViewCell" bundle:nil];
    AlbumsTableViewCell *cell = (AlbumsTableViewCell *)cellController.view;
    [cellController release];
    return cell;
}
- (void)dealloc{
    RELEASE_SAFELY(_albumNameLb);
    RELEASE_SAFELY(_addpictureBtn);
    [super dealloc];
}
@end
