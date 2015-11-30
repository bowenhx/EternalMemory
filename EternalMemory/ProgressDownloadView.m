//
//  ProgressDownloadView.m
//  EternalMemory
//
//  Created by xiaoxiao on 1/13/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "ProgressDownloadView.h"




@implementation ProgressDownloadView
@synthesize percentageLabel;
@synthesize controlButton;
@synthesize progressView;
@synthesize bgImageView;


- (void)dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 220, 30)];
        bgImageView.image = [UIImage imageNamed:@"offline_down_bg@2x"];
        bgImageView.userInteractionEnabled = YES;
        [self addSubview:bgImageView];
        [bgImageView release];
        
        progressView = [[DDProgressView alloc] initWithFrame:CGRectMake(2, 4, 120, 15)];
        [progressView setProgress:0.0f];
        [progressView setOuterColor: [UIColor clearColor]];
        [progressView setEmptyColor:[UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:1.0f]];
        [progressView setInnerColor: [UIColor colorWithRed:33.0f/255.0f green:121.0f/255.0f blue:208.0f/255.0f alpha:1.0f]];
        [self addSubview:progressView];
        [progressView release];
        
        percentageLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 4, 40, 20)];
        percentageLabel.textAlignment = NSTextAlignmentCenter;
        percentageLabel.backgroundColor = [UIColor clearColor];
        percentageLabel.font = [UIFont systemFontOfSize:12.0f];
        percentageLabel.text = @"0%";
        percentageLabel.textColor = [UIColor grayColor];
        [self addSubview:percentageLabel];
        [percentageLabel release];
        
        controlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        controlButton.frame = CGRectMake(160, 0, 60, 28);
        [controlButton setTitle:@"取消下载" forState:UIControlStateNormal];
        if (!(iOS7))
        {
            controlButton.titleLabel.font = [UIFont systemFontOfSize:11.0f];
        }
        else
        {
            controlButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        }
        [controlButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [controlButton addTarget:self action:@selector(cancelOfflineDownLoad:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:controlButton];
        
    }
    return self;
}

-(void)cancelOfflineDownLoad:(id)sender
{
    self.cancelDownload(percentageLabel.tag);
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
