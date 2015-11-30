//
//  MusicViewCell.m
//  EternalMemory
//
//  Created by Guibing Li on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MusicViewCell.h"

@implementation MusicViewCell
{
    NSInteger indexDelect;
}
@synthesize delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = RGBCOLOR(238, 242, 245);
        indexDelect = 100;
        
        _playImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 22, 22)];
        [_playImage setImage:[UIImage imageNamed:@"play_but"]];
        [self addSubview:_playImage];
        
        _musicName = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, self.bounds.size.width-50-15, 20)];
        _musicName.backgroundColor = [UIColor clearColor];
        _musicName.font = [UIFont systemFontOfSize:14];
        [self addSubview:_musicName];
        
//        _progressV = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
//        _progressV.frame = CGRectMake(120, 15, 100, 10);
//        _progressV.trackTintColor = [UIColor blueColor];
//        [self addSubview:_progressV];
//        [_progressV release];
        
        _playTime = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, self.bounds.size.width-50-15, 20)];
        _playTime.backgroundColor = [UIColor clearColor];
        _playTime.font = [UIFont systemFontOfSize:12];
        [self addSubview:_playTime];
        
        _deleteBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBut.frame = CGRectMake(self.frame.size.width-51, 0, 50, 50);
        [_deleteBut setImage:[UIImage imageNamed:@"public_delete"] forState:UIControlStateNormal];
        [_deleteBut addTarget:self action:@selector(touchDeleteBut:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteBut];
        
        
//        _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        _activityIndicatorView.frame = CGRectMake(115, 15, 20, 20);
//        [_activityIndicatorView startAnimating];
//        [self addSubview:_activityIndicatorView];
        
    }
    return self;
}
- (void)playMusic:(UIButton *)selectBut
{
    [delegate didPlayMusicBut:self];
}
- (void)touchDeleteBut:(UIButton *)but
{
    [delegate didDeleteActionSheetBut:but.tag];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
-(void)dealloc
{
    [_musicName release];
    [_playImage release];
    [_playTime release];
//    [_activityIndicatorView release];
    [super dealloc];
}

@end
