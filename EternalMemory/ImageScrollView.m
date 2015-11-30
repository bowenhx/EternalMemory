//
//  ImageScrollView.m
//  EternalMemory
//
//  Created by xiaoxiao on 3/10/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "ImageScrollView.h"
#import "MessageModel.h"
#import "StaticTools.h"
#import "Utilities.h"
#import "Config.h"
#import "MD5.h"
@implementation ImageScrollView

@synthesize index                   = _index;
@synthesize imageView               = _imageView;
@synthesize imageScrollViewDelegate	= _imageScrollViewDelegate;

- (void)dealloc
{
    RELEASE_SAFELY(_imageView);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.alwaysBounceVertical = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   	UITouch *touch = [touches anyObject];
	if ([touch tapCount] == 1)
	{
		_isSingleTap = YES;
	}
	else if ([touch tapCount] == 2)
	{
		_isDoubleTap = YES;
	}
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
	if ([touch tapCount] == 1)
	{
		_isSingleTap = NO;
	}
	else if ([touch tapCount] == 2)
	{
		_isDoubleTap = NO;
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([touch tapCount] == 1)
    {
        if (_isSingleTap)
        {
			[self performSelector:@selector(performSingleTap) withObject:nil afterDelay:0.5f];
        }
    }
    else
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performSingleTap) object:nil];

        if (!_zoomEnable)
        {
            return;
        }
        if (self.zoomScale == self.maximumZoomScale)
        {
            self.zoomScale = self.minimumZoomScale;
            [self setZoomScale:self.minimumZoomScale animated:YES];
        }
        else
        {
            CGRect zoomRect = [self zoomRectForScale:self.maximumZoomScale withCenter:[touch locationInView:_imageView]];
            [self zoomToRect:zoomRect animated:YES];
        }
    }
}

- (void)performSingleTap
{
	if ([_imageScrollViewDelegate respondsToSelector:@selector(singleTap:)])
	{
		[_imageScrollViewDelegate singleTap:self];
	}
}

-(CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    frameToCenter.origin.x = (frameToCenter.size.width < boundsSize.width ? ((boundsSize.width - frameToCenter.size.width) / 2) : 0);
    frameToCenter.origin.y = (frameToCenter.size.height < boundsSize.height ?((boundsSize.height - frameToCenter.size.height)/ 2) : 0);
    
    _imageView.frame = frameToCenter;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (_zoomEnable)
    {
        return _imageView;
    }
    else
    {
        return nil;     
    }
}
-(void)loadImageDate:(MessageModel *)model
{
    if (_imageView)
    {
        [_imageView removeFromSuperview];
        [_imageView release];
        _imageView = nil;
    }
    
    _zoomEnable = YES;
    self.zoomScale = 1.0f;
    
    NSString *filePath = [StaticTools getMemoPhoto:model];
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];

    if (filePath != nil && fileExist == YES)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.image = image;
        [StaticTools setViewRect:_imageView image:image];
        [self addSubview:_imageView];
        [self setMaxMinZoomScalesForCurrentBounds];
    }
    else
    {
        __block typeof(self) this = self;
        _imageView = [[UIImageView alloc]init];
        _imageView.backgroundColor = [UIColor blackColor];
        [_imageView setImageWithURL:[NSURL URLWithString:model.attachURL] placeholderImage:[UIImage imageNamed:@"photo"] success:^(UIImage *image){
            [StaticTools setViewRect:_imageView image:image];
            
            [this addSubview:_imageView];
            [this setMaxMinZoomScalesForCurrentBounds];
        }failure:nil];
        [StaticTools setViewRect:_imageView image:_imageView.image];
		[self addSubview:_imageView];
		[self setMaxMinZoomScalesForCurrentBounds];
    }
}

-(void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size; 
    CGSize imageSize = _imageView.bounds.size;
    
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    CGFloat maxScale = 2.0f;
    if (MAX(imageSize.width, imageSize.height) > 1024.0f)
    {
        maxScale = 1.5f;
    }
    
    if (minScale > maxScale)
    {
        CGFloat tempScale = minScale;
        minScale = maxScale;
        maxScale = tempScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = 1;
}


#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

// returns the center point, in image coordinate space, to try to restore after rotation.
- (CGPoint)pointToCenterAfterRotation
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    return [self convertPoint:boundsCenter toView:_imageView];
}

// returns the zoom scale to attempt to restore after rotation.
- (CGFloat)scaleToRestoreAfterRotation
{
    CGFloat contentScale = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (contentScale <= self.minimumZoomScale + FLT_EPSILON)
        contentScale = 0;
    
    return contentScale;
}



-(CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

-(CGPoint)minimumContentOffset
{
    return CGPointZero;
}

-(void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale
{
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, oldScale));
    
    CGPoint boundsCenter = [self convertPoint:oldCenter fromView:_imageView];
    
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.contentOffset = offset;
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
