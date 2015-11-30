//
//  DiaryGroupsSQL.h
//  EternalMemory
//
//  Created by xiaoxiao on 3/18/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "BaseDatas.h"
#import "DiaryGroupsModel.h"
#import <Foundation/Foundation.h>

@interface DiaryGroupsSQL : NSObject


+ (void)updateDiaryUsingBlock:(void (^)(FMDatabase *db,NSString *tableName))block WithUserID:(NSString *)ID;
+ (void)updateDiaryForGroupId:(NSString *)groupId photoPath:(NSString *)path WithUserID:(NSString *)ID;
+ (void)updateDiaryWithArr:(NSArray *)diaries WithUserID:(NSString *)ID;

+ (DiaryGroupsModel *)getDiaryModelByGroupId:(NSString *)groupID WithUserID:(NSString *)ID;
+ (void)deleteAllGroup;
+(void)addDiaryGroups:(NSDictionary *)dict;
+(void)deleteDiaryGroup:(NSDictionary *)dict;
+(void)changeDiaryGroup:(NSDictionary *)dict;

+(NSMutableArray *)getDiaryGroups:(NSString *)blogType AndUserId:(NSString *)userId;
+(NSMutableArray *)getDiaryGroupsByGroupId:(NSString *)groupId;

//设置日志分组数据中日志的数量（添加、删除日志）
+(void)changeDiaryCountWithGroupId:(NSString *)groupId OperateStyle:(NSString *)style OperateCount:(NSInteger)count;
//通过我的撰记删除日志时
+(void)deleteDiarysFromGroupIdArr:(NSArray *)groupIdArr;
//批量日志分组移动
+(void)moveDiaryFrom:(NSArray *)fromIdArr To:(NSString *)toId;
+(void)refershDiaryGroups:(NSArray *)array WithUserID:(NSString *)ID;
+(void)refersh:(NSArray *)array;
+ (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName;

@end
