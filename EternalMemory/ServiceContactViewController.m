//
//  ServiceContactViewController.m
//  EternalMemory
//
//  Created by jiangxl on 13-9-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "ServiceContactViewController.h"

@interface ServiceContactViewController ()

@end

@implementation ServiceContactViewController

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
    self.titleLabel.text = @"永恒记忆服务协议";
    self.rightBtn.hidden = YES;

    // Do any additional setup after loading the view from its nib.
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
