//
//  SavedRequests.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-8-1.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

@interface SavedRequests : NSObject
{
    NSMutableArray *_reqeusts;
}
@property (nonatomic, retain) NSMutableArray *requests;
@property (nonatomic, retain) ASINetworkQueue *requestQueue;
@property (nonatomic, copy)   NSString  *errorcodeStr;

+ (id)sharedSavedRequests;

- (void)setUpReqeustQueueDelegate:(id)delegate;

@end
