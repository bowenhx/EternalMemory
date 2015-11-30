//
//  StatusIndicatorView.h
//  EternalMemory
//
//  Created by FFF on 13-12-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusIndicatorView : UIWindow
{
    
}

@property (nonatomic, copy)   NSString    *message;
@property (nonatomic, assign) NSInteger   total;
@property (nonatomic, assign) NSInteger   current;


- (instancetype)initWithTaskCount:(NSInteger)taskCount message:(NSString *)message;
- (void)show;
- (void)dismiss;

@end
