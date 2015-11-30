//
//  DiaryModel.h
//  EternalMemory
//
//  Created by sun on 13-6-4.
//  Copyright (c) 2013年 sun. All rights reserved.
// blogId TEXT,blogType TEXT,summary varchar(100),content text,groupid TEXT,groupname TEXT,title TEXT, accessLevel TEXT,attachURL TEXT,thumbnail TEXT,paths TEXT,spaths TEXT,serverVer TEXT,localVer TEXT,status TEXT,deletestatus BOOL,needSyn BOOL,needUpdate BOOL,needDownL BOOL,size TEXT,createTime TEXT,lastModifyTime TEXT,syncTime TEXT,remark TEXT

#import <Foundation/Foundation.h>
#import "EMAudio.h"
/**
 *  标记thumbnail的类型
 */
typedef NS_ENUM(NSInteger, MessageModelThumbnailType) {
    /**
     *  用户上传
     */
    MessageModelThumbnailTypeUserUpload = 0,
    /**
     *  系统模板
     */
    MessageModelThumbnailTypeTemplate
};

@class EMAlbumImage;
@interface MessageModel : NSObject <NSCopying>
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

//------------------------测试字段----------------------------
@property (nonatomic, copy)NSString *tempPath;   //大图临时路径
@property (nonatomic, copy)NSString *tempSPath;  //小图临时路径
//-----------------------------------------------------------



@property (nonatomic) bool needSyn;//是否需要同步
@property (nonatomic) bool needUpdate;//是否更新
@property (nonatomic) bool needDownL;//是否下载
@property (nonatomic) bool deletestatus;//删除状态
@property (nonatomic) bool editStatus;//删除状态

@property (nonatomic, assign) BOOL selected;

//------------------------一生记忆字段----------------------------

@property (nonatomic, assign) MessageModelThumbnailType thumbnailType; //缩略图类型
@property (nonatomic, copy) NSString *photoWall;
@property (nonatomic, copy) NSString *theOrder;
@property (nonatomic, copy) NSString *templateImagePath;
@property (nonatomic, copy) NSString *templateImageURL;
//-----------------------------------------------------------
//

@property (nonatomic, retain) UIImage *rawImage;
@property (nonatomic, retain) UIImage *thumbnailImage;

@property (nonatomic, retain) EMAudio *audio;

- (id)initWithDict:(NSDictionary *)dict;
- (void)getThumbnailImageFromLocalPath;

- (NSString *)pathForSavedThumbnailImageToLocalPath;

- (UIImage *)thumbnailImageAtLocalPath;

- (instancetype)deepCopy;


@end
