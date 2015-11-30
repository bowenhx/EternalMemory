//
//  DiaryGroupsSQL.m
//  EternalMemory
//
//  Created by xiaoxiao on 3/18/14.
//  Copyright (c) 2014 sun. All rights reserved.
//
#import "FMDatabaseAdditions.h"
#import "DiaryGroupsSQL.h"
#import "EMAudio.h"
#import "Config.h"
#import "MD5.h"
@implementation DiaryGroupsSQL

+ (void)updateDiaryUsingBlock:(void (^)(FMDatabase *db,NSString *tableName))block WithUserID:(NSString *)ID
{
    FMDatabase *fmdb = [BaseDatas getBaseDatasInstance];
    NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",ID];
    if ([fmdb open]) {
        @try {
            block(fmdb,tableName);
        }
        @catch (NSException *exception) {
        }
        @finally {
            [fmdb close];
        }
    } else {
    }
    
    fmdb = nil;
}

+ (void)updateDiaryForGroupId:(NSString *)groupId photoPath:(NSString *)path WithUserID:(NSString *)ID
{
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *u_sql = [NSString stringWithFormat:@"UPDATE %@ SET latestPhotoPath = ?  WHERE groupId = ? and blogType = '1'",tableName];
        if([db executeUpdate:u_sql,path,groupId])
        {
        }
        else
        {
        }
    } WithUserID:ID];
}

+ (void)updateDiaryWithArr:(NSArray *)diaries WithUserID:(NSString *)ID
{
    for (DiaryGroupsModel *model in diaries)
    {
        [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
            NSString *u_sql = [NSString stringWithFormat:@"UPDATE %@ SET accessLevel=?,blogType=?,blogcount=?,deleteStatus=?,createTime=?,remark=?,syncTime=?,title=?,userId=? where groupId=? and blogType = 1",tableName];
            if([db executeUpdate:u_sql,model.accessLevel,model.blogType,model.blogcount,[NSNumber numberWithBool: model.deleteStatus],model.createTime,model.remark,model.syncTime,model.title,model.userId,model.groupId])
            {
            } else {
            }
        }WithUserID:ID];
    }
}

+ (DiaryGroupsModel *)getDiaryModelByGroupId:(NSString *)groupID WithUserID:(NSString *)ID
{
    __block DiaryGroupsModel *model = [[DiaryGroupsModel alloc] init];
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
            model.remark=[rs stringForColumn:@"remark"];
            model.syncTime=[rs stringForColumn:@"syncTime"];
            model.title=[rs stringForColumn:@"title"];
            model.userId=[rs stringForColumn:@"userId"];
        }
    } WithUserID:ID];
    return [model autorelease];
}
+ (void)deleteAllGroup
{
    [self updateDiaryUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *d_sql = [NSString stringWithFormat:@"delete from %@",tableName];
        [db executeUpdate:d_sql];
    } WithUserID:USERID];
}

+(void)addDiaryGroups:(NSDictionary *)dict
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",USERID];
        
        DiaryGroupsModel *model = [[[DiaryGroupsModel alloc] initWithDict:dict] autorelease];
        
        NSString *i_sql = [NSString stringWithFormat:@"INSERT INTO %@ (accessLevel,blogType,blogcount,deleteStatus,createTime,groupId,remark,syncTime,title,userId) VALUES(?,?,?,?,?,?,?,?,?,?)",tableName];
        if ([fmDatabase executeUpdate:i_sql,model.accessLevel,model.blogType,model.blogcount,[NSNumber numberWithBool:model.deleteStatus],model.createTime,model.groupId,model.remark,model.syncTime,model.title,model.userId]){
        }
        else{
        }
    }
    [fmDatabase close];
}
+(void)deleteDiaryGroup:(NSDictionary *)dict
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",USERID];
        
        DiaryGroupsModel *model = [[[DiaryGroupsModel alloc] initWithDict:dict] autorelease];
        
        NSString *delSql = [NSString stringWithFormat:@"delete From %@ where groupId = %@",tableName,model.groupId];
        
        if ([fmDatabase executeUpdate:delSql]){
        }
        else{
        }
    }
    [fmDatabase close];
}
+(void)changeDiaryGroup:(NSDictionary *)dict
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",USERID];
        
        DiaryGroupsModel *model = [[[DiaryGroupsModel alloc] initWithDict:dict] autorelease];
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ set title = ? where groupId = ?",tableName];
        if ([fmDatabase executeUpdate:updateSql,model.title,model.groupId]){
        }
        else{
        }
    }
    [fmDatabase close];
}

