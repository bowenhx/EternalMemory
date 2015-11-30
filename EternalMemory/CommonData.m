//
//  FileModel.m
//  EternalMemory
//
//  Created by Guibing on 06/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "CommonData.h"
#import "ZipArchive.h"
#import "Config.h"

@implementation CommonData {

}

+(NSString *)getFileSizeString:(NSString *)size
{
    if([size floatValue]>=1024*1024)//大于1M，则转化成M单位的字符串
    {
        return [NSString stringWithFormat:@"%.2fM",[size floatValue]/1024/1024];
    }
    else if([size floatValue]>=1024&&[size floatValue]<1024*1024) //不到1M,但是超过了1KB，则转化成KB单位
    {
        return [NSString stringWithFormat:@"%.2fM",[size floatValue]/1024/1024];
    }
    else//剩下的都是小于1K的，则转化成B单位
    {
        return [NSString stringWithFormat:@"%dKB",[size integerValue]];
    }
}

+(float)getFileSizeNumber:(NSString *)size
{
    NSInteger indexM=[size rangeOfString:@"M"].location;
    NSInteger indexK=[size rangeOfString:@"K"].location;
    NSInteger indexB=[size rangeOfString:@"B"].location;
    if(indexM<1000)//是M单位的字符串
    {
        return [[size substringToIndex:indexM] floatValue]*1024*1024;
    }
    else if(indexK<1000)//是K单位的字符串
    {
        return [[size substringToIndex:indexK] floatValue]*1024;
    }
    else if(indexB<1000)//是B单位的字符串
    {
        return [[size substringToIndex:indexB] floatValue];
    }
    else//没有任何单位的数字字符串
    {
        return [size floatValue];
    }
}
//取出下载文件
+(NSArray *)getOutDownloadFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
//    NSString *downFileName = [NSString stringWithFormat:@"down%@",USERID];
//    NSString *testDirectory = [documentsDirectory stringByAppendingPathComponent:downFileName];
    //NSArray *file = [fileManager subpathsOfDirectoryAtPath:testDirectory error:nil];
    
    NSArray *arrFiles = [fileManager subpathsAtPath:documentsDirectory];
    return arrFiles;
    
}
//风格模板的固定存储路径，在library中
+(NSString *)getDownloadFileDocumentPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager]; 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //这里不区分用户
//    NSString *downFileName = [NSString stringWithFormat:@"down%@",USERID];
//    NSString *testDirectory = [documentsDirectory stringByAppendingPathComponent:downFileName];
    
    // 创建目录
    [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    return  documentsDirectory;
}

+(NSString *)getTargetFloderPath
{
    return [self getDownloadFileDocumentPath];
}

//取出上传文件路径
+ (NSArray *)getOutUploadingFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *downFileName = [NSString stringWithFormat:@"uploading%@",USERID];
    NSString *testDirectory = [documentsDirectory stringByAppendingPathComponent:downFileName];
    //NSArray *file = [fileManager subpathsOfDirectoryAtPath:testDirectory error:nil];

    NSArray *arrFiles = [fileManager subpathsAtPath:testDirectory];
    return arrFiles;
}
//上传文件存储路径
+ (NSString *)getUploadingFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *downFileName = [NSString stringWithFormat:@"uploading%@",USERID];
    NSString *testDirectory = [documentsDirectory stringByAppendingPathComponent:downFileName];

    // 创建目录
    [fileManager createDirectoryAtPath:testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    return  testDirectory;
}

//解压下载的风格模板zip包
+(void)beginDecompressionFile:(NSDictionary *)dic
{
    NSString *zipSave = nil;
    NSString *strName = nil;
    NSString *zipPath = nil;
    if ([dic[@"sourceFrom"] isEqualToString:@"bundle"])
    {
        zipSave = [CommonData styleFilePath:@"style2"];
        zipPath = [[NSBundle mainBundle] pathForResource:@"style2" ofType:@"zip"];
    }
    else
    {
        strName = [NSString stringWithFormat:@"style%@",dic[@"styleId"]];
        zipSave= [CommonData styleFilePath:strName];
        NSString *fileName = [NSString stringWithFormat:@"%@.zip",strName];
        zipPath = [[CommonData getTargetFloderPath] stringByAppendingPathComponent:fileName];
    }
    if ([zipSave isEqualToString:@"0"]) {
        return;
    }
    ZipArchive *zipFiile = [[ZipArchive alloc] init];
 
    BOOL isFinish;
    if ([zipFiile UnzipOpenFile:zipPath]) {
        isFinish = [zipFiile UnzipFileTo:zipSave overWrite:YES];
        
        if (!isFinish) {
        }else
        {
            NSFileManager *fileManager=[NSFileManager defaultManager];
            NSError *error;
            if ([CommonData isExistFile:zipPath]) {
                [fileManager removeItemAtPath:zipPath error:&error];
                if (!error) {
                }
            }
        }
        [zipFiile UnzipCloseFile];
    }
    [zipFiile release];

}
+(void)deleteStylePath:(NSString *)pathName{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dir = [[CommonData getZipFilePathManager] stringByAppendingPathComponent:pathName];
    [fileManager removeItemAtPath:dir error:nil];
}
//风格模板zip文件解压后的路径
+(NSString *)styleFilePath:(NSString *)pathName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *savePath = [[CommonData getZipFilePathManager] stringByAppendingPathComponent:pathName];
    if (![fileManager fileExistsAtPath:savePath]) {
        [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }else
    {
        return @"0";
    }
    return savePath;
}

