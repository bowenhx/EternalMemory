//
//  CycleScrollView.m
//  CycleScrollDemo
//
//  Created by Weever Lu on 12-6-14.
//  Copyright (c) 2012年 linkcity. All rights reserved.
//

#import "CycleScrollView.h"
#import "MD5.h"
#import "SavaData.h"
#import "MessageSQL.h"
#import "UIImage+UIImageExt.h"
#import "MyToast.h"

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGTH   [UIScreen mainScreen].bounds.size.height

#define Tag_ImageView                   100
#define Tag_ImageHolderScrollView       200



@implementation CycleScrollView
@synthesize delegate;
@synthesize imagePath = _imagePath;
@synthesize rootScrollView = _rootScrollView;

- (void)dealloc
{
    [_rootScrollView release];
    RELEASE_SAFELY(_images);
    RELEASE_SAFELY(_models);
    RELEASE_SAFELY(_downloadIndicatorView);
    [_downloadImageRequest clearDelegatesAndCancel];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame cycleDirection:(CycleDirection)direction pictures:(NSArray *)pictureArray andIndex:(NSInteger)index
{
    
    
    self.images = pictureArray;
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor blackColor];
        [self layoutRootScrollView:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        _rootScrollView.contentSize = CGSizeMake(320 * [pictureArray count], frame.size.height);
        _rootScrollView.contentOffset = CGPointMake(index * SCREEN_WIDTH, 0);
        _rootScrollView.showsHorizontalScrollIndicator = NO;
        _rootScrollView.showsVerticalScrollIndicator = NO;
        _rootScrollView.bounces = NO;
        _imgIdx = index;
        
        _rootScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        _downloadIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _downloadIndicatorView.center = self.center;
        _downloadIndicatorView.bounds = CGRectMake(0, 0, 30, 30);
        _downloadIndicatorView.hidesWhenStopped = YES;
        [self addSubview:_downloadIndicatorView];
        

        
        for (int i = 0 ; i < [pictureArray count]; i ++)
        {
            int holderX = i * SCREEN_WIDTH;
            _imageHolderScrollView = _imageHolderScrollView = [[ReviewImageScrollView alloc] initWithFrame:CGRectMake(holderX, 0, SCREEN_WIDTH, frame.size.height)];
            _imageHolderScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, frame.size.height);
            _imageHolderScrollView.backgroundColor = [UIColor blackColor];
            _imageHolderScrollView.tag = Tag_ImageHolderScrollView + i;
            _imageHolderScrollView.minimumZoomScale = 1;
            _imageHolderScrollView.maximumZoomScale = 3;
            [_rootScrollView addSubview:_imageHolderScrollView];
            [_imageHolderScrollView release];
            
            _imageHolderScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ;
//
            if ([pictureArray[i] isKindOfClass:[NSString class]] || [pictureArray[i] isKindOfClass:[NSURL class]])
            {
                //load web image
                if (index == i)
                {
                    if ([pictureArray[i] isKindOfClass:[NSString class]] && [pictureArray[i] hasPrefix:@"/var/"])
                    {
                        NSError *error = nil;
                        NSString *imagePath = self.images[_imgIdx];
                        NSURL *fileUrl = [NSURL fileURLWithPath:imagePath];
                        NSData *imageData = [NSData dataWithContentsOfURL:fileUrl options:NSDataReadingUncached error:&error];
                        if (error.code == 260) {
                            NSString *imageName = [[imagePath componentsSeparatedByString:@"/"] lastObject];
                            imagePath = [Utilities dataPath:imageName FileType:@"Photos" UserID:USERID];
                            imageData = [NSData dataWithContentsOfFile:imagePath];
                        }
                        UIImage *image = [UIImage imageWithData:imageData];

                        [_imageHolderScrollView.imageView setImage:image];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kImageLoadedNotification object:nil userInfo:nil];
                    }
                    else if ([pictureArray[i] isKindOfClass:[NSURL class]])
                    {
//                        UIImage *image = [self loadImageFromWebWithUrl:pictureArray[i]];
//                        [_imageHolderScrollView.imageView setImage:image];
                        NSString *imgName = [NSString stringWithFormat:@"img_%@.png",pictureArray[i]];
                        NSString *localImageName = [MD5 md5:imgName];
                        self.imagePath = [Utilities dataPath:localImageName FileType:@"Photos" UserID:USERID];

                        UIImage *image = [[UIImage imageWithContentsOfFile:_imagePath] fixOrientation];
                        if (image)
                        {
//                            UIImage *image = [UIImage imageWithData:image];
                            [_imageHolderScrollView.imageView setImage:image];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kImageLoadedNotification object:nil userInfo:nil];
                        }
                        else
                        {
                            _downloadImageRequest = [[ASIHTTPRequest alloc] initWithURL:pictureArray[i]];
                            [_downloadImageRequest setDownloadDestinationPath:_imagePath];
                            [_downloadImageRequest startAsynchronous];
                            [_downloadImageRequest setStartedBlock:^{
                                [_downloadIndicatorView startAnimating];
                                _isLoadingImage = YES;
                            }];
                            [_downloadImageRequest setCompletionBlock:^{
                                ReviewImageScrollView *scrollView = (ReviewImageScrollView *)[_rootScrollView viewWithTag:Tag_ImageHolderScrollView+i] ;
                                UIImage *image = [[UIImage imageWithContentsOfFile:self.imagePath] fixOrientation];
                                [scrollView.imageView setImage:image];
                                [_downloadIndicatorView stopAnimating];
                                [MessageSQL updataPathForImageURL:pictureArray[i] withPath:_imagePath WithUserID:USERID];
                                _isLoadingImage = NO;
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:kImageLoadedNotification object:nil userInfo:nil];
                            }];
                            [_downloadImageRequest setFailedBlock:^{
                                [_downloadIndicatorView stopAnimating];
                                [MyToast showWithText:@"图片加载失败" :100];
                            }];
                            
                            [_downloadImageRequest release];

                        }

                        if ([delegate respondsToSelector:@selector(cycleScrollViewDelegate:didScrollImageView:)]) {
                            [delegate cycleScrollViewDelegate:self didScrollImageView:index];
                        }
                    }
                    else
                    {
                        [_imageHolderScrollView.imageView setImage:[UIImage imageWithContentsOfFile:pictureArray[i]]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kImageLoadedNotification object:nil userInfo:nil];
                        
                    }
                    
//                    __block UIImageView *imageView = _imageHolderScrollView.imageView;
                    //                    [_imageHolderScrollView.imageView setImageWithURL:imgUrl success:^(UIImage *image) {
                    //                        [imageView sizeToFit];
                    //                        [imageView scaleToFit];
                    //                    } failure:^(NSError *error) {
                    //                    }];
                    
                }
            }
            else if ([pictureArray[i] isKindOfClass:[UIImage class]])
            {
                [_imageHolderScrollView.imageView setImage:pictureArray[i]];
            }
        }
        
        //        scrollFrame = frame;
        //        scrollDirection = direction;
        //        totalPage = pictureArray.count;
        //        curPage = index;                                    // 显示的是图片数组里的第一张图片
        //        curImages = [[NSMutableArray alloc] init];
        //        imagesArray = [[NSArray alloc] initWithArray:pictureArray];
        
        //        scrollView = [[UIScrollView alloc] initWithFrame:frame];
        //        scrollView.backgroundColor = [UIColor blackColor];
        //        scrollView.showsHorizontalScrollIndicator = NO;
        //        scrollView.showsVerticalScrollIndicator = NO;
        //        scrollView.pagingEnabled = YES;
        //        scrollView.delegate = self;
        //scrollView.bounces=NO;
        
        //        [self addSubview:scrollView];
        
        
        // 在水平方向滚动
        //        if(scrollDirection == CycleDirectionLandscape) {
        //            _rootScrollView.contentSize = CGSizeMake(320 * totalPage,
        //                                                _rootScrollView.frame.size.height);
        //        }
        // 在垂直方向滚动
        //        if(scrollDirection == CycleDirectionPortait) {
        //            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,
        //                                                scrollView.frame.size.height * 3);
        //        }
        
        //        [self refreshScrollView];
    }
    
    return self;
}


