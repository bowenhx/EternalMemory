//
//  LogoMPMoviewPlayViewCtl.h
//  EternalMemory
//
//  Created by Guibing on 13-8-22.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RegisterViewController.h"
#import "FirstVisitMoviewPlayViewCtl.h"
#import "ZBarSDK.h"
@interface LogoMPMoviewPlayViewCtl : UIViewController<
    ZBarReaderDelegate,
    ASIHTTPRequestDelegate,
    UIAlertViewDelegate>
{
    UIButton            *_memoryBut;    //记忆吗
    UIButton            *_loginBut;     //登陆
    UIButton            *_firstVisitBut;//首次访问
    UIImageView         *_imageBg;
    BOOL        isHidden;
    NSTimeInterval      videoTime;
    MPMoviePlayerController  *player;
    NSString            *_authDecode;
    NSTimer             *_timer;
    BOOL                upOrdown;
    UIImageView         *_line;
    int                 num;
    ZBarReaderViewController *_reader;
    MBProgressHUD       *HUD;
    BOOL                _fromPhotoLibrary;
    BOOL                _VerticalScreen;
    UIButton            *_selectPhotoBtn;
}
@property (nonatomic , readonly)UIButton        *memoryBut;
@property (nonatomic , readonly)UIButton        *loginBut;
@property (nonatomic , readonly)UIButton        *firstVisitBut;
@property (nonatomic , readonly)UIImageView     *imageBg;

-(id)initWithView;
- (void)didSelectLogin;
@end

@interface UINavigationController (navCtrl)

@end