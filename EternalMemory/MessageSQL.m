//
//  MessageSQL.m
//  EternalMemory
//
//  Created by sun on 13-6-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MessageSQL.h"
#import "FMDatabaseAdditions.h"
#import "Config.h"
#import "MD5.h"
#import "DiaryPictureClassificationSQL.h"
#import "EMAudio.h"

@interface MessageModel (ParseDBData)


- (void)parseDataFromResultSet:(FMResultSet *)resultSet;

@end

@implementation MessageModel (ParseDBData)

- (void)parseDataFromResultSet:(FMResultSet *)resultSet {
    
    self.ID=[resultSet intForColumn:@"id"];
    self.localBlogId = [resultSet stringForColumn:@"id"];
    self.blogId=[resultSet stringForColumn:@"blogId"];
    self.blogType=[resultSet stringForColumn:@"blogType"];
    self.content=[resultSet stringForColumn:@"content"];
    self.summary=[resultSet stringForColumn:@"summary"];
    self.title=[resultSet stringForColumn:@"title"];
    self.groupId=[resultSet stringForColumn:@"groupId"];
    self.groupname=[resultSet stringForColumn:@"groupname"];
    self.accessLevel=[resultSet stringForColumn:@"accessLevel"];
    self.attachURL=[resultSet stringForColumn:@"attachURL"];
    self.thumbnail=[resultSet stringForColumn:@"thumbnail"];
    self.paths=[resultSet stringForColumn:@"paths"];
    self.spaths=[resultSet stringForColumn:@"spaths"];
    self.serverVer=[resultSet stringForColumn:@"serverVer"];
    self.localVer=[resultSet stringForColumn:@"localVer"];
    self.status=[resultSet stringForColumn:@"status"];
    self.needSyn=[[resultSet stringForColumn:@"needSyn"] boolValue];
    self.needUpdate=[[resultSet stringForColumn:@"needUpdate"] boolValue];
    self.needDownL=[[resultSet stringForColumn:@"needDownL"] boolValue];
    self.deletestatus=[[resultSet stringForColumn:@"deletestatus"] boolValue];
    self.size=[resultSet stringForColumn:@"size"];
    self.createTime=[resultSet stringForColumn:@"createTime"];
    self.lastModifyTime=[resultSet stringForColumn:@"lastModifyTime"];
    self.syncTime=[resultSet stringForColumn:@"syncTime"];
    self.remark=[resultSet stringForColumn:@"remark"];
    self.userId=[resultSet stringForColumn:@"userId"];
    
    EMAudio *audio = [EMAudio new];
    audio.wavPath = [resultSet stringForColumn:@"audioPath"];
    audio.audioURL = [resultSet stringForColumn:@"audioURL"];
    audio.duration = [resultSet intForColumn:@"audioDuration"];
    audio.size = [resultSet intForColumn:@"audioSize"];
    audio.audioStatus = [resultSet intForColumn:@"audioStatus"];
    self.audio = audio;
    
    [audio release];
    
    
}

@end



@implementation MessageSQL
sqlite_int64 lastId;


