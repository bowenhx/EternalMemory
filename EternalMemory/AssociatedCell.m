//
//  AssociatedCell.m
//  EternalMemory
//
//  Created by xiaoxiao on 1/13/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "AssociatedCell.h"

@implementation AssociatedCell
@synthesize downLoadButton = _downLoadButton;
@synthesize backImageView = _backImageView;
@synthesize relationLabel = _relationLabel;
@synthesize progressView = _progressView;
@synthesize waitingLoad = _waitingLoad;
@synthesize numberLabel = _numberLabel;
@synthesize nameLabel = _nameLabel;

-(UIImageView *)backImageView
{
    if (_backImageView == nil)
    {
        _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12.5, 20, 20)];
        _backImageView.image = [UIImage imageNamed:@"showNumber"];
    }
    [_backImageView addSubview:self.numberLabel];
    return _backImageView;
}

-(UILabel *)numberLabel
{
    if (_numberLabel == nil)
    {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textColor =  [UIColor colorWithRed:52.0f/255.0f green:130.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
    }
    return _numberLabel;
}

-(ProgressDownloadView *)progressView
{
    if (_progressView == nil)
    {
        _progressView = [[ProgressDownloadView alloc] initWithFrame:CGRectMake(90, 7.5, 220, 30)];
        _progressView.userInteractionEnabled = YES;
        _progressView.hidden = YES;
    }
    return _progressView;
}

-(UIButton *)downLoadButton
{
    if (_downLoadButton == nil)
    {
        _downLoadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _downLoadButton.frame = CGRectMake(230, 8.5, 80, 28);
        [_downLoadButton setTitle:@"点击下载" forState:UIControlStateNormal];
        [_downLoadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_downLoadButton setBackgroundImage:[UIImage imageNamed:@"flxz"] forState:UIControlStateNormal];
        _downLoadButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_downLoadButton addTarget:self action:@selector(downloadEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downLoadButton;
}

-(UILabel *)relationLabel
{
    if (_relationLabel == nil)
    {
        _relationLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 15.5, 130, 14)];
        _relationLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0f];
        _relationLabel.backgroundColor = [UIColor clearColor];
        _relationLabel.textColor = [UIColor grayColor];
    }
    return _relationLabel;
}

-(UILabel *)nameLabel
{
    if (_nameLabel == nil)
    {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(33, 12.5, 50, 20)];
        _nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor colorWithRed:52.0f/255.0f green:130.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
    }
    return _nameLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.nameLabel];
        [self addSubview:self.progressView];
        [self addSubview:self.relationLabel];
        [self addSubview:self.backImageView];
        [self addSubview:self.downLoadButton];
    }
    return self;
}

// 0 表示点击下载 1 表示取消下载 2 表示等待下载  3表示完成下载
-(void)setWaitingLoad:(NSInteger)waitingLoad
{
    BOOL progressHide = (waitingLoad == 1? NO : YES);
    self.progressView.hidden = progressHide;
    self.relationLabel.hidden = !progressHide;
    self.downLoadButton.hidden = !progressHide;
    if (waitingLoad == 0)
    {
        [self.downLoadButton setTitle:@"点击下载" forState:UIControlStateNormal];
    }
    else if (waitingLoad == 2)
    {
        [self.downLoadButton setTitle:@"等待下载" forState:UIControlStateNormal];
    }
    else if (waitingLoad == 3)
    {
        [self.downLoadButton setTitle:@"已完成" forState:UIControlStateNormal];
    }
}

-(void)downloadEvent:(id)sender
{
    self.downloadEvent(_nameLabel.tag);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    
    RELEASE_SAFELY(_progressView);
    RELEASE_SAFELY(_nameLabel);
    RELEASE_SAFELY(_relationLabel);
    RELEASE_SAFELY(_backImageView);
    RELEASE_SAFELY(_numberLabel);
    [super dealloc];
}

@end
