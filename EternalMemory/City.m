//
//  City.m
//  EternalMemory
//
//  Created by kiri on 13-9-7.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "City.h"
#import "BaseDatas.h"
#import "FMDatabase.h"
@implementation City
+(NSMutableArray *)getProvinceNameAndId{
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:0];

    FMDatabase *fmdb = [BaseDatas getBaseAreaDataInstance];

    if ([fmdb open]) {
        NSString *sql =@"select * from t_area where level=1";
        FMResultSet *rs = [fmdb executeQuery:sql];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                NSNumber *provinceId=[NSNumber numberWithInt:[rs intForColumn:@"area_id"]];
                NSNumber *pId = [NSNumber numberWithInt:[rs intForColumn:@"pid"]];
                [dic setValue:provinceId forKey:@"area_id"];
                [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
                [dic setValue:pId forKey:@"pid"];
                [array addObject:dic];
                [dic release];
            }
        }
    }else{
    }
    [fmdb close];
    fmdb = nil;
    return [array autorelease];
}
+(NSMutableArray *)getCityForstate:(NSInteger)stateId{
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:0];
    
    FMDatabase *fmdb = [BaseDatas getBaseAreaDataInstance];
    
    if ([fmdb open]) {
        NSString *sql =@"select * from t_area where pid=?";
        FMResultSet *rs = [fmdb executeQuery:sql,[NSNumber numberWithInt:stateId]];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                NSNumber *provinceId=[NSNumber numberWithInt:[rs intForColumn:@"area_id"]];
                NSNumber *pId = [NSNumber numberWithInt:[rs intForColumn:@"pid"]];
                [dic setValue:provinceId forKey:@"area_id"];
                [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
                [dic setValue:pId forKey:@"pid"];
                [array addObject:dic];
                [dic release];
            }
        }
    }else{
    }
    [fmdb close];
    fmdb = nil;
    return [array autorelease];
}
+(NSMutableArray *)getDistrictForCity:(NSInteger)cityId{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:0];
    
    FMDatabase *fmdb = [BaseDatas getBaseAreaDataInstance];
    
    if ([fmdb open]) {
        NSString *sql =@"select * from t_area where pid=?";
        FMResultSet *rs = [fmdb executeQuery:sql,[NSNumber numberWithInt:cityId]];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                NSNumber *provinceId=[NSNumber numberWithInt:[rs intForColumn:@"area_id"]];
                NSNumber *pId = [NSNumber numberWithInt:[rs intForColumn:@"pid"]];
                [dic setValue:provinceId forKey:@"area_id"];
                [dic setValue:[rs stringForColumn:@"title"] forKey:@"title"];
                [dic setValue:pId forKey:@"pid"];
                [array addObject:dic];
                [dic release];
            }
        }
    }else{
    }
    [fmdb close];
    fmdb = nil;
    return [array autorelease];
}
@end
