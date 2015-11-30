//
//  PhotoAlbumNavigationViewController.m
//  EternalMemory
//
//  Created by FFF on 14-3-13.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "PhotoAlbumNavigationViewController.h"

@interface PhotoAlbumNavigationViewController ()

@end

@implementation PhotoAlbumNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBarHidden = YES;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    if ([[self.viewControllers lastObject] isKindOfClass:NSClassFromString(@"MylifeDetailViewController")]) {
        return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskPortrait;;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskPortrait;
    
}

@end
