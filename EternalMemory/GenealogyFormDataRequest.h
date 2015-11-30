//
//  GenealogyFormDataRequest.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-21.
//  Copyright (c) 2013年 sun. All rights reserved.
//

typedef NS_ENUM(NSInteger, GenealogyUpdateType) {
    GenealogyUpdateTypeUpdateInfo = 0,
    GenealogyUpdateTypeUpdateParent ,
    GenealogyUpdateTypeAssociation
};

/**
 *  关联方式
 */
typedef NS_ENUM(NSInteger, GenealogyAssociteKey){
    /**
     *  通过记忆码关联
     */
    GenealogyAssociteKeyEternal = 0,
    /**
     *  通过授权码关联
     */
    GenealogyAssociteKeyAuth
};


#import "GenealogyMemberDetailViewController.h"

@interface GenealogyFormDataRequest : ASIFormDataRequest

@property (nonatomic, assign) GenealogyUpdateType updateType;
@property (nonatomic, assign) GenealogyAssociteKey associatedkey;

- (void)setCommentRequest;


- (void)setModifyRequestAttributesWithDictionary:(NSDictionary *)attributes;


- (void)setAdditionRequestAttributesWithDictionary:(NSDictionary *)attributes;

/**
 *  封装删除成员的请求数据
 *
 *  @param memberId 成员ID
 */
- (void)setupDeleteMemberRequestWithMemberid:(NSString *)memberId;

/**
 *  封装修改成员头像请求
 *
 *  @param image    头像
 *  @param memberId 成员ID
 */
- (void)setupModifyMemberHeaderRequestWithHeaderImage:(UIImage *)image andMemberId:(NSString *)memberId;

/**
 *  封装添加关联的请求
 *
 *  @param key  关联方式
 *  @param code 相应的关联码
 *  @param memberid 成员的memberid
 */
- (void)associatedMemberByAssociatedKey:(GenealogyAssociteKey)key withTheCode:(NSDictionary *)codes memberId:(NSString *)memberid;

@end
