//
//  ReviewImageViewController.m
//  EternalMemory
//
//  Created by FFF on 14-1-6.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "ReviewImageViewController.h"

typedef NS_ENUM(NSInteger, RVLocation) {
    RVLocationFirst = 0,
    RVLocationMiddle,
    RVLocationLast
};

@interface ReviewImageViewController ()
{
    RVLocation _location;
}

- (IBAction)backBtnPressed:(id)sender;

@end


@implementation ReviewImageViewController

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
    
    if (_index == 0) {
        _location = RVLocationFirst;
    } else if (_index == _displayedImages.count) {
        _location = RVLocationLast;
    } else {
        _location = RVLocationMiddle;
    }
    
	// Do any additional setup after loading the view.
}

- (IBAction)backBtnPressed:(id)sender;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return YES;
}


#pragma mark - rotate method
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