+(NSMutableArray *)getDiaryGroups:(NSString *)blogType AndUserId:(NSString *)userId
{
    NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",userId];
        NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where blogType = 0 ",tableName];
//        bool deletStyle = YES;
//        NSNumber *deleteNumber = [NSNumber numberWithBool:deletStyle];
        FMResultSet *rs = [fmDatabase executeQuery:sqlite];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                DiaryGroupsModel *model = [[DiaryGroupsModel alloc] init];
                model.accessLevel=[rs stringForColumn:@"accessLevel"];
                model.blogType=[rs stringForColumn:@"blogType"];
                model.blogcount=[rs stringForColumn:@"blogcount"];
                model.deleteStatus=[[rs stringForColumn:@"deleteStatus"] boolValue];
                model.groupId=[rs stringForColumn:@"groupId"];
                model.remark=[rs stringForColumn:@"remark"];
                model.syncTime=[rs stringForColumn:@"syncTime"];
                model.title=[rs stringForColumn:@"title"];
                model.userId=[rs stringForColumn:@"userId"];
                [array addObject:model];
                [model release];
            }
        }
    }
    [fmDatabase close];
    return array;
}

+(NSMutableArray *)getDiaryGroupsByGroupId:(NSString *)groupId
{
    NSMutableArray *array = [[[NSMutableArray alloc]initWithCapacity:0] autorelease];
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",USERID];
        NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where groupId=?  order by id asc",tableName];
        FMResultSet *rs = [fmDatabase executeQuery:sqlite,groupId];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                DiaryGroupsModel *model = [[[DiaryGroupsModel alloc] init] autorelease];
                model.accessLevel=[rs stringForColumn:@"accessLevel"];
                model.blogType=[rs stringForColumn:@"blogType"];
                model.blogcount=[rs stringForColumn:@"blogcount"];
                model.deleteStatus=[[rs stringForColumn:@"deleteStatus"] boolValue];
                model.groupId=[rs stringForColumn:@"groupId"];
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
        NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",USERID];
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
            NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",USERID];
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
        NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",USERID];
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

+(void)refershDiaryGroups:(NSArray *)array WithUserID:(NSString *)ID
{
    
    
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    fmDatabase.logsErrors = YES;
    if([fmDatabase open])
    {
        if ( [array count] > 0 )
        {
            NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",ID];
            for ( NSDictionary *dic in array )
            {
                DiaryGroupsModel *model = [[[DiaryGroupsModel alloc] initWithDict:dic] autorelease];
                NSString *selectSql = [NSString stringWithFormat:@"select * from %@ where groupId = %@",tableName,model.groupId];
                FMResultSet *rs =[fmDatabase executeQuery:selectSql];
                
                if ([rs next])
                {
                    NSString *u_sql = [NSString stringWithFormat:@"update %@ set accessLevel = ?,blogType = ?,blogcount = ?,deleteStatus = ?,createTime = ?,groupId = ?,remark = ?,syncTime = ?,title = ?,userId = ? where groupId = ?",tableName];
                    if([fmDatabase executeUpdate:u_sql,model.accessLevel,model.blogType,model.blogcount,[NSNumber numberWithBool:model.deleteStatus],model.createTime,model.groupId,model.remark,model.syncTime,model.title,model.userId,model.groupId])
                    {
                        continue;
                    }
                    else
                    {
                    }

                }
                else
                {
                    NSString *blogTypeStr = [NSString stringWithFormat:@"%@",model.blogType];
                    BOOL type = [blogTypeStr isEqualToString:@"1"];
                    if (type)
                    {
                    }
                    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (accessLevel,blogType,blogcount,deleteStatus,createTime,groupId,remark,syncTime,title,userId) VALUES(?,?,?,?,?,?,?,?,?,?)",tableName];
                    if ([fmDatabase executeUpdate:sqlStr,model.accessLevel,model.blogType,model.blogcount,model.deleteStatus,model.createTime,model.groupId,model.remark,model.syncTime,model.title,model.userId]){
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
                
                DiaryGroupsModel *model = [[[DiaryGroupsModel alloc] initWithDict:dic] autorelease];
                
                
                NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",USERID];
                
                
                NSString *searchStr = [NSString stringWithFormat:@"select * from %@ where groupId = ?",tableName];
                if ([fmDatabase executeQuery:searchStr,model.groupId])
                {
                    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET accessLevel=?,blogType=?,blogcount=?,deleteStatus=?,createTime=?,remark=?,syncTime=?,title=?,userId=? where groupId=?",tableName];
                    bool isOk = [fmDatabase executeUpdate:sqlStr,model.accessLevel,model.blogType,model.blogcount,[NSNumber numberWithBool: model.deleteStatus],model.createTime,model.remark,model.syncTime,model.title,model.userId,model.groupId];
                    if (isOk){
                    }
                    else
                    {
                    }
                }
                
                else
                {
                    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (accessLevel,blogType,blogcount,deleteStatus,createTime,groupId,remark,syncTime,title,userId) VALUES(?,?,?,?,?,?,?,?,?,?)",tableName];
                    if ([fmDatabase executeUpdate:sqlStr,model.accessLevel,model.blogType,model.blogcount,model.deleteStatus,model.createTime,model.groupId,model.remark,model.syncTime,model.title,model.userId]){
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