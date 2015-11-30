//
//  MyToast.h
//  EternalMemory
//
//  Created by apple on 13-7-4.
//  Copyright (c) 2013年 sun. All rights reserved.
//


#import <UIKit/UIKit.h>
#define RGB(a, b, c) [UIColor colorWithRed:(a / 255.0f) green:(b / 255.0f) blue:(c / 255.0f) alpha:1.0f]
#define RGBA(a, b, c, d) [UIColor colorWithRed:(a / 255.0f) green:(b / 255.0f) blue:(c / 255.0f) alpha:d]
@interface MyToast : UIView
+ (void)showWithText:(NSString *)text :(int)toastY;
+ (void)showWithText:(NSString *)text inView:(UIView *)view :(int)toastY;
+ (void)showWithImage:(UIImage *)image;
+ (MyToast *)__createWithText:(NSString *)text :(int)toastY;
- (void)showDelayTimeView:(CGFloat)time;

//lgb
+ (void)homeStyleTimeDelayText:(NSString *)text  :(int)toastY :(CGFloat)time;
@end