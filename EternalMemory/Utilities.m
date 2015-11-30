//
//  Utilities.m
//  PeopleBaseNetwork
//
//  Created by apple on 13-3-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "FailedOfflineDownLoad.h"
#import "OfflineDownLoad.h"
#import "Reachability.h"
#import "MessageSQL.h"
#import "Utilities.h"
#import "SavaData.h"
#import "MD5.h"
#import <sys/utsname.h>
#define _SEVER_URL   @"www.apple.com"
#define _RED_COLOR    245/255.
#define _GREEN_COLOR  245/255.
#define _BLUE_COLOR   245/255.
#define _ALPHA_COLOR  1.0f

#define failedDownLoad  [FailedOfflineDownLoad shareInstance]
#define offLine         [OfflineDownLoad shareOfflineDownload]

@implementation Utilities


//检查网络  
+(BOOL)checkNetwork{
    
    Reachability *reachability = [Reachability reachabilityWithHostName:_SEVER_URL];
    return  [reachability connectedToNetWork];
    
}
//判断网络
//检查当前网络连接是否正常
+ (NSString *)GetCurrntNet
{
    NSString* result = nil;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:                  // 没有网络连接
            result=@"没有网络链接";
            break;
        case ReachableViaWWAN:              // 使用3G网络
        case ReachableVia2G:
            result=@"当前使用的网络链接类型是WWAN（2G/3G）";
            break;
        case ReachableViaWiFi:              // 使用WiFi网络
            //result=@"当前使用的网络类型是WIFI";
            result = @"1";
            break;
        default:
            break;
    }
    return result;
}
+(void)setBackgroudColor:(UIView*)view{
    
    view.backgroundColor = [UIColor colorWithRed:_RED_COLOR green:_GREEN_COLOR blue:_BLUE_COLOR alpha:_ALPHA_COLOR];
    
}
//设置cell选中后的颜色
+(UIView *)setCellSelectedView{
    UIView *aView=[[UIView alloc] init];
    aView.backgroundColor=[UIColor colorWithRed:99/255. green:170/255. blue:231/255. alpha:1.0f];
    return [aView autorelease];
}
//有缓存时的界面显示
+(void)haveCacheView:(UIView*)view WithTag:(NSInteger)tag{
    
    UIView *haveView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, 320, view.bounds.size.height)];
    haveView.backgroundColor = [UIColor colorWithRed:_RED_COLOR green:_GREEN_COLOR blue:_BLUE_COLOR alpha:_ALPHA_COLOR];
    haveView.tag = tag;
    [view addSubview:haveView];
    [haveView release];
}
//无缓存有网络的时的界面显示
+(void)noCacheViewAndHaveNetwork:(UIView*)view WithTag:(NSInteger)tag{
    
    UIView *haveView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, 320, view.bounds.size.height)];
    haveView.backgroundColor = [UIColor colorWithRed:_RED_COLOR green:_GREEN_COLOR blue:_BLUE_COLOR alpha:_ALPHA_COLOR];
    UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    act.frame = CGRectMake(150, view.frame.size.height/2-40, 10, 10);
    [act startAnimating];
    [haveView addSubview:act];
    [act release];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(100, view.frame.size.height/2-15, 120, 15)];
    lab.backgroundColor = [UIColor clearColor];
    lab.text = @"数据正在加载中....";
    lab.font = [UIFont systemFontOfSize:15.];
    lab.textColor = [UIColor blackColor];
    [haveView addSubview:lab];
    [lab release];
    haveView.tag = tag;
    [view addSubview:haveView];
    [haveView release];
    
}
//无缓存无网络是的界面显示
+(void)noCacheAndNoNetwork:(UIView*)view WithTag:(NSInteger)tag Delegate:(id)delegate{
    UIView *noCacheView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, 320, view.bounds.size.height)];
    noCacheView.tag=tag;
    noCacheView.backgroundColor = [UIColor colorWithRed:_RED_COLOR green:_GREEN_COLOR blue:_BLUE_COLOR alpha:_ALPHA_COLOR];
   // noCacheView.backgroundColor  = [UIColor lightGrayColor];
    UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(127, 110, 66, 66)];
    imgv.image = [UIImage imageNamed:@"cxjz"];
    imgv.backgroundColor = [UIColor clearColor];
    [noCacheView addSubview:imgv];
    [imgv release];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(130,185,100,15)];
    lab.backgroundColor = [UIColor clearColor];
    lab.text = @"加载失败";
    lab.font = [UIFont systemFontOfSize:14.];
    lab.textColor = [UIColor blackColor];
    [noCacheView addSubview:lab];
    [lab release];

    UILabel *lab2 = [[UILabel alloc]initWithFrame:CGRectMake(110,205,140,15)];
    lab2.backgroundColor = [UIColor clearColor];
    lab2.text = @"请点击屏幕重试";
    lab2.font = [UIFont systemFontOfSize:14.];
    lab2.textColor = [UIColor blackColor];
    [noCacheView addSubview:lab2];
    [lab2 release];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 44, 320, view.bounds.size.height);
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:delegate action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [noCacheView addSubview:btn];
    
    [view addSubview:noCacheView];
    [noCacheView release];
    
}
//移除添加的viewfromsuperview
+(void)removeFromsuperview:(UIView *)view WithTag:(NSInteger)tag{
    
    UIView *temp = [view viewWithTag:tag];
    [temp removeFromSuperview];
}

