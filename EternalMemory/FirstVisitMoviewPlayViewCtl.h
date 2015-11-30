//
//  FirstVisitMoviewPlayViewCtl.h
//  EternalMemory
//
//  Created by kiri on 13-9-6.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "LogoMPMoviewPlayViewCtl.h"
#import "QuickRegisterViewController.h"
@protocol FirstMovieDelegate <NSObject>

-(void)backToLogoView;

@end
@interface FirstVisitMoviewPlayViewCtl : UIViewController<
    UIAlertViewDelegate,
    turnToLogoPro,
    UIApplicationDelegate>{
    NSInteger touchNum;
    BOOL      isJump;
    NSTimeInterval     videoTime;
    MPMoviePlayerController *player;
    BOOL              is_Finished;
    
}

@property (nonatomic , readonly) UIButton *registerBut;
@property (nonatomic , readonly) UIButton *jumpBut;
@property (nonatomic , readonly) UIImageView *imageBg;
@property (assign)   id <FirstMovieDelegate>delegate;
@end
