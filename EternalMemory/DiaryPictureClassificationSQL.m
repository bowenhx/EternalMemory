//
//  DiaryPictureClassificationSQL.m
//  EternalMemory
//
//  Created by sun on 13-6-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//'id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, accessLevel TEXT,blogType TEXT,blogcount TEXT,createTime TEXT,deleteStatus BOOL,groupId TEXT,latestPhotoURL TEXT,remark TEXT,syncTime TEXT,title TEXT,userId TEXT"

#import "DiaryPictureClassificationSQL.h"
#import "FMDatabaseAdditions.h"
#import "Config.h"
#import "EMAudio.h"
#import "MD5.h"
@implementation DiaryPictureClassificationSQL


+ (void)updateDiaryUsingBlock:(void (^)(FMDatabase *db,NSString *tableName))block WithUserID:(NSString *)ID
{
    FMDatabase *fmdb = [BaseDatas getBaseDatasInstance];
    NSString *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",ID];
    if ([fmdb open]) {
        @try {
            block(fmdb,tableName);
        }
        @catch (NSException *exception) {
//            NSLog(@"FMDB exec sql exception: %@",exception);
        }
        @finally {
            [fmdb close];
        }
    } else {
//        NSLog(@"db open failed , error = %@", [fmdb lastError]);
    }
    
    fmdb = nil;
}
+ (void)updateDiaryAudioInfo:(DiaryPictureClassificationModel *)model ForGrouID:(NSString *)groupId {
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"update %@ set audioPath = ?, audioDuration = ?, audioSize = ?, audioURL = ?, audioStatus = ? where groupId = ?", tableName];
        [db executeUpdate:s_sql,model.audio.wavPath, @(model.audio.duration), @(model.audio.size), model.audio.audioURL, @(model.audio.audioStatus), model.groupId];
    } WithUserID:USERID];
}

+ (void)updateDiaryAudioForServerData:(DiaryPictureClassificationModel *)model ForGrouID:(NSString *)groupId{

    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"update %@ set audioDuration = ?, audioSize = ?, audioURL = ?, audioStatus = ? where groupId = ?", tableName];
        [db executeUpdate:s_sql,model.audio.wavPath, @(model.audio.duration), @(model.audio.size), model.audio.audioURL, @(model.audio.audioStatus), model.groupId];
    } WithUserID:USERID];
}

+ (void)updatediaryForDeleteAudio:(NSString *)groupId{
    
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"update %@ set audioPath = '', audioDuration = '0', audioSize = '0', audioURL = '', audioStatus = '1' where groupId = ?", tableName];
        if (![db executeUpdate:s_sql,groupId]) {
//            NSLog(@"error : %@", [db lastErrorMessage]);
        }
    } WithUserID:USERID];
}
+ (DiaryPictureClassificationModel *)getAllLifeAudio {
    __block DiaryPictureClassificationModel *model = [DiaryPictureClassificationModel new];
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where title = '一生记忆'", tableName];
        FMResultSet *rs = [db executeQuery:sql];
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
            EMAudio *audio = [EMAudio new];
            audio.audioURL = [rs stringForColumn:@"audioURL"];
            audio.wavPath = [rs stringForColumn:@"audioPath"];
            audio.duration = [rs intForColumn:@"audioDuration"];
            audio.size = [rs intForColumn:@"audiSize"];
            model.audio = audio;
            [audio release];

        }
    } WithUserID:USERID];
    
    return [model autorelease];
}

+ (void)updateDiaryForGroupId:(NSString *)groupId photoPath:(NSString *)path WithUserID:(NSString *)ID
{
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *u_sql = [NSString stringWithFormat:@"UPDATE %@ SET latestPhotoPath = ?  WHERE groupId = ? and blogType = '1'",tableName];
        if([db executeUpdate:u_sql,path,groupId])
        {
//            NSLog(@"更新diary成功");
        }
        else
        {
//            NSLog(@"更新diary错误  error ： %@",[db lastError]);
        }
    } WithUserID:ID];
}

