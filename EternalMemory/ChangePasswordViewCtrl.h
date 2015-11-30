//
//  ChangePasswordViewCtrl.h
//  EternalMemory
//
//  Created by Guibing on 13-7-10.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
@interface ChangePasswordViewCtrl : CustomNavBarController<UITextFieldDelegate,ASIHTTPRequestDelegate,UIAlertViewDelegate>{
    
}
@property (retain, nonatomic) IBOutlet UIImageView *myImageView;
@property (retain, nonatomic) IBOutlet UIButton *showBut;
@property (retain, nonatomic) IBOutlet UITextField *oldPassw;
@property (retain, nonatomic) IBOutlet UITextField *MnewPassw;

@property (retain, nonatomic) IBOutlet UITextField *reNewPass;
- (IBAction)didSelectShowSecretAction:(UIButton *)sender;

@end
