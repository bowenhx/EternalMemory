//
//  NdUncaughtExceptionHandler.m
//  EternalMemory
//
//  Created by zhaogl on 14-2-17.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "NdUncaughtExceptionHandler.h"
#import "Utilities.h"
#import "Reachability.h"
#import "ExceptionBugSQL.h"

NSString *applicationDocumentsDirectory() {
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
}

void UncaughtExceptionHandler(NSException *exception) {
    
    NSArray *arr = [exception callStackSymbols];
    
    NSString *reason = [exception reason];
    
    NSString *name = [exception name];
    
    NSString *dateStr = [Utilities convertTimeDateToTimeString:[NSDate date]];
    NSString *device = [Utilities checkIphone];
    NSString *deviceVersion = [[UIDevice currentDevice] systemVersion];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *internet = @"";
    
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus  status = [reachability currentReachabilityStatus];
    if (status == ReachableViaWWAN){
        internet = @"3G";
    }else if(status == ReachableVia2G){
        internet = @"2G";
    }else if (status == ReachableViaWiFi){
        internet = @"WIFI";
    }else if (status == NotReachable){
        internet = @"无网络";
    }
        
    NSString *content = [NSString stringWithFormat:@"异常崩溃报告:\nDate:%@\nDevice:%@\nOsversion:%@\ninternet:%@\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",dateStr,device,deviceVersion,internet,name,reason,[arr componentsJoinedByString:@"\n"]];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:content,@"content",device,@"devicemodel",deviceVersion,@"osversion",dateStr,@"happentime",internet,@"internet",version,@"appversion",nil];
    [ExceptionBugSQL addExceptionBugInfo:dic];
    
//    NSString *path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
//    NSString *bugStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    content = [NSString stringWithFormat:@"%@\n%@",bugStr,content];
//    
//    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:url delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alert show];
//    [alert release];
    
    //除了可以选择写到应用下的某个文件，通过后续处理将信息发送到服务器等
    
    //还可以选择调用发送邮件的的程序，发送信息到指定的邮件地址
    
    //或者调用某个处理程序来处理这个信息
    
}

@implementation NdUncaughtExceptionHandler

-(NSString *)applicationDocumentsDirectory {
        
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
}

+ (void)setDefaultHandler
{
        
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
        
}

    
+ (NSUncaughtExceptionHandler*)getHandler
{
    
    return NSGetUncaughtExceptionHandler();
        
}

@end