+ (void)updataBlogPathUsingBlock:(void (^)(FMDatabase *db, NSString *tableName))block WithUserID:(NSString *)ID
{
    FMDatabase *fmdb = [BaseDatas getBaseDatasInstance];
    NSString *tableName = [NSString stringWithFormat:@"Message_%@",ID];
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

+ (BOOL)updateDBData:(BOOL (^)(FMDatabase *db, NSString *tableName))block WithUserID:(NSString *)ID
{
    BOOL flag = NO;
    FMDatabase *fmdb = [BaseDatas getBaseDatasInstance];
    NSString *tableName = [NSString stringWithFormat:@"Message_%@",ID];
    if ([fmdb open]) {
        @try {
            flag = block(fmdb,tableName);
        }
        @catch (NSException *exception) {
        }
        @finally {
            [fmdb close];
        }
    } else {
        flag = NO;
    }
    
    fmdb = nil;
    return flag;
    
}

+ (void)getAlbumBlogUsingBlock:(void (^)(FMDatabase *db, NSString *tableName))block
{
    FMDatabase *fmdb = [BaseDatas getBaseDatasInstance];
    NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
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

//+ (void)addBlogs:(NSArray *)blogs
//{
//    [self updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
//        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (blogId,blogType,content,summary,title,groupId,groupname,accessLevel,attachURL,thumbnail,paths,spaths,serverVer,localVer,status,needSyn,needUpdate,needDownL,deletestatus,size,createTime,lastModifyTime,syncTime,remark,userId) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
//        for (MessageModel *model in blogs) {
//            
//            if ([db executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.spaths,model.serverVer,model.localVer,model.status,model.needSyn,model.needUpdate,model.needDownL,model.deletestatus,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,USERID])
//            {
//                
//            }
//            else
//            {
//            }
//        }
//    }];
//}

+ (void)addBlogs:(NSArray *)blogs inGroup:(NSString *)groupId
{
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    if ([db open]) {
        NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (blogId,blogType,content,summary,title,groupId,groupname,accessLevel,attachURL,thumbnail,paths,spaths,serverVer,localVer,status,needSyn,needUpdate,needDownL,deletestatus,size,createTime,lastModifyTime,syncTime,remark,userId) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
        for (MessageModel *model in blogs) {
            NSString *s_sql = [NSString stringWithFormat:@"select * from %@ where blogId = ?", tableName];
            FMResultSet *rs = [db executeQuery:s_sql,model.blogId];
            if ([rs next]) {
                NSInteger version = [[rs stringForColumn:@"serverVer"] integerValue];
                if (version < [model.serverVer integerValue]) {
                    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogId=?,blogType=?,content=?,summary=?,title=?,groupId=?,accessLevel=?,attachURL=?,thumbnail=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,deletestatus=?,size=?,createTime=?,lastModifyTime=?,syncTime=?,remark=?,userId=? where blogId=?",tableName];
                    if ([db executeUpdate:sqlStr,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.serverVer,model.localVer,model.status,model.needSyn,model.needUpdate,model.needDownL,model.deletestatus,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,model.userId,model.blogId]) {
                    }

                    continue;
                } else if (version == [model.serverVer integerValue]) {
                    continue;
                }
            } else {
                
                if ([db executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.spaths,model.serverVer,model.localVer,model.status,model.needSyn,model.needUpdate,model.needDownL,model.deletestatus,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,USERID])
                {
                }
                else
                {
                }
            }
        }
    }
    
    [db close];
    db = nil;
}


+ (void)addBlogs:(NSArray *)blogs
{
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    if ([db open]) {
        NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (blogId,blogType,content,summary,title,groupId,groupname,accessLevel,attachURL,thumbnail,paths,spaths,serverVer,localVer,status,needSyn,needUpdate,needDownL,deletestatus,size,createTime,lastModifyTime,syncTime,remark,userId) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
        for (MessageModel *model in blogs) {
            
            if ([db executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.spaths,model.serverVer,model.localVer,model.status,model.needSyn,model.needUpdate,model.needDownL,model.deletestatus,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,USERID])
            {
            }
            else
            {
            }
        }
    }
    
    [db close];
    db = nil;
}

+ (void)addBlog:(MessageModel *)model
{
    [self updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (blogId,blogType,content,summary,title,groupId,groupname,accessLevel,attachURL,thumbnail,paths,spaths,serverVer,localVer,status,needSyn,needUpdate,needDownL,deletestatus,size,createTime,lastModifyTime,syncTime,remark,userId) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
        if ([db executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.spaths,model.serverVer,model.localVer,model.status,model.needSyn,model.needUpdate,model.needDownL,model.deletestatus,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,USERID])
        {
        }
        else
        {
        }
    } WithUserID:USERID];
    
}
+ (BOOL)updateAudio:(EMAudio *)audio forBlogid:(NSString *)blogid {
    
    return [self updateDBData:^BOOL(FMDatabase *db, NSString *tableName) {
        BOOL flag = NO;
        EMAudio *anAudio = [audio retain];
        NSString *u_sql = [NSString stringWithFormat:@"UPDATE %@ SET audioPath = ?, audioDuration = ?, audioSize = ?, audioURL = ?, audioStatus = ? where blogId = ?",tableName];
        NSString *path = audio.wavPath.length == 0 ? audio.amrPath : audio.wavPath;
        if ([db executeUpdate:u_sql,path, @(anAudio.duration), @(anAudio.size), anAudio.audioURL, @(audio.audioStatus), blogid]) {
            flag = YES;
            
        } else {
            flag = NO;
        }
        
        [anAudio release];
        
        return flag;

    } WithUserID:USERID];
}


+ (BOOL)updataAudio:(EMAudio *)audio forID:(NSNumber *)ID {
    
    return [self updateDBData:^BOOL(FMDatabase *db, NSString *tableName) {
        NSString *u_sql = [NSString stringWithFormat:@"UPDATE %@ SET audioPath = ?, audioDuration = ?, audioSize = ?, audioURL = ?, audioStatus = ? where id = ?", tableName];
        return [db executeUpdate:u_sql,audio.wavPath,@(audio.duration),@(audio.size),audio.audioURL,@(audio.audioStatus), ID];
    } WithUserID:USERID];

}


+ (BOOL)deleteAudioDataForAnID:(NSString *)ID {
    
    return [self updateDBData:^BOOL(FMDatabase *db, NSString *tableName) {
        NSString *d_sql = [NSString stringWithFormat:@"UPDATE %@ SET audioPath = ?, audioDuration = ?, audioSize = ?, audioURL = ?, audioStatus = ? where id = ?", tableName];
        return [db executeUpdate:d_sql,@"",@"",@"",@"",@"",ID];
    } WithUserID:USERID];
}


+ (BOOL)deleteAUdioDataForBlogId:(NSString *)blogid {
    return [self updateDBData:^BOOL(FMDatabase *db, NSString *tableName) {
        NSString *d_sql = [NSString stringWithFormat:@"UPDATE %@ SET audioPath = ?, audioDuration = ?, audioSize = ?, audioURL = ?, audioStatus = ? where blogId = ?",tableName];
        return [db executeUpdate:d_sql,@"",@"",@"",@"",@"",blogid];
    } WithUserID:USERID];
}

+ (BOOL)updateAudioPath:(NSString *)audioPath forModel:(MessageModel *)model {

    return [self updateDBData:^BOOL(FMDatabase *db, NSString *tableName) {
        NSString *u_sql = [NSString stringWithFormat:@"UPDATE %@ SET audioPath = ? where blogId = ?", tableName];
        return [db executeUpdate:u_sql,audioPath, model.blogId];
    } WithUserID:USERID];
}
+ (void)updateBlog:(MessageModel *)model
{
    [self updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogId=?,blogType=?,content=?,summary=?,title=?,groupId=?,accessLevel=?,attachURL=?,thumbnail=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,deletestatus=?,size=?,createTime=?,lastModifyTime=?,syncTime=?,remark=?,userId=? where blogId=?",tableName];
        if ([db executeUpdate:sqlStr,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.serverVer,model.localVer,model.status,model.needSyn,model.needUpdate,model.needDownL,model.deletestatus,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,model.userId,model.blogId]) {
        }
    } WithUserID:USERID];
}


+ (BOOL)deletePhotosWithDeleteList:(NSArray *)blogids
{
    __block BOOL flag = NO;
    [self updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
        for (NSString *blogid in blogids) {
            NSString *d_sql = [NSString stringWithFormat:@"delete from %@ where blogid = ?", tableName];
            flag = [db executeUpdate:d_sql,blogid];
            if (flag) {
            }
        }
    } WithUserID:USERID];
    
    return flag;
}

