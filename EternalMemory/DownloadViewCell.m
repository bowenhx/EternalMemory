//
//  DownloadViewCell.m
//  EternalMemory
//
//  Created by Guibing on 06/09/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DownloadViewCell.h"

@implementation DownloadViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initWithDownloadView];
    }
    return self;
}

- (void)initWithDownloadView
{
    [self.downloadBut setImage:[UIImage imageNamed:@"download_list"] forState:UIControlStateNormal];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_fileName release];
    [_fileNum release];
    [_imageVideo release];
    [_labStopDown release];
    [_downloadBut release];
    [_delectBut release];
    [super dealloc];
}
@end