//解压家园风格后的文件路径
+ (NSString *)getZipFilePathManager
{
    //在Library下的Documentation创建文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *downFileName = [NSString stringWithFormat:@"downStyle%@",USERID];
//    NSString *testDirectory = [documentsDirectory stringByAppendingPathComponent:downFileName];

    return  documentsDirectory;
}
//风格模板下载的临时存储路径
+(NSString *)getTempFolderPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Temp"];
// return [[self getTargetFloderPath] stringByAppendingPathComponent:@"Temp"];
}

//得到临时文件存储文件夹的路径(视频)
+(NSString *)getMovieTempFolderPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/ETMemory/Temp"];
}
//得到临时文件存储文件夹的路径(音频)
+(NSString *)getMusicTempFolderPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/ETMemory/Temp/Music"];
}

+(BOOL)isExistFile:(NSString *)fileName
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:fileName];
}

+(float)getProgress:(float)totalSize currentSize:(float)currentSize
{
    return currentSize/totalSize;
}

//判断视频判断是否有mov视频，有就只取mov视频，没有就取转码后的视频路径
+ (NSString *)strPathGetTargetFloderTranscodingPath:(NSDictionary *)dic
{
    NSString *strMov = dic[@"attachURL"];////判断视频是否已经转码
    if (strMov.length >10) {//判断是否有mov视频
        NSArray *tmpArr = [strMov componentsSeparatedByString:@"."];
        //文件类型
        NSString *fileType = [tmpArr lastObject];
        if ([fileType isEqualToString:@"mov"]|| [fileType isEqualToString:@"mp4"]|| [fileType isEqualToString:@"3gp"]|| [fileType isEqualToString:@"mpv"]) {//判断是否是mov格式的
            
            NSString *videoName = dic[@"content"];
            
            NSString *strPath = [Utilities dataPath:[NSString stringWithFormat:@"%@.%@",videoName,fileType] FileType:@"Videos" UserID:USERID];
            return strPath;
        }else if([dic[@"transcodingState"] integerValue] ==3 && ![dic[@"transcodingURL"] isEqualToString:@""]){
            return [self codeMp4Video:dic];//获取取转码后的视频路径
        }
    }else if ([dic[@"transcodingState"] integerValue] ==3 && ![dic[@"transcodingURL"] isEqualToString:@""])
    {
        return [self codeMp4Video:dic];//获取取转码后的视频路径
    }
    return nil;
    
}
+ (NSString *)codeMp4Video:(NSDictionary *)dic
{
    NSString *strMp4 = dic[@"transcodingURL"];
    NSArray *tmpArr = [strMp4 componentsSeparatedByString:@"."];
    //文件类型
    NSString *fileType = [tmpArr lastObject];
    
    NSString *videoName = dic[@"content"];
    
    NSString *strPathMp4 = [Utilities dataPath:[NSString stringWithFormat:@"%@.%@",videoName,fileType] FileType:@"Videos" UserID:USERID];

    return strPathMp4;
}
//获取视频路径url，主要是mov视频
+ (NSString *)getMovVideoPath:(NSDictionary *)dic
{
    NSString *strMov = dic[@"attachURL"];////获取原来视频路径
    if (strMov.length >10) {//判断是否有mov视频
        NSArray *tmpArr = [strMov componentsSeparatedByString:@"."];
        //文件类型
        NSString *fileType = [tmpArr lastObject];
        if ([fileType isEqualToString:@"mov"]|| [fileType isEqualToString:@"mp4"]|| [fileType isEqualToString:@"3gp"]|| [fileType isEqualToString:@"mpv"])
        {//判断是否是mov格式的
            return strMov;
        }
        else if([dic[@"transcodingState"] integerValue] ==3 && ![dic[@"transcodingURL"] isEqualToString:@""])
        {
            return dic[@"transcodingURL"];
        }else{
            return @"";
        }
    }else if([dic[@"transcodingState"] integerValue] ==3 && ![dic[@"transcodingURL"] isEqualToString:@""])
    {
        return dic[@"transcodingURL"];
    }else{
        return @"";
    }
}


//计算转换当前时间
+(NSString *)getTimeransitionPath:(NSString *)str
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *dateStr = [NSDate dateWithTimeIntervalSince1970:[str doubleValue] / 1000];

    NSString *strTime = [formatter stringFromDate:dateStr];
    return strTime;
}
//计算转换生日时间
+(NSString *)getTimeransitionBirthDataPath:(NSString *)str
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *dateStr = [NSDate dateWithTimeIntervalSince1970:[str doubleValue] / 1000];
    
    NSString *strTime = [formatter stringFromDate:dateStr];
    return strTime;
}
//判断字符串是否为空
+ (BOOL)isTitleBlank:(NSString *)str {
    if (str == nil && [str length] == 0)return YES;
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) return YES;
    return NO;
}

@end