- (void)setProgress:(float)newProgress
{
    if (newProgress == 1)
    {
        ReviewImageScrollView *scrollView = (ReviewImageScrollView *)[_rootScrollView viewWithTag:Tag_ImageHolderScrollView+_imgIdx];
        NSData *data = [NSData dataWithContentsOfFile:_imagePath];
        UIImage *image = [UIImage imageWithData:data];
        [scrollView.imageView setImage:image];
        
        [_downloadIndicatorView stopAnimating];
        
    }
}

- (UIImage *)loadImageFromWebWithUrl:(NSURL *)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    NSString *imageName = [NSString stringWithFormat:@"img_%@",url];
    NSString *localImageName = [MD5 md5:imageName];
    
    NSString *fullPath = [Utilities dataPath:localImageName FileType:@"Photos" UserID:USERID];
    [data writeToFile:fullPath atomically:YES];
    return image;
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView != _rootScrollView) {
        return _imageView;
    }
    else
    {
        return  nil;
    }
    
    return nil;
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    _imageView.center = CGPointMake(160, 240);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    _imageView.center = CGPointMake(160, 240);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    if (_downloadIndicatorView.isAnimating)
    {
        [_downloadIndicatorView stopAnimating];
    }
    
    NSInteger screenWidth = (_interfaceOrientation == UIInterfaceOrientationPortrait ? 320 : (iPhone5 ? 568 : 480));
    
    _imgIdx = scrollView.contentOffset.x / screenWidth;
    
    if (_interfaceOrientation == UIInterfaceOrientationLandscapeRight || _interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        _imgIdx = scrollView.contentOffset.x / SCREEN_HEIGHT;
    }

    
    if ([delegate respondsToSelector:@selector(cycleScrollViewDelegate:didScrollImageView:)])
    {
        [delegate cycleScrollViewDelegate:self didScrollImageView:_imgIdx+1];
    }
    
    __block ReviewImageScrollView *rScrollView = (ReviewImageScrollView *)[_rootScrollView viewWithTag:Tag_ImageHolderScrollView + _imgIdx];
    if (!rScrollView.imageView.image)
    {
        if ([self.images[_imgIdx] isKindOfClass:[NSString class]] && [self.images[_imgIdx] hasPrefix:@"/var/"])
        {
            NSError *error = nil;
            NSString *imagePath = self.images[_imgIdx];
            NSURL *fileUrl = [NSURL fileURLWithPath:imagePath];
            NSData *imageData = [NSData dataWithContentsOfURL:fileUrl options:NSDataReadingUncached error:&error];
            if (error.code == 260) {
                NSString *imageName = [[imagePath componentsSeparatedByString:@"/"] lastObject];
                imagePath = [Utilities dataPath:imageName FileType:@"Photos" UserID:USERID];
                imageData = [NSData dataWithContentsOfFile:imagePath];
            }
            UIImage *image = [UIImage imageWithData:imageData];
            [rScrollView.imageView setImage:image];
            [[NSNotificationCenter defaultCenter] postNotificationName:kImageLoadedNotification object:nil userInfo:nil];
        }
        else if ([self.images[_imgIdx] isKindOfClass:[NSURL class]])
        {
            NSString *imgName = [NSString stringWithFormat:@"img_%@",self.images[_imgIdx]];
            NSString *localImageName = [MD5 md5:imgName];
            _imagePath = [Utilities dataPath:localImageName FileType:@"Photos" UserID:USERID];
//            NSData *data = [NSData dataWithContentsOfFile:_imagePath];
            UIImage *image = [UIImage imageWithContentsOfFile:_imagePath];
            [[NSNotificationCenter defaultCenter] postNotificationName:kImageLoadedNotification object:nil userInfo:nil];
            if (image) {
//                UIImage *image = [UIImage imageWithData:data];
                
                [rScrollView.imageView setImage:image];
                [[NSNotificationCenter defaultCenter] postNotificationName:kImageLoadedNotification object:nil userInfo:nil];
                image = nil;
            }
            else
            {
                __block typeof(self) bself = self;

                _downloadImageRequest = [[ASIHTTPRequest alloc] initWithURL:self.images[_imgIdx]];
                //            [_downloadImageRequest setDownloadProgressDelegate:self];
                [_downloadImageRequest setDownloadDestinationPath:_imagePath];
                [_downloadImageRequest startAsynchronous];
                [_downloadImageRequest setStartedBlock:^{
                    [_downloadIndicatorView startAnimating];
                    _isLoadingImage = YES;
                }];
                [_downloadImageRequest setCompletionBlock:^{
                    UIImage *image = [UIImage imageWithContentsOfFile:_imagePath];
                    [rScrollView.imageView setImage:image];
                    [_downloadIndicatorView stopAnimating];
                    _isLoadingImage = NO;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kImageLoadedNotification object:nil userInfo:nil];
                    
                    [MessageSQL updataPathForImageURL:bself.images[_imgIdx] withPath:_imagePath WithUserID:USERID];
                    
                }];
                
                [_downloadImageRequest setFailedBlock:^{
                    [_downloadIndicatorView stopAnimating];
                    [MyToast showWithText:@"图片加载失败" :100];
                }];
                
                [_downloadImageRequest release];
            }
                
        }
        else
        {
            [rScrollView.imageView setImage:[UIImage imageWithContentsOfFile:_images[_imgIdx]]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kImageLoadedNotification object:nil userInfo:nil];
        }
        
    }
    
    
    NSInteger endPosition_X = scrollView.contentOffset.x;
    //向右
    if (_startPosition_X < endPosition_X)
    {
        _imgIdx = _imgIdx - 1;
        ReviewImageScrollView *tempScrollView = (ReviewImageScrollView *)[_rootScrollView viewWithTag:Tag_ImageHolderScrollView + _imgIdx];
        [tempScrollView setZoomScale:1];
        
        ReviewImageScrollView *setNilScrollView = (ReviewImageScrollView *)[_rootScrollView viewWithTag:Tag_ImageHolderScrollView + _imgIdx - 1];
        [setNilScrollView.imageView setImage:nil];
    }
    //向左
    else if (_startPosition_X > endPosition_X)
    {
        _imgIdx = _imgIdx + 1;
        ReviewImageScrollView *tempScrollView = (ReviewImageScrollView *)[_rootScrollView viewWithTag:Tag_ImageHolderScrollView + _imgIdx];
        [tempScrollView.imageView setImage:nil];
        [tempScrollView setZoomScale:1];
        
        ReviewImageScrollView *setNilScrollView = (ReviewImageScrollView *)[_rootScrollView viewWithTag:Tag_ImageHolderScrollView + _imgIdx + 1];
        [setNilScrollView.imageView setImage:nil];
    }
    else
    {
        ;
    }
    
    
}
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    CGFloat pageWidth = scrollView.frame.size.width;
//    int page1 = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;//floor向下取整；
//    if ([delegate respondsToSelector:@selector(cycleScrollViewDelegate:didScrollImageView:)]) {
//        [delegate cycleScrollViewDelegate:self didScrollImageView:page1+1];
//    }
//}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _startPosition_X = scrollView.contentOffset.x;
}

