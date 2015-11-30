//
//  AssoiatedFailureView.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-18.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OperationBlock)(void);

@interface AssoiatedFailureView : UIView

@property (nonatomic, copy) OperationBlock confirmBlock;
@property (nonatomic, copy) OperationBlock cancelBlock;

- (id)initWithTitle:(NSString *)title promptMessage:(NSString *)message canelButton:(NSString *)cancelButton containerView:(UIView *)container;

- (void)configData:(NSDictionary *)data;

@end
