//
//  DiaryClassificationModel.h
//  EternalMemory
//
//  Created by sun on 13-6-4.
//  Copyright (c) 2013年 sun. All rights reserved.
//
// INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, type TEXT,accessLevel TEXT,blogType TEXT,amount TEXT,createTime TEXT,deleteStatus BOOL,groupId TEXT,remark TEXT,syncTime TEXT,title TEXT
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EMCategorySyncStatus) {
    EMCategorySyncStatusUpload = 0,
    EMCategorySyncStatusDelete,
    EMCategorySyncStatusUpdate
};

@class EMAudio;
@interface DiaryPictureClassificationModel : NSObject
@property(nonatomic) int ID;//自增id
@property(nonatomic,copy)NSString *accessLevel;//访问级别.public 1 ，friend 2 self 3
@property(nonatomic,copy)NSString *blogType;//类别.blog,music,video等.
@property(nonatomic,copy)NSString *blogcount;//数量
@property(nonatomic,copy)NSString *createTime;//创建时间
@property(nonatomic,assign)BOOL   deleteStatus;//删除状态
@property(nonatomic,copy)NSString *groupId;//组id
@property(nonatomic,copy)NSString *remark;//说明
@property(nonatomic,copy)NSString *syncTime;// 同步时间
@property(nonatomic,copy)NSString *title;// 标题
@property(nonatomic,copy)NSString *userId;//用户id
@property(nonatomic,copy)NSString *latestPhotoURL;//最后上传图片地址
@property(nonatomic,copy)NSString *latestPhotoPath;//最后图片地址

@property(nonatomic,assign) EMCategorySyncStatus *syncStatus;

@property (nonatomic, retain) EMAudio *audio;


@property(nonatomic,retain)  UIImage        *thumbnail;

-(instancetype)initWithDict:(NSDictionary *)dict;

@end
