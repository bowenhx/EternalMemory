//
//  DiaryGroupsModel.h
//  EternalMemory
//
//  Created by xiaoxiao on 3/18/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiaryGroupsModel : NSObject

@property(nonatomic) int ID;//自增id
@property(nonatomic,copy)  NSString *accessLevel;//访问级别.public 1 ，friend 2 self 3
@property(nonatomic,copy)  NSString *blogType;//类别.blog,music,video等.
@property(nonatomic,copy)  NSString *blogcount;//数量
@property(nonatomic,copy)  NSString *createTime;//创建时间
@property(nonatomic,copy)  NSString *groupId;//组id
@property(nonatomic,copy)  NSString *remark;//说明
@property(nonatomic,copy)  NSString *syncTime;// 同步时间
@property(nonatomic,copy)  NSString *title;// 标题
@property(nonatomic,copy)  NSString *userId;//用户id
@property(nonatomic,assign)BOOL      deleteStatus;//删除状态


-(instancetype)initWithDict:(NSDictionary *)dict;

@end
