//
//  BaseDatas.m
//  EternalMemory
//
//  Created by Guibing Li on 13-5-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "BaseDatas.h"
#import "DatasTabas.h"
#import "FMDatabaseAdditions.h"
#import "DiaryPictureClassificationSQL.h"
#import "Config.h"
#import "FMDatabaseQueue.h"
@implementation BaseDatas

+ (FMDatabase *)getBaseDatasInstance
{
    NSString * doc = PATH_OF_DOCUMENT;
    NSString * path = [doc stringByAppendingPathComponent:@"memory.db"];
    FMDatabase * db = [FMDatabase databaseWithPath:path];
    return db;
}
+ (FMDatabase *)getBaseAreaDataInstance{
    NSString * doc = PATH_OF_DOCUMENT;
    NSString * path = [doc stringByAppendingPathComponent:@"t_area.db"];
    FMDatabase * db = [FMDatabase databaseWithPath:path];
    return db;
}
//创建关联人数据表
+(void)createAssocaitedDB:(NSString *)uid
{
    FMDatabase *fmDats = [BaseDatas getBaseDatasInstance];
    if ([fmDats open])
    {
        
        if(![fmDats tableExists:[NSString stringWithFormat:@"DiaryPictureClassification_%@",uid]]){
            [fmDats executeUpdate:DiaryPictureClassification(uid)];
            [BaseDatas addDefuleGroupWithUserID:uid];
        }
        if (![fmDats tableExists:[NSString stringWithFormat:@"MyFamily_%@",uid]]) {
            [fmDats executeUpdate:MyFamily(uid)];
        }
        if(![fmDats tableExists:[NSString stringWithFormat:@"Message_%@",uid]]){
            [fmDats executeUpdate:Message(uid)];
        }
    }
    [fmDats close];
}
//删除关联人数据表
+(void)deleteAssocaitedDB:(NSString *)uid
{
    FMDatabase *fmDats = [BaseDatas getBaseDatasInstance];
    NSString *dropDP = [NSString stringWithFormat:@"drop table DiaryPictureClassification_%@",uid];
    [fmDats executeUpdate:dropDP];
    NSString *dropMessage = [NSString stringWithFormat:@"drop table Message_%@",uid];
    [fmDats executeUpdate:dropMessage];
    NSString *dropFamily = [NSString stringWithFormat:@"drop table MyFamily_%@",uid];
    [fmDats executeUpdate:dropFamily];
}
+ (void)openBaseDatas:(NSString *)uid
{
    FMDatabase *fmDats = [BaseDatas getBaseDatasInstance];
    if (![fmDats open])
    {
        return;
    }
    else
    {
        //在这里创建数据表
        [self creatTable:fmDats andUserId:uid];
    }
    [fmDats setShouldCacheStatements:YES];
    [fmDats beginTransaction];
    [fmDats commit];
    
}

+ (void)creatTable:(FMDatabase *)fmDats andUserId:(NSString *)uid{
    
    if (![fmDats tableExists:@"DBVersion"]) {
        [fmDats executeUpdate:DBVersion];
    }
    
    if(![fmDats tableExists:[NSString stringWithFormat:@"DiaryPictureClassification_%@",uid]]){
        [fmDats executeUpdate:DiaryPictureClassification(uid)];
//        [BaseDatas addDefuleGroupWithUserID:uid];
    }
    if(![fmDats tableExists:[NSString stringWithFormat:@"DiaryGroups_%@",uid]]){
        [fmDats executeUpdate:DiaryGroups(uid)];
        [BaseDatas addDiaryDefaultGroupWithUserID:uid];
    }
    if (![fmDats tableExists:[NSString stringWithFormat:@"AllLifeMemo_%@",uid]]) {
        [fmDats executeUpdate:AllLifeMemo(uid)];
    }
    if (![fmDats tableExists:[NSString stringWithFormat:@"StyleList_%@",PUBLICUID]]) {
        [fmDats executeUpdate:StyleList(PUBLICUID)];
    }
    if (![fmDats tableExists:[NSString stringWithFormat:@"StyleDownLoad_%@",PUBLICUID]]) {
        [fmDats executeUpdate:StyleDownLoad(PUBLICUID)];
    }
    if (![fmDats tableExists:[NSString stringWithFormat:@"MyFamily_%@",uid]]) {
        [fmDats executeUpdate:MyFamily(uid)];
    }
    if(![fmDats tableExists:[NSString stringWithFormat:@"Message_%@",uid]]){
        [fmDats executeUpdate:Message(uid)];
    }
    if(![fmDats tableExists:[NSString stringWithFormat:@"DiaryMessage_%@",uid]]){
        [fmDats executeUpdate:DiaryMessage(uid)];
    }

    if (![fmDats tableExists:@"ExceptionBug"]) {
        [fmDats executeUpdate:ExceptionBug];
    }

}
+ (void)closeBaseDatas:(NSString *)uid
{
	FMDatabase *fmDats = [BaseDatas getBaseDatasInstance];
    if (![fmDats close])
    {
    }else
    {
    }
}
//判断是否存在
+ (BOOL) isHadGroup:(NSString *)groupId WithUserID:(NSString *)ID
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    
    fmDatabase.logsErrors = YES;
    if(![fmDatabase open])
    {
    }
    
    NSString *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",ID];
    NSString *sql = [NSString stringWithFormat:@"SELECT groupId FROM %@ WHERE groupId=?",tableName];
    FMResultSet *result = [fmDatabase executeQuery:sql,groupId];
    while ([result next])
    {
        return YES;
    }
    return NO;
}

