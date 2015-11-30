//
//  SynDataBackstage.m
//  EternalMemory
//
//  Created by SuperAdmin on 13-11-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import "DiaryMessageModel.h"
#import "SynDataBackstage.h"
#import "DiaryMessageSQL.h"
#import "DiaryGroupsSQL.h"
#import "RequestParams.h"
#import "Utilities.h"
#import "MD5.h"

#define PHOTOTEXT @"0"
#define REQUEST_FOR_LOGIN 100
#define REQUEST_FOR_GETGROUPS 200
#define REQUEST_FOR_ADDDIARY 1000
#define REQUEST_FOR_DELETBLOG 2000
#define REQUEST_FOR_UPDATADIARY 3000
#define REQUEST_FOR_ADDPHOTO 4000
#define REQUEST_FOR_DELETEPHOTO 5000
#define REQUEST_FOR_UPDATAPHOTO 6000
#define REQUEST_FOR_GETBLOGLIST 7000
@interface SynDataBackstage ()
{
    NSInteger overCount;
    BOOL      LoginOther;
    NSInteger synCount;
    NSArray  *diatyArray;
    ASIFormDataRequest *formRequest;
}
-(void)requestSuccess:(ASIFormDataRequest *)request;
-(void)requestFail:(ASIFormDataRequest *)request;
@end

@implementation SynDataBackstage

- (void)dealloc
{
    RELEASE_SAFELY(diatyArray);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        overCount = 0;
        LoginOther = NO;
        synCount = 0;
        diatyArray = [[DiaryMessageSQL getMessagesBySyn:@"0"] retain];
        synCount = diatyArray.count;
    }
    return self;
}

//测试后台同步功能
- (void)synchronousDBData
{
    //同步日记
    if (diatyArray && [diatyArray count] > 0)
    {
        DiaryMessageModel *blogModel = (DiaryMessageModel *)diatyArray[overCount];
        if (blogModel.blogId == nil || blogModel.blogId == NULL || blogModel.blogId.length == 0)
        {
            if ([Utilities checkNetwork]) {
                NSArray *array = [NSArray arrayWithObject:blogModel];
                [DiaryMessageSQL deletePhoto:array];
                [self addDiaryRequest:blogModel];
            }
        }
        if (blogModel.blogId != nil || blogModel.blogId != NULL)
        {
            //状态：noExchange 是1 ，add是2 、delete是3 、update是4
            switch ( [blogModel.status intValue]) {
                case 3:
                    [self deleteBlogsReauest:blogModel];
                    break;
                    
                case 4:
                    if ([Utilities checkNetwork]) {
                        [self upDateDiaryRequest:blogModel];
                    }
                    break;
                    
                default:
                    break;
            }
        }
    }
}

