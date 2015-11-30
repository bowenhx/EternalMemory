//
//  SynDataBackstage.h
//  EternalMemory
//
//  Created by SuperAdmin on 13-11-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
@interface SynDataBackstage : NSObject<ASIHTTPRequestDelegate>
//测试后台同步功能
- (void)synchronousDBData;

//同步日志列表
- (void)synchronousBlogList;

//取消请求（崩溃问题）
-(void)cleanRequest;

//退出登录取消同步
-(void)cancelRequestWhenLogout;


@end
