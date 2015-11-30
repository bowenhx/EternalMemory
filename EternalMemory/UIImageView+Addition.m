//
//  UIImageView+Addition.m
//  PhotoLookTest
//
//  Created by waco on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

NSString *urlStr;
int fromWhere;

#define kCoverViewTag           1234
#define kImageViewTag           1235
#define kAnimationDuration      0.3f
#define kImageViewWidth         300.0f
#define kBackViewColor          [UIColor colorWithWhite:0.667 alpha:0.8f]

#import "UIImageView+Addition.h"
#import "UIImageView+WebCache.h"

#import "StyleListSQL.h"
@implementation UIImageView (UIImageViewEx)

- (void)hiddenView
{
    UIView *coverView = (UIView *)[[self window] viewWithTag:kCoverViewTag];
    [coverView removeFromSuperview];
}

- (void)hiddenViewAnimation
{
    NSLog(@"hiddenViewAnimation---   ");
    UIImageView *imageView = (UIImageView *)[[self window] viewWithTag:kImageViewTag];
    
    [UIView beginAnimations:nil context:nil];    
    [UIView setAnimationDuration:kAnimationDuration]; //动画时长
    CGRect rect = [self convertRect:self.bounds toView:self.window];
    imageView.frame = rect;
    
    [UIView commitAnimations];
    [self performSelector:@selector(hiddenView) withObject:nil afterDelay:kAnimationDuration];
    
}

//自动按原UIImageView等比例调整目标rect
- (CGRect)autoFitFrame
{
    //调整为固定宽，高等比例动态变化
    float width = kImageViewWidth;
    float targeHeight = (width*self.frame.size.height)/self.frame.size.width;
    UIView *coverView = (UIView *)[[self window] viewWithTag:kCoverViewTag];
    CGRect targeRect = CGRectMake(coverView.frame.size.width/2 - width/2, coverView.frame.size.height/2 - targeHeight/2, width, targeHeight);
    return targeRect;
}

- (NSString * )imageUrlWith
{
    NSMutableArray *arrUrl = [StyleListSQL getAllStyleListData];
    NSString *url = @"";
    for (int i= 0;i<arrUrl.count;i++){
        NSMutableArray *stylesArr = arrUrl[i][@"styles"];
        for (NSDictionary *dic in stylesArr)
        {
            if ([dic[@"styleId"] intValue] == self.tag){
                url = dic[@"bigimagepath"];
                return url;
            }
        }
    }
    return url;
}

- (void)imageTap
{
    NSLog(@"self.tag#####################  = %d",self.tag);
    UIView *coverView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    coverView.backgroundColor = kBackViewColor;
    coverView.tag = kCoverViewTag;
    UITapGestureRecognizer *hiddenViewGecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenViewAnimation)];
    [coverView addGestureRecognizer:hiddenViewGecognizer];
    [hiddenViewGecognizer release];
    
    UIImageView *imageView = [[[UIImageView alloc] init] autorelease];
    NSString *strUrl = [self imageUrlWith];
    NSLog(@"-------    styURl = %@",strUrl);
    if ([strUrl isEqualToString:@""]) {
        imageView.image=self.image;
    }else{
        [imageView setImageWithURL:[NSURL URLWithString:strUrl]];
        //imageView.image=[UIImage imageWithContentsOfFile:urlStr];
    }
    imageView.tag = kImageViewTag;
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = self.contentMode;
    CGRect rect = [self convertRect:self.bounds toView:self.window];
    imageView.frame = rect;
       
    [coverView addSubview:imageView];
    [[self window] addSubview:coverView];
    [coverView release];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kAnimationDuration];    
    imageView.frame = [self autoFitFrame]; 
    [UIView commitAnimations];
     
}

- (void)addDetailShow:(NSString *)str
{
    self.userInteractionEnabled = YES;
    urlStr=str;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    [self addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
}

@end