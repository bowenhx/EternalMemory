//
//  DiaryClassificationModel.m
//  EternalMemory
//
//  Created by sun on 13-6-4.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "DiaryPictureClassificationModel.h"
#import "UIImageView+WebCache.h"
#import "EMAudio.h"

@implementation DiaryPictureClassificationModel

-(id)initWithDict:(NSDictionary *)dict{
    self = [super init];
    if (self==[super init]) {
        _accessLevel=[[dict objectForKey:@"accessLevel"] copy] ;
        _blogType=[[dict objectForKey:@"blogType"] copy];
        _blogcount=[[dict objectForKey:@"blogcount"] copy];
        _createTime=[[dict objectForKey:@"createTime"] copy];
        _deleteStatus=[[dict objectForKey:@"deleteStatus"]  boolValue];
        _groupId=[[dict objectForKey:@"groupId"] copy];
        _remark=[[dict objectForKey:@"remark"] copy];
        _syncTime = [[dict objectForKey:@"syncTime"] copy];
        _title=[[dict objectForKey:@"title"] copy];
        _userId=[[dict objectForKey:@"userId"] copy];
        _latestPhotoURL=[[dict objectForKey:@"latestPhotoURL"] copy];
        _latestPhotoPath = [[dict objectForKey:@"latestPhotoPath"] copy];
        
        _audio = [[EMAudio alloc] init];
        _audio.audioURL = [dict[@"voiceURL"] copy];
        _audio.size = [dict[@"voiceSize"]  integerValue];
        _audio.duration = [dict[@"duration"] integerValue];
    }
    return self;
}

- (void)downloadImage
{
    // TODO:
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
    RELEASE_SAFELY(_latestPhotoURL);
    RELEASE_SAFELY(_thumbnail);
    RELEASE_SAFELY(_latestPhotoPath);
    RELEASE_SAFELY(_audio);
    [super dealloc];
}

@end