/*- (void)refreshScrollView {
 
 NSArray *subViews = [scrollView subviews];
 if([subViews count] != 0) {
 [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
 }
 
 [self getDisplayImagesWithCurpage:curPage];
 for (int i = 0; i < 3; i++) {
 UIImageView *imageView = [[[UIImageView alloc] initWithFrame:scrollFrame] autorelease];
 imageView.userInteractionEnabled = YES;
 imageView.contentMode =  UIViewContentModeScaleAspectFit;
 imageView.image = [curImages objectAtIndex:i];
 
 UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
 action:@selector(handleTap:)];
 [imageView addGestureRecognizer:singleTap];
 [singleTap release];
 
 // 水平滚动
 if(scrollDirection == CycleDirectionLandscape) {
 imageView.frame = CGRectOffset(imageView.frame, scrollFrame.size.width * i, 0);
 }
 // 垂直滚动
 if(scrollDirection == CycleDirectionPortait) {
 imageView.frame = CGRectOffset(imageView.frame, 0, scrollFrame.size.height * i);
 }
 
 
 [scrollView addSubview:imageView];
 }
 if (scrollDirection == CycleDirectionLandscape) {
 [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0)];
 }
 if (scrollDirection == CycleDirectionPortait) {
 [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height)];
 }
 }
 
 - (NSArray *)getDisplayImagesWithCurpage:(int)page {
 int pre = [self validPageValue:curPage-1];
 int last = [self validPageValue:curPage+1];
 if([curImages count] != 0) [curImages removeAllObjects];
 
 [curImages addObject:[imagesArray objectAtIndex:pre-1]];
 [curImages addObject:[imagesArray objectAtIndex:curPage-1]];
 [curImages addObject:[imagesArray objectAtIndex:last-1]];
 
 return curImages;
 }
 
 - (int)validPageValue:(NSInteger)value {
 
 if(value == 0) value = totalPage;                   // value＝1为第一张，value = 0为前面一张
 if(value == totalPage + 1) value = 1;
 
 return value;
 }*/
