//
//  RegisterSecondStepViewController.h
//  EternalMemory
//
//  Created by sun on 13-5-20.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "HZAreaPickerView.h"

@interface RegisterSecondStepViewController : CustomNavBarController <UITextFieldDelegate,NavBarDelegate,HZAreaPickerDelegate,UIAlertViewDelegate>
{
    NSDictionary *_dataDictionary;
    NSInteger    countryID;
    NSInteger    provinceID;
    NSInteger    cityID;
    NSInteger    districtID;

}
@property (nonatomic, retain) NSDictionary *dataDictionary;

@end
