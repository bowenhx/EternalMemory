//
//  GenealogyModifyMemberInfoViewController.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CustomNavBarController.h"
#import "GenealogyMetaData.h"


// 修改成员信息成功的通知
static NSString * const ModifyMemberInfoSuccessNotification     = @"ModifyMemberInfoSuccessNotification";

// 添加成员成功的通知
static NSString * const AddingMemberSuccessNotification         = @"AddingMemberSuccessNotification";

// 删除成员成功的通知
static NSString * const DeleteMemberSuccessNotification         = @"DeleteMemberSuccessNotification";

/**
 *  编辑类型
 */
typedef NS_ENUM(NSUInteger, GenealogyEditorType) {
    /**
     *  添加
     */
    GenealogyEditorTypeAdd = 0,
    /**
     *  修改
     */
    GenealogyEditorTypeModify
};

/**
 *  添加成员的类型
 */
typedef NS_ENUM(NSUInteger, GenealogyMemberType) {
    /**
     *  添加配偶
     */
    GenealogyAdditionTypePartner = 0,
    /**
     *  添加儿子
     */
    GenealogyAdditionTypeSon,
    /**
     *  添加女儿
     */
    GenealogyAdditionTypeDaughter,
    /**
     *  添加祖先
     */
    GenealogyAdditionTypeAncestor
};
    
@interface GenealogyMemberEditorViewController : CustomNavBarController
<
    UINavigationControllerDelegate,
    UITextFieldDelegate,
    UIActionSheetDelegate,
    UIAlertViewDelegate,
    UIImagePickerControllerDelegate,
    ASIHTTPRequestDelegate
>

@property (retain, nonatomic) IBOutlet UIButton *deleteMemberBtn;
@property (assign, nonatomic) GenealogyEditorType editorType;
@property (assign, nonatomic) GenealogyMemberType memberType;

// 如果添加家族成员，为targetMemberInfo复制
@property (retain, nonatomic) NSMutableDictionary *targetMebmerInfo;
@property (retain, nonatomic) NSString          *targetMemberId;  
@property (retain, nonatomic) NSString          *level;

// 如果修改成员信息，为memberInfoDic赋值。
@property (retain, nonatomic) NSMutableDictionary *memberInfoDic;

@property (retain, nonatomic) NSMutableDictionary *editMemberInfoDic;

@property (retain, nonatomic) NSDictionary *tempMemberInfo;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(GenealogyEditorType)editorType;



@end
