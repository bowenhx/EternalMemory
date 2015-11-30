//
//  StyleListSQL.m
//  EternalMemory
//
//  Created by Guibing on 13-8-30.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "StyleListSQL.h"
//#import "FMDatabase.h"
#import "SavaData.h"
#define StyleList(UIDNAME)     [NSString stringWithFormat:@"StyleList_%@",UIDNAME]
#define StyleDownLoad(UIDNAME)     [NSString stringWithFormat:@"StyleDownLoad_%@",UIDNAME]

@implementation StyleListSQL

/*
 @"CREATE TABLE if not exists 'StyleList%@'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,sid INTEGER,zippath TEXT,thumbnail TEXT,styleName TEXT,styleId INTEGER,isDown BOOL)",UIDNAME
 */
+ (void)saveAllStyleListData:(NSMutableArray *)arr andUid:(NSString *)uid
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
       
        if ( [arr count] > 0 )
        {
            NSString *tableName = [NSString stringWithFormat:@"StyleList_%@",PUBLICUID];
            NSString *sql=[NSString stringWithFormat:@"DELETE FROM %@",tableName];
            [fmDatabase executeUpdate:sql];
//            NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (jsonStr) VALUES(?)",tableName];
//            [fmDatabase executeUpdate:sqlStr,[arr JSONString]];
            for ( NSDictionary *dic in arr )
            {
                NSString *tableName = [NSString stringWithFormat:@"StyleList_%@",PUBLICUID];
                NSNumber *sid = dic[@"sid"];
                NSString *typeName = dic[@"typename"];
                NSMutableArray *styleArr = dic[@"styles"];
                for (NSDictionary *dicStyles in styleArr) {
                    NSString *zippath = dicStyles[@"zippath"];
                    NSString *zipname = dicStyles[@"zipname"];
                    NSString *thumbnail = dicStyles[@"thumbnail"];
                    NSString *bigimagepath = dicStyles[@"bigimagepath"];
                    NSString *styleName = dicStyles[@"styleName"];
                    NSNumber *styleId = dicStyles[@"styleId"];
                    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (sid,zippath,zipname,thumbnail,bigimagepath,styleName,styleId,typeName) VALUES(?,?,?,?,?,?,?,?)",tableName];
                    if ([fmDatabase executeUpdate:sqlStr,sid,zippath,zipname,thumbnail,bigimagepath,styleName,styleId,typeName,@"0"])
                    {
                    }
                        
                }
            }
        }
    }
    [fmDatabase close];

}
+ (BOOL)delectStyleBoad:(NSMutableArray *)array
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        if (array.count>0) {
            NSString *tableName = [NSString stringWithFormat:@"StyleList_%@",PUBLICUID];
            NSString *sql1 = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
            if (![fmDatabase executeUpdate:sql1]) {
                return NO;
            }else{
                return YES;
            }
        }else{
            return NO;
        }
       
    
    }
    return NO;
    [fmDatabase close];
}
+ (NSInteger)getMaxSid{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    NSInteger  maxSid = 0;

    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"StyleList_%@",PUBLICUID];
        NSString *sql1 = [NSString stringWithFormat:@"SELECT max(sid) from %@",tableName];
        FMResultSet *rs1 = [fmDatabase executeQuery:sql1];
        if (rs1 != nil) {
            while ([rs1 next]) {
                maxSid = [rs1 intForColumnIndex:0];
            }
        }
    }

    [fmDatabase close];
    return maxSid;
}
+ (NSMutableArray *)getAllStyleListData{
//    NSInteger maxSid = [self getMaxSid];
    NSMutableArray *stylesAll = [[NSMutableArray alloc] initWithCapacity:0];
   
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"StyleList_%@",PUBLICUID];

        NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
        FMResultSet *rs = [fmDatabase executeQuery:sql];
        NSString *typeName = @"";
        int index = 0;
            
        if (rs != nil) {
            while ([rs next]) {
                NSString *zippath = [rs stringForColumn:@"zippath"];;
                NSString *thumbnail = [rs stringForColumn:@"thumbnail"];
                NSString *bigimagepath = [rs stringForColumn:@"bigimagepath"];
                NSString *styleName = [rs stringForColumn:@"styleName"];
                NSString *zipnName = [rs stringForColumn:@"zipname"];
                NSNumber *styleId = [NSNumber numberWithInt:[rs intForColumn:@"styleId"]];
                NSNumber *sid = [NSNumber numberWithInt:[rs intForColumn:@"sid"]];
                typeName = [rs stringForColumn:@"typeName"];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:zippath,@"zippath",thumbnail,@"thumbnail",bigimagepath,@"bigimagepath",styleId,@"styleId",styleName,@"styleName",zipnName,@"zipname",sid,@"sid",typeName,@"typename", nil];
                
                for (int i = 0; i < stylesAll.count; i ++)
                {
                    NSMutableDictionary *dic2 = stylesAll[i];
                    if ([typeName isEqualToString:dic2[@"typename"]])
                    {
                        index =1000;//用来记录风格字典是否加入数组
                        NSMutableArray *stylesArr = dic2[@"styles"];
                        [stylesArr addObject:dic];
                        
                        [dic2 setObject:stylesArr forKey:@"styles"];
                        
                        [stylesAll replaceObjectAtIndex:i withObject:dic2];
                        break;
                    }
                }

                if (index  != 1000) {//当已加入时不用重复加入
                    NSMutableArray *styleArrN = [[NSMutableArray alloc] initWithCapacity:0];
                    [styleArrN addObject:dic];
                    
                    NSMutableDictionary *styleDicN = [[NSMutableDictionary alloc] initWithObjectsAndKeys:styleArrN,@"styles",typeName,@"typename", nil];
                    
                    [stylesAll addObject:styleDicN];
                    
                    [styleArrN release],styleArrN = nil;
                    [styleDicN release],styleDicN = nil;
                }
                index = 0;
                [dic release],dic = nil;
            }
            
        }
        
    }
    [fmDatabase close];
    return [stylesAll autorelease];
}
//isDownLoad  0 未下载  1 已经下载  2  未下载完
+ (void)addDownLoadList:(NSInteger)styleID{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if ([fmDatabase open]) {
        NSString *tableName = [NSString stringWithFormat:@"StyleDownLoad_%@",PUBLICUID];
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where styleId=?",tableName];
        NSInteger a=0;
        FMResultSet *rs =[fmDatabase executeQuery:sql,[NSNumber numberWithInt:styleID]];
        if (rs != nil) {
            while ([rs next]) {
                a = [rs intForColumn:@"isDownLoad"];
            }
        }
        if (a) {
            return;
        }
        NSString *sql1 = [NSString stringWithFormat:@"insert into %@(styleId,isDownLoad) values(?,?)",tableName];
        [fmDatabase executeUpdate:sql1,[NSNumber numberWithInt:styleID],@"2"];

    }
    [fmDatabase close];
}

