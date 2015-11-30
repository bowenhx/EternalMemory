//
//  GenealogyRelationEngine.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  定义各种判断关系的方法。
 */
@interface GenealogyRelationEngine : NSObject

/**
 *  判断是否应该加在中轴线上
 *
 *  @param level 指定的层
 *
 *  @return 是否改在中轴线上
 */
+ (BOOL)shouldAddOnCentralAxisForLevel:(NSDictionary *)aMember;

/**
 *  判断与我的关系
 *
 *  @param level 指定层级
 *  @param birthDate 出生日期 时间戳
 *  @param gender 性别 1:男 0:女
 *
 *  @return 与我的关系
 */
+ (NSString *)judgeRelationshipWithMeForLevel:(NSString *)level andBirthdate:(long long int)birthDate gender:(NSInteger)gender;

+ (NSDictionary *)moveaMemberToCentralAxisAtLevel:(NSString *)level;

@end
