//
//  SaveData.h
//  EternalMemory
//
//  Created by sun on 13-5-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "config.h"

@interface SaveData : NSObject
+(SaveData *)shareInstance;

//保存token
-(void)savaToken:(NSString*)token KeyString:(NSString*)key;
-(NSString*)printToken:(NSString*)key;
@end
