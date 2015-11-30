//
//  LeaveMessageModel.h
//  EternalMemory
//
//  Created by xiaoxiao on 1/2/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeaveMessageModel : NSObject

@property (nonatomic, copy)NSString *localBlogId;//本地自增id字段
@property (nonatomic, copy)NSString *blogId;//消息id
@property (nonatomic, copy)NSString *blogType;//类别.blog,music,video等.
@property (nonatomic, copy)NSString *content;//日记内容 照片简介
@property (nonatomic, copy)NSString *summary;//日记前几个字
@property (nonatomic, copy)NSString *title;//日记内容 照片简介
@property (nonatomic, copy)NSString *groupId;//分组id
@property (nonatomic, copy)NSString *groupname; //分组名称
@property (nonatomic, copy)NSString *accessLevel;//访问级别.public 1 ，friend 2 self 3
@property (nonatomic, copy)NSString *attachURL;//图片原图url、日记过长返回url
@property (nonatomic, copy)NSString *thumbnail;//缩略图url
@property (nonatomic, copy)NSString *paths;//图片本地路径
@property (nonatomic, copy)NSString *spaths;//缩略图本地路径
@property (nonatomic, copy)NSString *serverVer;//服务器版本号
@property (nonatomic, copy)NSString *localVer;//本地版本号
@property (nonatomic, copy)NSString *status;//状态：noExchange 是1 ，add是2 、delete是3 、update是4
@property (nonatomic, copy)NSString *size;//图片大小
@property (nonatomic, copy)NSString *createTime;//创建时间
@property (nonatomic, copy)NSString *lastModifyTime;//最后更新时间
@property (nonatomic, copy)NSString *syncTime;//同步时间
@property (nonatomic, copy)NSString *remark;//备注
@property (nonatomic, copy)NSString *userId;//用户id
@property (nonatomic) bool deletestatus;//删除状态

@end
