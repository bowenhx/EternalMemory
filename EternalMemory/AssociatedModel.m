//
//  AssociatedModel.m
//  EternalMemory
//
//  Created by xiaoxiao on 1/13/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "AssociatedModel.h"
#import "GenealogyMetaData.h"
@implementation AssociatedModel

@synthesize name = _name;
@synthesize authCode = _authCode;
@synthesize relation = _relation;
@synthesize downloadState = _downloadState;
@synthesize associateUserId = _associateUserId;
- (void)dealloc
{
    RELEASE_SAFELY(_name);
    RELEASE_SAFELY(_relation);
    RELEASE_SAFELY(_authCode);
    [super dealloc];
}

-(id)initWithFMReuslt:(FMResultSet *)rs
{
    self = [super init];
    if (self)
    {
        self.name     = [rs stringForColumn:kName];
        self.relation = [rs stringForColumn:kNickName];
        self.authCode = [rs stringForColumn:kEternalCode];
        self.associateUserId = [[rs stringForColumn:kAssociateUserId] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        self.downloadState = 0;
    }
    return self;
}

@end
