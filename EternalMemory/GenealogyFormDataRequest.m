//
//  GenealogyFormDataRequest.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-21.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "GenealogyFormDataRequest.h"
#import "SavaData.h"



static NSString * const kOperationTypeUpdateInfo    = @"updateinfo";
static NSString * const kOperationTypeUpdateParent  = @"updateparent";
static NSString * const kOperationTypeAssociation   = @"associate";

static NSString * const kAssociationKeyAuth         = @"authcode";
static NSString * const kAssociationKeyEternal      = @"eternalcode";

@interface GenealogyFormDataRequest () {

}

@property (nonatomic, retain) NSString * operationTypeValue;

@end

@implementation GenealogyFormDataRequest



- (void)setUpdateType:(GenealogyUpdateType)updateType
{
    if (_updateType == GenealogyUpdateTypeUpdateInfo) {
        self.operationTypeValue = kOperationTypeUpdateInfo;
    } else if (_updateType == GenealogyUpdateTypeUpdateParent) {
        self.operationTypeValue = kOperationTypeUpdateParent;
    } else if (_updateType == GenealogyUpdateTypeAssociation) {
        self.operationTypeValue = kOperationTypeAssociation;
    }
}

- (void)setCommentRequest
{
    [self setPostValue:self.operationTypeValue forKey:@"operation"];
    [self setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [self setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
}

- (void)setModifyRequestAttributesWithDictionary:(NSDictionary *)attributes
{
    [self setPostValue:self.operationTypeValue forKey:@"operation"];
    [self setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [self setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [self setPostValue:attributes[kAssociateAuthCode] forKey:@"associateauthcode"];
    [self setPostValue:attributes[kMemberId] forKey:@"memberid"];
    [self setPostValue:attributes[kParentId] forKey:@"parentid"];
    [self setPostValue:attributes[kPartnerId] forKey:@"partnerid"];
    [self setPostValue:attributes[kName] forKey:@"name"];
    [self setPostValue:attributes[kIntro] forKey:@"intro"];
    [self setPostValue:attributes[kSex] forKey:@"sex"];
    [self setPostValue:attributes[kLevel] forKey:@"level"];
    [self setPostValue:attributes[kBirthDate] forKey:@"birthdate"];
    [self setPostValue:attributes[kSubTitle] forKey:@"subtitle"];
    [self setPostValue:attributes[kNickName] forKey:@"nickname"];
    [self setPostValue:attributes[kAddress] forKey:@"address"];
    [self setPostValue:attributes[kDeathWarnned] forKey:@"deathwarned"];
    [self setPostValue:attributes[kBirthWarned] forKey:@"birthwarned"];
    [self setPostValue:attributes[kIsDead] forKey:@"isdead"];
    [self setPostValue:attributes[kDeathDate] forKey:@"deathdate"];
    [self setPostValue:attributes[kMotherID] forKey:@"motherid"];
    [self setPostValue:attributes[kDirectLine] forKey:@"directline"];
}


- (void)setAdditionRequestAttributesWithDictionary:(NSDictionary *)attributes
{
    [self setPostValue:self.operationTypeValue forKey:@"operation"];
    [self setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [self setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [self setPostValue:attributes[kMotherID] forKey:@"motherid"];
    [self setPostValue:attributes[kIsDead] forKey:@"isdead"];
    [self setPostValue:attributes[kDirectLine] forKey:@"directline"];
    [self setPostValue:attributes[kDeathDate] forKey:@"deathdate"];
    [self setPostValue:attributes[kPartnerId] forKey:@"partnerid"];
    [self setPostValue:attributes[kParentId] forKey:@"parentid"];
    [self setPostValue:attributes[kLevel] forKey:@"level"];
    [self setPostValue:attributes[kName] forKey:@"name"];
    [self setPostValue:attributes[kIntro] forKey:@"intro"];
    [self setPostValue:attributes[kDeathWarnned] forKey:@"deathwarned"];
    [self setPostValue:attributes[kBirthWarned] forKey:@"birthwarned"];
    [self setPostValue:attributes[kSex] forKey:@"sex"];
    [self setPostValue:attributes[kBirthDate] forKey:@"birthdate"];
    [self setPostValue:attributes[kSubTitle] forKey:@"subtitle"];
    [self setPostValue:attributes[kNickName] forKey:@"nickname"];
    [self setPostValue:attributes[kAddress] forKey:@"address"];
    [self setPostValue:attributes[kDirectLine] forKey:@"directline"];
    if ([attributes[kSex] integerValue] == 2 && [attributes[kLevel] integerValue] > 0) {
        [self setPostValue:@"0" forKey:@"directline"];
    }
    [self setPostValue:attributes[kKinRelation] forKey:@"kinrelation"];

}

- (void)setupDeleteMemberRequestWithMemberid:(NSString *)memberId
{
    [self setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [self setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [self setPostValue:@"cascade" forKey:@"cascade"];
    [self setPostValue:memberId forKey:@"memberid"];
}

- (void)setupModifyMemberHeaderRequestWithHeaderImage:(UIImage *)image andMemberId:(NSString *)memberId;
{
    [self setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [self setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    NSData *imageDate = UIImageJPEGRepresentation(image, 0.1);
    [self addData:imageDate withFileName:@"imageHeader.png" andContentType:@"image/png" forKey:@"imageheader"];
}

- (void)associatedMemberByAssociatedKey:(GenealogyAssociteKey)key withTheCode:(NSDictionary *)code memberId:(NSString *)memberid
{
    [self setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [self setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [self setPostValue:memberid forKey:@"memberid"];
    if (key == GenealogyAssociteKeyAuth) {
//        NSString *eternalnum = code[kAssociateValue];
//        [self setPostValue:@"eternalnum" forKey:@"associatekey"];
//        [self setPostValue:eternalnum forKey:@"eternalnum"];
//        [self setPostValue:code[kAssociateAuthCode] forKey:@"associateauthcode"];
        [self setPostValue:@"eternalcode" forKey:@"associatekey"];
        [self setPostValue:code[kAssociateAuthCode] forKey:@"eternalcode"];
    }
//    if (key == GenealogyAssociteKeyEternal) {
//        [self setPostValue:kAssociationKeyEternal forKey:@"associatekey"];
//        [self setPostValue:code[kEternalCode] forKey:@"eternalcode"];
//    }
    
}

@end
