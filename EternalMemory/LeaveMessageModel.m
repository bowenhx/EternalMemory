//
//  LeaveMessageModel.m
//  EternalMemory
//
//  Created by xiaoxiao on 1/2/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "LeaveMessageModel.h"

@implementation LeaveMessageModel
-(id)initWithDict:(NSDictionary *)dict{
    self = [super init];
    if (self==[super init]) {
        
        
        _accessLevel=[[dict objectForKey:@"accessLevel"] copy];
        _blogId=[[dict objectForKey:@"blogId"] copy];
        _blogType=[[dict objectForKey:@"blogType"] copy];
        _localBlogId=[[dict objectForKey:@"clientid"] copy];
        _content=[[dict objectForKey:@"content"]  copy];
        _summary=[[dict objectForKey:@"summary"]  copy];
        _createTime=[[dict objectForKey:@"createTime"] copy];
        _deletestatus=[[dict objectForKey:@"deleteStatus"] boolValue];
        _groupId=[[dict objectForKey:@"groupId"] copy];
        _lastModifyTime = [[dict objectForKey:@"lastModifyTime"] copy];
        _remark=[[dict objectForKey:@"remark"] copy];
        _syncTime=[[dict objectForKey:@"syncTime"] copy];
        _title=[[dict objectForKey:@"title"] copy];
        _userId=[[dict objectForKey:@"userId"] copy];
        _serverVer=[[dict objectForKey:@"versions"] copy];
        _attachURL= [[dict objectForKey:@"attachURL"] copy];
        _thumbnail = [[dict objectForKey:@"thumbnail"] copy];
        _groupname = [[dict objectForKey:@"groupname"] copy];
        
    }
    return self;
}


-(void)dealloc
{
    
    RELEASE_SAFELY(_size);
    RELEASE_SAFELY(_status);
    RELEASE_SAFELY(_localVer);
    RELEASE_SAFELY(_paths);
    RELEASE_SAFELY(_spaths);
    RELEASE_SAFELY(_title);
    RELEASE_SAFELY(_content);
    RELEASE_SAFELY(_groupname);
    RELEASE_SAFELY(_attachURL);
    RELEASE_SAFELY(_thumbnail);
    RELEASE_SAFELY(_remark);
    RELEASE_SAFELY(_userId);
    RELEASE_SAFELY(_localBlogId);
    RELEASE_SAFELY(_accessLevel);
    RELEASE_SAFELY(_blogId);
    RELEASE_SAFELY(_createTime);
    RELEASE_SAFELY(_groupId);
    RELEASE_SAFELY(_lastModifyTime);
    RELEASE_SAFELY(_syncTime);
    RELEASE_SAFELY(_serverVer);
    RELEASE_SAFELY(_summary)
    RELEASE_SAFELY(_blogType);
    
    [super dealloc];
    
}

@end