//无网络或者网络链接失败
+(void)noNetworkAlert{
    
    UIAlertView *alert =  [[UIAlertView alloc]initWithTitle:ALERT_TITLE message:ALERT_NETWORK delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    
}
//断网给予提示
+(void)addHelpAlert:(int)intTag AndDelegate:(id)Delegate{

    UIAlertView *alert =  [[UIAlertView alloc]initWithTitle:@"友情提示" message:@"当前无网络，您的照片/日记均可继续编写操作，重新登录后数据将自动同步上传。" delegate:Delegate cancelButtonTitle:@"不再提示" otherButtonTitles:@"确定", nil];
    alert.tag = intTag;
    alert.delegate = Delegate;
    [alert show];
    [alert release];
  
}
//用户退出登录时公用数据的重置
+(void)resetCommonData
{
    [offLine stopOfflineDownLoad];
    [offLine reset];
    [failedDownLoad stopOfflineDownLoad];
    [failedDownLoad reset];
    offLine.downloadFinished = NO;
    failedDownLoad.downloadFinished = NO;
}


+(BOOL)thereHasBeenAlready20Pics
{
    BOOL has20Pics = NO;
    NSInteger picCount = 0;
    picCount = [MessageSQL getMessageCount];
    picCount >= 20 ? (has20Pics = YES) : (has20Pics = NO);
    
    return has20Pics;
}

+ (NSString *)convertTimestempToDateWithString:(NSString *)timeStemp andDateFormat:(NSString *)format
{
//    NSString *regx = @"^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)$";
    
    NSString *dataFormat = nil;
    (format.length == 0) ? (dataFormat = @"yyyy年MM月dd日") : (dataFormat = format);
    NSTimeInterval interval = [timeStemp doubleValue] / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:dataFormat];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    return dateStr;
    
}
+ (NSString *)convertTimestempToDateWithString2:(NSString *)timeStemp{
    NSTimeInterval interval = [timeStemp doubleValue] / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    return dateStr;
}

//时间转换yyy-mm-dd hh:mm:ss
+ (NSString *)convertTimeDateToTimeString:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