//删除日志
+(void)deleteDiaryBlogs:(NSArray *)BlogIdArr
{
    NSInteger count = BlogIdArr.count;
    for (int i = 0; i < count; i++)
    {
        FMDatabase *db = [BaseDatas getBaseDatasInstance];
        if ([db open])
        {
            NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
            NSString *deleteBlogId = [NSString stringWithFormat:@"%@",BlogIdArr[i]];
            NSString *sqlStr = [NSString stringWithFormat:@"Delete from %@ where blogId = ?",tableName];
            [db executeUpdate:sqlStr,deleteBlogId];
        }
        
        [db close];
        db = nil;
    }
}

+ (NSInteger)getMessageCount
{
    __block NSInteger count = 0 ;
    [self updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"select count(id) from %@ where blogType = '1' and (status != '3' or status is NULL)",tableName];
        FMResultSet *rs = [db executeQuery:s_sql];
        while ([rs next]) {
            count = [rs intForColumn:@"count(id)"];
        }
    } WithUserID:USERID];
    
    return count;
}

+ (void)updateBlogGroupIdWithArr:(NSArray *)arr
{
    __block typeof(self)bself = self;
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MessageModel *model = (MessageModel *)obj;
        [bself updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
            NSString *u_sql = [NSString stringWithFormat:@"update %@ set groupId = ? where blogId = ? and blogType = '1'",tableName];
            if([db executeUpdate:u_sql,model.groupId,model.blogId])
            {
            }
            else
            {
            }
        } WithUserID:USERID];
    }];
}


+ (NSMutableArray *)getNeedsToBeSynedMessages
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    [self updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *s_sql = [NSString stringWithFormat:@"select * from %@ where status > 1 and blogType = 1",tableName];
        FMResultSet *rs = [db executeQuery:s_sql];
        while ([rs next]) {
            MessageModel *model = [[MessageModel alloc] init];
            [model parseDataFromResultSet:rs];
            [arr addObject:model];
            [model release];

        }
    } WithUserID:USERID];
    

    return [arr autorelease];
}

+ (void)deleteTempDataWithPath:(NSString *)spaths
{
    [self updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *d_sql = [NSString stringWithFormat:@"delete from %@ where spaths = ? and status = 2", tableName];
        [db executeUpdate:d_sql,spaths];
    } WithUserID:USERID];
}

//获取分类对应的信息
+(NSMutableArray *)getGroupIDMessages:(NSString *)groupID AndUserId:(NSString *)userId
{
    NSMutableArray *array = [[[NSMutableArray alloc]initWithCapacity:0] autorelease];
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"Message_%@",userId];
//        bool deletStyle = YES;
//        NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where groupId=? and status !='3' order by createTime desc",tableName];
        NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where groupId=? order by createTime desc",tableName];
        FMResultSet *rs = [fmDatabase executeQuery:sqlite,groupID];
       
        while ( [rs next] )
        {
            MessageModel *model = [[MessageModel alloc] init] ;
            [model parseDataFromResultSet:rs];
            
            [array addObject:model];
            [model release];
            
        }
        
    }
    [fmDatabase close];
    return array;
    
}

+ (NSArray *)getNeedsSyncPhotos
{
    NSMutableArray *photos = [[NSMutableArray alloc] initWithArray:0];
    [self updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *q_sql = [NSString stringWithFormat:@"select * from %@ where blogType=1 and (status != 1 or audioStatus != %d)", tableName, EMAudioSyncStatusNone];
        FMResultSet *rs = [db executeQuery:q_sql];
        while ([rs next]) {
            MessageModel *model = [[MessageModel alloc] init] ;
            [model parseDataFromResultSet:rs];
            [photos addObject:model];
            [model release];
        }
    } WithUserID:USERID];
    
    return [photos autorelease];
}
+ (NSArray *)getNeedsSyncLifePhotoOrder{
    
//    NSMutableArray *photos = [[NSMutableArray alloc] initWithArray:0];
//    [self updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
//        NSString *q_sql = [NSString stringWithFormat:@"select * from %@ where blogType=1 and (status != 1 or audioStatus != %d)", tableName, EMAudioSyncStatusNone];
//        FMResultSet *rs = [db executeQuery:q_sql];
//        while ([rs next]) {
//            MessageModel *model = [[MessageModel alloc] init] ;
//            [model parseDataFromResultSet:rs];
//            [photos addObject:model];
//            [model release];
//        }
//    } WithUserID:USERID];
//    
//    return [photos autorelease];
}
+(NSMutableArray *)getMessages:(NSString *)classificationesblogType AndUserId:(NSString *)userId
{
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:0];
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"Message_%@",userId];
        bool deletStyle = YES;
        NSNumber *deleteNumber = [NSNumber numberWithBool:deletStyle];
        NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where groupid=? and blogType='1' and (deleteStatus !=? or deleteStatus is null) order by createTime desc",tableName];
        FMResultSet *rs = [fmDatabase executeQuery:sqlite,classificationesblogType,deleteNumber];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                MessageModel *model = [[MessageModel alloc] init] ;
                [model parseDataFromResultSet:rs];
                [array addObject:model];
                [model release];
            }
        }
        [rs close];
        [fmDatabase close];
        
    }
    return [array autorelease];
    
}
//获取分组的所有图片
+(NSMutableArray *)getAllPhotosWithUserId:(NSString *)userId
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:0];
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"Message_%@",userId];
        bool deletStyle = YES;
        NSNumber *deleteNumber = [NSNumber numberWithBool:deletStyle];
        NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where blogType='1' and (deleteStatus !=? or deleteStatus is null) order by createTime desc",tableName];
        FMResultSet *rs = [fmDatabase executeQuery:sqlite,deleteNumber];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                MessageModel *model = [[MessageModel alloc] init] ;
                [model parseDataFromResultSet:rs];
                [array addObject:model];
                [model release];
            }
        }
        [rs close];
        [fmDatabase close];
        
    }
    return [array autorelease];
}