+ (void)updatePostPhotoPath:(NSString *)path andPhotoCount:(NSString *)count forGroupId:(NSString *)groupId userId:(NSString *)userId {
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set latestPhotoPath = ?, blogcount = ? where groupId = ? and blogType = '1'",tableName];
        
        BOOL flag = [db executeUpdate:sql, path, count, groupId];
        if (flag) {
        } else {
        }
        
    } WithUserID:USERID];
}


+ (NSString *)serverversionForGourpId:(NSString *)groupId {
    __block NSString *serverversion = nil;
    
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sql = [NSString stringWithFormat:@"select serverversion from %@ where groupId = ?",tableName];
        FMResultSet *rs = [db executeQuery:sql, groupId];
        if ([rs next]) {
            serverversion = [rs stringForColumn:@"serverversion"];
        }
    } WithUserID:USERID];
    
    return serverversion;
}

+ (void)setServerversion:(NSString *)serverversion forGroupId:(NSString *)groupId {
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set serverversion = ? where groupId = ?", tableName];
        BOOL flag = [db executeUpdate:sql, serverversion, groupId];
        if (flag) {
//            NSLog(@"相册版本号更新成功");
        } else {
//            NSLog(@"相册版本号更新失败 : %@", [db lastError]);
        }
    } WithUserID:USERID];
}

+ (void)updateDiaryWithArr:(NSArray *)diaries WithUserID:(NSString *)ID
{
    for (DiaryPictureClassificationModel *model in diaries)
    {
        [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
            NSString *u_sql = [NSString stringWithFormat:@"UPDATE %@ SET accessLevel=?,blogType=?,blogcount=?,deleteStatus=?,createTime=?,latestPhotoURL=?,latestPhotoPath=?,remark=?,syncTime=?,title=?,userId=? where groupId=? and blogType = 1",tableName];
            if([db executeUpdate:u_sql,model.accessLevel,model.blogType,model.blogcount,[NSNumber numberWithBool: model.deleteStatus],model.createTime,model.latestPhotoURL,model.latestPhotoPath,model.remark,model.syncTime,model.title,model.userId,model.groupId])
            {
            } else {
            }
        }WithUserID:ID];
    }
}

+ (DiaryPictureClassificationModel *)getDiaryModelByGroupId:(NSString *)groupID WithUserID:(NSString *)ID
{
    __block DiaryPictureClassificationModel *model = [[DiaryPictureClassificationModel alloc] init];
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"select * from %@ where groupId = ?",tableName];
        FMResultSet *rs = [db executeQuery:s_sql,groupID];
        while ([rs next])
        {
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
        }
    } WithUserID:ID];
    return [model autorelease];
}
+ (void)deleteAllGroup {
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *d_sql = [NSString stringWithFormat:@"delete from %@",tableName];
        [db executeUpdate:d_sql];
    } WithUserID:USERID];
}

+ (void)deleteGroupByBlogType:(NSInteger)blogType AndUserId:(NSString *)userId{
    
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    if ([db open]) {
        NSString *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",userId];
        NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where blogType = ?",tableName];
        [db executeUpdate:sqlStr,[NSNumber numberWithInt:blogType]];
    }
    [db close];
    db = nil;
}
+(void)addDiaryPictureClassificationes:(NSArray *)array
{
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        [array enumerateObjectsUsingBlock:^(DiaryPictureClassificationModel *model, NSUInteger idx, BOOL *stop) {
            NSString *s_sql = [NSString stringWithFormat:@"select * from %@ where groupId = ?",tableName];
            FMResultSet *rs = [db executeQuery:s_sql, model.groupId];
            if ([rs next]) {
                NSString *u_sql = [NSString stringWithFormat:@"update %@ set accessLevel = ?,blogType = ?,blogcount = ?,deleteStatus = ?,createTime = ?,groupId = ?,latestPhotoURL = ?,latestPhotoPath = ?,remark = ?,syncTime = ?,title = ?,userId = ?,audioPath = ?, audioDuration = ?, audioSize = ?, audioURL = ?, audioStatus = ? where groupId = ?", tableName];
                BOOL flag = [db executeUpdate:u_sql,model.accessLevel,model.blogType,model.blogcount,[NSNumber numberWithBool:model.deleteStatus],model.createTime,model.groupId,model.latestPhotoURL,model.latestPhotoPath,model.remark,model.syncTime,model.title,model.userId,model.audio.wavPath, @(model.audio.duration), @(model.audio.size), model.audio.audioURL, @(model.audio.audioStatus), model.groupId];
                if (!flag) {
                }
            } else {
                
                NSString *i_sql = [NSString stringWithFormat:@"INSERT INTO %@ (accessLevel,blogType,blogcount,deleteStatus,createTime,groupId,latestPhotoURL,latestPhotoPath,remark,syncTime,title,userId,audioPath, audioDuration, audioSize, audioURL, audioStatus) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
                if ([db executeUpdate:i_sql,model.accessLevel,model.blogType,model.blogcount,[NSNumber numberWithBool:model.deleteStatus],model.createTime,model.groupId,model.latestPhotoURL,model.latestPhotoPath,model.remark,model.syncTime,model.title,model.userId,model.audio.wavPath, @(model.audio.duration), @(model.audio.size), model.audio.audioURL, @(model.audio.audioStatus)]){
                }
                else{
                }
            }
        }];
    } WithUserID:USERID];
}


