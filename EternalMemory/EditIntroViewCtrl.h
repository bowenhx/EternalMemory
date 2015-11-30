//
//  EditIntroViewCtrl.h
//  EternalMemory
//
//  Created by Guibing Li on 13-5-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomNavBarController.h"
@interface EditIntroViewCtrl : CustomNavBarController<UITextViewDelegate,UIAlertViewDelegate>

@property (nonatomic , retain) NSString *strIntro;
@end