//测试用方法
+(NSMutableArray *)getMessages:(NSString *)classificationesblogType AndUserId:(NSString *)userId Limit:(NSInteger)limitNum
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:0];
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"Message_%@",userId];
        bool deletStyle = YES;
        NSNumber *deleteNumber = [NSNumber numberWithBool:deletStyle];
        NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where blogType=? and (deleteStatus !=? or deleteStatus is null) order by createTime desc limit %d",tableName,limitNum];
        FMResultSet *rs = [fmDatabase executeQuery:sqlite,classificationesblogType,deleteNumber];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                MessageModel *model = [[MessageModel alloc] init] ;
                [model parseDataFromResultSet:rs];
                [array addObject:model];
                [model release];
            }
        }
        [rs close];
        [fmDatabase close];
        
    }
    return [array autorelease];

}


+(NSMutableArray *)getMessagesBySyn:(NSString *)classificationesblogType
{
    
    NSMutableArray *array = [[[NSMutableArray alloc]initWithCapacity:0] autorelease];
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
//        NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where blogType=? order by createTime desc",tableName];
        NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where blogType=? and status != 1",tableName];

        FMResultSet *rs = [fmDatabase executeQuery:sqlite,classificationesblogType];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                MessageModel *model = [[MessageModel alloc] init];
                model.ID=[rs intForColumn:@"id"];
                model.localBlogId = [rs stringForColumn:@"id"];
                model.blogId=[rs stringForColumn:@"blogId"];
                model.blogType=[rs stringForColumn:@"blogType"];
                model.content=[rs stringForColumn:@"content"];
                model.summary=[rs stringForColumn:@"summary"];
                model.title=[rs stringForColumn:@"title"];
                model.groupId=[rs stringForColumn:@"groupId"];
                model.groupname=[rs stringForColumn:@"groupname"];
                model.accessLevel=[rs stringForColumn:@"accessLevel"];
                model.attachURL=[rs stringForColumn:@"attachURL"];
                model.thumbnail=[rs stringForColumn:@"thumbnail"];
                model.paths=[rs stringForColumn:@"paths"];
                model.spaths=[rs stringForColumn:@"spaths"];
                model.serverVer=[rs stringForColumn:@"serverVer"];
                model.localVer=[rs stringForColumn:@"localVer"];
                model.status=[rs stringForColumn:@"status"];
                model.needSyn=[[rs stringForColumn:@"needSyn"] boolValue];
                model.needUpdate=[[rs stringForColumn:@"needUpdate"] boolValue];
                model.needDownL=[[rs stringForColumn:@"needDownL"] boolValue];
                model.deletestatus=[[rs stringForColumn:@"deletestatus"] boolValue];
                model.size=[rs stringForColumn:@"size"];
                model.createTime=[rs stringForColumn:@"createTime"];
                model.lastModifyTime=[rs stringForColumn:@"lastModifyTime"];
                model.syncTime=[rs stringForColumn:@"syncTime"];
                model.remark=[rs stringForColumn:@"remark"];
                model.userId=[rs stringForColumn:@"userId"];
                [array addObject:model];
                [model release];
            }
        }
        [fmDatabase close];
    }
    return array;
    
}


//更新添加的blog
+(void)refershMessages:(NSArray *)array clientId:(NSString *)clientId{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        if ( [array count] > 0 )
        {
            for ( NSDictionary *dic in array )
            {
                MessageModel *model = [[[MessageModel alloc] initWithDict:dic] autorelease];
                model.localVer = model.serverVer;
                model.needDownL = NO;
                model.needSyn = NO;
                model.needUpdate = NO;
                model.status = @"1";
                NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
                NSString *userIdStr = [NSString stringWithFormat:@"%@",USERID];
                NSNumber *needDownLNumber = [NSNumber numberWithBool:model.needDownL];
                NSNumber *needSynNumber = [NSNumber numberWithBool:model.needSyn];
                NSNumber *needUpdateNumber = [NSNumber numberWithBool:model.needUpdate];
                NSNumber *deletestatusNumber = [NSNumber numberWithBool:model.deletestatus];
                NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogId=?,blogType=?,content=?,summary=?,title=?,groupId=?,accessLevel=?,attachURL=?,thumbnail=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,deletestatus=?,size=?,createTime=?,lastModifyTime=?,syncTime=?,remark=?,userId=? where id=?",tableName];
                if ([fmDatabase executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.accessLevel,model.attachURL,model.thumbnail,model.serverVer,model.localVer,model.status,needSynNumber,needUpdateNumber,needDownLNumber,deletestatusNumber,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,userIdStr,clientId]){
                }
                
                else{
                }
                
            }
        }
        [fmDatabase close];
    }
    
}
+(NSInteger)getMaxId{
    
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    int lastId = 0;
    if ([fmDatabase open]) {
        NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
        NSString *sql = [NSString stringWithFormat:@"select max(id) from %@",tableName];
        FMResultSet *rs = [fmDatabase executeQuery:sql];
        if ( rs !=nil )
        {
            while ( [rs next] )
            {
                lastId=[rs intForColumnIndex:0];
            }
        }
    }
    [fmDatabase close];
    return lastId;
}

