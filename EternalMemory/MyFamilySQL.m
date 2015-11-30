//
//  MyFamilySQL.m
//  EternalMemory
//
//  Created by kiri on 13-9-14.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import "AssociatedModel.h"
#import "MyFamilySQL.h"
#import "FMDatabase.h"
#import "BaseDatas.h"
#import "Config.h"
#import "GenealogyMemberDetailViewController.h"

#define TABLENAME(UIDNAME)     [NSString stringWithFormat:@"MyFamily_%d",UIDNAME]

@implementation MyFamilySQL

// 操作数据库的模板方法。
+ (void)handleDatabaseUsingBlock:(void (^)(FMDatabase *db,NSString *tableName))block
{
    FMDatabase *fmdb = [BaseDatas getBaseDatasInstance];
    NSString *tableName = [NSString stringWithFormat:@"MyFamily_%@",USERID];
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

+(void)addFamilyMembers:(NSArray *)array AndType:(NSString *)type WithUserID:(NSString *)ID{
    
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    if ([db open]) {
        NSString *tableName = [NSString stringWithFormat:@"MyFamily_%@",ID];
        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (address,associateAuthCode,associateKey,associateUserId,associateValue,associated,birthDate,birthDateStr,birthWarned,deathDate,deathDateStr,deathWarned,isDead,motherId,headPortrait,directLine,eternalCode,eternalnum,intro,kinRelation,level,memberId,name,nickName,parentId,partnerId,sex,subTitle,userId) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
        
        if ([type isEqualToString:@"reAdd"]) {
            
            for(NSDictionary *obj in array){
                
                NSString *sql = [NSString stringWithFormat:@"delete from %@ where level=?",tableName];
                NSNumber *level = [NSNumber numberWithInt:[obj[@"members"][0][@"level"] integerValue]];
                [db executeUpdate:sql,level];
                
                [self addFamilyMembers:db andSqlStr:sqlStr AndData:obj[@"members"]];
            }
            
        }else{
            [self addFamilyMembers:db andSqlStr:sqlStr AndData:array];
        }
        /*for (NSDictionary *dic in array) {
            
            NSString *address = dic[kAddress];
            NSString *associateAuthCode = dic[kAssociateAuthCode];
            NSString *associateKey = dic[kAssociateKey];
            NSString *associateUserId = dic[kAssociateUserId];
            NSString *associateValue = dic[kAssociateValue];
            NSNumber *associated = dic[kAssociated];
            NSString *birthDate = dic[kBirthDate];
            NSString *deathDate = dic[@"deathDate"];
            NSNumber *isDead = dic[@"isDead"];
            NSString *motherId = dic[@"motherId"];
            NSNumber *directLine = dic[kDirectLine];
            NSString *eternalCode = dic[kEternalCode];
            NSString *eternalnum = dic[kEternalNum];
            NSString *headPortrait = dic[kHeadPortrait];
            NSString *intro = dic[kIntro];
            NSNumber *kinRelation = dic[kKinRelation];
            NSNumber *level = dic[kLevel];
            NSString *memberId = dic[kMemberId];
            NSString *name = dic [kName];
            NSString *nickName = dic[kNickName];
            NSString *parentId = dic[kParentId];
            NSString *partnerId = dic[kPartnerId];
            NSNumber *sex = dic[kSex];
            NSString *subTitle = dic[kSubTitle];
            NSString *userId = dic[kUserId];
            
            BOOL a = [db executeUpdate:sqlStr,address,associateAuthCode,associateKey,associateUserId,associateValue,associated,birthDate,deathDate,isDead,motherId,headPortrait,directLine,eternalCode,eternalnum,intro,kinRelation,level,memberId,name,nickName,parentId,partnerId,sex,subTitle,userId];
            if (a) {
            }else{
            }
        }*/
    }
    [db close];
    db = nil;
}
+(void)addFamilyMembers:(FMDatabase *)db andSqlStr:(NSString *)sqlStr AndData:(NSArray *)array{
    
    for (NSDictionary *dic in array) {
        
        NSString *address = dic[kAddress];
        NSString *associateAuthCode = dic[kAssociateAuthCode];
        NSString *associateKey = dic[kAssociateKey];
        NSString *associateUserId = dic[kAssociateUserId];
        NSString *associateValue = dic[kAssociateValue];
        NSNumber *associated = dic[kAssociated];
        NSNumber *birthDate = dic[kBirthDate];
        NSString *deathDate = dic[@"deathDate"];
        NSString *birthDateStr = dic[@"birthDateStr"];
        NSString *deathDateStr = dic[@"deathDateStr"];
        NSNumber *birthWarned = dic[kBirthWarned];
        NSNumber *deathWarned = dic[kDeathWarnned];
        NSNumber *isDead = dic[@"isDead"];
        NSString *motherId = dic[@"motherId"];
        NSNumber *directLine = dic[kDirectLine];
        NSString *eternalCode = dic[kEternalCode];
        NSString *eternalnum = dic[kEternalNum];
        NSString *headPortrait = dic[kHeadPortrait];
        NSString *intro = dic[kIntro];
        NSNumber *kinRelation = dic[kKinRelation];
        NSNumber *level = dic[kLevel];
        NSString *memberId = dic[kMemberId];
        NSString *name = dic [kName];
        NSString *nickName = dic[kNickName];
        NSString *parentId = dic[kParentId];
        NSString *partnerId = dic[kPartnerId];
        NSNumber *sex = dic[kSex];
        NSString *subTitle = dic[kSubTitle];
        NSString *userId = dic[kUserId];
        
        BOOL a = [db executeUpdate:sqlStr,address,associateAuthCode,associateKey,associateUserId,associateValue,associated,birthDate,birthDateStr,birthWarned,deathDate,deathDateStr,deathWarned,isDead,motherId,headPortrait,directLine,eternalCode,eternalnum,intro,kinRelation,level,memberId,name,nickName,parentId,partnerId,sex,subTitle,userId];
        if (a) {
        }else{
        }
    }
}
+(NSArray *)getFamilyMembersWithUserId:(NSString *)userId{
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    if ([db open]) {
        NSString *tableName = [NSString stringWithFormat:@"MyFamily_%@",userId];
        NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",tableName];
        FMResultSet *rs = [db executeQuery:sqlStr];
        while ([rs next]) {
            NSString *address = [rs stringForColumn:kAddress];
            NSString *associateAuthCode = [rs stringForColumn:kAssociateAuthCode];
            NSString *associateKey = [rs stringForColumn:kAssociateKey];
            NSString *associateUserId = [rs stringForColumn:kAssociateUserId];
            NSString *associateValue = [rs stringForColumn:kAssociateValue];
            NSNumber *associated = [NSNumber numberWithInt:[rs intForColumn:kAssociated]];
            NSNumber *birthDate = [NSNumber numberWithLongLong:[rs longLongIntForColumn:kBirthDate]];
            NSString *deathDate = [rs stringForColumn:@"deathDate"];
            NSString *birthDateStr = [rs stringForColumn:@"birthDateStr"];
            NSString *deathDateStr = [rs stringForColumn:@"deathDateStr"];
            NSNumber *birthWarned = [NSNumber numberWithInt:[rs intForColumn:kBirthWarned]];
            NSNumber *deathWarned = [NSNumber numberWithInt:[rs intForColumn:kDeathWarnned]];
            NSNumber *isDead =[NSNumber numberWithInt:[rs intForColumn:@"isDead"]];
            NSString *motherId = [rs stringForColumn:@"motherId"];
            NSNumber *directLine = [NSNumber numberWithInt:[rs intForColumn:kDirectLine]];
            NSString *eternalCode = [rs stringForColumn:kEternalCode];
            NSString *eternalnum = [rs stringForColumn:kEternalNum];
            NSString *headPortrait = [rs stringForColumn:kHeadPortrait];
            NSString *intro = [rs stringForColumn:kIntro];
            NSNumber *kinRelation = [NSNumber numberWithInt:[rs intForColumn:kKinRelation]];
            NSNumber *level = [NSNumber numberWithInt:[rs intForColumn:kLevel]];
            NSString *memberId = [rs stringForColumn:kMemberId];
            NSString *name = [rs stringForColumn:kName];
            NSString *nickName = [rs stringForColumn:kNickName];
            NSString *parentId = [rs stringForColumn:kParentId];
            NSString *partnerId = [rs stringForColumn:kPartnerId];
            NSNumber *sex = [NSNumber numberWithInt:[rs intForColumn:kSex]];
            NSString *subTitle = [rs stringForColumn:kSubTitle];
            NSString *userId = [rs stringForColumn:kUserId];
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:address,associateAuthCode,associateKey,associateUserId,associateValue,associated,birthDate,birthDateStr,birthWarned,deathDate,deathDateStr,deathWarned,isDead,motherId,directLine,eternalCode,eternalnum,headPortrait,intro,kinRelation,level,memberId,name,nickName,parentId,partnerId,sex,subTitle,userId, nil] forKeys:[NSArray arrayWithObjects:kAddress,kAssociateAuthCode,kAssociateKey,kAssociateUserId,kAssociateValue,kAssociated,kBirthDate,@"birthDateStr",kBirthWarned,@"deathDate",@"deathDateStr",kDeathWarnned,@"isDead",@"motherId",kDirectLine,kEternalCode,kEternalNum,kHeadPortrait,kIntro,kKinRelation,kLevel,kMemberId,kName,kNickName,kParentId,kPartnerId,kSex,kSubTitle,kUserId,nil]];
            NSArray *levelsAry = [array valueForKey:@"level"];
            BOOL is = NO;
            for (int i = 0; i < levelsAry.count; i ++ ) {
                
                if ([levelsAry[i] integerValue] == [level integerValue]) {
                    is = YES;
                    NSMutableArray *ary = [[NSMutableArray alloc] initWithCapacity:0];
                    [ary addObjectsFromArray:array[i][@"members"]];
                    [ary addObject:dic];
                    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:level,@"level",ary,@"members", nil];
                    [array replaceObjectAtIndex:i withObject:dic2];
                    [ary release];
                    
                    break;
                }
            }
            if (!is) {
                NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:level,@"level",[NSArray arrayWithObject:dic],@"members", nil];
                [array addObject:dic2];
            }
        }
    }
    [db close];
    db = nil;
    return [array autorelease];
}

