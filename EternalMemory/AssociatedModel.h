//
//  AssociatedModel.h
//  EternalMemory
//
//  Created by xiaoxiao on 1/13/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
@interface AssociatedModel : NSObject

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *relation;
@property(nonatomic,copy)NSString *authCode;
@property(nonatomic,copy)NSString *associateUserId;
@property(nonatomic,assign)NSInteger downloadState;


-(id)initWithFMReuslt:(FMResultSet *)rs;

@end
