//
//  MyHomeVideoListViewController.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-8-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"

#define VIDEO_COUNT         5

@interface MyHomeVideoListViewController : UIViewController
{
    NSMutableArray      *_videoList;
    bool                _isDownloading[VIDEO_COUNT];
    NSInteger           _videoIdx;
    
    UIButton            *_closeButton;
    UILabel             *_videoTitleLabel;
    UIImageView         *_videoThumnailImageView;
    UIButton            *_playVideoButton;
    UIButton            *_nextButton;
    UIButton            *_preButton;
    
    __block id bself;
}

@property (nonatomic, retain) NSMutableArray       *videoList;
@property (nonatomic, retain) NSMutableArray       *videoNamesArr;   //只在断网的时候保存视频名字。
@property (nonatomic, copy)   NSString             *eternalCode;
@property (nonatomic, copy)   NSString             *pathForSavingVideoEternalcode;
@property (nonatomic, retain) NSString *associatevalue;
@property (nonatomic, retain) NSString *associateauthcode;
@property (nonatomic, retain) NSString *currentUserID;


@end
