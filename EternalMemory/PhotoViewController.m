//
//  PhotoViewController.m
//  EternalMemory
//
//  Created by sun on 13-6-7.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize photoBtn = _photoBtn ;
@synthesize photoImgSelectedImg = _photoImgSelectedImg;
@synthesize photoImage = _photoImage;
#pragma mark - object lifecycle
- (void)dealloc
{
    RELEASE_SAFELY(_photoBtn);
    RELEASE_SAFELY(_photoImage);
    RELEASE_SAFELY(_photoImgSelectedImg);
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction methods,public methods
- (IBAction)onPhotoBtnClicked
{
    if ([_delegate respondsToSelector:@selector(getPhotoView:)])
    {
        [_delegate getPhotoView:self];
    }

       
}
@end
