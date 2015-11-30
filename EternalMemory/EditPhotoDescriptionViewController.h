//
//  EditPhotoDescriptionViewController.h
//  EternalMemory
//
//  Created by FFF on 13-12-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CustomNavBarController.h"

extern NSString * const PhotoDesChangedNotification;

@class MessageModel;

@interface EditPhotoDescriptionViewController : CustomNavBarController

@property (nonatomic, retain) MessageModel *model;

@end
