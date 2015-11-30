
//
//  SaveData.m
//  EternalMemory
//
//  Created by sun on 13-5-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "SaveData.h"

@implementation SaveData

static SaveData * _shareInstance = nil;

+(SaveData *)shareInstance{
    if (!_shareInstance) {
        _shareInstance = [[SaveData alloc] init];
    }
    return _shareInstance;
}

//保存token
-(void)savaToken:(NSString*)token KeyString:(NSString*)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:token forKey:TOKEN];
    [defaults synchronize];
    
}
-(NSString*)printToken:(NSString*)key{
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:TOKEN];
}

@end
