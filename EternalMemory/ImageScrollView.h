//
//  ImageScrollView.h
//  EternalMemory
//
//  Created by xiaoxiao on 3/10/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MessageModel;
@class ImageScrollView;
@protocol ImageScrollViewDelegate <NSObject>

@optional
- (void)singleTap:(ImageScrollView *)imageScrollView;

@end


@interface ImageScrollView : UIScrollView<UIScrollViewDelegate>
{
//    UIActivityIndicatorView     *_activityView;
    NSUInteger                   _index;
    BOOL                         _zoomEnable;
    BOOL                         _isSingleTap;
	BOOL                         _isDoubleTap;
    id<ImageScrollViewDelegate>  _imageScrollViewDelegate;

    
}
@property (nonatomic, assign) NSUInteger                    index;
@property (nonatomic, retain) __block UIImageView          *imageView;
@property (nonatomic, assign) id<ImageScrollViewDelegate>	imageScrollViewDelegate;


-(void)loadImageDate:(MessageModel *)model;
-(void)setMaxMinZoomScalesForCurrentBounds;

- (CGPoint) pointToCenterAfterRotation;
- (CGFloat) scaleToRestoreAfterRotation;
- (void) restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;

-(CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end
