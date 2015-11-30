//
//  LoginSecondViewController.h
//  EternalMemory
//
//  Created by Guibing on 13-12-5.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
@interface LoginSecondViewController : CustomNavBarController<UIAlertViewDelegate>{
    
    NSString                *_strVersion;
    UIImageView             *_guideImg;
    IBOutlet UIButton       *_onLineBtn;

}
@property (nonatomic, retain) NSString *errorcodeStr ;

- (IBAction)didTapOnLineTouchInside:(UIButton *)sender;
- (IBAction)didTapOffLineTouchInside:(UIButton *)sender;

@end
