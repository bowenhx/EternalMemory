//
//  UserDatasSQL.m
//  EternalMemory
//
//  Created by Guibing Li on 13-5-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "UserDatasSQL.h"
#import "BaseDatas.h"
#import "Config.h"
#import "SavaData.h"

#define TABLENAME(UIDNAME)     [NSString stringWithFormat:@"UserDatas_%d",UIDNAME]

@implementation UserDatasSQL
/*
+(void)userDatas:(NSDictionary *)dic AndID:(NSInteger)uide
{
    [BaseDatas openBaseDatas:uide];
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = TABLENAME(uide);
        NSNumber *uid = [dic objectForKey:@"userId"];
        NSNumber *SID = [dic objectForKey:@"SID"];
        NSString *uName = [dic objectForKey:@"userName"];
        NSString *realName = [dic objectForKey:@"realName"];
        NSString *address = [dic objectForKey:@"addressdetail"];
        NSString *city = [dic objectForKey:@"city"];
        NSString *country = [dic objectForKey:@"country"];
        NSString *district = [dic objectForKey:@"district"];
        NSString *email = [dic objectForKey:@"email"];
        NSNumber *favoriteMusic = [dic objectForKey:@"favoriteMusic"];
        NSNumber *favoriteStyle = [dic objectForKey:@"favoriteStyle"];
        NSString *groupIds = [dic objectForKey:@"groupIds"];
        NSString *guideTel = [dic objectForKey:@"guideTel"];
        NSString *intro = [dic objectForKey:@"intro"];
        NSNumber *lastLoginTime = [dic objectForKey:@"lastLoginTime"];
        NSNumber *latestVersion = [dic objectForKey:@"latestVersion"];
        NSString *memoryCode = [dic objectForKey:@"memoryCode"];
        NSString *mobile = [dic objectForKey:@"mobile"];
        NSString *openStatus = [dic objectForKey:@"openStatus"];
        NSString *province = [dic objectForKey:@"province"];
        NSString *sex = [dic objectForKey:@"sex"];
        NSString *spaceTotal = [dic objectForKey:@"spaceTotal"];
        NSNumber *spaceUsed = [dic objectForKey:@"spaceUsed"];
        NSNumber *telephone = [dic objectForKey:@"telephone"];
        NSString *userPasswod = [dic objectForKey:@"userPassword"];
        NSString *userRole = [dic objectForKey:@"userRole"];

        // text,surName text,address text,IDCard integer,phoneN integer
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (SID,uName,realName,address,city,country,district,email,fmusic,fStyle,groupIds,guideTel,intro,lTime,lVewsion,mCode,mobile,oStatus,province,sex,spaceTotal,spaceUsed,telephone,userPassword,userRole) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];

        BOOL success = [fmDatabase executeUpdate:sql,uid,SID,uName,realName,address,city,country,district,email,favoriteMusic,favoriteStyle,groupIds,guideTel,intro,lastLoginTime,latestVersion,memoryCode,mobile,openStatus,province,sex,spaceTotal,spaceUsed,telephone,userPasswod,userRole];



    }
}


*/
@end
