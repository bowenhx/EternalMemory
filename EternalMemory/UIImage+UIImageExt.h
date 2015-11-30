//
//  UIImage+UIImageExt.h
//  PeopleBaseNetwork
//
//  Created by Liu Zhuang on 4/10/13.
//  Copyright (c) 2013 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(UIImageExt)

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (UIImage *)scalingImageByRatio;
- (UIImage *)fixOrientation;
- (UIImage *)compressedImage;
- (NSData *)compressedData:(CGFloat)compressionQuality;
- (CGFloat)compressionQuality;
- (NSData *)compressedData;
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)getImageFromImage;

- (UIImage *)normalizedImage;

@end
