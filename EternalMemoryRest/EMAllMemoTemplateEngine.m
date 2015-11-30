//
//  EMAllMemoTemplateEngine.m
//  EternalMemory
//
//  Created by FFF on 14-3-18.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMAllMemoTemplateEngine.h"
#import "ASIFormDataRequest.h"
#import "RequestParams.h"
#import "MessageModel.h"

typedef void(^SuccessBlock)(NSArray *allTemplates);
typedef void(^FailureBlock)(id obj);

@interface EMAllMemoTemplateEngine ()<ASIHTTPRequestDelegate> {
    SuccessBlock _successBlock;
    FailureBlock _failureBlock;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) ASIFormDataRequest *request;

@end

@implementation EMAllMemoTemplateEngine

- (void)dealloc {
    
    Block_release(_failureBlock);
    Block_release(_successBlock);
    [_url release];
    [_request release];
    [super dealloc];
}
#pragma mark - public API

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must use initWithURL: instead" userInfo:nil];
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        
        _url = [url retain];
        _request = [[ASIFormDataRequest alloc] initWithURL:_url];
        [self amt_setupReuqest];
    }
    
    return self;
}

- (void)start {
    [_request startAsynchronous];
    self.isLoading = YES;
}

- (void)stop {
    [_request clearDelegatesAndCancel];
    self.isLoading = NO;
    
}

#pragma mark - accessor
- (void)setSuccessBlock:(void (^)(NSArray *allTemplates))successBlock {
    Block_release(_successBlock);
    _successBlock = Block_copy(successBlock);
    
}
- (void)setFailureBlock:(void (^)(id obj))failureBlock {
    Block_release(_failureBlock);
    _failureBlock = Block_copy(_failureBlock);
}


#pragma mark - ASIHTTPRequestDelegate 
- (void)requestFinished:(ASIHTTPRequest *)request {
    self.isLoading = NO;
    NSData *data = [request responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSInteger success = [dic[@"success"] integerValue];
    NSString *message = dic[@"message"];
    if (success) {
        
        NSArray *tempArr = dic[@"data"];
        NSMutableArray *resultArr = [[NSMutableArray alloc] init];
        [tempArr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
            MessageModel *model = [[MessageModel alloc] initWithDict:dic];
            model.thumbnailType = MessageModelThumbnailTypeTemplate;
            [resultArr addObject:model];
            [model release];
        }];
        
        if (_successBlock) {
            _successBlock(resultArr);
        }
        
        [resultArr release];
        
    } else {
//        NSLog(@"message %@", message);
        if (_failureBlock) {
            _failureBlock(message);
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    self.isLoading = NO;
    if (_failureBlock) {
        _failureBlock([request error]);
    }
}

#pragma mark - privete

- (void)amt_setupReuqest {
    
    [_request setRequestMethod:@"POST"];
    [[RequestParams sharedInstance] setCommonDataForRequest:_request];
    [_request setPostValue:@"wall" forKey:@"flag"];
    _request.delegate = self;
}
@end
