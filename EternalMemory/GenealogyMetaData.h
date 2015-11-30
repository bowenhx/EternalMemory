//
//  GenealogyMetaData.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

// -----------------------------memberInfoDic中的字段---------------------------------------

/**
 *  居住地址
 */
static NSString * const kAddress            = @"address";           
/**
 *  授权码
 */
static NSString * const kAssociateAuthCode  = @"associateAuthCode";
/**
 *  关联方式 "eternalcode" "sid" "username"
 */
static NSString * const kAssociateKey       = @"associateKey";
/**
 *  关联用户ID
 */
static NSString * const kAssociateUserId    = @"associateUserId";
/**
 *  关联key的值
 */
static NSString * const kAssociateValue     = @"associateValue";
/**
 *  是否已关联
 */
static NSString * const kAssociated         = @"associated";
/**
 *  生日
 */
static NSString * const kBirthDate          = @"birthDate";
/**
 *  是否中轴线
 */
static NSString * const kDirectLine         = @"directLine";
/**
 *  记忆码
 */
static NSString * const kEternalCode        = @"eternalCode";
/**
 *  永恒号
 */
static NSString * const kEternalNum         = @"eternalnum";
/**
 *  简介、备注
 */
static NSString * const kIntro              = @"intro";
/**
 *  是否血亲
 */
static NSString * const kKinRelation        = @"kinRelation";
/**
 *  层级
 */
static NSString * const kLevel              = @"level";
/**
 *  成员ID
 */
static NSString * const kMemberId           = @"memberId";
/**
 *  姓名
 */
static NSString * const kName               = @"name";
/**
 *  与我的关系
 */
static NSString * const kNickName           = @"nickName";
/**
 *  父ID
 */
static NSString * const kParentId           = @"parentId";
/**
 *  配偶ID
 */
static NSString * const kPartnerId          = @"partnerId";
/**
 *  配偶
 */
static NSString * const kPartners           = @"partners";
/**
 *  性别
 */
static NSString * const kSex                = @"sex";
/**
 *  身份标识（妻子：现任，离异；儿子：亲生，领养，过继） 
 */
static NSString * const kSubTitle           = @"subTitle";
/**
 *  用户ID
 */
static NSString * const kUserId             = @"userId";
/**
 *  头像
 */
static NSString * const kHeadPortrait       = @"headPortrait";

/**
 *  去世时间
 */
static NSString * const kDeathDate          = @"deathDate";

/**
 *  是否健在
 */
static NSString * const kIsDead             = @"isDead";

/**
 *  母亲ID
 */
static NSString * const kMotherID           = @"motherId";

/**
 *  母亲的姓名
 */
static NSString * const kMotherName         = @"mothername";

/**
 *  更新时间
 */
static NSString * const kUpdateTime         = @"updatetime";

/**
 *  最大层级
 */
static NSString * const kMaxLevel           = @"maxLevel";

/**
 *  是否生日提醒
 */
static NSString * const kBirthWarned        = @"birthWarned";

/**
 *  生日提醒时间
 */
static NSString * const kBirthWarnTime      = @"birthwarntime";

/**
 *  是否提醒去世时间
 */
static NSString * const kDeathWarnned       = @"deathWarned";

/**
 *  提醒去世时间的提醒
 */
static NSString * const kDeathWarnTime      = @"deathwarntime";


// ----------------------------------------------------------------------------------------



@interface GenealogyMetaData : NSObject



@end