+(NSMutableArray *)getDiaryPictureClassificationes:(NSString *)classificationesblogType AndUserId:(NSString *)userId
{
    NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
       NSString *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",userId];
       NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where blogType =? and (deleteStatus !=? or deleteStatus is null) order by id asc",tableName];
        bool deletStyle = YES;
        NSNumber *deleteNumber = [NSNumber numberWithBool:deletStyle];
        FMResultSet *rs = [fmDatabase executeQuery:sqlite,classificationesblogType,deleteNumber];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                DiaryPictureClassificationModel *model = [[DiaryPictureClassificationModel alloc] init];
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
                [array addObject:model];
                [model release];
            }
        }
    }
    [fmDatabase close];
    return array;
}


+ (NSArray *)albumsExceptForLifeMemoForAUser:(NSString *)userId {
    __block NSMutableArray *arr = [NSMutableArray array];
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where title != '一生记忆' and blogType = '1'",tableName];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            DiaryPictureClassificationModel *model = [DiaryPictureClassificationModel new];
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
            [arr addObject:model];
            [model release];

        }
    } WithUserID:USERID];
    
    return arr;
}

+ (void)updataAlbumWithCount:(NSString *)count forGroupID:(NSString *)groupID
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    NSString *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",USERID];
    if ([fmDatabase open] && [fmDatabase tableExists:tableName]) {
        NSString *u_sql = [NSString stringWithFormat:@"update %@ set blogcount = ? where groupId = ?",tableName];
        if ([fmDatabase executeUpdate:u_sql])
        {
        }
    }
    else
    {
    }
}

+(NSMutableArray *)getDiaryPictureClassificationesByGroupId:(NSString *)groupId
{
    NSMutableArray *array = [[[NSMutableArray alloc]initWithCapacity:0] autorelease];
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",USERID];
        NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where groupId=?  order by id asc",tableName];
        FMResultSet *rs = [fmDatabase executeQuery:sqlite,groupId];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                DiaryPictureClassificationModel *model = [[[DiaryPictureClassificationModel alloc] init] autorelease];
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
                [array addObject:model];
            }
        }
    }
    [fmDatabase close];
    return array;
}

//设置日志分组数据中日志的数量（添加、删除日志）
+(void)changeDiaryCountWithGroupId:(NSString *)groupId OperateStyle:(NSString *)style OperateCount:(NSInteger)count
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSInteger origincount = 0;
        NSString *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",USERID];
        NSString *selectSql = [NSString stringWithFormat:@"select * from %@ where groupId = ?",tableName];
        FMResultSet *rs = [fmDatabase executeQuery:selectSql,groupId];
        if (rs != nil)
        {
            while ([rs next])
            {
                origincount = [[rs stringForColumn:@"blogcount"] intValue];
            }
        }
        if ([style isEqualToString:@"addDiary"])
        {
            origincount +=count;
        }
        else if ([style isEqualToString:@"deleteDiary"])
        {
            if (origincount > count || origincount == count)
            {
                origincount -= count;
            }
        }
        NSString *updateSql = [NSString stringWithFormat:@"Update %@ set blogcount = ? where groupId = ?",tableName];
        [fmDatabase executeUpdate:updateSql,[NSString stringWithFormat:@"%d",origincount],groupId];
    }
    [fmDatabase close];
}

