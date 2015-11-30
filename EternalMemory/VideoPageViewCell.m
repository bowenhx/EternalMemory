//
//  VideoPageViewCell.m
//  EternalMemory
//
//  Created by Guibing on 13-6-5.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "VideoPageViewCell.h"

@implementation VideoPageViewCell
{
    int index;
}
@synthesize delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        index = 500;
        self.backgroundColor = RGBCOLOR(238, 242, 245);
        [self shouVideoPageView];
    }
    return self;
}
- (void)shouVideoPageView
{
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(15, 15, self.frame.size.width-30, 110)];
    viewBg.backgroundColor = [UIColor whiteColor];
    viewBg.layer.borderWidth = 1;
    viewBg.layer.cornerRadius = 3;
    viewBg.layer.borderColor = RGBCOLOR(208, 211, 209).CGColor;
    
    _labText = [[UILabel alloc] initWithFrame:CGRectMake(105, 5, self.frame.size.width-135, 55)];
    _labText.backgroundColor = [UIColor clearColor];
    _labText.numberOfLines = 0;
    [_labText setFont:[UIFont fontWithName:@"helvetica" size:14]];
    
    
    _labTextNum = [[UILabel alloc] initWithFrame:CGRectMake(105, 65, 60, 20)];
    _labTextNum.font = [UIFont systemFontOfSize:12];
    _labTextNum.backgroundColor = [UIColor clearColor];
    
    
    [viewBg addSubview:_labText];
    [viewBg addSubview:_labTextNum];

    
    _imageThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(10,16,83, 78)];
    _imageThumbnail.image = [UIImage imageNamed:@"video_play_list"];
    [viewBg addSubview:_imageThumbnail];
    
    [self addSubview:viewBg];
    
    _deleteBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBut.frame = CGRectMake(self.frame.size.width-62, viewBg.frame.size.height-38, 60, 60);
    [_deleteBut setImage:[UIImage imageNamed:@"video_file_delete"] forState:UIControlStateNormal];
    [_deleteBut addTarget:self action:@selector(touchDeleteBut:) forControlEvents:UIControlEventTouchUpInside];
    //_deleteBut.layer.borderWidth = 1;
    //_deleteBut.layer.borderColor = [UIColor redColor].CGColor;
    [self addSubview:_deleteBut];
    
    /*_downloadBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _downloadBut.frame = CGRectMake(self.frame.size.width-47, 50, 38, 33);
    [_downloadBut setBackgroundImage:[UIImage imageNamed:@"video_downlod"] forState:UIControlStateNormal];
    [_downloadBut addTarget:self action:@selector(selectDownloadVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_downloadBut];*/
    
    
    [viewBg release];
}
- (void)touchDeleteBut:(UIButton *)but
{
//    if (but.tag !=index) {
    
    [delegate didDeleteVideoSheetBut:but.tag];
//    }else{
//        but.tag--;
//        [delegate didDeleteVideoSheetBut:but.tag];
//    }
//    index = but.tag;
    
//    but.enabled = NO;
}
- (void)selectDownloadVideo:(UIButton *)but
{
    [delegate didSelectDownloadingVideo:_deleteBut.tag isHint:YES];
    but.enabled = NO;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)dealloc
{
    [_labText release];
    [_imageThumbnail release];
    [_labTextNum release];
    [super dealloc];
}

@end
