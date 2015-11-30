//
//  GenealogyRelationEngine.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//


#import "GenealogyRelationEngine.h"
#import "MyFamilySQL.h"
#import "GenealogyMetaData.h"

@implementation GenealogyRelationEngine

+ (BOOL)shouldAddOnCentralAxisForLevel:(NSDictionary *)aMember
{
    BOOL shoulOnCentralAxis = YES;
    
    if (([aMember[kSex] integerValue] == 2) && !([aMember[kUserId] isEqualToString:aMember[kMemberId]])) {
        return NO;
    }
    if ([aMember[kDirectLine] integerValue] == 0) {
        return NO;
    }
    
    NSInteger level = [aMember[kLevel] integerValue] + 1;
    NSString *levelStr = [NSString stringWithFormat:@"%d",level];
    NSArray *members = [MyFamilySQL getMemberFroLevel:levelStr];
    for (NSDictionary *dic in members) {
        NSInteger isDirectLine = [dic[kDirectLine] integerValue];
        if (isDirectLine == 1) {
            shoulOnCentralAxis = NO;
            break;
        }
    }
    return shoulOnCentralAxis;
}

+ (NSString *)judgeRelationshipWithMeForLevel:(NSString *)level andBirthdate:(long long)birthDate gender:(NSInteger)gender
{
    NSMutableString *relationship = [[NSMutableString alloc] init];
    
    
    return [relationship autorelease];
}

+ (NSDictionary *)moveaMemberToCentralAxisAtLevel:(NSString *)level
{
    NSArray *members = [MyFamilySQL getMemberFroLevel:level];
    NSInteger count = members.count;
    if (count <= 0) {
        return nil;
    }
    NSMutableDictionary *mDic = nil;
    for (NSDictionary *aMember in members) {
        
        if ([aMember[kSex] integerValue] == 1) {
            mDic = [NSMutableDictionary dictionaryWithDictionary:mDic];
            mDic[kDirectLine] = @"1";
            break;
        } else {
            continue;
        }
    }
    
    return mDic;
}

@end