//同步blog
+(void)synchronizeBlog:(NSArray *)array WithUserID:(NSString *)ID{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        if ( [array count] > 0 )
        {
            for ( NSDictionary *dic in array )
            {
                MessageModel *model = [[[MessageModel alloc] initWithDict:dic] autorelease];
                model.localVer = model.serverVer;
                model.needDownL = NO;
                model.needSyn = NO;
                model.needUpdate = NO;
                model.status = @"1";
                NSString *blogTypeStr = [NSString stringWithFormat:@"0"];
                NSString *blogTypeStr1 = [NSString stringWithFormat:@"%@",model.blogType];
                if ([blogTypeStr1 isEqualToString:blogTypeStr])
                {
                    if (model.summary ==nil||(NSNull *)model.summary==[NSNull null])
                    {
                        if (model.content!=nil&&(NSNull *)model.content!=[NSNull null]&&model.content.length<50) {
                            model.summary = model.content;
                        }else if(model.content!=nil&&(NSNull *)model.content!=[NSNull null]&&model.content.length>50){
                            model.summary = [model.content substringWithRange:NSMakeRange(0, 50)];
                        }
                    }
                    NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationesByGroupId:model.groupId];
                    if (groupArray && [groupArray count]>0) {
                        [groupArray objectAtIndex:0];
                        DiaryPictureClassificationModel *groupModel = [groupArray objectAtIndex:0];
                        model.groupname = groupModel.title;
                    }
                }
                NSString *tableName = [NSString stringWithFormat:@"Message_%@",ID];
                NSString *userIdStr = [NSString stringWithFormat:@"%@",ID];
                NSNumber *needDownLNumber = [NSNumber numberWithBool:model.needDownL];
                NSNumber *needSynNumber = [NSNumber numberWithBool:model.needSyn];
                NSNumber *needUpdateNumber = [NSNumber numberWithBool:model.needUpdate];
                NSNumber *deletestatusNumber = [NSNumber numberWithBool:model.deletestatus];
                if ([self isHadBlog:model.blogId]) {
                    NSString *sqlStr=nil;
                    NSString *blogType=[NSString stringWithFormat:@"%@",model.blogType];
                    
                    if ([blogType isEqualToString:@"1"]) {
                        sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogId=?,blogType=?,content=?,summary=?,title=?,groupId=?,accessLevel=?,attachURL=?,thumbnail=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,deletestatus=?,size=?,createTime=?,lastModifyTime=?,syncTime=?,remark=?,userId=? where blogId=?",tableName];
                        [fmDatabase executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.accessLevel,model.attachURL,model.thumbnail,model.serverVer,model.localVer,model.status,needSynNumber,needUpdateNumber,needDownLNumber,deletestatusNumber,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,userIdStr,model.blogId];
                    }else if ([blogType isEqualToString:@"0"]){
                        sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogId=?,blogType=?,summary=?,content=?,title=?,groupId=?,accessLevel=?,attachURL=?,thumbnail=?,paths=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,deletestatus=?,size=?,createTime=?,lastModifyTime=?,syncTime=?,remark=?,userId=? where blogId=?",tableName];
                        [fmDatabase executeUpdate:sqlStr,model.blogId,model.blogType,model.summary,model.content,model.title,model.groupId,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.serverVer,model.localVer,model.status,needSynNumber,needUpdateNumber,needDownLNumber,deletestatusNumber,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,userIdStr,model.blogId];
                    }
                    /*NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogId=?,blogType=?,content=?,summary=?,title=?,groupId=?,accessLevel=?,attachURL=?,thumbnail=?,paths=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,deletestatus=?,size=?,createTime=?,lastModifyTime=?,syncTime=?,remark=?,userId=? where blogId=?",tableName];
                     
                     if ([fmDatabase executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.serverVer,model.localVer,model.status,needSynNumber,needUpdateNumber,needDownLNumber,deletestatusNumber,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,userIdStr,model.blogId]){
                     
                     }
                     
                     else{
                     
                     }*/
                    
                }
                else
                {
                    if (!model.paths || model.paths.length == 0||(NSNull *)model.paths==[NSNull null]) {
                    
                        NSString *blogTypeStr = [NSString stringWithFormat:@"%@",model.blogType];
                        BOOL type = [blogTypeStr isEqualToString:@"1"];
                        if (type) {
                            /*
                            if (model.paths.length == 0) {
                                NSString *imgUrlStr = [NSString stringWithFormat:@"%@",model.attachURL];
                                NSURL *imgURL = [NSURL URLWithString:imgUrlStr];
                                NSData *imgData = [NSData dataWithContentsOfURL:imgURL] ;
                                UIImage *bigImg = [UIImage imageWithData:imgData];
                                NSString *imgName = [NSString stringWithFormat:@"img_%@.png",model.attachURL];
                                NSString *localImgName = [MD5 md5:imgName];
                                [self saveImage:bigImg withName:localImgName];
                                
                                NSString *bigImgPath = [self dataPath:localImgName];
                                model.paths = bigImgPath;
                                
                            }
                            if (model.spaths.length == 0) {
                                NSString *simgUrlStr = [NSString stringWithFormat:@"%@",model.thumbnail];
                                NSURL *simgURL = [NSURL URLWithString:simgUrlStr];
                                NSData *simgData = [NSData dataWithContentsOfURL:simgURL] ;
                                UIImage *sImg = [UIImage imageWithData:simgData];
                                
                                NSString *sImgName = [NSString stringWithFormat:@"simg_%@.png",model.thumbnail];
                                NSString *localSImgName = [MD5 md5:sImgName];
                                [self saveImage:sImg withName:localSImgName];
                                
                                NSString *smallImgPath =[self dataPath:localSImgName];
                                model.spaths = smallImgPath;
                            }
                             */
                        }
                        
                        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (blogId,blogType,content,summary,title,groupId,groupname,accessLevel,attachURL,thumbnail,paths,spaths,serverVer,localVer,status,needSyn,needUpdate,needDownL,deletestatus,size,createTime,lastModifyTime,syncTime,remark,userId) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
                        
                        if ([fmDatabase executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.spaths,model.serverVer,model.localVer,model.status,needSynNumber,needUpdateNumber,needDownLNumber,deletestatusNumber,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,userIdStr])
                        {
                            lastId =[fmDatabase lastInsertRowId];
                            
                            
                        }
                        else{
                            
                        }
                    }
                }
            }
        }
    }
    [fmDatabase close];
}