+(NSArray *)getMembersHeadPortrait:(NSString *)userId
{
    NSMutableArray *array = [NSMutableArray array];
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    if ([db open]) {
        NSString *tableName = [NSString stringWithFormat:@"MyFamily_%@",userId];
        NSString *sqlStr = [NSString stringWithFormat:@"select headPortrait from %@",tableName];
        FMResultSet *rs = [db executeQuery:sqlStr];
        while ([rs next]) {
            if ([[rs stringForColumn:kHeadPortrait] length] != 0)
            {
                [array addObject:[rs stringForColumn:kHeadPortrait]];
            }
        }
    }
    [db close];
    db = nil;
    return (NSArray *)array;
}

+(NSMutableArray *)getAssociatedMembers
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [self handleDatabaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"select * from %@ where  associated = 1",tableName];
        FMResultSet *rs = [db executeQuery:s_sql];
        while ([rs next]) {
//            NSString *name     = [rs stringForColumn:kName];
//            NSString *motherId = [rs stringForColumn:kMemberId];
//            NSString *authCode = [rs stringForColumn:kEternalCode];
//            NSString *nickName = [rs stringForColumn:kNickName];
//            
//            NSDictionary *dic = @{kName: name, kMotherID: motherId,kAssociateAuthCode:authCode,kNickName:nickName};
            AssociatedModel *model = [[AssociatedModel alloc] initWithFMReuslt:rs];
            if (![model.associateUserId isEqualToString:USERID])
            {
                [arr addObject:model];
            }
            [model release];
        }
    }];
    
    return [arr autorelease];

}


