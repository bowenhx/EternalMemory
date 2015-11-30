//
//  StyleSendOperation.h
//  EternalMemory
//
//  Created by Guibing on 13-8-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

//风格下载类
@interface StyleSendOperation : NSOperation<ASIHTTPRequestDelegate>

@property (nonatomic , copy) void (^didDownStyleProgressBlock)(long long gress,long long pro);
@property (nonatomic ,retain)ASIHTTPRequest *styleRequest;
@property (nonatomic , retain)NSDictionary *dicData;
@property (nonatomic , assign)NSInteger  indexHome;


-(id)initWithStyleSendOperation:(NSDictionary *)dic;


@end
