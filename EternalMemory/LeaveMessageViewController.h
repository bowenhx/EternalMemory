//
//  LeaveMessageViewController.h
//  EternalMemory
//
//  Created by zhaogl on 13-12-19.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CustomNavBarController.h"
#import <QuartzCore/QuartzCore.h>

@interface LeaveMessageViewController : CustomNavBarController<UIScrollViewDelegate,
    ASIHTTPRequestDelegate,
    UITextFieldDelegate,
    UITextViewDelegate>{
        ASIFormDataRequest      *_request;
        IBOutlet UIImageView    *_bgImageView;
}

@property (nonatomic,retain) IBOutlet UITextField  *nickNameTextField;
@property (nonatomic,retain) IBOutlet UIImageView  *contentImg;
@property (nonatomic,retain) IBOutlet UITextView   *contentTextView;
@property (nonatomic,retain) IBOutlet UIButton     *leaveMessageBtn;
@property (nonatomic,retain) IBOutlet UIButton     *closeBtn;
@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;

-(IBAction)leaveMessage:(id)sender;
-(IBAction)close:(id)sender;
@end
