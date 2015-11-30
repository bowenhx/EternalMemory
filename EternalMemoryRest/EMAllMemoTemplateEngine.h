//
//  EMAllMemoTemplateEngine.h
//  EternalMemory
//
//  Created by FFF on 14-3-18.
//  Copyright (c) 2014年 sun. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface EMAllMemoTemplateEngine : NSObject

@property (nonatomic, assign) BOOL isLoading;

- (instancetype)initWithURL:(NSURL *)url;
- (void)start;
- (void)stop;

- (void)setSuccessBlock:(void (^)(NSArray *allTemplates))successBlock;
- (void)setFailureBlock:(void (^)(id obj))failureBlock;

@end
