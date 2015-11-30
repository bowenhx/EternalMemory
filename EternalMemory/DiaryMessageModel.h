//
//  DiaryMessageModel.h
//  EternalMemory
//
//  Created by xiaoxiao on 3/18/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiaryMessageModel : NSObject


@property (nonatomic)int ID;//自增id
@property (nonatomic, copy)NSString *localBlogId;//本地自增id字段
@property (nonatomic, copy)NSString *blogId;//消息id
@property (nonatomic, copy)NSString *blogType;//类别.blog,music,video等.
@property (nonatomic, copy)NSString *content;//日记内容 照片简介
@property (nonatomic, copy)NSString *summary;//日记前几个字
@property (nonatomic, copy)NSString *title;//日记内容 照片简介
@property (nonatomic, copy)NSString *groupId;//分组id
@property (nonatomic, copy)NSString *groupname; //分组名称
@property (nonatomic, copy)NSString *accessLevel;//访问级别.public 1 ，friend 2 self 3
@property (nonatomic, copy)NSString *serverVer;//服务器版本号
@property (nonatomic, copy)NSString *localVer;//本地版本号
@property (nonatomic, copy)NSString *status;//状态：noExchange 是1 ，add是2 、delete是3 、update是4
@property (nonatomic, copy)NSString *size;//图片大小
@property (nonatomic, copy)NSString *createTime;//创建时间
@property (nonatomic, copy)NSString *lastModifyTime;//最后更新时间
@property (nonatomic, copy)NSString *syncTime;//同步时间
@property (nonatomic, copy)NSString *remark;//备注
@property (nonatomic, copy)NSString *userId;//用户id

@property (nonatomic, copy) NSString *theOrder;
@property (nonatomic, copy)NSString *versions;//用户id

@property (nonatomic) bool needSyn;//是否需要同步
@property (nonatomic) bool needUpdate;//是否更新
@property (nonatomic) bool needDownL;//是否下载
@property (nonatomic) bool deletestatus;//删除状态
@property (nonatomic) bool editStatus;//删除状态


- (id)initWithDict:(NSDictionary *)dict;

@end
