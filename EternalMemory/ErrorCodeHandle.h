//
//  ErrorCodeHandle.h
//  EternalMemory
//
//  Created by zhaogl on 14-3-24.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorCodeHandle : NSObject<UIAlertViewDelegate>{
    
}

+(instancetype)sharedInstance;
+(void)handleErrorCode:(NSString *)errorCode AndMsg:(NSString *)msg;
-(void)handleCode:(NSString *)errorCode AndMsg:(NSString *)msg;
-(void)showAlertViewWithTag:(NSInteger)tag AndMessage:(NSString *)msg;
@end
