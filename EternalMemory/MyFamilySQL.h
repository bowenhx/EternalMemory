//
//  MyFamilySQL.h
//  EternalMemory
//
//  Created by kiri on 13-9-14.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyFamilySQL : NSObject

/**
 *  添加家庭成员
 *
 *  @param array 家庭成员
 */
+(void)addFamilyMembers:(NSArray *)array AndType:(NSString *)type WithUserID:(NSString *)ID;

/**
 *  获得家庭成员
 *
 *  @return 家庭成员
 */
+(NSArray *)getFamilyMembersWithUserId:(NSString *)userId;

/**
 *  获得关联成员
 *
 *  @return 关联成员
 */
+(NSMutableArray *)getAssociatedMembers;

+(NSArray *)getMembersHeadPortrait:(NSString *)userId;


/**
 *  删除家族成员(单个)
 *
 *  @param memberId 成员ID
 */
+ (void)deleteMemberWithMemberID:(NSString *)memberId;

/**
 *  删除家族成员
 *
 *  @param memberIds 要删除家族成员的ID
 */
+ (void)deleteMembersWithMemberIds:(NSArray *)memberIds;

/**
 *  级联删除家族成员，如果该成员在中轴线上，则再指定另一名成员到中轴线
 *
 *  @param memberIds   删除家族成员的ID
 *  @param movedMemberID    移动的成员
 */
+ (void)deleteMembers:(NSArray *)memberIds andMoveMemberToCentralAxis:(NSArray *)movedMemberID;

/**
 *  获得指定层级上的成员
 *
 *  @param level 指定层级
 *
 *  @return 制定层级上的所有成员
 */
+ (NSArray *)getMemberFroLevel:(NSString *)level;

/**
 *  修改家庭成员的信息
 *
 *  @param aMember 成员信息
 */
+ (void)updateMemberByMemberId:(NSDictionary *)aMember;

/**
 *  获得母亲的相关信息
 *
 *  @param motherId 母亲的ID
 *
 *  @return 母亲的信息
 */
+ (NSDictionary *)getMotherInfoWithMotherId:(NSString *)motherId andMemberId:(NSString *)memberId;

/**
 *  查找自定成员的爸爸的配偶
 *
 *  @param memberInfo 成员信息
 *
 *  @return 爸爸的所有配偶
 */
+ (NSArray *)getAllMothersForAMember:(NSDictionary *)memberInfo;

/**
 *  根据个人资料修改的信息更新我的家谱里面我的信息
 *
 *  @param dic 我的信息
 *
 */
+ (void)updateMyinfoForData:(NSDictionary *)dic;

@end
