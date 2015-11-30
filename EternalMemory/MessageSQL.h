//
//  MessageSQL.h
//  EternalMemory
//
//  Created by sun on 13-6-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDatas.h"
#import "MessageModel.h"

@class EMAudio;

@interface MessageSQL : NSObject

+ (void)updataBlogPathUsingBlock:(void (^)(FMDatabase *db, NSString *tableName))block WithUserID:(NSString *)ID;
+ (void)getAlbumBlogUsingBlock:(void (^)(FMDatabase *db, NSString *tableName))block;

+ (void)addBlogs:(NSArray *)blogs;

+ (void)addBlogs:(NSArray *)blogs inGroup:(NSString *)groupId;
+ (void)addBlog:(MessageModel *)model;

+ (void)updateBlog:(MessageModel *)model;
//删除日志
+(void)deleteDiaryBlogs:(NSArray *)BlogIdArr;

#pragma mark - audio cache method
+ (BOOL)updateAudio:(EMAudio *)audio forBlogid:(NSString *)blogid;

+ (BOOL)updataAudio:(EMAudio *)audio forID:(NSString *)ID;

+ (BOOL)updateAudioPath:(NSString *)audioPath forModel:(MessageModel *)model;

+ (BOOL)deleteAudioDataForAnID:(NSString *)ID;

+ (BOOL)deleteAUdioDataForBlogId:(NSString *)blogid;

#pragma mark - 
+ (NSMutableArray *)getNeedsToBeSynedMessages;
+ (void)deleteTempDataWithPath:(NSString *)spaths;
+ (void)updateBlogGroupIdWithArr:(NSArray *)arr;
+ (NSInteger)getMessageCount;


+ (BOOL)deletePhotosWithDeleteList:(NSArray *)blogids;

+(void)updataSPathForImageURL:(NSString *)ImageURLStr withPath:(NSString *)path;

+(NSMutableArray *)getMessages:(NSString *)classificationesblogType AndUserId:(NSString *)userId;
//获取分组的所有图片
+(NSMutableArray *)getAllPhotosWithUserId:(NSString *)userId;
//测试用方法
+(NSMutableArray *)getMessages:(NSString *)classificationesblogType AndUserId:(NSString *)userId Limit:(NSInteger)limitNum;

+(NSMutableArray *)getGroupIDMessages:(NSString *)groupID AndUserId:(NSString *)userId;
+(void)refershMessages:(NSArray *)array clientId:(NSString *)clientId;
+(void)refershMessagesByMessageModelArrayAfterHttp:(NSArray *)array;
+(void)refershMessageAfterUpdata:(NSArray *)array;
+(BOOL)refershMessagesByMessageModelArray:(NSArray *)array;
//处理本地无网时添加的日志数据
+(void)refreshLocalMessages:(NSArray *)localArr ToGroupId:(NSString *)groupId;
//处理本地无网时删除的日志数据
+(void)deleteLocalMessage:(NSArray *)localArr;
+(void)synchronizeBlog:(NSArray *)array WithUserID:(NSString *)ID;
+(MessageModel *)getBlogByBlogId:(NSString *)blogId;
+(BOOL)deletePhoto:(NSArray *)ary;
+(void)deletePhotoByBlogId:(NSArray *)blogIds;
+(void)deleteAllPhotos;
+(NSInteger)getMaxId;
+(NSMutableArray *)getMessagesBySyn:(NSString *)classificationesblogType;

+ (NSArray *)getNeedsSyncPhotos;
+ (NSArray *)getNeedsSyncLifePhotoOrder;

+ (void)refreshAllMessage:(NSArray *)models ForGroupID:(NSString *)groupId;

+(void)updataPathForImageURL:(NSString *)ImageURL withPath:(NSString *)path WithUserID:(NSString *)ID;

@end
