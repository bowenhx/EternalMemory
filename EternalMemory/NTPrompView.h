//
//  NTPrompView.h
//  EternalMemory
//
//  Created by FFF on 13-11-29.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTPrompView : UIView

@property (nonatomic, copy) NSString *message;

- (instancetype)initWithMessage:(NSString *)message;
- (void)show;
- (void)dismiss;

@end
