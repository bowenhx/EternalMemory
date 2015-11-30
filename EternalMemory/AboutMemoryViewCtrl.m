//
//  AboutMemoryViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 13-8-16.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "AboutMemoryViewCtrl.h"
#import "IdeaFeedbackViewCtrl.h"
#import "CaseVideoViewController.h"
#import "UseVideoViewController.h"
#import "RookieHelpViewController.h"
#import "AboutInfoViewController.h"
#import "AuthLoginViewController.h"

@interface AboutMemoryViewCtrl ()
{
     LogoMPMoviewPlayViewCtl *playerViewController;
}
@end

@implementation AboutMemoryViewCtrl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"新手帮助";
    self.rightBtn.hidden = YES;
    self.middleBtn.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;

}
- (IBAction)didSelectWelcomePage:(UIButton *)sender
{
    AboutInfoViewController *aVC = [[AboutInfoViewController alloc] init];
    [self.navigationController pushViewController:aVC animated:YES];
    [aVC release];
}

- (IBAction)didSelectCaseVideoPage:(UIButton *)sender
{
    CaseVideoViewController *caseVideoVC = [[CaseVideoViewController alloc] init];
    caseVideoVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

    [self presentViewController:caseVideoVC animated:YES completion:nil];
    [caseVideoVC release];
    
}
//- (IBAction)didSelectUseVideoPage:(UIButton *)sender{
//    
//    UseVideoViewController *useVideoVC = [[UseVideoViewController alloc] init];
//    useVideoVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//
//    [self presentViewController:useVideoVC animated:YES completion:nil];
//    [useVideoVC release];
//}
//当点击Done按键或者播放完毕时调用此函数
- (void) playVideoFinished:(NSNotification *)theNotification
{
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    AuthLoginViewController *authLogin = [[AuthLoginViewController alloc] init];
    
    //    QuickRegisterViewController *quickRegistVC = [[QuickRegisterViewController alloc] init];
    //    quickRegistVC.quickRegistDelegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:authLogin];
    [self presentViewController:nav animated:YES completion:nil];
    [authLogin release];
    [nav release];

}


- (IBAction)didSelectHelpPage:(UIButton *)sender
{
    RookieHelpViewController *rookieHelp = [[RookieHelpViewController alloc] init];
    [self.navigationController pushViewController:rookieHelp animated:YES];
    [rookieHelp release];
}

- (IBAction)didSelectFeedbackPage:(UIButton *)sender
{
    IdeaFeedbackViewCtrl *ideaFeedback = [IdeaFeedbackViewCtrl new];
    [self.navigationController pushViewController:ideaFeedback animated:YES];
    [ideaFeedback release];
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
