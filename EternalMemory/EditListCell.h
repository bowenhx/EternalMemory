//
//  EditListCell.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AdditionOperationBlock)(void);
typedef void(^ReviewOperationBlock)(void);

@interface EditListCell : UITableViewCell

@property (nonatomic, copy) AdditionOperationBlock  addtionOperationBlock;
@property (nonatomic, copy) ReviewOperationBlock    reviewOperationBlock;

@property (nonatomic, retain) UIImage               *additionButtonBackgroud;
@property (nonatomic, retain) UIImage               *reviewButtonBackground;

@property (nonatomic, assign) CGPoint               containerPosition;

@property (nonatomic, assign) BOOL                  enable;

@end