//通过我的撰记删除日志时
+(void)deleteDiarysFromGroupIdArr:(NSArray *)groupIdArr
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSInteger count = groupIdArr.count;
        for (int i = 0; i < count; i++)
        {
            NSInteger originCount = 0;
            NSString *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",USERID];
            NSString *groupId = groupIdArr[i];
            NSString *selectSql = [NSString stringWithFormat:@"select * from %@ where groupId = ?",tableName];
            FMResultSet *rs = [fmDatabase executeQuery:selectSql,groupId];
            if (rs != nil)
            {
                while ([rs next])
                {
                    originCount = [[rs stringForColumn:@"blogcount"] intValue];
                }
            }
            if (originCount > 0)
            {
                originCount -= 1;
                NSString *updateSql = [NSString stringWithFormat:@"Update %@ set blogcount = ? where groupId = ?",tableName];
                [fmDatabase executeUpdate:updateSql,[NSString stringWithFormat:@"%d",originCount],groupId];
            }
        }
    }
    [fmDatabase close];
}

//批量日志分组移动
+(void)moveDiaryFrom:(NSArray *)fromIdArr To:(NSString *)toId
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",USERID];
        NSInteger count = fromIdArr.count;
        for (int i = 0; i < count; i++)
        {
            NSString *fromId = fromIdArr[i];
            NSInteger fromCount = 0;
            NSInteger toCount = 0;
            if (![fromId isEqualToString:toId])
            {
                NSString *deleteSql = [NSString stringWithFormat:@"select * from %@ where groupId = ?",tableName];
                FMResultSet *deleteRs = [fmDatabase executeQuery:deleteSql,fromId];
                if (deleteRs != nil)
                {
                    while ([deleteRs next])
                    {
                        fromCount = [[deleteRs stringForColumn:@"blogcount"] intValue];
                    }
                }
                if (fromCount > 0)
                {
                    fromCount -= 1;
                    NSString *updateSql = [NSString stringWithFormat:@"Update %@ set blogcount = ? where groupId = ?",tableName];
                    [fmDatabase executeUpdate:updateSql,[NSString stringWithFormat:@"%d",fromCount],fromId];
                }
                
                NSString *addSql = [NSString stringWithFormat:@"select * from %@ where groupId = ?",tableName];
                FMResultSet *addRs = [fmDatabase executeQuery:addSql,toId];
                if (addRs != nil)
                {
                    while ([addRs next])
                    {
                        toCount = [[addRs stringForColumn:@"blogcount"] intValue];
                    }
                }
                if (toCount > 0 || toCount == 0)
                {
                    toCount += 1;
                    NSString *updateSql = [NSString stringWithFormat:@"Update %@ set blogcount = ? where groupId = ?",tableName];
                    [fmDatabase executeUpdate:updateSql,[NSString stringWithFormat:@"%d",toCount],toId];
                }
            }
        }
    }
    [fmDatabase close];
}

