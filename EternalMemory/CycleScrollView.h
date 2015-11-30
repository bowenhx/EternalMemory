//
//  CycleScrollView.h
//  CycleScrollDemo
//
//  Created by Weever Lu on 12-6-14.
//  Copyright (c) 2012年 linkcity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReviewImageScrollView.h"

#define kImageLoadedNotification                    @"kImageLoadedNotification"

typedef enum {
    CycleDirectionPortait,          // 垂直滚动
    CycleDirectionLandscape         // 水平滚动
}CycleDirection;

@protocol CycleScrollViewDelegate;

@interface CycleScrollView : UIView <UIScrollViewDelegate> {
    
    UIScrollView *_rootScrollView;
    UIImageView *curImageView;
    
    int totalPage;
    int curPage;
    
    ASIHTTPRequest          *_downloadImageRequest;
    
    CGRect                  scrollFrame;
    NSString                *_imagePath;
    UIImageView             *_imageView;
    UIActivityIndicatorView *_downloadIndicatorView;
    NSInteger               _startPosition_X;

    id delegate;
    
    __block ReviewImageScrollView   *_imageHolderScrollView;
    __block NSInteger               _imgIdx;
    __block BOOL                    _isLoadingImage;
    
}
@property (nonatomic, assign) BOOL        isLoadingImage;
@property (nonatomic, assign) id          delegate;
@property (nonatomic, assign) NSInteger   imgIdx;
@property (nonatomic, copy)   NSArray   *images;
@property (nonatomic, copy)   NSArray   *models;
@property (nonatomic, copy)   NSString  *imagePath;
@property (nonatomic, retain) UIScrollView *rootScrollView;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

//- (int)validPageValue:(NSInteger)value;
- (id)initWithFrame:(CGRect)frame cycleDirection:(CycleDirection)direction pictures:(NSArray *)pictureArray andIndex:(NSInteger)index;
//- (NSArray *)getDisplayImagesWithCurpage:(int)page;
//- (void)refreshScrollView;

@end

@protocol CycleScrollViewDelegate <NSObject>
@optional
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didSelectImageView:(int)index;
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didScrollImageView:(int)index;

@end

@interface UIImageView (ReviewBigImage)

- (CGRect)scaleToFit;

@end