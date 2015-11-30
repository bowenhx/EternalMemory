//
//  StyleListSQL.h
//  EternalMemory
//
//  Created by Guibing on 13-8-30.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDatas.h"
@interface StyleListSQL : NSObject

+ (void)saveAllStyleListData:(NSMutableArray *)arr andUid:(NSString *)uid;
+ (NSMutableArray *)getAllStyleListData;
+ (void)addDownLoadList:(NSInteger)arr;
+ (void)updateDownLoadState:(NSInteger)styleId;
+ (void)isDelectdateDownLoadState:(NSInteger)state styleID:(NSInteger)styleId;
+ (NSInteger)getDownLoadState:(NSInteger)styleId;
+ (void)deleteDownLoad:(NSInteger)styleId;
+ (void)deleteDownLoadByIsDownLoad:(NSInteger)isDownLoad;
@end
