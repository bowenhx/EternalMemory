//
//  CompleteLoginInfoViewController.h
//  EternalMemory
//
//  Created by SuperAdmin on 13-11-29.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CustomNavBarController.h"


@interface CompleteLoginInfoViewController : CustomNavBarController<UITextFieldDelegate,UIScrollViewDelegate,ASIHTTPRequestDelegate,NavBarDelegate>{
    
}


@property(assign) BOOL          registToLogin;
@property(assign) NSInteger     comeInStyle;//0 表示push  1 表示present
@property(nonatomic,retain)     IBOutlet UIButton *nextBtn;

@end
