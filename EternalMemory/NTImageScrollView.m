//
//  NTImageScrollView.m
//  NTImageReviewer
//
//  Created by FFF on 13-12-25.
//  Copyright (c) 2013年 Liu Zhuang. All rights reserved.
//

#import "NTImageScrollView.h"

@implementation NTImageScrollView

@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupImageView];

    }
    return self;
}

- (void)setupImageView
{
    
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;

        [self addSubview:_imageView];
        [_imageView release];
        
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        
    }
}

- (void)dealloc
{
    [super dealloc];
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