+ (void)deleteMemberWithMemberID:(NSString *)memberId
{
    [self handleDatabaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *d_sql = [NSString stringWithFormat:@"delete from %@ where memberId = ?",tableName];
        BOOL flag = [db executeUpdate:d_sql,memberId];
        if (flag) {
            
        } else {
        }
    }];
}


+ (void)deleteMembersWithMemberIds:(NSArray *)memberIds
{
    [self handleDatabaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        
        NSString *d_sql = [NSString stringWithFormat:@"delete from %@ where memberId = ?", tableName];
        for (NSString *memberID in memberIds) {
            NSDictionary *dic = [self getMemberLeveForMemberId:memberID AndDB:db];
            BOOL f = [db executeUpdate:d_sql,memberID];
            if (f) {
                if ([dic[@"level"] integerValue] < 0 && [dic[@"directLine"] integerValue] == 1) {
                    [self updateNextLevelParentId:[dic[@"level"] integerValue]+1 AndDB:db];
                }
            } else {
            }
        }
    }];
}

+ (NSDictionary *)getMemberLeveForMemberId:(NSString *)memberId AndDB:(FMDatabase *)db{
    
    NSString *tableName = [NSString stringWithFormat:@"MyFamily_%@",USERID];
    NSString *s_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ?", tableName,kMemberId];
    FMResultSet *rs = [db executeQuery:s_sql,memberId];
    NSInteger level = 0;
    NSInteger directLine = 0;
    while ([rs next]) {
        level = [rs intForColumn:kLevel];
        directLine = [rs intForColumn:kDirectLine];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:level],@"level",[NSNumber numberWithInt:directLine],@"directLine", nil];
        return dic;
    }
    return nil;
}