/*
 
 +(void)synchronizeBlog:(NSArray *)array{
 FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
 if([fmDatabase open])
 {
 if ( [array count] > 0 )
 {
 for ( NSDictionary *dic in array )
 {
 
 MessageModel *model = [[MessageModel alloc] initWithDict:dic];
 model.localVer = model.serverVer;
 model.needDownL = NO;
 model.needSyn = NO;
 model.needUpdate = NO;
 model.status = @"1";
 NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
 NSString *userIdStr = [NSString stringWithFormat:@"%@",USERID];
 NSNumber *needDownLNumber = [NSNumber numberWithBool:model.needDownL];
 NSNumber *needSynNumber = [NSNumber numberWithBool:model.needSyn];
 NSNumber *needUpdateNumber = [NSNumber numberWithBool:model.needUpdate];
 NSNumber *deletestatusNumber = [NSNumber numberWithBool:model.deletestatus];
 if (model.paths.length == 0||(NSNull *)model.paths==[NSNull null]) {
 
 NSString *blogTypeStr = [NSString stringWithFormat:@"%@",model.blogType];
 BOOL type = [blogTypeStr isEqualToString:@"1"];
 if (type) {
 if (model.paths.length == 0) {
 NSString *imgUrlStr = [NSString stringWithFormat:@"%@",model.attachURL];
 NSURL *imgURL = [NSURL URLWithString:imgUrlStr];
 NSData *imgData = [NSData dataWithContentsOfURL:imgURL] ;
 UIImage *bigImg = [UIImage imageWithData:imgData];
 NSString *imgName = [NSString stringWithFormat:@"img_%@.png",model.attachURL];
 NSString *localImgName = [MD5 md5:imgName];
 [self saveImage:bigImg withName:localImgName];
 
 NSString *bigImgPath = [self dataPath:localImgName];
 model.paths = bigImgPath;
 
 }
 if (model.spaths.length == 0) {
 NSString *simgUrlStr = [NSString stringWithFormat:@"%@",model.thumbnail];
 NSURL *simgURL = [NSURL URLWithString:simgUrlStr];
 NSData *simgData = [NSData dataWithContentsOfURL:simgURL] ;
 UIImage *sImg = [UIImage imageWithData:simgData];
 
 NSString *sImgName = [NSString stringWithFormat:@"simg_%@.png",model.thumbnail];
 NSString *localSImgName = [MD5 md5:sImgName];
 [self saveImage:sImg withName:localSImgName];
 
 NSString *smallImgPath =[self dataPath:localSImgName];
 model.spaths = smallImgPath;
 }
 }
 
 if ([self isHadBlog:model.blogId]) {
 NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogId=?,blogType=?,content=?,summary=?,title=?,groupId=?,accessLevel=?,attachURL=?,thumbnail=?,paths=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,deletestatus=?,size=?,createTime=?,lastModifyTime=?,syncTime=?,remark=?,userId=? where blogId=?",tableName];
 
 if ([fmDatabase executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.serverVer,model.localVer,model.status,needSynNumber,needUpdateNumber,needDownLNumber,deletestatusNumber,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,userIdStr,model.blogId]){
 
 }
 
 else{
 
 }
 
 }else{
 NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (blogId,blogType,content,summary,title,groupId,groupname,accessLevel,attachURL,thumbnail,paths,spaths,serverVer,localVer,status,needSyn,needUpdate,needDownL,deletestatus,size,createTime,lastModifyTime,syncTime,remark,userId) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
 
 if ([fmDatabase executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.spaths,model.serverVer,model.localVer,model.status,needSynNumber,needUpdateNumber,needDownLNumber,deletestatusNumber,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,userIdStr])
 {
 lastId =[fmDatabase lastInsertRowId];
 
 
 }
 else{
 
 }
 
 }
 
 }
 }
 }
 
 }
 [fmDatabase close];
 }
 
 
 
 */


+(BOOL)deletePhoto:(NSArray *)ary
{
    BOOL flag = NO;
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        if ( [ary count] > 0 )
        {
            for (MessageModel *model in ary )
            {
                NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
                NSString *sql;
                if (model.blogId == nil||model.blogId == NULL) {
                    sql=[NSString stringWithFormat:@"delete from %@ where id=?",tableName];
                    flag = [fmDatabase executeUpdate:sql,[NSString stringWithFormat:@"%d",model.ID]];

                }else{
                    sql=[NSString stringWithFormat:@"delete from %@ where blogId=?",tableName];
                    flag = [fmDatabase executeUpdate:sql,[NSString stringWithFormat:@"%@",model.blogId]];

                }
//                BOOL a=[fmDatabase executeUpdate:sql,[NSString stringWithFormat:@"%@",model.blogId]];
//                if (a) {
//                }
            }
        }
        [fmDatabase close];
    }
    
    return  flag;
}
+(void)deletePhotoByBlogId:(NSArray *)blogIds{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        if ( [blogIds count] > 0 )
        {
            for (NSString *blogId in blogIds )
            {
                NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
                NSString *sql=[NSString stringWithFormat:@"delete from %@ where blogId=? and blogType=?",tableName];
                if ([fmDatabase executeUpdate:sql,blogId,@"1"]) {
                }
            }
        }
        [fmDatabase close];
    }
}

