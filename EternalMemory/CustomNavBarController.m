//
//  CustomNavBarController.m
//  PeopleBaseNetwork
//
//  Created by kiri on 13-3-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CustomNavBarController.h"
#import "FileModel.h"
#import "PhotoUploadRequest.h"
#import "PhotoUploadEngine.h"
#import "EMPhotoSyncEngine.h"
#import "PhotoListFormedRequest.h"

@interface CustomNavBarController ()

@end

@implementation CustomNavBarController
@synthesize delegate;
@synthesize navBarView = _navBarView;

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
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

    self.view.backgroundColor = RGBCOLOR(238, 242, 245);
    self.navigationController.navigationBar.hidden=YES;
    _navBarView=[[UIImageView alloc] init];
    _navBarView.frame=CGRectMake(0, 0, SCREEN_WIDTH, 44);
    if (iOS7) {
        
        _navBarView.frame=CGRectMake(0, 0, SCREEN_WIDTH, 64);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    _navBarView.backgroundColor = [UIColor blackColor];
    [_navBarView setImage:[UIImage imageNamed:@"top"]];
    [self.view addSubview:_navBarView];
    [_navBarView release];
    
    _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-160)/2, 2, 160, 40)];
    if (iOS7) {
        _titleLabel.frame=CGRectMake((SCREEN_WIDTH-160)/2, 22, 160, 40);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    _titleLabel.backgroundColor=[UIColor clearColor];
    _titleLabel.font=[UIFont systemFontOfSize:18.0f];
    _titleLabel.textAlignment=NSTextAlignmentCenter;
    _titleLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:_titleLabel];
    [_titleLabel release];
    
    _middleImage=[[UIImageView alloc] initWithFrame:CGRectMake(185, 20, 8, 8)];
    _middleImage.backgroundColor=[UIColor clearColor];
    if (iOS7)
    {
        _middleImage.frame = CGRectMake(185, 40, 8, 8);
    }
    [self.view addSubview:_middleImage];
    [_middleImage release];
    
    _middleBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _middleBtn.frame=CGRectMake(110, 7, 100, 30);
    if (iOS7) {
        _middleBtn.frame=CGRectMake(110, 27, 100, 30);
    }
    _middleBtn.backgroundColor=[UIColor clearColor];
    _middleBtn.showsTouchWhenHighlighted=YES;
    [_middleBtn addTarget:self action:@selector(middleBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_middleBtn];
    
    
    UIFont *btnTxtFont = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    
    _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.titleLabel.font = btnTxtFont;
//    _backBtn.frame = CGRectMake(0, 0, 77, 44);
    _backBtn.frame = CGRectMake(10, 7, 52, 31);
    if (iOS7) {
        _backBtn.frame=CGRectMake(10, 27, 52, 31);
    }
    [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
//    _backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 25, 0, 0);
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"but_left_nav_normal"] forState:UIControlStateNormal];
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"but_left_nav_selected"] forState:UIControlStateSelected];
//    [_backBtn setImage:[UIImage imageNamed:@"but_left_nav_normal"] forState:UIControlStateNormal];
//    _backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 27);

    [_backBtn addTarget:self action:@selector(backBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
    _rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.titleLabel.font = btnTxtFont;
    _rightBtn.frame=CGRectMake(SCREEN_WIDTH - 52, 6, 42, 31);
    if (iOS7) {
        _rightBtn.frame=CGRectMake(SCREEN_WIDTH - 52, 26, 42, 31);
    }
//    _rightBtn.showsTouchWhenHighlighted=YES;
    [_rightBtn setBackgroundImage:[UIImage imageNamed:@"but_right_nav_normal"] forState:UIControlStateNormal];  //btn_rbg 图片在子类定义
    [_rightBtn setBackgroundImage:[UIImage imageNamed:@"but_right_nav_selected"] forState:UIControlStateSelected];
    _rightBtn.titleLabel.font=[UIFont systemFontOfSize:13.0f];
    [_rightBtn addTarget:self action:@selector(rightBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rightBtn];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSynchronousOperation:) name:kReachabilityChangedNotification object:nil];
    
	// Do any additional setup after loading the view.
}

- (void)startSynchronousOperation:(NSNotification *)notification
{
    Reachability *reachability = (Reachability *)notification.object;
    if (reachability.currentReachabilityStatus != NotReachable) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [[EMPhotoSyncEngine sharedEngine] SyncOperation];
            
        });
    }
}

- (void)networkPromptMessage:(NSString *)message
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [[EternalMemoryAppDelegate getAppDelegate].window addSubview:HUD];
    HUD.labelText = message;
    HUD.mode = MBProgressHUDModeText;
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        [HUD release];
    }];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [FileModel sharedInstance].isOpenGcd = YES;
    [super dealloc];
}
@end
