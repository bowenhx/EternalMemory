//
//  FileModel.h
//  EternalMemory
//
//  Created by Guibing on 06/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CommonData : NSObject

//将文件大小转化成M单位或者B单位
+(NSString *)getFileSizeString:(NSString *)size;

//经文件大小转化成不带单位ied数字
+(float)getFileSizeNumber:(NSString *)size;

//取出下载文件
+(NSArray *)getOutDownloadFile;

//得到实际文件存储文件夹的路径
+(NSString *)getTargetFloderPath;


//取出上传文件路径
+ (NSArray *)getOutUploadingFile;

//上传文件存储路径
+ (NSString *)getUploadingFile;

//解压下载的风格模板zip包
+(void)beginDecompressionFile:(NSDictionary *)dic;

//风格模板zip文件解压后的路径
+(NSString *)styleFilePath:(NSString *)pathName;

//解压家园风格后的文件路径
+ (NSString *)getZipFilePathManager;

//删除本地的默认模版
+(void)deleteStylePath:(NSString *)pathName;

//得到临时文件存储文件夹的路径(音乐、家园模板)
+(NSString *)getTempFolderPath;

//得到临时文件存储文件夹的路径(视频)
+(NSString *)getMovieTempFolderPath;
//得到临时文件存储文件夹的路径(音频)
+(NSString *)getMusicTempFolderPath;

//检查文件名是否存在
+(BOOL)isExistFile:(NSString *)fileName;    

//传入文件总大小和当前大小，得到文件的下载进度
+(CGFloat) getProgress:(float)totalSize currentSize:(float)currentSize;

//判断并获取视频路径，主要是mov视频
+ (NSString *)strPathGetTargetFloderTranscodingPath:(NSDictionary *)dic;

//取视频路径url
+ (NSString *)getMovVideoPath:(NSDictionary *)dic;

//计算转换当前时间
+(NSString *)getTimeransitionPath:(NSString *)str;

//计算转换生日时间
+(NSString *)getTimeransitionBirthDataPath:(NSString *)str;

//判断字符串是否为空
+ (BOOL)isTitleBlank:(NSString *)str;
@end