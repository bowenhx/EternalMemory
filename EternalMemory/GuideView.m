//
//  GuideView.m
//  EternalMemory
//
//  Created by kiri on 13-10-16.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "GuideView.h"
#import "EternalMemoryAppDelegate.h"

@implementation GuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
+(void)guideViewAddToWindow:(NSString *)type{
    
    GuideView *guideView = [[GuideView alloc] initWithFrame:[EternalMemoryAppDelegate getAppDelegate].window.frame];
    guideView.tag = 10000;
    if ([type isEqualToString:@"photo"]) {
        if (iPhone5) {
            guideView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"guide_photo-568h"]];
        }else{
            guideView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"guide_photo"]];
        }
    }
    if ([type isEqualToString:@"text"]) {
        if (iPhone5) {
            guideView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"guide_text-568h"]];
        }else{
            guideView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"guide_text"]];
        }
    }
    if ([type isEqualToString:@"video"]) {
        if (iPhone5) {
            guideView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"guide_video-568h"]];
        }else{
            guideView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"guide_video"]];
        }
    }
    [[[UIApplication sharedApplication] keyWindow] addSubview:guideView];
    [guideView release];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UIView *aview = [self viewWithTag:10000];
    [aview removeFromSuperview];
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
