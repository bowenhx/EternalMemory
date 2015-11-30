//
//  UploadingDebugging.h
//  EternalMemory
//
//  Created by xiaoxiao on 1/21/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadingDebugging : NSObject

//将上传的数据存储到plist表中
+(void)savaUplaodFiles:(NSMutableArray *)fileArr;

//下载成功或删除文件成功后对上传的数据组的操作
+(void)uploadSuccessOrDeleteFileNotification:(int)index;

//一个文件上传完成或失败后继续上传其他文件的操作
+(void)goOnUploadingAfterSuccessOrFailed;

//恢复上传操作
+(void)resumeUploading:(int)index;

//判断上传列表是否有正在上传的数据及正在上传的内容的位置
+(void)setUploadIndex;

//上传中暂停、恢复按钮操作
+(void)stopAndReStartUploadAtIndex:(int)index;
//设置等待上传数据的点击暂停、恢复按钮后的状态
+(void)setWaitingDataStateAtIndex:(int)index;

//获取正在上传的数据的位置
+(int)uploadingIndex:(NSString *)name;
//设置数据上传失败的状态
+(void)setFailedState:(int)index FailedIdentifier:(NSString *)identifier;

//程序进入后台后不同情况（上传成功、失败、内存不足等）下的操作
+(void)setBackgroundOperation:(int)state Index:(int)index;

//判断是否正在上传
+(BOOL)isUploading;
//退出时设置上传数据
+(void)setupUploadingInfo;

//处理上传完成意外存留的数据
+(void)dealWithUploadedData;
//处理意外数据问题
+(void)dealWithErrorMusicData:(NSMutableArray *)uploadMusicArr;

//应用启动或从后台返回时上传数据的处理
+(void)updateDataWhenBeginOrComeBack;

@end
