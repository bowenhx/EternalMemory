//
//  NdUncaughtExceptionHandler.h
//  EternalMemory
//
//  Created by zhaogl on 14-2-17.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NdUncaughtExceptionHandler : NSObject


+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler*)getHandler;

@end