//检测手机设备类型
+ (NSString*)checkIphone{
    
    NSString*
    machineName();
    {
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *platform = [NSString stringWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
        /*NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"iPhone 2G",@"iPhone1,1",@"iPhone 3G",@"iPhone1,2",@"iPhone 3GS",@"iPhone2,1",@"iPhone 4",@"iPhone3,1",@"iPhone4",@"iPhone3,2",@"iPhone 4 (CDMA)",@"iPhone3,3",@"iPhone 4S",@"iPhone4,1",@"iPhone 5"@"iPhone5,1",@"iPhone 5 (GSM+CDMA)",@"iPhone5,2",@"iPhone 5S",@"iPhone6,2",@"iPod Touch (1 Gen)",@"iPod1,1",@"iPod Touch (2 Gen)",@"iPod2,1",@"iPod Touch (3 Gen)",@"iPod3,1",@"iPod Touch (4 Gen)",@"iPod4,1",@"iPod Touch (5 Gen)",@"iPod5,1",@"iPad 1",@"iPad1,1",@"iPad 3G",@"iPad1,2",@"iPad 2 (WiFi)",@"iPad2,1",@"iPad 2 (CDMA)",@"iPad2,3",@"iPad 2",@"iPad2,4",@"iPad Mini (WiFi)",@"iPad2,5",@"iPad Mini",@"iPad2,6",@"iPad Mini (GSM+CDMA)",@"iPad2,7",@"iPad 3 (WiFi)",@"iPad3,1",@"iPad 3 (GSM+CDMA)",@"iPad3,2",@"iPad 3",@"iPad3,3",@"iPad 4 (WiFi)",@"iPad3,4",@"iPad 4",@"iPad3,5",@"iPad 4 (GSM+CDMA)",@"iPad3,6",@"Simulator",@"i386",@"Simulator",@"x86_64", nil];
        NSString *str = dic[@"platform"];
        if (!str) {
            str = platform;
        }*/
        if ([platform isEqualToString:@"iPhone1,1"]){
            return @"iPhone 2G";
        }else if ([platform isEqualToString:@"iPhone1,2"]){
            return @"iPhone 3G";
        }else if ([platform isEqualToString:@"iPhone2,1"]){
            return @"iPhone 3GS";
        }else if ([platform isEqualToString:@"iPhone3,1"]){
            return @"iPhone 4";
        }else if ([platform isEqualToString:@"iPhone3,2"]){
            return @"iPhone 4";
        }else if ([platform isEqualToString:@"iPhone3,3"]){
            return @"iPhone 4 (CDMA)";
        }else if ([platform isEqualToString:@"iPhone4,1"]){
            return @"iPhone 4S";
        }else if ([platform isEqualToString:@"iPhone5,1"]){
            return @"iPhone 5";
        }else if ([platform isEqualToString:@"iPhone5,2"]){
            return @"iPhone 5 (GSM+CDMA)";
        }else if ([platform isEqualToString:@"iPhone6,2"]){
            return @"iPhone 5S";
        }else if ([platform isEqualToString:@"iPod1,1"]) {
            return @"iPod Touch (1 Gen)";
        }else if ([platform isEqualToString:@"iPod2,1"]) {
            return @"iPod Touch (2 Gen)";
        }else if ([platform isEqualToString:@"iPod3,1"]) {
            return @"iPod Touch (3 Gen)";
        }else if ([platform isEqualToString:@"iPod4,1"]) {
            return @"iPod Touch (4 Gen)";
        }else if ([platform isEqualToString:@"iPod5,1"]) {
            return @"iPod Touch (5 Gen)";
        }else if ([platform isEqualToString:@"iPad1,1"]) {
            return @"iPad";
        }else if ([platform isEqualToString:@"iPad1,2"]) {
            return @"iPad 3G";
        }else if ([platform isEqualToString:@"iPad2,1"]) {
            return @"iPad 2 (WiFi)";
        }else if ([platform isEqualToString:@"iPad2,2"]) {
            return @"iPad 2";
        }else if ([platform isEqualToString:@"iPad2,3"]) {
            return @"iPad 2 (CDMA)";
        }else if ([platform isEqualToString:@"iPad2,4"]) {
            return @"iPad 2";
        }else if ([platform isEqualToString:@"iPad2,5"]) {
            return @"iPad Mini (WiFi)";
        }else if ([platform isEqualToString:@"iPad2,6"]) {
            return @"iPad Mini";
        }else if ([platform isEqualToString:@"iPad2,7"]) {
            return @"iPad Mini (GSM+CDMA)";
        }else if ([platform isEqualToString:@"iPad3,1"]) {
            return @"iPad 3 (WiFi)";
        }else if ([platform isEqualToString:@"iPad3,2"]) {
            return @"iPad 3 (GSM+CDMA)";
        }else if ([platform isEqualToString:@"iPad3,3"]) {
            return @"iPad 3";
        }else if ([platform isEqualToString:@"iPad3,4"]) {
            return @"iPad 4 (WiFi)";
        }else if ([platform isEqualToString:@"iPad3,5"]) {
            return @"iPad 4";
        }else if ([platform isEqualToString:@"iPad3,6"]) {
            return @"iPad 4 (GSM+CDMA)";
        }else if ([platform isEqualToString:@"i386"])    {
            return @"Simulator";
        }else if ([platform isEqualToString:@"x86_64"])  {
            return @"Simulator";
        }else{
            return platform;
        }
        return platform;
    }
}


+ (NSDate *)transformDateStrToDate:(NSString *)dateStr{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    return [dateFormatter dateFromString:dateStr];
}
+ (void)adjustUIForiOS7WithViews:(NSArray *)views
{

    if (iOS7) {
        for (UIView *aView in views) {
            CGRect frame = aView.frame;
            frame.origin.y += 20;
            aView.frame = frame;
        }
    }
    
}

//隐藏tableviewCell多余的分割线
+(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [view release];
}

//更新存储用户数据信息
+(void)saveUserInfo:(NSDictionary *)dataDic
{
    NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
    NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:User_File];
    NSMutableDictionary *userDataDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    if (dataDic.count >0) {
        [userDataDic setObject:[dataDic objectForKey:@"SID"] forKey:@"SID"];
        [userDataDic setObject:[dataDic objectForKey:@"addressdetail"] forKey:@"addressdetail"];
        [userDataDic setObject:[dataDic objectForKey:@"clientToken"] forKey:@"clientToken"];
        [userDataDic setObject:[dataDic objectForKey:@"email"] forKey:@"email"];
        [userDataDic setObject:[dataDic objectForKey:@"favoriteMusic"] forKey:@"favoriteMusic"];
        [userDataDic setObject:[dataDic objectForKey:@"favoriteStyle"] forKey:@"favoriteStyle"];
        [userDataDic setObject:[dataDic objectForKey:@"intro"] forKey:@"intro"];
        [userDataDic setObject:[dataDic objectForKey:@"lastLoginTime"] forKey:@"lastLoginTime"];
        [userDataDic setObject:[dataDic objectForKey:@"latestVersion"] forKey:@"latestVersion"];
        [userDataDic setObject:[dataDic objectForKey:@"memoryCode"] forKey:@"memoryCode"];
        [userDataDic setObject:[dataDic objectForKey:@"mobile"] forKey:@"mobile"];
        [userDataDic setObject:[dataDic objectForKey:@"openStatus"] forKey:@"openStatus"];
        [userDataDic setObject:[dataDic objectForKey:@"realName"] forKey:@"realName"];
        [userDataDic setObject:[dataDic objectForKey:@"serverAuth"] forKey:@"serverAuth"];
        [userDataDic setObject:[dataDic objectForKey:@"sex"] forKey:@"sex"];
        [userDataDic setObject:[dataDic objectForKey:@"spaceTotal"] forKey:@"spaceTotal"];
        [userDataDic setObject:[dataDic objectForKey:@"spaceUsed"] forKey:@"spaceUsed"];
        [userDataDic setObject:[dataDic objectForKey:@"userId"] forKey:@"userId"];
        [userDataDic setObject:[dataDic objectForKey:@"userName"] forKey:@"userName"];
        [userDataDic writeToFile:plistPath atomically:YES];
        
    }
    [userDataDic release];
}
//家谱图片路径
+(NSString *)portraitImagePath:(NSString *)file
{
    NSString *headPath = [MD5 md5:file];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
        NSString *result = [path stringByAppendingPathComponent:headPath];
    return result;
}