+(void)deleteAllPhotos
{
    [self updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *d_sql = [NSString stringWithFormat:@"delete from %@ where blogType='1'", tableName];
        if ([db executeUpdate:d_sql])
        {
        }
        else
        {
        }
        
    }WithUserID:USERID];
}

+(BOOL)refershMessagesByMessageModelArray:(NSArray *)array{
    
    BOOL flag = NO;
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        if ( [array count] > 0 )
        {
            for (MessageModel *model in array )
            {
                
                NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
                NSString *userIdStr = [NSString stringWithFormat:@"%@",USERID];
                NSNumber *needDownLNumber = [NSNumber numberWithBool:model.needDownL];
                NSNumber *needSynNumber = [NSNumber numberWithBool:model.needSyn];
                NSNumber *needUpdateNumber = [NSNumber numberWithBool:model.needUpdate];
                NSNumber *deletestatusNumber = [NSNumber numberWithBool:model.deletestatus];
                if (model.blogId.length == 0)
                {
                    NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationesByGroupId:model.groupId];
                    if (groupArray && [groupArray count]>0) {
                        [groupArray objectAtIndex:0];
                        DiaryPictureClassificationModel *groupModel = [groupArray objectAtIndex:0];
                        model.groupname = groupModel.title;
                    }
                    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogType=?,content=?,summary=?,title=?,groupId=?,groupname=?,accessLevel=?,attachURL=?,thumbnail=?,paths=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,deletestatus=?,size=?,lastModifyTime=?,syncTime=?,remark=?,userId=?,spaths=? where createTime=?",tableName];
                    if ([fmDatabase executeUpdate:sqlStr,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.serverVer,model.localVer,model.status,needSynNumber,needUpdateNumber,needDownLNumber,deletestatusNumber,model.size,model.lastModifyTime,model.syncTime,model.remark,userIdStr,model.spaths,model.createTime])
                    {
                        flag = YES;
                    }else{
                        flag = NO;
                    }
                }
                else
                {
                    NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationesByGroupId:model.groupId];
                    if (groupArray && [groupArray count]>0) {
                        [groupArray objectAtIndex:0];
                        DiaryPictureClassificationModel *groupModel = [groupArray objectAtIndex:0];
                        model.groupname = groupModel.title;
                    }
                    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogType=?,content=?,summary=?,title=?,groupId=?,groupname=?,accessLevel=?,attachURL=?,thumbnail=?,paths=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,deletestatus=?,size=?,createTime=?,lastModifyTime=?,syncTime=?,remark=?,userId=?where id=?",tableName];
                    if ([fmDatabase executeUpdate:sqlStr,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.serverVer,model.localVer,model.status,needSynNumber,needUpdateNumber,needDownLNumber,deletestatusNumber,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,userIdStr,[NSNumber numberWithInt:model.ID]]){
                        flag = YES;
                    }
                    else{
                        flag = NO;
                        
                    }
                }
            }
        }
        [fmDatabase close];
    }
    
    return flag;
}

//处理本地无网时添加的日志数据
+(void)refreshLocalMessages:(NSArray *)localArr ToGroupId:(NSString *)groupId
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        if ( [localArr count] > 0 )
        {
            for (MessageModel *model in localArr)
            {
                NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
                NSString *sqlStr = [NSString stringWithFormat:@"update %@ set groupId = ? where groupId = ? and createTime = ?",tableName];
                [fmDatabase executeUpdate:sqlStr,groupId,model.groupId,model.createTime];
            }
        }
    }
    [fmDatabase close];
}
//处理本地无网时删除的日志数据
+(void)deleteLocalMessage:(NSArray *)localArr;
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        if ( [localArr count] > 0 )
        {
            for (MessageModel *model in localArr)
            {
                NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
                NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where groupId = ? and createTime = ? ",tableName];
                [fmDatabase executeUpdate:sqlStr,model.groupId,model.createTime];
            }
        }
    }
    [fmDatabase close];

}

+(void)refershMessagesByMessageModelArrayAfterHttp:(NSArray *)array{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        if ( [array count] > 0 )
        {
            for (MessageModel *model in array )
            {
                model.localVer = model.serverVer;
                model.needDownL = NO;
                model.needSyn = NO;
                model.needUpdate = NO;
                model.status = @"1";
                NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
                NSString *userIdStr = [NSString stringWithFormat:@"%@",USERID];
                NSNumber *localBlogId = [NSNumber numberWithInt:model.ID];
                NSNumber *needDownLNumber = [NSNumber numberWithBool:model.needDownL];
                NSNumber *needSynNumber = [NSNumber numberWithBool:model.needSyn];
                NSNumber *needUpdateNumber = [NSNumber numberWithBool:model.needUpdate];
                NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogId=?,blogType=?,content=?,summary=?,title=?,groupId=?,accessLevel=?,attachURL=?,thumbnail=?,paths=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,size=?,createTime=?,lastModifyTime=?,syncTime=?,remark=?,userId=?where id=?",tableName];
                if ([fmDatabase executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.serverVer,model.localVer,model.status,needSynNumber,needUpdateNumber,needDownLNumber,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,userIdStr,localBlogId]){
                }
                
                else{
                }
                
            }
        }
        [fmDatabase close];
    }
    
}
+(void)refershMessageAfterUpdata:(NSArray *)array
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    if([fmDatabase open])
    {
        if ( [array count] > 0 )
        {
            for ( NSDictionary *dic in array )
            {
                MessageModel *model = [[[MessageModel alloc] initWithDict:dic] autorelease];
                model.localVer = model.serverVer;
                model.needDownL = NO;
                model.needSyn = NO;
                model.needUpdate = NO;
                model.status = @"1";
                NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
                NSString *userIdStr = [NSString stringWithFormat:@"%@",USERID];
                NSNumber *needDownLNumber = [NSNumber numberWithBool:model.needDownL];
                NSNumber *needSynNumber = [NSNumber numberWithBool:model.needSyn];
                NSNumber *needUpdateNumber = [NSNumber numberWithBool:model.needUpdate];
                NSNumber *deletestatusNumber = [NSNumber numberWithBool:model.deletestatus];
                NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogType=?,content=?,summary=?,title=?,groupId=?,accessLevel=?,attachURL=?,thumbnail=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,deletestatus=?,size=?,createTime=?,lastModifyTime=?,syncTime=?,remark=?,userId=?where blogId=?",tableName];
                if ([fmDatabase executeUpdate:sqlStr,model.blogType,model.content,model.summary,model.title,model.groupId,model.accessLevel,model.attachURL,model.thumbnail,model.serverVer,model.localVer,model.status,needSynNumber,needUpdateNumber,needDownLNumber,deletestatusNumber,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,userIdStr,model.blogId]){
                }
                
                else{
                }
                
            }
        }
        [fmDatabase close];
    }
    
    
}

