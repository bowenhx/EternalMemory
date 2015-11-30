//
//  AssociatedInfoInputView.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-24.
//  Copyright (c) 2013年 sun. All rights reserved.
//



#import <UIKit/UIKit.h>



typedef NS_ENUM(NSInteger, AssociationType) {
    AssociationTypeAuthcode = 0,
    AssociationTypeEternalcode
};

typedef void(^BtnDidPressedBlock)(NSDictionary *dic, AssociationType type);

@interface AssociatedInfoInputView : UIView<UITextFieldDelegate>


@property (nonatomic, assign) AssociationType associationType;
@property (nonatomic, copy)   BtnDidPressedBlock btnPressedBlock;
@property (nonatomic, retain) UILabel         *titleLabel;

- (id)initWithAssociationType:(AssociationType)type;

@end
