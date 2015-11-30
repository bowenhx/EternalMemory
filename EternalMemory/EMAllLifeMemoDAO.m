//
//  EMAllLifeMemoDAO.m
//  EternalMemory
//
//  Created by FFF on 14-3-17.
//  Copyright (c) 2014年 sun. All rights reserved.
//
#import "DiaryPictureClassificationModel.h"
#import "EMAllLifeMemoDAO.h"
#import "FMDatabase.h"
#import "Config.h"
#import "FMDatabaseQueue.h"
#import "FMDatabasePool.h"
#import "FMDatabaseAdditions.h"
#import "BaseDatas.h"
#import "MessageModel.h"

#define INSERT_SQL(TABLE_NAME) [NSString stringWithFormat:@"INSERT INTO %@ (blogId, content,status, photoWall, theOrder, templateUrl, templatePath, photoUrl, photoPath, title, userId) VALUES (?,?,?,?,?,?,?,?,?,?,?)", TABLE_NAME]
#define UPDATE_SQL(TABLE_NAME) [NSString stringWithFormat:@"update %@ set content=?,status=?,photoWall=?,theOrder=?,title=?,userId=? where blogId=?", TABLE_NAME]

@interface MessageModel (Memo)

- (void)memo_parseDataFromResultSet:(FMResultSet *)rs;

@end

@implementation MessageModel (Memo)

- (void)memo_parseDataFromResultSet:(FMResultSet *)rs {
    self.blogId = [rs stringForColumn:@"blogId"];
    self.ID = [rs intForColumn:@"id"];
    self.content = [rs stringForColumn:@"content"];
    self.status = [rs stringForColumn:@"status"];
    self.photoWall = [rs stringForColumn:@"photoWall"];
    self.theOrder = [rs stringForColumn:@"theOrder"];
    self.templateImageURL = [rs stringForColumn:@"templateUrl"];
    self.templateImagePath = [rs stringForColumn:@"templatePath"];
    self.thumbnail = [rs stringForColumn:@"photoUrl"];
    self.paths = [rs stringForColumn:@"photoPath"];
    self.title = [rs stringForColumn:@"title"];
    self.userId = [rs stringForColumn:@"userId"];
    if (self.blogId.length == 0 || self.blogId == nil) {
        self.thumbnailType = MessageModelThumbnailTypeTemplate;
    }
}

@end

@implementation EMAllLifeMemoDAO

#pragma mark - private
+ (void)handleDataBaseUsingBlock:(void (^)(FMDatabase *db, NSString *tableName))block WithUserID:(NSString *)ID {
    FMDatabase *fmdb = [BaseDatas getBaseDatasInstance];
    NSString *tableName = [NSString stringWithFormat:@"AllLifeMemo_%@",ID];
    if ([fmdb open]) {
        @try {
            block(fmdb, tableName);
        }
        @catch (NSException *exception) {
//            NSLog(@"FMDB exec sql exception: %@", exception);
        }
        @finally {
            [fmdb close];
        }
    }
}


+ (instancetype)sharedInstance
{
    static EMAllLifeMemoDAO *_sharedInstance = nil;
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

#pragma mark - thread safe

- (void)insertModelSafely:(NSArray *)models {
    
}

#pragma mark - insert

+ (void)insertMemoModel:(MessageModel *)model {
    [self handleDataBaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        BOOL flag = [db executeUpdate:INSERT_SQL(tableName), model.blogId, model.content, model.status, model.photoWall, model.theOrder, model.templateImageURL, model.templateImagePath, model.thumbnail, model.paths, model.title, USERID];
        if (flag) {
//            NSLog(@" insert memo success");
        } else {
//            NSLog(@"insert failure  error : %@", [db lastErrorMessage]);
        }
    } WithUserID:USERID];
}


+ (void)insertMemoModels:(NSArray *)model {
    
    [self handleDataBaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@",tableName]];
        
        [model enumerateObjectsUsingBlock:^(MessageModel *model, NSUInteger idx, BOOL *stop) {
            BOOL flag = [db executeUpdate:INSERT_SQL(tableName), model.blogId, model.content, model.status, model.photoWall, model.theOrder, model.templateImageURL, model.templateImagePath, model.attachURL, model.paths, model.title, USERID];
            if (flag) {
//                NSLog(@"insert memo success");
            } else {
//                NSLog(@"insert failure  error : %@", [db lastErrorMessage]);
            }
        }];
        
    } WithUserID:USERID];
    
}

