//
//  ForbidVisitViewController.h
//  EternalMemory
//
//  Created by sun on 13-6-30.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "SavaData.h"

@interface ForbidVisitViewController : CustomNavBarController<NavBarDelegate,UITextFieldDelegate,ASIHTTPRequestDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>{
    
//    ASIFormDataRequest *_formatReq;
}
@property (retain, nonatomic) IBOutlet UIButton *applyBtn;
@property (retain, nonatomic) IBOutlet UIView      *bgView;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UITextField *phoneTextField;
@property (retain, nonatomic) IBOutlet UITextField *mailAddrTextField;

//@property (retain, nonatomic) ASIFormDataRequest *formatReq;
//- (IBAction)clickMemoryCode:(UIButton *)sender;
- (IBAction)applyForbidVisit:(UIButton *)sender;

@end
