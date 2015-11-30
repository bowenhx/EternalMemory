//
//  Utilities.h
//  PeopleBaseNetwork
//
//  Created by apple on 13-3-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"


@interface Utilities : NSObject{
    

}

/**
 *  将时间戳转化为指定格式的时间
 *
 *  @param timeStemp 时间戳
 *  @param format    日期格式 默认格式为 yyyy年MM月dd日
 *
 *  @return 格式化后的日期字符串
 */
+ (NSString *)convertTimestempToDateWithString:(NSString *)timeStemp andDateFormat:(NSString *)format;

+ (NSDate *)transformDateStrToDate:(NSString *)dateStr;


/**
 *时间戳转换 yyyy.MM.dd 格式的时间
 */
+ (NSString *)convertTimestempToDateWithString2:(NSString *)timeStemp;
//时间转换yyy-mm-dd hh:mm:ss
+ (NSString *)convertTimeDateToTimeString:(NSDate *)date;
//检测手机设备类型
+ (NSString*)checkIphone;
//检查网络
+(BOOL)checkNetwork;
//判断网络是否是3G还是wifi
+ (NSString *)GetCurrntNet;
//设置背景色
+(void)setBackgroudColor:(UIView*)view;
//设置cell选中后的颜色
+(UIView *)setCellSelectedView;
//有缓存时的界面显示
+(void)haveCacheView:(UIView*)view WithTag:(NSInteger)tag;
//无缓存有网络的时的界面显示
+(void)noCacheViewAndHaveNetwork:(UIView*)view WithTag:(NSInteger)tag;
//无缓存无网络是的界面显示
+(void)noCacheAndNoNetwork:(UIView*)view WithTag:(NSInteger)tag Delegate:(id)delegate;
//移除viewfromsuperview
+(void)removeFromsuperview:(UIView*)view WithTag:(NSInteger)tag;
//无网络或者网络异常alert提示
+(void)noNetworkAlert;
//无网络帮助提示
+(void)addHelpAlert:(int)intTag AndDelegate:(id)Delegate;
//用户退出登录时公用数据的重置
+(void)resetCommonData;





/**
 *	检查本地是否已经有20张图片
 *
 *	@return	BOOL has20Pics Yes 已经存在20张  No 不满20张，还可以继续上传
 */
+(BOOL)thereHasBeenAlready20Pics;

/**
 *  调整适配iOS7的UI布局，方法内部判断是否为iOS7，直接调用即可。
 *
 *  @param views 需要调整的UI视图
 */
+ (void)adjustUIForiOS7WithViews:(NSArray *)views;

//隐藏tableviewCell多余的分割线
+(void)setExtraCellLineHidden: (UITableView *)tableView;

//更新存储用户数据信息
+(void)saveUserInfo:(NSDictionary *)dataDic;

//家谱图片路径
+(NSString *)portraitImagePath:(NSString *)file;

/**
 *  清除当前用户的所有照片的缓存数据
 *
 *  @return 是否成功
 */
+ (BOOL)deleteAllPhotoDataOfCurrentUser;

/**
 *  清楚当前用户所有语音缓存
 *
 *  @return 是否成功
 */
+ (BOOL)deleteAllAudioOfCurrentUser;

+ (NSString *)fullPathForAudioFileOfType:(NSString *)type;

+ (NSString *)fullPathForSavingPhotos;
/**
 *  获得存放图片的相对路径
 *
 *  @return 相对路径
 */
+ (NSString *)relativePathForSavingPhotos;
+ (NSString *)relativePathOfFullPath:(NSString *)fullPath;


/**
 *  音频文件的文件名
 *
 *  @return 文件名
 */
+ (NSString *)audioFileNameWithType:(NSString *)type;
/**
 *  获得指定路径文件的类型
 *
 *  @param path 文件路径
 *
 *  @return 文件类型
 */
+ (NSString *)fileTypeOfPath:(NSString *)path;

/**
 *  设置文件存储文件夹路径
 *
 *  @param fileType 文件类型  ID 用户的ID
 *
 *  @return 文件类型
 */

+(NSString *)FileFolder:(NSString *)fileType UserID:(NSString *)ID;

/**
 *  设置文件存储路径
 *
 *  @param file 文件名  fileType 文件类型  ID 用户的ID
 *
 *  @return 文件类型
 */
+(NSString *)dataPath:(NSString *)file FileType:(NSString *)fileType UserID:(NSString *)ID;

+ (NSString *)pathForAllLifeMemo;
+ (NSString *)lifeMemoPathOfTemplate;
+ (NSString *)lifeMemoPathOfUserUploaded;
+ (NSString *)fileNameOfURL:(NSString *)urlStr;

@end
