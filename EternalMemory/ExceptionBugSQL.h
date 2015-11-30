//
//  ExceptionBugSQL.h
//  EternalMemory
//
//  Created by zhaogl on 14-2-19.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExceptionBugSQL : NSObject


/**
 *  存储bug信息
 *
 *  @param bugInfo bug信息
 *
 */
+ (void)addExceptionBugInfo:(NSDictionary *)bugInfo;

/**
 *  删除bug信息
 *
 *  @param  自增ID
 *
 */
+ (void)deleteExceptionBugInfo:(NSInteger)ID;

/**
 *  获取bug信息
 *
 *  @param
 *
 *  return array bug信息
 */

+ (NSArray *)getAllExceptionBugInfo;
@end
