//
//  PhotoViewController.h
//  EternalMemory
//
//  Created by sun on 13-6-7.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PhotoViewDelegate;
@interface PhotoViewController : UIViewController
{
     NSObject<PhotoViewDelegate> *_delegate;
}
@property (nonatomic, retain) IBOutlet UIButton *photoBtn;
@property (nonatomic, retain) IBOutlet UIImageView *photoImage;
@property (nonatomic, retain) IBOutlet UIImageView *photoImgSelectedImg;
@property (nonatomic, assign) NSObject<PhotoViewDelegate> *delegate;
@end
@protocol PhotoViewDelegate
@optional
- (void)getPhotoView:(PhotoViewController *)photoView;
@end