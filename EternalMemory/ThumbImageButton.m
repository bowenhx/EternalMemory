//
//  ThumbImageButton.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-7-21.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "ThumbImageButton.h"

@implementation ThumbImageButton

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(frame.origin.x, frame.origin.y, 90, 90);
    self = [super initWithFrame:frame];
    if (self)
    {
        
        _placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
        _placeholderImageView.backgroundColor = [UIColor whiteColor];
        _placeholderImageView.clipsToBounds = YES;
        [_placeholderImageView setImage:[UIImage imageNamed:@"photo_mr.png"]];
        _placeholderImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_placeholderImageView];
        [_placeholderImageView release];
        
        _checkingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(90 - 18, 90 - 18, 18, 18)];
        _checkingImageView.backgroundColor = [UIColor clearColor];
        [_checkingImageView setImage:[UIImage imageNamed:@"bj_xz.png"]];
        _checkingImageView.hidden = YES;
        [self addSubview:_checkingImageView];
        [_checkingImageView release];
        
        
    }
    return self;
}

- (void)setIsChecked:(BOOL)isChecked
{
    _isChecked = isChecked;
    isChecked ? (_checkingImageView.hidden = NO) : (_checkingImageView.hidden = YES);
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

@implementation UIImage (Resize)

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image’s imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}
@end