+ (BOOL)deleteAllPhotoDataOfCurrentUser {
    
    //delete all image file at sandbox
    NSString *pathOfImages = [self FileFolder:@"Photos" UserID:USERID];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *fileError = nil;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:pathOfImages error:&fileError];
    [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *content = (NSString *)obj;
        NSString *filePath = [pathOfImages stringByAppendingPathComponent:content];
        NSError *deleteErr = nil;
        if ([fileManager removeItemAtPath:filePath error:&deleteErr]) {
        } else {
        }
        
    }];
    
    //delete all image data that stored in database
    [MessageSQL deleteAllPhotos];
    
    return NO;
}

+ (BOOL)deleteAllAudioOfCurrentUser {
    
    NSString *pathOfImages = [Utilities FileFolder:@"Audioes" UserID:USERID];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *fileError = nil;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:pathOfImages error:&fileError];
    [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *content = (NSString *)obj;
        NSString *filePath = [pathOfImages stringByAppendingPathComponent:content];
        NSError *deleteErr = nil;
        if ([fileManager removeItemAtPath:filePath error:&deleteErr]) {
        } else {
        }
        
    }];
    
    //delete all image data that stored in database
    [MessageSQL deleteAllPhotos];

    return YES;
}

+ (NSString *)fullPathForAudioFileOfType:(NSString *)type {

    return [Utilities dataPath:[self audioFileNameWithType:type] FileType:@"Audioes" UserID:USERID];
}

