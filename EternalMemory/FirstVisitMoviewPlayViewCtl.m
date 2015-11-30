//
//  FirstVisitMoviewPlayViewCtl.m
//  EternalMemory
//
//  Created by kiri on 13-9-6.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "FirstVisitMoviewPlayViewCtl.h"
#import "QuickRegisterViewController.h"

#define VIDEO_TIME    120.989422 //视频定格在末尾阶段

@interface FirstVisitMoviewPlayViewCtl ()

@end

@implementation FirstVisitMoviewPlayViewCtl
static BOOL isTouchSelf;
-(id)init{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"case" ofType:@"mp4"];
        NSURL *url = [NSURL fileURLWithPath:path] ;
        player = [[MPMoviePlayerController alloc] initWithContentURL:url];
        player.controlStyle = MPMovieControlStyleNone;
        player.scalingMode = MPMovieScalingModeAspectFill;
        [player.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];//自动适应屏幕大小；
        [player.view setFrame:self.view.bounds];
        [self.view addSubview:player.view];
        [self initView];
        isJump = NO;
        is_Finished = NO;
        [player play];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    is_Finished = NO;
    isTouchSelf = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndPlayVideoFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    isTouchSelf = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
/*- (id)initWithContentURL:(NSURL *)contentURL
{
    self = [super initWithContentURL:contentURL];
    if (self) {
        [self initView];
        isJump = NO;

    }
    return self;
}*/
-(void)goonPlay{
    [player play];
}
- (void)initView
{
    _registerBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [_registerBut setImage:[UIImage imageNamed:@"cj"] forState:UIControlStateNormal];
    [_registerBut setTitle:@"立即注册" forState:UIControlStateNormal];
    _registerBut.frame = CGRectMake(self.view.bounds.size.height/2-50, 220, 100, 40);
    _registerBut.hidden = YES;
    [self.view addSubview:_registerBut];
    
    
    _jumpBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _jumpBut.frame = CGRectMake(self.view.bounds.size.height-100, 20, 80, 36);
    [_jumpBut setImage:[UIImage imageNamed:@"jump"] forState:UIControlStateNormal];
    [_jumpBut setTitle:@"跳过" forState:UIControlStateNormal];
    [self.view addSubview:_jumpBut];
    
    [_registerBut addTarget:self action:@selector(didSelectRegisterBut) forControlEvents:UIControlEventTouchUpInside];
    [_jumpBut addTarget:self action:@selector(didSelectJumpBut:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self performSelector:@selector(hiddenJumpBtn) withObject:self afterDelay:5];
}

-(void)hiddenJumpBtn{
    if (!_jumpBut.hidden) {
        [UIView animateWithDuration:1 animations:^{
            _jumpBut.alpha = 0;
        }];
    }
}

-(void)appWillEnterForegroundNotification:(NSNotification *)obj{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"case" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path] ;
    player.contentURL = url;
    if (is_Finished) {
        [player setCurrentPlaybackTime:VIDEO_TIME];
        [player setInitialPlaybackTime:VIDEO_TIME];
        [player pause];
    }else{
        [player setCurrentPlaybackTime:videoTime];
        [player setInitialPlaybackTime:videoTime];
        [player play];
    }
}
-(void)appWillEnterBackgroundNotification:(NSNotification *)obj{
    
    videoTime = player.currentPlaybackTime;
    [player pause];
    
}
//这里是跳过视频操作
- (void)didSelectJumpBut:(UIButton *)but
{
    //不是自动播放完的
    is_Finished = YES;
    [self didEndPlayVideoFinished];
    
}

- (void)didEndPlayVideoFinished
{
    if (!is_Finished) {
        //视频自动播放完成,出现注册按钮
        is_Finished = YES;
    }else {
        //如果不是自动播放完成，定格视频最后一帧，并出现注册按钮
        [player pause];
        [player setCurrentPlaybackTime:VIDEO_TIME];
        _jumpBut.hidden = YES;
    }
     _registerBut.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
 
}
-(void)didSelectRegisterBut{
    
    [player stop];
    [player release];
    
    QuickRegisterViewController *quickRegistVC = [[QuickRegisterViewController alloc] init];
    quickRegistVC.quickRegistDelegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:quickRegistVC];
    [self presentViewController:nav animated:YES completion:nil];
    [quickRegistVC release];
    [nav release];

}
- (void)jump1
{
    isJump = YES;
    [player pause];
}
-(void)jump2{
    
    isJump = YES;
    [player pause];
    [self playVideoFinished2];
    
    
}
- (void)playVideoFinished2
{
    if (isJump) {
        _jumpBut.hidden = YES;
        isJump = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"跳过？" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"下一步", nil];
        alert.tag = 1002;
        [alert show];
        [alert release];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"是否注册" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"马上注册", nil];
        alert.tag = 1000;
        [alert show];
        [alert release];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1000) {
        switch (buttonIndex) {
            case 0:
//                [self dismissModalViewControllerAnimated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            case 1:
            {
               RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:iPhone5 ?  @"RegisterViewController-5":@"RegisterViewController" bundle:nil];
                registerViewController.registDelegate = self;

                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:registerViewController];
                [self presentViewController:nav animated:YES completion:nil];
                [registerViewController release];
                [nav release];
            }
                
                break;
                
            default:
                break;
        }
        
    }else if (alertView.tag == 1001){
        
  /*      switch (buttonIndex) {
            case 0:
                [[self.view viewWithTag:200] removeFromSuperview];
                [player play];
                break;
            case 1:
            {
                [[self.view viewWithTag:200] removeFromSuperview];
                self.button.hidden = YES;
                self.imageBg.hidden = YES;
                player.contentURL = nil;
                NSString *path = [[NSBundle mainBundle] pathForResource:@"logoVideo" ofType:@"mp4"];
                NSURL *url = [NSURL fileURLWithPath:path] ;
                player.contentURL = url;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished2) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
                
                [player play];
                
            }
                break;
                
            default:
                break;
        }*/
    }else if (alertView.tag == 1002){
        switch (buttonIndex) {
            case 0:
                [player play];
                break;
            case 1:
            {
                RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:iPhone5 ?  @"RegisterViewController-5":@"RegisterViewController" bundle:nil];
                registerViewController.registDelegate = self;
                
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:registerViewController];
                [self presentViewController:nav animated:YES completion:nil];
                [registerViewController release];
                [nav release];
            }
                break;
                
            default:
                break;
        }
    }
}
-(void)turnViewtoLogo{
    
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //判断是否在次页面，不在此页面则不再操作
    if (!isTouchSelf) {
        return;
    }
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"case" ofType:@"mp4"];
    NSURL *url1 = [NSURL fileURLWithPath:path1] ;
    
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"logoVideo" ofType:@"mp4"];
    NSURL *url2 = [NSURL fileURLWithPath:path2] ;

    if ([player.contentURL isEqual:url1]) {
        //判断是否是正否是正常播放完成
        if (!is_Finished) {
            [UIView animateWithDuration:1 animations:^{
                _jumpBut.alpha = 1 - _jumpBut.alpha;
            }];
        }else{
             [UIView animateWithDuration:1 animations:^{
                 _registerBut.hidden = NO;
             }];
        }
        
    }else if ([player.contentURL isEqual:url2]) {
        
        if (!is_Finished) {
            [UIView animateWithDuration:1 animations:^{
                _jumpBut.alpha = 1 - _jumpBut.alpha;
            }];
        }else{
            [UIView animateWithDuration:1 animations:^{
                _registerBut.hidden = NO;
            }];
            
        }
    }
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

@end