- (void)layoutRootScrollView:(CGRect)frame
{
    
    _rootScrollView = [[UIScrollView alloc] initWithFrame:frame];
    _rootScrollView.backgroundColor = [UIColor clearColor];
    _rootScrollView.delegate = self;
    _rootScrollView.showsHorizontalScrollIndicator = YES;
    //_rootScrollView.showsVerticalScrollIndicator = YES;
    _rootScrollView.pagingEnabled = YES;
    [self addSubview:_rootScrollView];

    
}

/*- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
 
 int x = aScrollView.contentOffset.x;
 int y = aScrollView.contentOffset.y;
 // 水平滚动
 if(scrollDirection == CycleDirectionLandscape) {
 // 往下翻一张
 //        if(x >= (2*scrollFrame.size.width)) {
 //            curPage = [self validPageValue:curPage+1];
 //            [self refreshScrollView];
 //        }
 //        if(x <= 0) {
 //            curPage = [self validPageValue:curPage-1];
 //            [self refreshScrollView];
 //        }
 if (curPage==1&&totalPage==2) {
 curPage = 2;//[self validPageValue:curPage];
 [self refreshScrollView];
 }
 if (curPage!=totalPage) {
 if(x >= (2*scrollFrame.size.width)) {
 curPage = [self validPageValue:curPage+1];
 [self refreshScrollView];
 }
 }else if (curPage!=1) {
 if(x <= 0) {
 curPage = [self validPageValue:curPage-1];
 [self refreshScrollView];
 }
 }
 }
 
 // 垂直滚动
 //    if(scrollDirection == CycleDirectionPortait) {
 //        // 往下翻一张
 //        if(y >= 2 * (scrollFrame.size.height)) {
 //            curPage = [self validPageValue:curPage+1];
 //            [self refreshScrollView];
 //        }
 //        if(y <= 0) {
 //            curPage = [self validPageValue:curPage-1];
 //            [self refreshScrollView];
 //        }
 //    }
 
 if ([delegate respondsToSelector:@selector(cycleScrollViewDelegate:didScrollImageView:)]) {
 [delegate cycleScrollViewDelegate:self didScrollImageView:curPage];
 }
 }
 
 - (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
 if (scrollDirection == CycleDirectionLandscape) {
 if (curPage != totalPage+1&&curPage != 2) {
 [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0) animated:YES];
 }
 }
 if (scrollDirection == CycleDirectionPortait) {
 [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height) animated:YES];
 }
 }
 
 - (void)handleTap:(UITapGestureRecognizer *)tap {
 
 if ([delegate respondsToSelector:@selector(cycleScrollViewDelegate:didSelectImageView:)]) {
 [delegate cycleScrollViewDelegate:self didSelectImageView:curPage];
 }
 }*/



@end