+(BOOL)addDiaryDefaultGroupWithUserID:(NSString *)ID
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    
    fmDatabase.logsErrors = YES;
    if(![fmDatabase open])
    {
    }
    
    NSString *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",ID];
    NSString *sql = [NSString stringWithFormat:@"SELECT groupId FROM %@ WHERE groupId=?",tableName];
    FMResultSet *result = [fmDatabase executeQuery:sql,@"-1"];
    while ([result next])
    {
        return YES;
    }
    NSString * doc = PATH_OF_DOCUMENT;
    NSString * path = [doc stringByAppendingPathComponent:@"memory.db"];
    FMDatabase *fmDats = [BaseDatas getBaseDatasInstance];
    [fmDats open];
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_async(q1, ^
                   {
                           [queue inDatabase:^(FMDatabase *db)
                            {
                                NSString  *tableName = [NSString stringWithFormat:@"DiaryGroups_%@",ID];
                                NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (accessLevel,blogType,createTime,groupId,title,deleteStatus,syncTime,userId) VALUES(?,?,?,?,?,?,?,?)",tableName];
                                NSString *accessLevelStr = [NSString stringWithFormat:@"0"];
                                NSDate *date = [NSDate date];
                                NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
                                NSString *timeStr =[NSString stringWithFormat:@"%f",timestamp];
                                NSString *titleStr ;
                                NSString *deleteStatusStr = [NSString stringWithFormat:@"0"];
                                titleStr = [NSString stringWithFormat:@"默认日记"];
                                if ([db executeUpdate:sqlStr,accessLevelStr,@"0",timeStr,@"-1",titleStr,deleteStatusStr,timeStr,ID])
                                {
                                    
                                }
                                else{
                                }
                                
                            }];
                   });

    
    return NO;
}

+ (void)addDefuleGroupWithUserID:(NSString *)ID
{
    if ([self isHadGroup:@"-1" WithUserID:ID])
    {
        return;
    }
    if ([self isHadGroup:@"0" WithUserID:ID])
    {
        return;
    }
    NSString * doc = PATH_OF_DOCUMENT;
    NSString * path = [doc stringByAppendingPathComponent:@"memory.db"];
    FMDatabase *fmDats = [BaseDatas getBaseDatasInstance];
    [fmDats open];
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_async(q1, ^
    {
        for (int i = -1; i < 1; ++i)
        {
            [queue inDatabase:^(FMDatabase *db)
            {
                NSString  *tableName = [NSString stringWithFormat:@"DiaryPictureClassification_%@",ID];
                NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (accessLevel,blogType,createTime,groupId,title,deleteStatus,syncTime,userId) VALUES(?,?,?,?,?,?,?,?)",tableName];
                NSString *accessLevelStr = [NSString stringWithFormat:@"0"];
                NSString *blogTypeStr = [NSString stringWithFormat:@"%d",i+1];
                NSDate *date = [NSDate date];
                NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
                NSString *timeStr =[NSString stringWithFormat:@"%f",timestamp];
                NSString *groupIdStr = [NSString stringWithFormat:@"%d",i];
                NSString *titleStr ;
                NSString *deleteStatusStr = [NSString stringWithFormat:@"0"];
                if (i==-1)
                {
                    titleStr = [NSString stringWithFormat:@"默认日记"];
                }else{
                    titleStr = [NSString stringWithFormat:@"默认相册"];
                }
                if ([db executeUpdate:sqlStr,accessLevelStr,blogTypeStr,timeStr,groupIdStr,titleStr,deleteStatusStr,timeStr,ID]){
                    
                }
                else{
                }
               
            }];
        }
    });
}
+(void)moveToDBFile
{
	NSString *sourcesPath = [[NSBundle mainBundle] pathForResource:@"t_area" ofType:@"db"];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentPath = [paths objectAtIndex:0];
	NSString *desPath = [documentPath stringByAppendingPathComponent:@"t_area.db"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:desPath])
	{
		NSError *error ;
		
		if ([fileManager copyItemAtPath:sourcesPath toPath:desPath error:&error]) {
		}
		else {
		}
	}
}
+ (BOOL)isTableExit:(NSString *)userId{
    
    FMDatabase *fmDats = [BaseDatas getBaseDatasInstance];
    if (![fmDats open]) {
    }else{
        BOOL a = [fmDats tableExists:[NSString stringWithFormat:@"DiaryPictureClassification_%@",userId]];
        [fmDats close];
        return a;
    }
    return NO;
}