+ (void)updateNextLevelParentId:(NSInteger)level AndDB:(FMDatabase *)db{
    
    NSString *tableName = [NSString stringWithFormat:@"MyFamily_%@",USERID];
    NSString *u_sql = [NSString stringWithFormat:@"update %@ set %@ = ? where level = ? ",tableName,kParentId];
    [db executeUpdate:u_sql,@"",[NSNumber numberWithInt:level]];
}


+ (void)deleteMembers:(NSArray *)memberIds andMoveMemberToCentralAxis:(NSArray *)movedMemberID
{
    [self deleteMembersWithMemberIds:memberIds];
    
    [self handleDatabaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *u_sql = [NSString stringWithFormat:@"update %@ set %@ = ? where memberid = ?", tableName,kDirectLine];
        for (NSString *memberid in movedMemberID) {
            
            BOOL flag = [db executeUpdate:u_sql,@"1",memberid];
            if (flag) {
            } else {
            }
            
        }
        
    }];
}

+ (NSArray *)getMemberFroLevel:(NSString *)level
{
    NSMutableArray *members = [[NSMutableArray alloc] initWithCapacity:0];
    [self handleDatabaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"select * from %@ where level=?",tableName];
        FMResultSet *rs = [db executeQuery:s_sql,level];
        while ([rs next]) {
            NSString *address = [rs stringForColumn:kAddress];
            NSString *associateAuthCode = [rs stringForColumn:kAssociateAuthCode];
            NSString *associateKey = [rs stringForColumn:kAssociateKey];
            NSString *associateUserId = [rs stringForColumn:kAssociateUserId];
            NSString *associateValue = [rs stringForColumn:kAssociateValue];
            NSNumber *associated = [NSNumber numberWithInt:[rs intForColumn:kAssociated]];
            NSNumber *birthDate = [NSNumber numberWithLongLong:[rs longLongIntForColumn:kBirthDate]];
            NSString *deathDate = [rs stringForColumn:@"deathDate"];
            NSString *birthDateStr = [rs stringForColumn:@"birthDateStr"];
            NSString *deathDateStr = [rs stringForColumn:@"deathDateStr"];
            NSNumber *birthWarned = [NSNumber numberWithInt:[rs intForColumn:kBirthWarned]];
            NSNumber *deathWarned = [NSNumber numberWithInt:[rs intForColumn:kDeathWarnned]];
            NSNumber *isDead =[NSNumber numberWithInt:[rs intForColumn:@"isDead"]];
            NSString *motherId = [rs stringForColumn:@"motherId"];
            NSNumber *directLine = [NSNumber numberWithInt:[rs intForColumn:kDirectLine]];
            NSString *eternalCode = [rs stringForColumn:kEternalCode];
            NSString *eternalnum = [rs stringForColumn:kEternalNum];
            NSString *headPortrait = [rs stringForColumn:kHeadPortrait];
            NSString *intro = [rs stringForColumn:kIntro];
            NSNumber *kinRelation = [NSNumber numberWithInt:[rs intForColumn:kKinRelation]];
            NSNumber *level = [NSNumber numberWithInt:[rs intForColumn:kLevel]];
            NSString *memberId = [rs stringForColumn:kMemberId];
            NSString *name = [rs stringForColumn:kName];
            NSString *nickName = [rs stringForColumn:kNickName];
            NSString *parentId = [rs stringForColumn:kParentId];
            NSString *partnerId = [rs stringForColumn:kPartnerId];
            NSNumber *sex = [NSNumber numberWithInt:[rs intForColumn:kSex]];
            NSString *subTitle = [rs stringForColumn:kSubTitle];
            NSString *userId = [rs stringForColumn:kUserId];
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:address,associateAuthCode,associateKey,associateUserId,associateValue,associated,birthDate,birthDateStr,birthWarned,deathDate,deathDateStr,deathWarned,isDead,motherId,directLine,eternalCode,eternalnum,headPortrait,intro,kinRelation,level,memberId,name,nickName,parentId,partnerId,sex,subTitle,userId, nil] forKeys:[NSArray arrayWithObjects:kAddress,kAssociateAuthCode,kAssociateKey,kAssociateUserId,kAssociateValue,kAssociated,kBirthDate,@"birthDateStr",kBirthWarned,@"deathDate",@"deathDateStr",kDeathWarnned,@"isDead",@"motherId",kDirectLine,kEternalCode,kEternalNum,kHeadPortrait,kIntro,kKinRelation,kLevel,kMemberId,kName,kNickName,kParentId,kPartnerId,kSex,kSubTitle,kUserId,nil]];
            [members addObject:dic];
            
            
        }
    }];
    
    return [members autorelease];
}

