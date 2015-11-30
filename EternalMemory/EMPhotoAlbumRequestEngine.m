//
//  EMPhotoAlbumRequestEngine.m
//  EternalMemory
//
//  Created by FFF on 14-3-11.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMPhotoAlbumRequestEngine.h"
#import "SavaData.h"
#import "RequestParams.h"
#import "ASIFormDataRequest.h"
#import "MessageModel.h"
#import "DiaryPictureClassificationModel.h"
#import "DiaryPictureClassificationSQL.h"
#import "MessageSQL.h"

NSString * const kEMAlbumRequestEngineResultAlbumArray = @"kEMAlbumRequestEngineResultAlbumArray";
NSString * const kEMAlubmRequestEngineResultMemoPhotoArray = @"kEMAlubmRequestEngineResultMemoPhotoArray";
NSString * const kEMAlbumRequestEngineResultLifeTimeAlbum = @"kEMAlbumRequestEngineResultLifeTimeAlbum";

@interface EMPhotoAlbumRequestEngine ()<ASIHTTPRequestDelegate> {
    EMPhotoAlbumRequestFailureBlock _failureBlock;
    EMPhotoAlbumRequestSuccessBlock _successBlcok;
}

@property  (nonatomic, retain) ASIFormDataRequest *request;
@property  (nonatomic, retain) NSDictionary *resultDictionary;

@end

@implementation EMPhotoAlbumRequestEngine

- (void) dealloc {
    
    [_failureBlock release];
    [_successBlcok release];
    [_resultDictionary release];
    [_request release];
    [super dealloc];
}
+ (instancetype)sharedEngine
{
    static EMPhotoAlbumRequestEngine *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)startRequest {
    
    NSURL *url = [[RequestParams sharedInstance] photoAlbums];
    self.request = [ASIFormDataRequest requestWithURL:url];
    self.request.timeOutSeconds = 60;
    [[RequestParams sharedInstance] setCommonDataForRequest:_request];
    [self.request setPostValue:@"list" forKey:@"operation"];
    [self.request setPostValue:@"1" forKey:@"type"];
    self.request.delegate = self;
    [self.request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSData *resultData = [request responseData];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingAllowFragments error:nil];
    NSInteger success = [result[@"success"] integerValue];
    NSString *message = result[@"message"];
    if (success) {
        
        NSArray *albums = result[@"data"];
        NSArray *memorizePhotos = result[@"meta"][@"photos"];
        
        NSMutableArray *albumResultArr = [[NSMutableArray alloc] init];
        NSMutableArray *memoPhotoResultArr = [[NSMutableArray alloc] init];
        __block DiaryPictureClassificationModel *lifetimeDiary = nil;
        [albums enumerateObjectsUsingBlock:^(NSDictionary *albumDic, NSUInteger idx, BOOL *stop) {
            if ([albumDic[@"status"] integerValue] == 1) {
                lifetimeDiary = [[DiaryPictureClassificationModel alloc] initWithDict:albumDic];
            } else {
                DiaryPictureClassificationModel *albumModel = [[DiaryPictureClassificationModel alloc] initWithDict:albumDic];
                [albumResultArr addObject:albumModel];
                [albumModel release];
            }
            
        }];
        
        [memorizePhotos enumerateObjectsUsingBlock:^(NSDictionary *photoDic, NSUInteger idx, BOOL *stop) {
            MessageModel *photoModel = [[MessageModel alloc] initWithDict:photoDic];
            [memoPhotoResultArr addObject:photoModel];
            [photoModel release];
        }];
        
        
        self.resultDictionary = @{kEMAlbumRequestEngineResultAlbumArray: albumResultArr,
                                  kEMAlubmRequestEngineResultMemoPhotoArray: memoPhotoResultArr,
                                  kEMAlbumRequestEngineResultLifeTimeAlbum: lifetimeDiary};
        
        [albumResultArr release];
        [memoPhotoResultArr release];
        
        if (_successBlcok) {
            _successBlcok(_resultDictionary);
        }
        
    } else {
        
        if (_failureBlock) {
            _failureBlock(result[@"errorcode"], message);
        }
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
}

- (oneway void)release  {
    
}

- (id)retain {
    
    return [EMPhotoAlbumRequestEngine sharedEngine];
}

- (id)autorelease {
    
    return [EMPhotoAlbumRequestEngine sharedEngine];
}


- (void)setSuccessBlock:(EMPhotoAlbumRequestSuccessBlock)successBlock {
    if (_successBlcok != successBlock) {
        [_successBlcok release];
        _successBlcok = [successBlock copy];
    }
}
- (void)setFailureBlock:(EMPhotoAlbumRequestFailureBlock)failureBlock {
    if (_failureBlock != failureBlock) {
        [_failureBlock release];
        _failureBlock = [failureBlock copy];
    }
}



@end
