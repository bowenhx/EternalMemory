//
//  PhotoListFormedRequest.m
//  EternalMemory
//
//  Created by FFF on 13-12-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "PhotoListFormedRequest.h"
#import "SavaData.h"
#import "MessageSQL.h"
#import "EMAudio.h"
#import "MessageModel.h"
#import "DiaryPictureClassificationSQL.h"
#import "EternalMemoryAppDelegate.h"

@implementation PhotoListFormedRequest

#pragma mark - Build up a post request
- (void)setCommonPostValue
{
    [self setRequestMethod:@"POST"];
    [self setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [self setPostValue:USER_AUTH_GETOUT  forKey:@"serverauth"];
}

- (void)setupRequestForGettingPhotoList
{
    [self setCommonPostValue];
    [self setPostValue:@"1"  forKey:@"getdeleted"];
    
}

- (void)setupRequestForDeletingPhoto:(MessageModel *)model
{
    [self setCommonPostValue];
    [self setPostValue:model.blogId forKey:@"blogid"];
}

- (void)setupRequestForDeletingPhotoWithBlogid:(NSString *)blogid
{
    [self setCommonPostValue];
    [self setPostValue:blogid forKey:@"blogid"];
}

- (void)setupRequestForUpdatePhotoDes:(MessageModel *)model
{
    [self setCommonPostValue];
    [self setPostValue:model.blogId forKey:@"blogid"];
    [self setPostValue:@"-2" forKey:@"groupid"];
    [self setPostValue:model.content forKey:@"content"];
    [self setPostValue:@"0" forKey:@"theorder"];
}


#pragma mark - Handle a server response

- (NSArray *)handleRequestResultForGroupId:(NSString *)groupId
{
    NSData *data = [self responseData];
    NSDictionary *dic = [data objectFromJSONData];
    NSInteger success = [dic[@"success"] integerValue];
    NSString *rspsMsg = dic[@"message"];
    if (success == 1) {
        
        
//        NSString *serverVersion = dic[@"meta"][@"serverversion"];
        NSArray *deletedArr     = dic[@"meta"][@"deletelist"];
        NSArray *photosArr      = dic[@"data"];
        
        NSMutableArray *resultArr = nil;
        if (photosArr.count > 0) {
            resultArr = [NSMutableArray array];
            for (NSDictionary *dic in photosArr) {
                MessageModel *model = [[MessageModel alloc] initWithDict:dic];
//                model.status = @"1";
                [resultArr addObject:model];
                [model release];
            }
        }
        
        dispatch_queue_t dataBaseQueue = dispatch_queue_create("com.iyhjy.listDataQueue", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(dataBaseQueue, ^{
            
            NSString *serverversion = dic[@"meta"][@"serverversion"];
            [DiaryPictureClassificationSQL setServerversion:serverversion forGroupId:groupId];
            [MessageSQL deletePhotoByBlogId:deletedArr];
            [MessageSQL addBlogs:resultArr inGroup:groupId];
        });
        
        dispatch_release(dataBaseQueue);
       
        return resultArr;
//        //如果没有新添加或者要删除的照片，则不更新数据库， 直接返回，避免不必要的视图刷新。
//        if (!deletedArr && !(!photosArr || (photosArr.count != 0))) {
//            return nil;
//        }
//        
//        [[SavaData shareInstance] directSave:serverVersion forKey:kSavedPhotoListServerVersion];
//        [self handleResponseDataDictionary:dic];
//        
//        NSMutableArray *resultArr = nil;
//        if (deletedArr.count > 0) {
//            [MessageSQL deletePhotosWithDeleteList:deletedArr];
//            deletedArr = nil;
//        }
//        
////        resultArr = [MessageSQL getMessages:@"1" AndUserId:USERID] ;
//        resultArr = [MessageSQL getGroupIDMessages:groupId AndUserId:USERID];
//
//        return resultArr;
        
    }
    else if(success == 0) {
    }
    
    return nil;
}

- (BOOL)handleDeletingRequest
{
    BOOL flag = NO;
    NSData *data = [self responseData];
    NSDictionary *dic = [data objectFromJSONData];
    NSInteger success = [dic[@"success"] integerValue];
//    NSInteger errorcode = [dic[@"errorcode"] integerValue];
    NSString *rspsMsg = dic[@"message"];
    if (success == 1) {
        
        flag = YES;

        [self updateSpaceUsed:dic];
        MessageModel *model = nil;
        @try {
            model = [self.userInfo[@"model"] retain];
        }
        @catch (NSException *exception) {
        }
        @finally {
            
        }
        
        if (model) {
            [MessageSQL deletePhoto:@[model]];
            [[NSFileManager defaultManager] removeItemAtPath:model.paths error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:model.spaths error:nil];
        }
        
        
        [model release];
        
    } else {
        // 请求错误
                flag = NO;
    }
    
    return flag;
}

- (NSDictionary *)requestForUpdatingPhotoDesSuccess;
{
    NSDictionary *responseModelDic = nil;
    
    NSData *data = [self responseData];
    NSDictionary *dic = [data objectFromJSONData];
    NSInteger success = [dic[@"success"] integerValue];
    NSString *rspsMsg = dic[@"message"];
    if (success == 1) {
        
        responseModelDic = dic[@"data"];
        
        MessageModel *model = nil;
        @try {
            model = [self.userInfo[@"model"] retain];
            model.status = @"1";
        }
        @catch (NSException *exception) {
        }
        @finally {
            
        }
        
        if (model) {
            [MessageSQL refershMessagesByMessageModelArray:@[model]];
        }
        
    } else {
        // 请求错误
    }
    
    return responseModelDic;
}

- (void)handleResponseDataDictionary:(NSDictionary *)dic
{
    NSArray *modelDicArr = dic[@"data"];
    for (NSDictionary *modelDic in modelDicArr) {
        @autoreleasepool {
            MessageModel *model = [[[MessageModel alloc] initWithDict:modelDic] autorelease];
            
            [MessageSQL updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
                NSString *s_sql = [NSString stringWithFormat:@"select * from %@ where blogId = ?", tableName];
                FMResultSet *rs = [db executeQuery:s_sql,model.blogId];
                if ([rs next]) {
                    
                    NSInteger version = [[rs stringForColumn:@"serVer"] integerValue];
                    NSInteger modelVer = [[[SavaData shareInstance] printDataStr:kSavedPhotoListServerVersion] integerValue];
                    if (modelVer > version) {
                        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET blogId=?,blogType=?,content=?,summary=?,title=?,groupId=?,accessLevel=?,attachURL=?,thumbnail=?,serverVer=?,localVer=?,status=?,needSyn=?,needUpdate=?,needDownL=?,deletestatus=?,size=?,createTime=?,lastModifyTime=?,syncTime=?,remark=?,userId=? where blogId=?",tableName];
                        if ([db executeUpdate:sqlStr,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.serverVer,model.localVer,model.status,model.needSyn,model.needUpdate,model.needDownL,model.deletestatus,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,model.userId,model.blogId]) {
                        }
                    }
                    
                } else {
                    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (blogId,blogType,content,summary,title,groupId,groupname,accessLevel,attachURL,thumbnail,paths,spaths,serverVer,localVer,status,needSyn,needUpdate,needDownL,deletestatus,size,createTime,lastModifyTime,syncTime,remark,userId, audioPath, audioDuration, audioSize, audioURL) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
                    model.status = @"1";
                    if ([db executeUpdate:sqlStr,model.blogId,model.blogType,model.content,model.summary,model.title,model.groupId,model.groupname,model.accessLevel,model.attachURL,model.thumbnail,model.paths,model.spaths,model.serverVer,model.localVer,model.status,model.needSyn,model.needUpdate,model.needDownL,model.deletestatus,model.size,model.createTime,model.lastModifyTime,model.syncTime,model.remark,USERID, model.audio.wavPath, @(model.audio.duration), @(model.audio.size), model.audio.audioURL])
                    {
                    }
                    else
                    {
                    }

                }
            }WithUserID:USERID];
        }
    }
}


- (void)updateSpaceUsed:(NSDictionary *)responseDic {
    NSDictionary *meteDic = responseDic[@"meta"];
    [SavaData  fileSpaceUseAmount:[NSNumber numberWithInteger:[meteDic[@"spaceused"] integerValue]]];
}

@end
