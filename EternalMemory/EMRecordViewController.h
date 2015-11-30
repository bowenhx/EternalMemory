//
//  EMRecordViewController.h
//  EternalMemory
//
//  Created by FFF on 14-2-18.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import "RecordPromptView.h"
#import "EMAudioUploader.h"
@class EMAudio;

typedef void(^RecordBlock)(EMAudio *audio);

@class MessageModel;

@interface EMRecordViewController : UIViewController<AVAudioPlayerDelegate>

@property (nonatomic, retain) MessageModel *model;
@property (nonatomic, copy)   RecordBlock   stopBlock;
@property (nonatomic,retain)  UIImage      *backImage;
@property (nonatomic, copy)   RecordBlock   dismissBlock;
@property (nonatomic, copy)   RecordBlock   timeTooShortBlock;
@property (nonatomic,retain)  RecordPromptView* recordPromptView;

- (IBAction)finash:(id)sender ;

@end
