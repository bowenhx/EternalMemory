//
//  CaseVideoViewController.h
//  EternalMemory
//
//  Created by kiri on 13-9-10.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface CaseVideoViewController : UIViewController{
    MPMoviePlayerController *player;
    NSTimeInterval  videoTime;
    UIButton        *backBtn;
    BOOL            isHidden;
}

@end
