//
//  DiaryGroupsModel.m
//  EternalMemory
//
//  Created by xiaoxiao on 3/18/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "DiaryGroupsModel.h"

@implementation DiaryGroupsModel

-(id)initWithDict:(NSDictionary *)dict{
    self = [super init];
    if (self==[super init]) {
        _title        =[[dict objectForKey:@"title"] copy];
        _remark       =[[dict objectForKey:@"remark"] copy];
        _userId       =[[dict objectForKey:@"userId"] copy];
        _groupId      =[[NSString alloc] initWithFormat:@"%d",[[dict objectForKey:@"groupId"] intValue]];
        _syncTime     =[[dict objectForKey:@"syncTime"] copy];
        _blogType     =[[dict objectForKey:@"blogType"] copy];
        _blogcount    =[[dict objectForKey:@"blogcount"] copy];
        _createTime   =[[dict objectForKey:@"createTime"] copy];
        _accessLevel  =[[dict objectForKey:@"accessLevel"] copy] ;
        _deleteStatus =[[dict objectForKey:@"deleteStatus"]  boolValue];

    }
    return self;
}
-(void)dealloc{
    
    RELEASE_SAFELY(_blogType);
    RELEASE_SAFELY(_title);
    RELEASE_SAFELY(_userId);
    RELEASE_SAFELY(_syncTime);
    RELEASE_SAFELY(_accessLevel);
    RELEASE_SAFELY(_blogcount);
    RELEASE_SAFELY(_createTime);
    RELEASE_SAFELY(_groupId);
    RELEASE_SAFELY(_remark);
    [super dealloc];
}

@end