#pragma mark - delete

+ (void)deleteAllMemos {
    [self handleDataBaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *d_sql = [NSString stringWithFormat:@"delete from %@",tableName];
        [db executeUpdate:d_sql];
    } WithUserID:USERID];
}

#pragma mark - update
+ (void)updateMemoPath:(NSString *)path ForBlogId:(NSString *)blogId {
    [self handleDataBaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set photoPath = ? where blogId = ?", tableName];
        BOOL flag = [db executeUpdate:sql, path, blogId];
        NSString *meg = flag ? @"success" : @"failure";
//        NSLog(@"%@", meg);
    } WithUserID:USERID];
}

+ (void)updateMemoPath:(NSString *)path forPhotoWall:(NSString *)photoWall {
    [self handleDataBaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set photoPath = ? where photoWall = ?",tableName];
        [db executeUpdate:sql, path, photoWall];
    } WithUserID:USERID];
}
+ (void)updateTemplatePath:(NSString *)path forPhotoWall:(NSString *)photoWall {
    [self handleDataBaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set templatePath = ? where photoWall = ?", tableName];
        [db executeUpdate:sql, path, photoWall];
    } WithUserID:USERID];
}

#pragma mark - query

+ (NSArray *)allMemoModels {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [self handleDataBaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"select * from %@ order by theOrder asc",tableName];
        FMResultSet *rs = [db executeQuery:s_sql];
        while ([rs next]) {
            MessageModel *model = [MessageModel new];
            [model memo_parseDataFromResultSet:rs];
            [arr addObject:model];
            
        }
    } WithUserID:USERID];
    
    return [arr autorelease];
}
+(DiaryPictureClassificationModel *)getMemoAudio
{
    __block DiaryPictureClassificationModel *model = nil;
    [self handleDataBaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"select * from %@ where title = '一生记忆'",tableName];
        FMResultSet *rs = [db executeQuery:s_sql];
        while ([rs next]) {
            model.accessLevel=[rs stringForColumn:@"accessLevel"];
            model.blogType=[rs stringForColumn:@"blogType"];
            model.blogcount=[rs stringForColumn:@"blogcount"];
            model.deleteStatus=[[rs stringForColumn:@"deleteStatus"] boolValue];
            model.groupId=[rs stringForColumn:@"groupId"];
            model.latestPhotoURL=[rs stringForColumn:@"latestPhotoURL"];
            model.remark=[rs stringForColumn:@"remark"];
            model.syncTime=[rs stringForColumn:@"syncTime"];
            model.title=[rs stringForColumn:@"title"];
            model.userId=[rs stringForColumn:@"userId"];
            model.latestPhotoPath = [rs stringForColumn:@"latestPhotoPath"];
            model.audio.audioURL = [rs stringForColumn:@"voiceURL"];
            model.audio.size =  [[rs stringForColumn:@"voiceSize"] intValue];
            model.audio.duration = [[rs stringForColumn:@"duration"] intValue];
        }
    } WithUserID:USERID];
    return [model autorelease];
}

+ (MessageModel *)modelAtCertainWall:(NSString *)photoWall {
    __block MessageModel *model = nil;
    [self handleDataBaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where photoWall = ?",tableName];
        FMResultSet *rs = [db executeQuery:sql,photoWall];
        if ([rs next]) {
            model = [[MessageModel alloc] init];
            [model memo_parseDataFromResultSet:rs];
        }
    } WithUserID:USERID];
    
    return [model autorelease];
}

+ (NSString *)templateImagePathForCertainWall:(NSString *)photoWall {
    __block NSString *path = nil;
    [self handleDataBaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sql = [NSString stringWithFormat:@"select photoPath from %@ where photoWall = ?",tableName];
        FMResultSet *rs = [db executeQuery:sql, photoWall];
        if ([rs next]) {
            path = [rs stringForColumn:@"templatePath"];
        }
    } WithUserID:USERID];
    
    return path;
}

@end
