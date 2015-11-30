//
//  DiaryMessageSQL.h
//  EternalMemory
//
//  Created by xiaoxiao on 3/18/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "DiaryMessageModel.h"
@interface DiaryMessageSQL : NSObject



+ (void)updataBlogPathUsingBlock:(void (^)(FMDatabase *db, NSString *tableName))block WithUserID:(NSString *)ID;
+ (BOOL)updateDBData:(BOOL (^)(FMDatabase *db, NSString *tableName))block WithUserID:(NSString *)ID;



+ (void)getAlbumBlogUsingBlock:(void (^)(FMDatabase *db, NSString *tableName))block;
+ (void)addBlogs:(NSArray *)blogs inGroup:(NSString *)groupId;
+ (void)addBlogs:(NSArray *)blogs;
+ (void)addBlog:(DiaryMessageModel *)model;
+ (void)updateBlog:(DiaryMessageModel *)model;
+ (void)deleteDiaryBlogs:(NSArray *)BlogIdArr;
+ (NSInteger)getMessageCount;
+ (void)updateBlogGroupIdWithArr:(NSArray *)arr;
+ (NSMutableArray *)getNeedsToBeSynedMessages;
+(NSMutableArray *)getGroupIDMessages:(NSString *)groupID AndUserId:(NSString *)userId;
+(NSMutableArray *)getMessages:(NSString *)classificationesblogType AndUserId:(NSString *)userId;
//测试用方法
+(NSMutableArray *)getMessages:(NSString *)blogType AndUserId:(NSString *)userId Limit:(NSInteger)limitNum;
+(NSMutableArray *)getMessagesBySyn:(NSString *)blogType;
+(void)refershMessages:(NSArray *)array clientId:(NSString *)clientId;
+(NSInteger)getMaxId;
+(void)synchronizeBlog:(NSArray *)array WithUserID:(NSString *)ID;
+(BOOL)refershMessagesByMessageModelArray:(NSArray *)array;
//处理本地无网时添加的日志数据
+(void)refreshLocalMessages:(NSArray *)localArr ToGroupId:(NSString *)groupId;
//处理本地无网时删除的日志数据
+(void)deleteLocalMessage:(NSArray *)localArr;
+(BOOL)deletePhoto:(NSArray *)ary;
+(void)refershMessagesByMessageModelArrayAfterHttp:(NSArray *)array;
+(void)refershMessageAfterUpdata:(NSArray *)array;
+(DiaryMessageModel *)getBlogByBlogId:(NSString *)blogId;
+ (void)refreshAllMessage:(NSArray *)models ForGroupID:(NSString *)groupId;
//判断是否存在
+ (BOOL)isHadBlog:(NSString *)blogId;
#pragma mark - 保存图片至沙盒
+ (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName;
@end