+(void)updataSPathForImageURL:(NSString *)ImageURLStr withPath:(NSString *)path
{
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    
    NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
    if ([db open] && [db tableExists:tableName])
    {
        [db setShouldCacheStatements:YES];
        
        NSString *u_sql = [NSString stringWithFormat:@"update %@ set spaths = ? where  thumbnail = ?",tableName];
        if([db executeUpdate:u_sql,path,ImageURLStr])
        {
        }
    }
    else
    {
        
    }
}

+(void)updataPathForImageURL:(NSString *)ImageUL withPath:(NSString *)path WithUserID:(NSString *)ID
{
    FMDatabase *db = [BaseDatas getBaseDatasInstance];
    
    NSString *tableName = [NSString stringWithFormat:@"Message_%@",ID];
    if ([db open] && [db tableExists:tableName])
    {
        [db setShouldCacheStatements:YES];
        
        NSString *u_sql = [NSString stringWithFormat:@"update %@ set paths = ? where  attachURL = ?",tableName];
        if([db executeUpdate:u_sql,path,ImageUL])
        {
        }
    }
    else
    {
    }
}
+ (void)refreshAllMessage:(NSArray *)models ForGroupID:(NSString *)groupId {
    
    [self updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *d_sql = [NSString stringWithFormat:@"delete from %@ where groupId = ? and status = '1'",tableName];
        if (![db executeUpdate:d_sql,groupId]) {
            return ;
        }
        
        [MessageSQL addBlogs:models];
    } WithUserID:USERID];
    
    
}

+(MessageModel *)getBlogByBlogId:(NSString *)blogId 
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    MessageModel *model = [[[MessageModel alloc] init] autorelease];
    if([fmDatabase open])
    {
        NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
        NSString *sqlite=[NSString stringWithFormat:@"select * from %@ where blogId=?",tableName];
        FMResultSet *rs = [fmDatabase executeQuery:sqlite,blogId];
        if ( rs !=nil && [rs next]){
            model.ID=[rs intForColumn:@"id"];
            model.blogId=[rs stringForColumn:@"blogId"];
            model.blogType=[rs stringForColumn:@"blogType"];
            model.content=[rs stringForColumn:@"content"];
            model.summary=[rs stringForColumn:@"summary"];
            model.title=[rs stringForColumn:@"title"];
            model.groupId=[rs stringForColumn:@"groupId"];
            model.groupname=[rs stringForColumn:@"groupname"];
            model.accessLevel=[rs stringForColumn:@"accessLevel"];
            model.attachURL=[rs stringForColumn:@"attachURL"];
            model.thumbnail=[rs stringForColumn:@"thumbnail"];
            model.paths=[rs stringForColumn:@"paths"];
            model.spaths=[rs stringForColumn:@"spaths"];
            model.serverVer=[rs stringForColumn:@"serverVer"];
            model.localVer=[rs stringForColumn:@"localVer"];
            model.status=[rs stringForColumn:@"status"];
            model.needSyn=[rs stringForColumn:@"needSyn"];
            model.needUpdate=[rs stringForColumn:@"needUpdate"];
            model.needDownL=[rs stringForColumn:@"needDownL"];
            model.deletestatus=[rs stringForColumn:@"deletestatus"];
            model.size=[rs stringForColumn:@"size"];
            model.createTime=[rs stringForColumn:@"createTime"];
            model.lastModifyTime=[rs stringForColumn:@"lastModifyTime"];
            model.syncTime=[rs stringForColumn:@"syncTime"];
            model.remark=[rs stringForColumn:@"remark"];
            model.userId=[rs stringForColumn:@"userId"];
            //
            if ([model.serverVer isEqualToString:model.localVer]) {
                
                NSMutableString *contenString = [NSMutableString stringWithFormat:@"%@",model.content];
                if (contenString.length > 50) {
                    model.summary = [contenString substringWithRange:NSMakeRange(0, 50)];
                }
                model.summary = model.content;
                
            }
        }
        
    }
    [fmDatabase close];
    return model;
    
}

//判断是否存在
+ (BOOL)isHadBlog:(NSString *)blogId
{
    FMDatabase *fmDatabase = [BaseDatas getBaseDatasInstance];
    
    fmDatabase.logsErrors = YES;
    if(![fmDatabase open])
    {
    }
    
    NSString *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
    NSString *sql = [NSString stringWithFormat:@"SELECT blogId FROM %@ WHERE blogId=?",tableName];
    FMResultSet *result = [fmDatabase executeQuery:sql,blogId];
    while ([result next])
    {
        [fmDatabase close];
        return YES;
    }
    [fmDatabase close];
    return NO;
}
#pragma mark - 保存图片至沙盒
+ (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    NSString *fullPath = [Utilities dataPath:imageName FileType:@"Photos" UserID:USERID];

    [imageData writeToFile:fullPath atomically:NO];
}
@end

