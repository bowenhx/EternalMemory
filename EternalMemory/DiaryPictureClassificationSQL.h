//
//  DiaryPictureClassificationSQL.h
//  EternalMemory
//
//  Created by sun on 13-6-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDatas.h"
#import "DiaryPictureClassificationModel.h"


@interface DiaryPictureClassificationSQL : NSObject

+ (DiaryPictureClassificationModel *)getAllLifeAudio;
+ (NSString *)serverversionForGourpId:(NSString *)groupId;
+ (void)setServerversion:(NSString *)serverversion forGroupId:(NSString *)groupId;
+(void)addDiaryPictureClassificationes:(NSArray *)array;
+(NSMutableArray *)getDiaryPictureClassificationes:(NSString *)classificationesblogType AndUserId:(NSString *)userId;
+(NSMutableArray *)getDiaryPictureClassificationesByGroupId:(NSString *)groupId;
//设置日志分组数据中日志的数量（添加、删除日志）
+(void)changeDiaryCountWithGroupId:(NSString *)groupId OperateStyle:(NSString *)style OperateCount:(NSInteger)count;
//通过我的撰记删除日志时
+(void)deleteDiarysFromGroupIdArr:(NSArray *)groupIdArr;
//批量日志分组移动
+(void)moveDiaryFrom:(NSArray *)fromIdArr To:(NSString *)toId;

+(void)refershDiaryPictureClassificationes:(NSArray *)array WithUserID:(NSString *)ID;
+(void)refersh:(NSArray *)array;

+ (void)updataAlbumWithCount:(NSString *)count forGroupID:(NSString *)groupID;
+ (void)updateDiaryWithArr:(NSArray *)diaries WithUserID:(NSString *)ID;
+ (DiaryPictureClassificationModel *)getDiaryModelByGroupId:(NSString *)groupID WithUserID:(NSString *)ID;
+ (void)updateDiaryForGroupId:(NSString *)groupId photoPath:(NSString *)path WithUserID:(NSString *)ID;

+ (NSArray *)albumsExceptForLifeMemoForAUser:(NSString *)userId;
+ (void)updateDiaryAudioInfo:(DiaryPictureClassificationModel *)model ForGrouID:(NSString *)groupId;
+ (void)updateDiaryAudioForServerData:(DiaryPictureClassificationModel *)model ForGrouID:(NSString *)groupId;
+ (void)updatediaryForDeleteAudio:(NSString *)groupId;
+ (void)updatePostPhotoPath:(NSString *)path andPhotoCount:(NSString *)count forGroupId:(NSString *)groupId userId:(NSString *)userId;
+ (void)deleteLifeMemoryAudio:(NSString *)groupId;

+ (void)deleteAllGroup;
+ (void)deleteGroupByBlogType:(NSInteger)blogType AndUserId:(NSString *)userId;
@end
