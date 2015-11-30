//
//  AboutInfoViewController.m
//  EternalMemory
//
//  Created by FFF on 13-11-29.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "AboutInfoViewController.h"

@interface AboutInfoViewController ()

@end

@implementation AboutInfoViewController

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
    self.titleLabel.text = @"关于我们";
    self.rightBtn.hidden = YES;
    self.middleBtn.hidden = YES;
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