+ (void)updateDownLoadState:(NSInteger)styleId{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if ([fmDatabase open]) {
        NSString *tableName = [NSString stringWithFormat:@"StyleDownLoad_%@",PUBLICUID];
        NSString *sql = [NSString stringWithFormat:@"update %@ set isDownLoad=? where styleId=?",tableName];
        [fmDatabase executeUpdate:sql,@"1",[NSNumber numberWithInt:styleId]];
    }
    [fmDatabase close];
}
+ (void)isDelectdateDownLoadState:(NSInteger)state styleID:(NSInteger)styleId
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if ([fmDatabase open]) {
        NSString *tableName = [NSString stringWithFormat:@"StyleDownLoad_%@",PUBLICUID];
        NSString *sql = [NSString stringWithFormat:@"update %@ set isDownLoad=? where styleId=?",tableName];
        [fmDatabase executeUpdate:sql,@(state),@(styleId)];
    }
    [fmDatabase close];
}
+(NSInteger)getDownLoadState:(NSInteger)styleId{
    
    NSInteger isDownLoad = 0;

    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if ([fmDatabase open]) {
        NSString *tableName = [NSString stringWithFormat:@"StyleDownLoad_%@",PUBLICUID];
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where styleId=?",tableName];
        FMResultSet *rs = [fmDatabase executeQuery:sql,[NSNumber numberWithInt:styleId]];
        
        if (rs != nil) {
            while ([rs next]) {
                isDownLoad = [rs intForColumn:@"isDownLoad"];
            }
        }
    }
    [fmDatabase close];
    return isDownLoad;
}
+ (void)deleteDownLoad:(NSInteger)styleId{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if ([fmDatabase open]) {
        NSString *tableName = [NSString stringWithFormat:@"StyleDownLoad_%@",PUBLICUID];
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where styleId=?",tableName];
        [fmDatabase executeUpdate:sql,[NSNumber numberWithInt:styleId]];
    }
    [fmDatabase close];
}
+ (void)deleteDownLoadByIsDownLoad:(NSInteger)isDownLoad{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if ([fmDatabase open]) {
        NSString *tableName = [NSString stringWithFormat:@"StyleDownLoad_%@",PUBLICUID];
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where isDownLoad=?",tableName];
        [fmDatabase executeUpdate:sql,[NSNumber numberWithInt:isDownLoad]];
    }
    [fmDatabase close];
}
@end
