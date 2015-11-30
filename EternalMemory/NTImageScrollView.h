//
//  NTImageScrollView.h
//  NTImageReviewer
//
//  Created by FFF on 13-12-25.
//  Copyright (c) 2013年 Liu Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTImageScrollView : UIScrollView
{
    UIImageView *_imageView;
}

@property (nonatomic, retain) UIImageView *imageView;

@end
