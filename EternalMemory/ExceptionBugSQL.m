//
//  ExceptionBugSQL.m
//  EternalMemory
//
//  Created by zhaogl on 14-2-19.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "ExceptionBugSQL.h"
#import "BaseDatas.h"
#import "FMDatabase.h"

@implementation ExceptionBugSQL


+ (void)addExceptionBugInfo:(NSDictionary *)bugInfo{
    
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    if ([db open]) {
        NSString *tableName = @"ExceptionBug";
        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (content,osversion,appversion,happentime,devicemodel,internet) VALUES(?,?,?,?,?,?)",tableName];
        BOOL a = [db executeUpdate:sqlStr,bugInfo[@"content"],bugInfo[@"osversion"],bugInfo[@"appversion"],bugInfo[@"happentime"],bugInfo[@"devicemodel"],bugInfo[@"internet"]];
        if (a) {
//            NSLog(@"存储bug信息成功");
        }else{
//            NSLog(@"存储bug信息失败");
        }
    }
    [db close];
    db = nil;

}

+ (void)deleteExceptionBugInfo:(NSInteger)ID{
    
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    if ([db open]) {
        NSString *tableName = @"ExceptionBug";
        NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where id = ?",tableName];
        BOOL a = [db executeUpdate:sqlStr,[NSNumber numberWithInt:ID]];
        if (a) {
            NSLog(@"删除bug信息成功");
        }else{
            NSLog(@"删除bug信息失败");
        }
    }
    [db close];
    db = nil;
    
}

+ (NSArray *)getAllExceptionBugInfo{
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    if ([db open]) {
        NSString *tableName = @"ExceptionBug";
        NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",tableName];
        FMResultSet *rs = [db executeQuery:sqlStr];
        while ([rs next]) {
            
            NSString *content = [rs stringForColumn:@"content"];
            NSString *osversion = [rs stringForColumn:@"osversion"];
            NSString *appversion = [rs stringForColumn:@"appversion"];
            NSString *happentime = [rs stringForColumn:@"happentime"];
            NSString *deveceModel = [rs stringForColumn:@"devicemodel"];
            NSString *internet = [rs stringForColumn:@"internet"];
            NSNumber *ID = [NSNumber numberWithInt:[rs intForColumn:@"id"]];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:content,@"content",osversion,@"osversion",appversion,@"appversion",happentime,@"happentime",deveceModel,@"devicemodel",internet,@"internet",ID,@"id",nil];
            [array addObject:dic];
        }
    }
    [db close];
    db = nil;
    return [array autorelease];
}
@end
