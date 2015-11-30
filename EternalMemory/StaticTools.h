//
//  StaticTools.h
//  EternalMemory
//
//  Created by sun on 13-5-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MessageModel;
@interface StaticTools : NSObject
+(StaticTools *)shareInstance;
- (BOOL)Chk18PaperId:(NSString *)sPaperId;

//判断文本信息长度
+ (NSUInteger) lenghtWithString:(NSString *)string;


//判断一生记忆的图片本地是否存在
+(NSString *)getMemoPhoto:(MessageModel *)model;
//横竖屏时设置相关尺寸
+(void)setViewRect:(UIImageView *)imageView image:(UIImage *)image;

//测试方法
+(void)setViewOldRect:(UIImageView *)imageView image:(UIImage *)image;

//更新相册分组
+(void)updateDiaryAndPhotoGroup:(NSArray *)groupArray WithUserID:(NSString *)UserID;
//更新图片数据库问题
+(void)insertDBPhotos:(NSArray *)photoArray;

//无网通过家园浏览全部的图片
+ (void)getPhotoFromLocal:(id)obj;

//有网通过家园浏览全部的图片
+(void)getPhotoFromServer:(id)obj;
@end
