//
//  PhotoOrderCell.h
//  EternalMemory
//
//  Created by zhaogl on 14-3-10.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTLimitationInputView.h"

typedef void(^EditBtnPressedBlock)(void);


@interface PhotoOrderCell : UITableViewCell<UITextFieldDelegate>{
    
}

@property (nonatomic,retain)IBOutlet UIImageView *photoImg;
@property (nonatomic,retain)IBOutlet UIButton    *editBtn;
@property (nonatomic,retain)IBOutlet UITextField *contentTextField;
@property (nonatomic,retain)IBOutlet NTLimitationInputView *inputView;
@property (nonatomic, copy) EditBtnPressedBlock editBtnPressedBlock;


-(IBAction)editBtnPressed:(id)sender;
@end
