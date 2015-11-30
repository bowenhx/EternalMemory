//
//  BackgroundMusicViewCtrl.h
//  EternalMemory
//
//  Created by Guibing Li on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MPMediaPickerController.h>
#import <UIKit/UIKit.h>
#import "BaseTableController.h"
#import "MusicViewCell.h"

//typedef void (^DidUplodingCellProgressBlock)(long long up);

@interface BackgroundMusicViewCtrl : BaseTableController<UITableViewDelegate,UITableViewDataSource,MPMediaPickerControllerDelegate,MusicViewCellDelegate,ASIHTTPRequestDelegate,ASIProgressDelegate,UIAlertViewDelegate>
{
    MPMusicPlayerController *playerMusic;
    MPMediaPickerController *pickerMusic;
//    UIProgressView *_proVC;
}
@property (strong , nonatomic , retain ) AVAudioPlayer *player;
//@property (nonatomic , copy)void (^didMusicUplodingCellProgressBlock)(long long up);
//@property(nonatomic, retain)UIProgressView *pro;
@end
