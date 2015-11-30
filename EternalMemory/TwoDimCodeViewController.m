//
//  TwoDimCodeViewController.m
//  EternalMemory
//
//  Created by zhaogl on 13-11-6.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "TwoDimCodeViewController.h"

@interface TwoDimCodeViewController ()

@end

@implementation TwoDimCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 100, 260, 260)];
//    imgView.backgroundColor = [UIColor redColor];
    imgView.image = _twoDimCodeImg;
    [self.view addSubview:imgView];
    [imgView release];
    
	// Do any additional setup after loading the view.
}
-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