+ (void)updateMemberByMemberId:(NSDictionary *)aMember
{
    [self handleDatabaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *u_sql = [NSString stringWithFormat:@"update %@ set %@ = ?, %@ = ?, %@ = ?, %@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?, %@ = ?,%@ = ?,%@ = ?,%@ = ? where memberid = ? ",tableName,kAddress,kAssociateAuthCode,kAssociateKey,kAssociateUserId,kAssociateValue,kAssociated,kBirthDate,@"birthDateStr",kBirthWarned,@"deathDate",@"deathDateStr",kDeathWarnned,@"isDead",@"motherId",kEternalCode,kEternalNum,kHeadPortrait,kIntro,kKinRelation,kLevel,kName,kNickName,kSex,kSubTitle,kUserId,kParentId,kPartnerId];
        BOOL f =[db executeUpdate:u_sql,aMember[kAddress],aMember[kAssociateAuthCode],aMember[kAssociateKey],aMember[kAssociateUserId],aMember[kAssociateValue],aMember[kAssociated],aMember[kBirthDate],aMember[@"birthDateStr"],aMember[kBirthWarned],aMember[@"deathDate"],aMember[@"deathDateStr"],aMember[kDeathWarnned],aMember[@"isDead"],aMember[@"motherId"],aMember[kEternalCode],aMember[kEternalNum],aMember[kHeadPortrait],aMember[kIntro],aMember[kKinRelation],aMember[kLevel],aMember[kName],aMember[kNickName],aMember[kSex],aMember[kSubTitle],aMember[kUserId],aMember[kParentId],aMember[kPartnerId],aMember[kMemberId]];
        
        if (f) {
        } else {
        }
    }];
}

