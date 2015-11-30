//
//  BaseDatas.h
//  EternalMemory
//
//  Created by Guibing Li on 13-5-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "StyleListSQL.h"
@class DiaryPictureClassificationModel;
@class MessageModel;

@interface BaseDatas : NSObject

+ (FMDatabase *)getBaseDatasInstance;
+ (FMDatabase *)getBaseAreaDataInstance;
//创建关联人数据表
+(void)createAssocaitedDB:(NSString *)uid;
+(BOOL)addDiaryDefaultGroupWithUserID:(NSString *)ID;
//删除关联人数据表
+(void)deleteAssocaitedDB:(NSString *)uid;
+ (void)openBaseDatas:(NSString *)uid;
+ (void)closeBaseDatas:(NSString *)uid;
+ (void)addDefuleGroupWithUserID:(NSString *)ID;
+ (BOOL) isHadGroup:(NSString *)groupId WithUserID:(NSString *)ID;
+ (void)moveToDBFile;
+ (BOOL)isTableExit:(NSString *)userId;
+ (void)upgradeDB:(NSString *)userId;
@end
