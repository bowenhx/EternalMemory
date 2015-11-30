//
//  OffLineDownLoadCell.m
//  EternalMemory
//
//  Created by xiaoxiao on 12/6/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import "OffLineDownLoadCell.h"
@implementation OffLineDownLoadCell


@synthesize downlingNameLable = _downlingNameLable;
@synthesize percentageLabel   = _percentageLabel;
@synthesize separatorView     = _separatorView;
@synthesize cancelButton      = _cancelButton;
@synthesize reloadButton      = _reloadButton;
@synthesize progressView      = _progressView;
@synthesize waitingLoad       = _waitingLoad;
@synthesize nameLabel         = _nameLabel;
@synthesize Dismiss           = _Dismiss;
@synthesize Reload            = _Reload;


- (void)dealloc
{
    RELEASE_SAFELY(_downlingNameLable);
    RELEASE_SAFELY(_percentageLabel);
    RELEASE_SAFELY(_separatorView);
    RELEASE_SAFELY(_progressView);
    RELEASE_SAFELY(_nameLabel);
    [super dealloc];
}

-(UILabel *)percentageLabel
{
    if (_percentageLabel == nil)
    {
        _percentageLabel = [[UILabel alloc] initWithFrame:CGRectMake(102, 5, 33, 15)];
        _percentageLabel.textColor = [UIColor grayColor];
        _percentageLabel.backgroundColor = [UIColor clearColor];
        _percentageLabel.font = [UIFont systemFontOfSize:11.0f];
    }
    return _percentageLabel;
}

-(UILabel *)downlingNameLable
{
    if (_downlingNameLable == nil)
    {
        _downlingNameLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 95, 15)];
        _downlingNameLable.textColor = [UIColor grayColor];
        _downlingNameLable.backgroundColor = [UIColor clearColor];
        _downlingNameLable.font = [UIFont systemFontOfSize:13.0f];
    }
    return _downlingNameLable;
}
-(DDProgressView *)progressView
{
    if (_progressView == nil)
    {
        _progressView = [[DDProgressView alloc] initWithFrame:CGRectMake(3, 25, 130, 20)];
        [_progressView setOuterColor: [UIColor clearColor]] ;
        [_progressView setEmptyColor:[UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:1.0f]];
        [_progressView setInnerColor: [UIColor colorWithRed:33.0f/255.0f green:121.0f/255.0f blue:208.0f/255.0f alpha:1.0f]];
        [_progressView setProgress:0.0f];
    }
    return _progressView;
}

-(UILabel *)nameLabel
{
    if (_nameLabel == nil)
    {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, 130, 20)];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _nameLabel;
}

-(UIView *)separatorView
{
    if (_separatorView == nil)
    {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, 300, 1)];
        _separatorView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    }
    return _separatorView;
}
-(UIButton *)cancelButton
{
    if (_cancelButton == nil)
    {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(228, 11, 60, 30);
        [_cancelButton setTitle:@"忽略" forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"offline_but_@2x"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(dismissDownload:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(UIButton *)reloadButton
{
    if (_reloadButton == nil)
    {
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reloadButton.frame = CGRectMake(153, 11, 60, 30);
        [_reloadButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [_reloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_reloadButton setBackgroundImage:[UIImage imageNamed:@"offline_but_@2x"] forState:UIControlStateNormal];
        [_reloadButton addTarget:self action:@selector(reloadDownload:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadButton;
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addSubview:self.nameLabel];
        [self addSubview:self.cancelButton];
        [self addSubview:self.reloadButton];
        [self addSubview:self.separatorView];
        [self addSubview:self.progressView];
        [self addSubview:self.percentageLabel];
        [self addSubview:self.downlingNameLable];

        self.downlingNameLable.hidden = YES;
        self.progressView.hidden = YES;
    }
    return self;
}

-(void)dismissDownload:(id)sender
{
    self.Dismiss();
}

-(void)reloadDownload:(id)sender
{
    self.Reload();
}

-(void)setWaitingLoad:(int)waitingLoad
{
    _reloadButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    if (waitingLoad == 0)
    {
        [_reloadButton setTitle:@"重新下载" forState:UIControlStateNormal];
        self.nameLabel.hidden = NO;
        self.progressView.hidden = YES;
        self.downlingNameLable.hidden = YES;
        self.percentageLabel.hidden = YES;
        self.reloadButton.userInteractionEnabled = YES;

    }
    else  if (waitingLoad == 1)
    {
        [_reloadButton setTitle:@"等待中" forState:UIControlStateNormal];
        self.nameLabel.hidden = YES;
        self.progressView.hidden = NO;
        self.downlingNameLable.hidden = NO;
        self.percentageLabel.hidden = NO;
        self.reloadButton.userInteractionEnabled = NO;
    }
    else if (waitingLoad == 2)
    {
        [_reloadButton setTitle:@"重新下载完成" forState:UIControlStateNormal];
        self.nameLabel.hidden = YES;
        self.progressView.hidden = NO;
        self.downlingNameLable.hidden = NO;
        self.percentageLabel.hidden = NO;
        self.cancelButton.userInteractionEnabled = NO;
        self.reloadButton.userInteractionEnabled = NO;
    }
    else if (waitingLoad == 4)
    {
        _reloadButton.titleLabel.font = [UIFont systemFontOfSize:11.0f];
        [_reloadButton setTitle:@"重新下载中" forState:UIControlStateNormal];
        self.nameLabel.hidden = YES;
        self.progressView.hidden = NO;
        self.downlingNameLable.hidden = NO;
        self.percentageLabel.hidden = NO;
        self.cancelButton.userInteractionEnabled = YES;
        self.reloadButton.userInteractionEnabled = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
