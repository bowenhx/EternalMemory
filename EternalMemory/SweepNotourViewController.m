//
//  SweepInviteViewController.m
//  PeopleBaseNetwork
//
//  Created by kiri on 13-3-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SweepNotourViewController.h"
@interface SweepNotourViewController ()

@end

@implementation SweepNotourViewController

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
    
    self.rightBtn.hidden = YES;
    self.middleBtn.hidden = YES;
    self.titleLabel.text = @"扫描结果";
    
    UILabel *aLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 100, 300, 20)];
    aLabel.backgroundColor=[UIColor clearColor];
    aLabel.textColor=[UIColor colorWithRed:93/255. green:102/255. blue:113/255. alpha:1.0f];
    aLabel.font=[UIFont systemFontOfSize:15.0f];
    aLabel.text=@"已扫描到以下内容";
    aLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:aLabel];
    [aLabel release];
    
    UIView *aview=[[UIView alloc] initWithFrame:CGRectMake(30, 125, 260, 1)];
    aview.backgroundColor=[UIColor grayColor];
    [self.view addSubview:aview];
    [aview release];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10, 135, 300, 20)];
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor colorWithRed:93/255. green:102/255. blue:113/255. alpha:1.0f];
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont systemFontOfSize:15.0f];
    label.text=[NSString stringWithFormat:@"%@",self.sweepResults];
    [self.view addSubview:label];
    [label release];
    
    UIView *bview=[[UIView alloc] initWithFrame:CGRectMake(30, 165, 260, 1)];
    bview.backgroundColor=[UIColor grayColor];
    [self.view addSubview:bview];
    [bview release];
    
    NSString *str=@"您所扫描内容非授权码";
    CGSize size=[str sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(280, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *bLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 172, 280, size.height+50)];
    bLabel.backgroundColor=[UIColor clearColor];
    bLabel.textColor=[UIColor colorWithRed:93/255. green:102/255. blue:113/255. alpha:1.0f];
    bLabel.textAlignment=NSTextAlignmentCenter;
    bLabel.numberOfLines=0;
    bLabel.text=str;
    [self.view addSubview:bLabel];
    [bLabel release];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark navBarDelegate
-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)middleBtnPressed{
    
}
-(void)rightBtnPressed{
    
}
@end