+ (NSInteger)getDBVersion{
    
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    NSInteger dbVersion = 0;
    if (![db open]) {
    }else{
        NSString *tableName = @"DBVersion";
        NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSNumber *version = [NSNumber numberWithInt:[rs intForColumn:@"dbVersion"]];
            dbVersion = [version integerValue];
        }
    }
    [db close];
    return dbVersion;
}

+ (void)setDBVersion:(NSInteger)version andUserId:(NSString *)userId{
    
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    NSString *tableName = @"DBVersion";

    NSInteger oldVersion = [self getDBVersion];
    if (oldVersion == 0) {
        NSString *sql = [NSString stringWithFormat:@"insert into %@(DBVersion)VALUES(?)",tableName];
        [db executeUpdate:sql,[NSNumber numberWithInt:version]];
    }else{
        NSString *sql = [NSString stringWithFormat:@"update %@ set dbVersion=?",tableName];
        BOOL a = [db executeUpdate:sql,[NSNumber numberWithInt:version]];
        if (a) {
        }
    }
    [db close];
    
}

+ (void)upgradeDB:(NSString *)userId{

    NSInteger version = [self getDBVersion];
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    if (![db open]) {
    }else{
        switch (version) {
            case 0:
            {
//                [self creatTable:db andUserId:userId];
                [self setDBVersion:1 andUserId:userId];
//                [db setShouldCacheStatements:YES];
//                [db beginTransaction];
//                [db commit];
            }
            case 1:
            {
                NSArray *fieldAry = [NSArray arrayWithObjects:@"birthDateStr",@"deathDateStr",nil];
                for (NSString *field in fieldAry) {
                    
                    NSString *sql = [NSString stringWithFormat:@"alter table MyFamily_%@ add %@ text default ''",userId,field];
                    [db executeUpdate:sql];
                    
                }
                NSArray *fieldAryPhoto = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"audioPath",@"text",nil],[NSArray arrayWithObjects:@"audioDuration",@"interger",nil],[NSArray arrayWithObjects:@"audioSize",@"interger",nil],[NSArray arrayWithObjects:@"audioURL",@"text",nil],[NSArray arrayWithObjects:@"audioStatus",@"integer",nil], nil];
                for(NSArray *ary in fieldAryPhoto){
                    
                    NSString *sql = [NSString stringWithFormat:@"alter table Message_%@ add %@ %@ default ''",userId,ary[0],ary[1]];
                    [db executeUpdate:sql];

                }
                [self setDBVersion:2 andUserId:userId];
            }
            case 2:
            {
                if (![db tableExists:[NSString stringWithFormat:@"AllLifeMemo_%@",userId]]) {
                    [db executeUpdate:AllLifeMemo(userId)];
                }
                if(![db tableExists:[NSString stringWithFormat:@"DiaryMessage_%@",userId]]){
                    [db executeUpdate:DiaryMessage(userId)];
                }
                if(![db tableExists:[NSString stringWithFormat:@"DiaryGroups_%@",userId]]){
                    [db executeUpdate:DiaryGroups(userId)];
//                    [BaseDatas addDiaryDefaultGroupWithUserID:userId];
                }
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:DIARYVERSION];
                
                NSArray *fieldAry = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"theOrder",@"text",nil],[NSArray arrayWithObjects:@"photoWall",@"text",nil],[NSArray arrayWithObjects:@"templatePath",@"text",nil],[NSArray arrayWithObjects:@"templateUrl",@"text",nil], nil];
                for(NSArray *ary in fieldAry){
                    
                    NSString *sql = [NSString stringWithFormat:@"alter table Message_%@ add %@ %@ default ''",userId,ary[0],ary[1]];
                    [db executeUpdate:sql];
                    
                }
                NSArray *fieldPhotoAry = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"audioPath",@"text",nil],[NSArray arrayWithObjects:@"audioDuration",@"interger",nil],[NSArray arrayWithObjects:@"audioSize",@"interger",nil],[NSArray arrayWithObjects:@"audioURL",@"text",nil],[NSArray arrayWithObjects:@"audioStatus",@"interger",nil],[NSArray arrayWithObjects:@"syncStatus",@"interger",nil], nil];
                for(NSArray *ary in fieldPhotoAry){
                    
                    NSString *sql = [NSString stringWithFormat:@"alter table DiaryPictureClassification_%@ add %@ %@ default ''",userId,ary[0],ary[1]];
                    [db executeUpdate:sql];
                }
                [DiaryPictureClassificationSQL deleteGroupByBlogType:0 AndUserId:userId];
                [self setDBVersion:3 andUserId:userId];
            }
            default:
                break;
        }
        [db close];
    }
}
@end
