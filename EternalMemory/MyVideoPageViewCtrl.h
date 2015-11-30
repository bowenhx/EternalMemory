//
//  MyVideoPageViewCtrl.h
//  EternalMemory
//
//  Created by Guibing on 13-6-5.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BaseTableController.h"
#import "VideoPageViewCell.h"
@class FileModel;

@interface AddVideoView :UIView

@end

@interface MyVideoPageViewCtrl : BaseTableController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,VideoPageViewCellDelegate,UIAlertViewDelegate,ASIHTTPRequestDelegate>

@property (nonatomic , retain)FileModel *fileInfo;
//@property (nonatomic , retain)NSString  *fromView;
@end
