//
//  ThumImageContainerView.m
//  AGImagePickerController Demo
//
//  Created by Liu Zhuang on 13-8-20.
//  Copyright (c) 2013年 Artur Grigor. All rights reserved.
//

#import "ThumImageContainerView.h"
#import "AGImagePickerController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

#define Image_Width     66
#define Image_Height    66
#define Image_OFFSET    12

@implementation ThumImageContainerView

- (void)dealloc
{
    [_thumbnailImages release];
    [_thumbnailImageView release];
    Block_release(_didDeleteImageAtIndexBlock);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _thumbnailImages = [[NSMutableArray alloc] initWithCapacity:0];

    }
    return self;
}

- (void)setThumbnailImages:(NSMutableArray *)thumbnailImages
{
    if (_thumbnailImages != thumbnailImages) {
        [_thumbnailImages removeAllObjects];
        [_thumbnailImages addObjectsFromArray:thumbnailImages];
    }
    
    if ([self subviews].count > 0) {
        for (UIView *aView in [self subviews]) {
            [aView removeFromSuperview];
        }
    }
    
    if (_thumbnailImages.count > 0 && [_thumbnailImages[0] isKindOfClass:[ALAsset class]]) {
         _thumbnailImages = [[NSMutableArray arrayWithArray:[self getImagesFromAssets:thumbnailImages]] retain];
    }
    
    int imageCount = _thumbnailImages.count;
    int rowCount = 0;
    (imageCount % 3 > 0) ? (rowCount = imageCount / 3 + 1) : (rowCount = imageCount / 3);
    
    UIImageView *imageView = nil;
    for (int i = 0 ; i < imageCount; i ++)
    {
        int row = i / 4;
        int colonm = i % 4;
        int x = 10 + colonm * (Image_Width + Image_OFFSET);
        int y = 10 + row * (Image_Height + Image_OFFSET);
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, Image_Width, Image_Height)];
        imageView.userInteractionEnabled = YES;
        imageView.layer.cornerRadius = 5;
        imageView.clipsToBounds = YES;
        imageView.tag = i + 100;
        [imageView setImage:_thumbnailImages[i]];
        [self addSubview:imageView];
        [imageView release];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDeleteImage:)];
        [imageView addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
    
    int viewHeight = rowCount * Image_Height + 20 + ((rowCount - 1) * Image_OFFSET);
    CGRect rect = self.frame;
    (viewHeight < Image_Height + 20) ? (rect.size.height = Image_Height + 20) : (rect.size.height = viewHeight);
    self.frame = rect;

}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

- (void)tapDeleteImage:(UITapGestureRecognizer *)tapGesture
{
    UIImageView *aImageView = (UIImageView *)tapGesture.view;
    int index = aImageView.tag - 100;
    
    [_thumbnailImages removeObjectAtIndex:index];
    [self setThumbnailImages:_thumbnailImages];
    
    if (_didDeleteImageAtIndexBlock) {
        _didDeleteImageAtIndexBlock(index);
    }
}

- (NSArray *)getImagesFromAssets:(NSArray *)assets
{
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *assetsArr = [[NSMutableArray arrayWithArray:assets] retain];
    for (ALAsset *aAsset in assetsArr) {
        CGImageRef imageRef = [aAsset thumbnail];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [images addObject:image];
    }
    
    [assetsArr release];
    return [images autorelease];
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