+ (NSString *)audioFileNameWithType:(NSString *)type {
    NSString *fileName = @"";
    NSDate *date = [[NSDate alloc] init];
    NSTimeInterval interval = [date timeIntervalSince1970];
    fileName = [NSString stringWithFormat:@"%.0f.%@",interval, type];
    [date release];
    return fileName ;
}

+ (NSString *)fileTypeOfPath:(NSString *)path {
    
    return [[path componentsSeparatedByString:@"."] lastObject];
}

+(NSString *)FileFolder:(NSString *)fileType UserID:(NSString *)ID
{
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"ETMemory"] stringByAppendingPathComponent:fileType];
    NSString *fullPath = [path stringByAppendingPathComponent:ID];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL *isDir = NO;
    if (![manager fileExistsAtPath:fullPath isDirectory:isDir]) {
        NSError *error = nil;
        BOOL bo = [manager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];
        NSAssert(bo,@"创建%@目录失败",fileType);
    }
    return fullPath;
}

+(NSString *)dataPath:(NSString *)file FileType:(NSString *)fileType UserID:(NSString *)ID
{
    NSString *fileFolder = [Utilities FileFolder:fileType UserID:ID];
    NSString *result = [fileFolder stringByAppendingPathComponent:file];
    return result;
}

+ (NSString *)relativePathOfFullPath:(NSString *)fullPath {
    return [@"/Library" stringByAppendingPathComponent:[[fullPath componentsSeparatedByString:@"Library"] lastObject]];
}

+ (NSString *)relativePathForSavingPhotos {
    NSString *absPath = [Utilities FileFolder:@"Photos" UserID:USERID];
    NSString *relativePath = [@"/Library" stringByAppendingPathComponent:[[absPath componentsSeparatedByString:@"Library"] lastObject]];
    
    return relativePath;
    
}


+ (NSString *)fullPathForSavingPhotos {
    NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/ETMemory/Photos/%@",USERID]];
    
    return fullPath;
    
}

+ (NSString *)pathForAllLifeMemo {
    NSString *absPath = [Utilities FileFolder:@"AllLifeMemo" UserID:USERID];
    return absPath;
}
//存放一生记忆模板图片的路径
+ (NSString *)lifeMemoPathOfTemplate {
    NSString *basePath = [Utilities pathForAllLifeMemo];
    NSString *fullPath = [basePath stringByAppendingPathComponent:@"template"];
    [Utilities createFolderForPath:fullPath];
    
    return fullPath;
}
//存放一生记忆用户上传的图片
+ (NSString *)lifeMemoPathOfUserUploaded {
    NSString *basePath = [Utilities pathForAllLifeMemo];
    NSString *fullPath =  [basePath stringByAppendingPathComponent:@"useruploaded"];
    [Utilities createFolderForPath:fullPath];
    
    return fullPath;
}

+ (NSString *)fileNameOfURL:(NSString *)urlStr {
    return [urlStr lastPathComponent];
}

+ (BOOL)createFolderForPath:(NSString *)path {
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:Nil error:nil];
}
@end
