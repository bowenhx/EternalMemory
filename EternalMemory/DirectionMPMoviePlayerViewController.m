//
//  DirectionMPMoviePlayerViewController.m
//  EternalMemory
//
//  Created by Guibing on 13-8-5.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "DirectionMPMoviePlayerViewController.h"

@implementation DirectionMPMoviePlayerViewController

- (id)initWithContentURL:(NSURL *)contentURL
{
    self = [super initWithContentURL:contentURL];
    if (self) {
    }
    return self;
}

/*
- (void)dealloc
{
    [_videoUrl release];
    [_moviePlayer release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (id)initWithDirectionMPMoviePlayerViewController:(NSURL *)url
{
    self = [super init];
    _videoUrl = [url retain];
    if (self) {
        self.view.backgroundColor = [UIColor greenColor];
    }
    return self;
}
 */
/*
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
//        // iOS 7
//        [self prefersStatusBarHidden];
//        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//    }
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self initNotificationCenter];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
 */

- (void)initNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillDirectionEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillDirectionDidBecomeActionNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)appWillDirectionEnterBackgroundNotification:(NSNotification *)info
{
    _playTime = self.moviePlayer.currentPlaybackTime;
    [self.moviePlayer pause];
}
- (void)appWillDirectionDidBecomeActionNotification:(NSNotification *)info
{
    [self.moviePlayer setCurrentPlaybackTime:_playTime];
    [self.moviePlayer setInitialPlaybackTime:_playTime];
    [self.moviePlayer play];
}

//当点击Done按键或者播放完毕时调用此函数
- (void)videoPlayerPlaybackDidFinishNotification:(NSNotification *)theNotification
{
    MPMoviePlayerController *play = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:play];
    [play stop];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didTouchUpInsideBack
{
    [self.moviePlayer stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:_videoUrl];
    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    _moviePlayer.movieControlMode = MPMovieControlModeVolumeOnly;
    _moviePlayer.scalingMode = MPMovieScalingModeNone;//不对视频进行缩放
    [_moviePlayer.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];//自动适应屏幕大小；
    [_moviePlayer.view setFrame:self.view.bounds];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerPlaybackDidFinishNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
    [_moviePlayer setFullscreen:NO animated:YES];
    [self.view addSubview:_moviePlayer.view];
    [_moviePlayer play];
    
    _moviePlayer.backgroundColor = [UIColor redColor];
    //设置横屏
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:[UIImage imageNamed:@"fc"] forState:UIControlStateNormal];
    _backBtn.frame = CGRectMake(3,iOS7?20:10, 52, 52);
    [self.view addSubview:_backBtn];
    _backBtn.hidden = NO;
    
    [_backBtn addTarget:self action:@selector(didTouchUpInsideBack) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (_backBtn.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            _backBtn.alpha = 0;
            _backBtn.hidden = NO;
            _backBtn.alpha = 1;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _backBtn.alpha = 1;
            _backBtn.hidden = YES;
            _backBtn.alpha = 0;
        }];
    }
}
 */

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
   return UIInterfaceOrientationMaskAllButUpsideDown;
}



@end

//@implementation UINavigationController (navCtrl)
//
//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
//{
//    return UIInterfaceOrientationMaskPortrait;
//}
//@end