+(void)refershDiaryPictureClassificationes:(NSArray *)array WithUserID:(NSString *)ID
{
    
    
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    fmDatabase.logsErrors = YES;
    if([fmDatabase open])
    {
        if ( [array count] > 0 )
        {
            NSString *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",ID];
            NSString *deletStr = [NSString stringWithFormat:@"DELETE FROM %@ where blogType = '1'",tableName];
            if (![fmDatabase executeUpdate:deletStr]) {
                return;
            }
            for ( NSDictionary *dic in array )
            {
                DiaryPictureClassificationModel *model = [[[DiaryPictureClassificationModel alloc] initWithDict:dic] autorelease];
                
                DiaryPictureClassificationModel *tempModel = [self getDiaryModelByGroupId:model.groupId WithUserID:ID];
//                if ([tempModel.groupId isEqualToString:[NSString stringWithFormat:@"%@",model.groupId]] && tempModel.groupId.length != 0)
                if (tempModel.groupId.length != 0)
                {
                    NSString *u_sql = [NSString stringWithFormat:@"update %@ set accessLevel = ?,blogType = ?,blogcount = ?,deleteStatus = ?,createTime = ?,groupId = ?,latestPhotoURL = ?,remark = ?,syncTime = ?,title = ?,userId = ? where groupId = ?",tableName];
                    if([fmDatabase executeUpdate:u_sql,model.accessLevel,model.blogType,model.blogcount,[NSNumber numberWithBool:model.deleteStatus],model.createTime,model.groupId,model.latestPhotoURL,model.remark,model.syncTime,model.title,model.userId,model.groupId])
                    {
                        
                        continue;
                    }
                    else
                    {
                    }
                }
                
                NSString *blogTypeStr = [NSString stringWithFormat:@"%@",model.blogType];
                BOOL type = [blogTypeStr isEqualToString:@"1"];
                if (type)
                {
                    
                    //                    NSString *imgName = [NSString stringWithFormat:@"simg_%@.png",model.latestPhotoURL];
                    //                    NSString *localImgName = [MD5 md5:imgName];
                    //                    model.latestPhotoPath = [self dataPath:localImgName];
                }
                NSString *sqlStr = [NSString stringWithFormat:@"I NSERT INTO %@ (accessLevel,blogType,blogcount,deleteStatus,createTime,groupId,latestPhotoURL,remark,syncTime,title,userId,latestPhotoPath) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
                if ([fmDatabase executeUpdate:sqlStr,model.accessLevel,model.blogType,model.blogcount,model.deleteStatus,model.createTime,model.groupId,model.latestPhotoURL,model.remark,model.syncTime,model.title,model.userId,model.latestPhotoPath]){
                }
                else
                {
                }
            }
        }
    }
    [fmDatabase close];
}

+(void)refersh:(NSArray *)array
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    fmDatabase.logsErrors = YES;
    if([fmDatabase open])
    {
        if ( [array count] > 0 )
        {
            for ( NSDictionary *dic in array )
            {
                
                DiaryPictureClassificationModel *model = [[[DiaryPictureClassificationModel alloc] initWithDict:dic] autorelease];
                
                
                NSString *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",USERID];
                
                
                NSString *searchStr = [NSString stringWithFormat:@"select * from %@ where groupId = ?",tableName];
                if ([fmDatabase executeQuery:searchStr,model.groupId])
                {
                    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET accessLevel=?,blogType=?,blogcount=?,deleteStatus=?,createTime=?,latestPhotoURL=?,remark=?,syncTime=?,title=?,userId=? where groupId=?",tableName];
                    bool isOk = [fmDatabase executeUpdate:sqlStr,model.accessLevel,model.blogType,model.blogcount,[NSNumber numberWithBool: model.deleteStatus],model.createTime,model.latestPhotoURL,model.remark,model.syncTime,model.title,model.userId,model.groupId];
                    if (isOk){
                    }
                    else
                    {
                    }
                }

                else
                {
                    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (accessLevel,blogType,blogcount,deleteStatus,createTime,groupId,latestPhotoURL,remark,syncTime,title,userId,latestPhotoPath) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
                    if ([fmDatabase executeUpdate:sqlStr,model.accessLevel,model.blogType,model.blogcount,model.deleteStatus,model.createTime,model.groupId,model.latestPhotoURL,model.remark,model.syncTime,model.title,model.userId,model.latestPhotoPath]){
                    }
                    else
                    {
                    }
                }
            }
        }
    }
    [fmDatabase close];

}
#pragma mark - 保存图片至沙盒
+ (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    NSString *fullPath = [Utilities dataPath:imageName FileType:@"Images" UserID:USERID];
    [imageData writeToFile:fullPath atomically:NO];
}

@end
