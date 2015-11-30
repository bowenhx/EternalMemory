//
//  SavaData.h
//  PeopleBase
//
//  Created by apple on 12-12-22.
//  Copyright (c) 2012年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"

static NSString * const kOpenSynchr     = @"openSynchr";
static NSString * const offLineStyle = @"offLineFavoriteStyle";
extern NSString * const kSavedPhotoListServerVersion;

@interface SavaData : NSObject
+(SavaData*)shareInstance;
//保存服务器选择
-(void)savaServer:(NSString*)ser KeyString:(NSString*)key;
-(NSString*)printServer:(NSString*)key;
//保存token
-(void)savaToken:(NSString*)token KeyString:(NSString*)key;
-(NSString*)printToken:(NSString*)key;

//保存的bool值 by jxl
-(void)savaDataBool:(BOOL)dataBool KeyString:(NSString*)key;
-(BOOL)printBoolData:(NSString*)key;
//保存nsinteger
-(void)savaData:(NSInteger)dataInt KeyString:(NSString*)key;
-(NSInteger)printData:(NSString*)key;

//保存NSString数据
-(void)savadataStr:(NSString*)dataStr KeyString:(NSString*)key;
-(NSString*)printDataStr:(NSString*)key;

//保存nsmutablearray
-(void)savaArray:(NSMutableArray*)dataAry KeyString:(NSString*)key;
-(NSMutableArray*)printDataAry:(NSString*)key;
//保存nsdictionary
-(void)savaDictionary:(NSDictionary*)dataDic keyString:(NSString*)key;
-(NSDictionary*)printDataDic:(NSString*)key;
-(NSMutableDictionary*)printDataMutableDic:(NSString *)key;
//保存照片
-(void)saveImage:(UIImage *)image forUid:(NSString *)uid;
//把数组写入文件
+(void) writeArrToFile:(NSArray *)arr FileName:(NSString *)file;
//将网络加载的音乐Data流写到文件
+(void) writeMusicDataToFile:(NSData *)data FileName:(NSString *)file;
//解析文件得到数组
+(NSMutableArray *) parseArrFromFile:(NSString *)file;
//把字典写入文件
+(void) writeDicToFile:(NSDictionary *)dic FileName:(NSString *)file;
//解析文件得到字典
+(NSDictionary *)parseDicFromFile:(NSString *)file;
//判断空间使用量
+ (void)fileSpaceUseAmount:(NSNumber *)num;


//- (UIImage *)imageForUid:(NSString *)uid;
//- (UIImage *)imageForUid:(NSString *)uid defaultUrl:(NSString *)url;
//获取当前ID
-(NSString *)currentUid;
-(void)directSave:(id)obj forKey:(NSString *)key;
-(id)directPrintObject:(NSString *)key;
//清楚数据
-(void)clearData:(NSString *)key;
//
-(void)savaStrServer:(NSString*)str forKey:(NSString*)key;
-(NSString*)printStrServer:(NSString*)key;

//+(void)setHomeStatus:(NSString *)str;
//+(void)getHomeStatus;


-(void)saveisAppFirstBool:(BOOL)boolData forKey:(NSString *)str;
-(BOOL)printisAppFirst:(NSString *)key;

-(NSArray *)getConfig:(NSString *)key;

-(void)saveStrValue:(NSString *)str andKey:(NSString *)key;
-(NSString *)getStrValue:(NSString *)key;
@end
