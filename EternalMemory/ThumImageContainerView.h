//
//  ThumImageContainerView.h
//  AGImagePickerController Demo
//
//  Created by Liu Zhuang on 13-8-20.
//  Copyright (c) 2013年 Artur Grigor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DeleteImageAtIndexBlock)(NSUInteger);

@interface ThumImageContainerView : UIView<UIActionSheetDelegate>
{
    UIImageView         *_thumbnailImageView;
    NSMutableArray      *_thumbnailImages;
    
}

@property (nonatomic, retain) NSMutableArray  *thumbnailImages;
@property (nonatomic, retain) UIImageView     *thumbnailImageView;
@property (nonatomic, copy)   DeleteImageAtIndexBlock didDeleteImageAtIndexBlock;


- (void)setThumbnailImages:(NSMutableArray *)thumbnailImages;


@end
