//
//  MAImagePickerFinalViewController.h
//  instaoverlay
//
//  Created by Maximilian Mackh on 11/10/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "MAConstants.h"
@class EMAudio;
@interface MAImagePickerFinalViewController : UIViewController <UIScrollViewDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate>
{
    int currentlySelected;
    UIImageOrientation sourceImageOrientation;
}

@property BOOL imageFrameEdited;

@property (nonatomic , copy)void (^finishBackImagePickerBlock)(UIImage * image , EMAudio * audio);
@property (strong, nonatomic) UIImage *sourceImage;
@property (retain, nonatomic) UIImage *adjustedImage;

@property (strong, nonatomic) UIImageView *finalImageView;

@property (nonatomic, retain) NSString *selectInt;

@end