+ (NSDictionary *)getMotherInfoWithMotherId:(NSString *)motherId andMemberId:(NSString *)memberId
{
    NSMutableDictionary *motherInfo = [@{} mutableCopy];
    [self handleDatabaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ?", tableName,kMemberId];
        
        FMResultSet *rs = [db executeQuery:s_sql,motherId];
        while ([rs next]) {
            motherInfo[kAddress] = [rs stringForColumn:kAddress];
            motherInfo[kAssociateAuthCode] = [rs stringForColumn:kAssociateAuthCode];
            motherInfo[kAssociateKey] = [rs stringForColumn:kAssociateKey];
            motherInfo[kAssociateUserId] = [rs stringForColumn:kAssociateUserId];
            motherInfo[kAssociateValue] = [rs stringForColumn:kAssociateValue];
            motherInfo[kAssociated] = [rs stringForColumn:kAssociated];
            motherInfo[kBirthDate] = [NSNumber numberWithLongLong:[rs longLongIntForColumn:kBirthDate]];
            motherInfo[@"birthDateStr"] = [rs stringForColumn:@"birthDateStr"];
            motherInfo[kBirthWarned] = [NSNumber numberWithInt:[rs intForColumn:kBirthWarned]];
            motherInfo[kDirectLine] = [rs stringForColumn:kDirectLine];
            motherInfo[kEternalCode] = [rs stringForColumn:kEternalCode];
            motherInfo[kEternalNum] = [rs stringForColumn:kEternalNum];
            motherInfo[kIntro] = [rs stringForColumn:kIntro];
            motherInfo[kKinRelation] = [rs stringForColumn:kKinRelation];
            motherInfo[kLevel] = [rs stringForColumn:kLevel];
            motherInfo[kMotherID] = [rs stringForColumn:kMemberId];
            motherInfo[kName] = [rs stringForColumn:kName];
            motherInfo[kNickName] = [rs stringForColumn:kNickName];
            motherInfo[kParentId] = [rs stringForColumn:kParentId];
            motherInfo[kPartnerId] = [rs stringForColumn:kPartnerId];
            motherInfo[kSex] = [rs stringForColumn:kSex];
            motherInfo[kSubTitle] = [rs stringForColumn:kSubTitle];
            motherInfo[kUserId] = [rs stringForColumn:kUserId];
            motherInfo[kHeadPortrait] = [rs stringForColumn:kHeadPortrait];
            motherInfo[kDeathDate] = [rs stringForColumn:kDeathDate];
            motherInfo[@"deathDateStr"] = [rs stringForColumn:@"deathDateStr"];
            motherInfo[kDeathWarnned] = [NSNumber numberWithInt:[rs intForColumn:kDeathWarnned]];
            motherInfo[kIsDead] = [rs stringForColumn:kIsDead];
            motherInfo[kMotherID] = [rs stringForColumn:kMotherID];
        }
    }];
    
    return motherInfo;
}

+ (NSArray *)getAllMothersForAMember:(NSDictionary *)memberInfo
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [self handleDatabaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ?",tableName,kPartnerId];
        FMResultSet *rs = [db executeQuery:s_sql,memberInfo[kParentId]];
        while ([rs next]) {
            NSString *name = [rs stringForColumn:kName];
            NSString *motherId = [rs stringForColumn:kMemberId];
            NSDictionary *dic = @{kName: name, kMotherID: motherId};
            [arr addObject:dic];
        }
    }];
    
    return [arr autorelease];
}

+ (void)updateMyinfoForData:(NSDictionary *)dic{
    
    [self handleDatabaseUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *u_sql = [NSString stringWithFormat:@"update %@ set %@ = ?, %@ = ?, %@ = ?, %@ = ? where memberid = ? ",tableName,kAddress,kBirthDate,kName,kSex];
        BOOL f =[db executeUpdate:u_sql,dic[kAddress],dic[kBirthDate],dic[kName],dic[kSex],dic[kMemberId]];
        
        if (f) {
        } else {
        }
    }];
}


@end
