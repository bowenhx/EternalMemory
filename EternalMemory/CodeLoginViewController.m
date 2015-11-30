//
//  CodeLoginViewController.m
//  EternalMemory
//
//  Created by zhaogl on 13-12-28.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CodeLoginViewController.h"
#import "MyToast.h"
#import "NSString+Base64.h"
#import "MD5.h"
#import "SweepNotourViewController.h"
#import "LoginSecondViewController.h"
#import "SealWarnViewController.h"
#import "OfflineDownLoad.h"
#import "OffLineDownLoadCell.h"
#import "FailedOfflineDownLoad.h"
#import "BaseDatas.h"
#import "ZBarHelpController.h"


#define failedDownLoad  [FailedOfflineDownLoad shareInstance]
#define offLine         [OfflineDownLoad shareOfflineDownload]

@interface CodeLoginViewController ()

@end

@implementation CodeLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelView) name:@"cancalCodeView" object:nil];
    self.navigationController.navigationBar.hidden = YES;
    
    //判断
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    
    UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
    if (SCREEN_HEIGHT == 568 && version >= 7.0) {
        aView.frame = CGRectMake(0, 0, 320, self.view.bounds.size.height + 30);
    }
    
    aView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_sweep_backg"]];
    
    aView.alpha=0.7;
    UIImageView *aImageView=[[UIImageView alloc] initWithFrame:CGRectMake(44, self.view.bounds.size.height-49-75, 232, 45)];
    [aImageView setImage:[UIImage imageNamed:@"ic_sweep_lay"]];
    [aView addSubview:aImageView];
    
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(49, 45, 221, 10)];
    imageView.userInteractionEnabled = YES;
    [imageView setImage:[UIImage imageNamed:@"ic_sweep_line"]];
    
    [aView addSubview:imageView];
    
    if (version >= 7.0) {
        imageView.frame = CGRectMake(49,100,221,10);
    }
    
    self.cameraOverlayView=aView;
    [aImageView release];
    [imageView release];
    [aView release];
    
    if (version>=6.0) {
        int i = 0;
        for (UIView *temp in [self.view subviews]) {
            for (UIView *v in [temp subviews]) {
                if ([v isKindOfClass:[UIToolbar class]]) {
                    UIToolbar *aa = (UIToolbar *)v;
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(0, 10, 60, 50);
                    [btn addTarget:self action:@selector(cancelView) forControlEvents:UIControlEventTouchUpInside];
                    [aa addSubview:btn];
                    for (UIView *ev in [v subviews]) {
                        if (i== 3) {
                            [ev removeFromSuperview];
                        }
                        
                        i++;
                    }
                }
            }
        }
    }else{
        int i = 0;
        for (UIView *temp in [self.view subviews]) {
            for (UIView *v in [temp subviews]) {
                if ([v isKindOfClass:[UIToolbar class]]) {
                    for (UIView *ev in [v subviews]) {
                        if (i== 2) {
                            [ev removeFromSuperview];
                        }
                        i++;
                    }
                }
            }
        }
    }
    
    //    UIBezierPath *path = [UIBezierPath bezierPath];
    //    [path moveToPoint:CGPointMake(160, imageView.frame.origin.y )];
    //    [path addLineToPoint:CGPointMake(160,imageView.frame.origin.y + 250)];
    //    CAKeyframeAnimation *keyframe = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //    keyframe.path = path.CGPath;
    //    keyframe.duration = 3;
    //    keyframe.repeatCount = 1000;
    //    [imageView.layer addAnimation:keyframe forKey:@"animationKey"];
    
    CABasicAnimation *translation2 = [CABasicAnimation animationWithKeyPath:@"position"];
    translation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    translation2.fromValue = [NSValue valueWithCGPoint:CGPointMake(160, (7*self.view.bounds.size.height/48)+35)];
    if ([[UIScreen mainScreen]bounds].size.height==568) {
        if (version >= 7.0) {
            translation2.toValue=[NSValue valueWithCGPoint:CGPointMake(160, (49*self.view.bounds.size.height/96)+45)];
        }else{
            translation2.toValue=[NSValue valueWithCGPoint:CGPointMake(160, (49*self.view.bounds.size.height/96)+15)];
        }
    }else if([[UIScreen mainScreen] bounds].size.height==480){
        translation2.toValue = [NSValue valueWithCGPoint:CGPointMake(160, (49*self.view.bounds.size.height/96)+50)];
    }
    translation2.duration = 3;
    translation2.repeatCount = 1000;
    translation2.autoreverses = YES;
    [imageView.layer addAnimation:translation2 forKey:@"translation2"];
    
	// Do any additional setup after loading the view.
}
-(void)cancelView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
