//
//  AuthLoginViewController.h
//  EternalMemory
//
//  Created by Guibing Li on 13-12-18.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CustomNavBarController.h"
@interface AuthLoginViewController : CustomNavBarController<
    NavBarDelegate,
    ASIHTTPRequestDelegate,
    UIWebViewDelegate,
    UIAlertViewDelegate,
    UITextFieldDelegate>{
       
}

@end
