//
//  MylifeDetailViewController.h
//  EternalMemory
//
//  Created by xiaoxiao on 3/10/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "CustomNavBarController.h"
#import "ImageScrollView.h"
#import "EMAudio.h"
@class DiaryPictureClassificationModel;
@interface MylifeDetailViewController : UIViewController<UIScrollViewDelegate,ImageScrollViewDelegate,AVAudioPlayerDelegate>
{
    UIScrollView		*_pagingScrollView;
    NSMutableSet		*_recycledPages;
    NSMutableSet		*_visiblePages;
    NSMutableArray		*_imageData;
	NSInteger			_currentPage;
}

@property (nonatomic, retain) NSMutableArray	*imageData;
@property (nonatomic, retain) __block EMAudio   *audio;
@property (nonatomic, assign) NSInteger			currentPage;
//@property (nonatomic, retain) NSMutableArray    *albumArray;
//@property (nonatomic, assign) NSInteger          comeInStyle;

-(id)initWithDataArray:(NSMutableArray *)dataArray withPage:(NSInteger)pageIndex withModel:(DiaryPictureClassificationModel *)model comeInStyle:(NSInteger)style albumArray:(NSArray *)photoArray;

-(void)createView;

@end

