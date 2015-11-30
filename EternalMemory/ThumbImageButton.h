//
//  ThumbImageButton.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-7-21.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbImageButton : UIButton
{
    UIImageView             *_placeholderImageView;
    UIImageView             *_checkingImageView;
}

@property (nonatomic, retain) UIImageView   *placeholderImageView;
@property (nonatomic        ) BOOL          isChecked;

@end


@interface UIImage (Resize)
- (UIImage *)croppedImage:(CGRect)bounds;
@end

