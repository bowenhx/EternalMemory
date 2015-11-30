//
//  UploadingListCell.m
//  EternalMemory
//
//  Created by Guibing on 13-6-18.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "UploadingListCell.h"

@implementation UploadingListCell

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

- (void)dealloc {
    [_labTitle release];
    [_labNum release];
    [_progress release];
    [_delectBut release];
    [_labStopDown release];
    [_resumeButton release];
    [super dealloc];
}
- (IBAction)stopOrResumeUpload:(id)sender {
    self.StopOrResume(YES,self.resumeButton.tag);
}

- (IBAction)removeUploadFile:(id)sender {
    self.removeUpLoadFile(_resumeButton.tag);
}
@end