//取消请求（崩溃问题）
-(void)cleanRequest
{
    if (formRequest)
    {
        [formRequest clearDelegatesAndCancel];
        formRequest = nil;
    }
}
//退出登录取消同步
-(void)cancelRequestWhenLogout
{
    if (formRequest)
    {
        [formRequest clearDelegatesAndCancel];
        formRequest = nil;
    }
}
//同步日志列表
- (void)synchronousBlogList
{
    NSURL *registerUrl = [[RequestParams sharedInstance] manageGroup];
    formRequest = [ASIFormDataRequest requestWithURL:registerUrl];
    formRequest.delegate = self;
    formRequest.shouldAttemptPersistentConnection = NO;
    formRequest.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_GETGROUPS],@"tag", nil] ;
    [formRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [formRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [formRequest setPostValue:@"list" forKey:@"operation"];
    [formRequest setRequestMethod:@"POST"];
    [formRequest setTimeOutSeconds:30.0];
    __block typeof (self) bself=self;
    
    [formRequest setCompletionBlock:^{
        [bself requestSuccess:formRequest];
    }];
    [formRequest setFailedBlock:^{
        [bself requestFail:formRequest];
    }];
    [formRequest startAsynchronous];
}

#pragma mark - http
- (void)addDiaryRequest:(DiaryMessageModel *)blog
{
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
    NSURL *registerUrl = [[RequestParams sharedInstance] addblog];
    formRequest = [ASIFormDataRequest requestWithURL:registerUrl];
    formRequest.shouldAttemptPersistentConnection = NO;
    formRequest.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_ADDDIARY],@"tag", blog.groupId,@"groupId",nil];
    [formRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [formRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [formRequest setPostValue:@"0" forKey:@"blogtype"];
    [formRequest setPostValue:blog.accessLevel   forKey:@"accesslevel"];
    [formRequest setPostValue:blog.title forKey:@"title"];
    [formRequest setPostValue:blog.content forKey:@"content"];
    [formRequest setPostValue:@"" forKey:@"remark"];
    [formRequest setPostValue:[NSString stringWithFormat:@"%f",timestamp] forKey:@"lastmodifytime"];
    [formRequest setPostValue:blog.createTime forKey:@"createTime"];
    [formRequest setPostValue:blog.groupId forKey:@"groupid"];
    [formRequest setRequestMethod:@"POST"];
    [formRequest setTimeOutSeconds:30.0];
    __block typeof (self) bself=self;
    
    [formRequest setCompletionBlock:^{
        [bself requestSuccess:formRequest];
    }];
    [formRequest setFailedBlock:^{
        [bself requestFail:formRequest];
    }];
    [formRequest startAsynchronous];
}
- (void)deleteBlogsReauest:(DiaryMessageModel *)blog
{
    NSURL *registerUrl = [[RequestParams sharedInstance] deleteBlog];
    formRequest = [ASIFormDataRequest requestWithURL:registerUrl];
    formRequest.shouldAttemptPersistentConnection = NO;
    formRequest.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_DELETBLOG],@"tag", blog.groupId,@"groupId",nil];
    [formRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [formRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [formRequest setPostValue:blog.blogId forKey:@"blogid"];
    [formRequest setRequestMethod:@"POST"];
    [formRequest setTimeOutSeconds:15.0];
    __block typeof (self) bself=self;
    
    [formRequest setCompletionBlock:^{
        [bself requestSuccess:formRequest];
    }];
    [formRequest setFailedBlock:^{
        [bself requestFail:formRequest];
    }];
    [formRequest startAsynchronous];
    
}
- (void)upDateDiaryRequest:(DiaryMessageModel *)blog
{
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
    NSString *dateStr = [NSString stringWithFormat:@"%f",timestamp];
    blog.lastModifyTime = dateStr;
    
    NSURL *registerUrl = [[RequestParams sharedInstance] editBlog];
    formRequest = [ASIFormDataRequest requestWithURL:registerUrl];
    formRequest.shouldAttemptPersistentConnection = NO;
    formRequest.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_UPDATADIARY],@"tag", nil] ;
    [formRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [formRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [formRequest setPostValue:@"0" forKey:@"blogtype"];
    [formRequest setPostValue:blog.groupId forKey:@"groupid"];
    [formRequest setPostValue:blog.accessLevel forKey:@"accesslevel"];
    [formRequest setPostValue:blog.title forKey:@"title"];
    [formRequest setPostValue:blog.content forKey:@"content"];
    [formRequest setPostValue:@"" forKey:@"remark"];
    [formRequest setPostValue:dateStr forKey:@"lastmodifytime"];
    [formRequest setPostValue:blog.blogId forKey:@"blogid"];
    [formRequest setRequestMethod:@"POST"];
    [formRequest setTimeOutSeconds:30.0];
    __block typeof (self) bself=self;
    [formRequest setCompletionBlock:^{
        [bself requestSuccess:formRequest];
    }];
    [formRequest setFailedBlock:^{
        [bself requestFail:formRequest];
    }];
    [formRequest startAsynchronous];
    
}

#pragma mark - request
-(void)requestSuccess:(ASIFormDataRequest *)request
{
    formRequest = nil;
    overCount ++;
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    @try {
        NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
        NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
        NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
        if ([resultStr isEqualToString:@"0"])
        {
            if (overCount < synCount)
            {
                [self synchronousDBData];
            }
            else if (overCount == synCount)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"synDataOver" object:[NSNumber numberWithInteger:overCount]];
            }
        }
        else if ([resultStr isEqualToString:@"1"])
        {
            if (tag == REQUEST_FOR_GETGROUPS) {
                NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:10];
                [dataArray setArray:[resultDictionary objectForKey:@"data"]];
                [DiaryGroupsSQL  refershDiaryGroups:dataArray WithUserID:USERID];
            }
            //同步
            if (tag == REQUEST_FOR_ADDDIARY) {
                NSDictionary *dataDic =[resultDictionary objectForKey:@"data"];
                NSArray *blogArray = [NSArray arrayWithObject:dataDic];
                [DiaryMessageSQL synchronizeBlog:blogArray WithUserID:USERID];
            }
            if (tag == REQUEST_FOR_DELETBLOG) {
                NSString *blogId = [resultDictionary objectForKey:@"data"];
                [DiaryMessageSQL deleteDiaryBlogs:[NSArray arrayWithObject:blogId]];
            }
            if (tag == REQUEST_FOR_UPDATADIARY) {
                NSDictionary *dataDic =[resultDictionary objectForKey:@"data"];
                NSArray *blogArray = [NSArray arrayWithObject:dataDic];
                [DiaryMessageSQL synchronizeBlog:blogArray WithUserID:USERID];
            }
            if (tag == REQUEST_FOR_GETGROUPS)
            {
                NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:10];
                [dataArray setArray:[resultDictionary objectForKey:@"data"]];
                [DiaryGroupsSQL  refershDiaryGroups:dataArray WithUserID:USERID];
            }
            
            if (overCount < synCount)
            {
                [self synchronousDBData];
            }
            else if (overCount == synCount)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"synDataOver" object:[NSNumber numberWithInteger:overCount]];
            }
        }

    }
    @catch (NSException *exception) {
        
    }
    @finally {
        if (overCount < synCount)
        {
            [self synchronousDBData];
        }
        else if (overCount == synCount)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"synDataOver" object:[NSNumber numberWithInteger:overCount]];
        }
    }
}

-(void)requestFail:(ASIFormDataRequest *)request
{
    formRequest = nil;
    overCount ++;
    if (overCount < synCount)
    {
        [self synchronousDBData];
    }
    else if (overCount == synCount)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"synDataOver" object:[NSNumber numberWithInteger:overCount]];
    }
}


@end
