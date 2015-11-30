//
//  CaseVideoViewController.m
//  EternalMemory
//
//  Created by kiri on 13-9-10.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CaseVideoViewController.h"

@interface CaseVideoViewController ()

@end

@implementation CaseVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    
    [player release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"case" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path] ;
    player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    player.controlStyle = MPMovieControlStyleNone;
    player.scalingMode = MPMovieScalingModeAspectFill;
    [player.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];//自动适应屏幕大小；
    [player.view setFrame:self.view.bounds];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self.view addSubview:player.view];
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"but_left_nav_normal"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(20, 20, 52, 31);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [backBtn addTarget:self action:@selector(backBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    backBtn.hidden = YES;
    isHidden = YES;
    [player play];
    
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)playVideoFinished
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)appWillEnterForegroundNotification:(NSNotification *)obj{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"case" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path] ;
    player.contentURL = url;
    [player setCurrentPlaybackTime:videoTime];
    [player setInitialPlaybackTime:videoTime];
    [player play];
    
}
-(void)appWillEnterBackgroundNotification:(NSNotification *)obj{
    
    videoTime = player.currentPlaybackTime;
    [player pause];
}

-(void)backBtnPressed{
    
    [player stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (isHidden) {
        isHidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            backBtn.alpha = 0;
            backBtn.hidden = NO;
            backBtn.alpha = 1;
        }];
    }else if (!isHidden){
        isHidden = YES;
        [UIView animateWithDuration:0.3 animations:^{
            backBtn.alpha = 1;
            backBtn.hidden = YES;
            backBtn.alpha = 0;
        }];
    }
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (BOOL)shouldAutorotate
{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
