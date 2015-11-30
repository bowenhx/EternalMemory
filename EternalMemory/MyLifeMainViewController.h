//
//  MyLifeMainViewController.h
//  EternalMemory
//

//  Created by sun on 13-5-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CompleteInfoVC;
@class ASIFormDataRequest;
@interface MyLifeMainViewController : UIViewController<
    UIActionSheetDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIAlertViewDelegate>{
    
        CompleteInfoVC *_completeInfoVC;
        IBOutlet  UIScrollView *_scrollView;
        ASIFormDataRequest *_request;
        
}

@property (nonatomic) BOOL isNewVersion;

@end

