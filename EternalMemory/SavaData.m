//
//  SavaData.m
//  PeopleBase
//
//  Created by apple on 12-12-22.
//  Copyright (c) 2012年 apple. All rights reserved.
//

#import "SavaData.h"
#import "Config.h"

@implementation SavaData
static SavaData* _shareInstance = nil;

NSString * const kSavedPhotoListServerVersion = @"kSavedPhotoListServerVersion";

+(SavaData*)shareInstance{
    if (!_shareInstance) {
        _shareInstance = [[SavaData alloc] init];
    }
    return _shareInstance;
}

//保存token
-(void)savaToken:(NSString*)token KeyString:(NSString*)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:token forKey:TOKEN];
    [defaults synchronize];
    
}
-(NSString*)printToken:(NSString*)key{

   return [[NSUserDefaults standardUserDefaults] objectForKey:TOKEN];
}


-(NSString *)currentUid {
    return [NSString stringWithFormat:@"%d", [[NSUserDefaults standardUserDefaults] integerForKey:USER_ID_SAVA]];
//    return [[NSUserDefaults standardUserDefaults] stringForKey:USER_ID_SAVA];
}

-(NSMutableDictionary *)dataForUser:(NSString *)uid
{
    if (uid.length > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:uid]];
        if (dict != nil) {
            return dict;
        } else {
            return [NSMutableDictionary dictionary];
        }
    }
    return nil;
}

-(void)directSave:(id)obj forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:obj forKey:key];
    [defaults synchronize];
}

-(id)directPrintObject:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

-(void)savaData:(NSInteger)dataInt KeyString:(NSString*)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([key isEqualToString:USER_ID_SAVA]) {
        [defaults setInteger:dataInt forKey:key];
    }
    NSMutableDictionary *dict = [self dataForUser:[self currentUid]];
    if (dict) {
        [dict setValue:[NSNumber numberWithInteger:dataInt] forKey:key];
        [defaults setValue:dict forKey:[self currentUid]];
    } else {
        [defaults setInteger:dataInt forKey:key];
    }
    [defaults synchronize];
}

-(NSInteger)printData:(NSString*)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [self dataForUser:[self currentUid]];
    if (dict) {
        return [[dict objectForKey:key] integerValue];
    } else {
        return [defaults integerForKey:key];
    }
}
//保存bool值类型
-(void)savaDataBool:(BOOL)dataBool KeyString:(NSString *)key{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([key isEqualToString:USER_ID_SAVA]) {

        [defaults setBool:dataBool forKey:key];
        
    }
    NSMutableDictionary *dict = [self dataForUser:[self currentUid]];
    if (dict) {
        [dict setValue:[NSNumber numberWithBool:dataBool] forKey:key];
        [defaults setValue:dict forKey:[self currentUid]];
    } else {
        [defaults setBool:dataBool forKey:key];
    }
    [defaults synchronize];
    
    
}

-(BOOL)printBoolData:(NSString *)key{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [self dataForUser:[self currentUid]];
    if (dict) {
        return [[dict objectForKey:key] boolValue];
    } else {
        return [defaults boolForKey:key];
    }
    
}

//保存字符串类型
-(void)savadataStr:(NSString*)dataStr KeyString:(NSString*)key{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([key isEqualToString:USER_ID_SAVA]) {//保存用户ID
        
        [defaults setValue:dataStr forKey:key];
        
    }
    NSMutableDictionary *dict = [self dataForUser:[self currentUid]];
    if (dict) {//用户登录的情况下，按照用户ID存储
        [dict setValue:dataStr forKey:key];
        [defaults setValue:dict forKey:[self currentUid]];
    } else {//用户没登录的情况下，没ID存储(像注册里面的存储)
        [defaults setValue:dataStr forKey:key];
    }
    [defaults synchronize];
}

-(NSString*)printDataStr:(NSString*)key{    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [self dataForUser:[self currentUid]];
    if (dict) {
        return [dict objectForKey:key];
    } else {
        return [defaults objectForKey:key];
    }
}

//保存数组类型
-(void)savaArray:(NSMutableArray *)dataAry KeyString:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [self dataForUser:[self currentUid]];
    if (dict) {
        [dict setValue:dataAry forKey:key];
        [defaults setValue:dict forKey:[self currentUid]];
    } else {
        [defaults setValue:dataAry forKey:key];
    }
    [defaults synchronize];
}

-(NSMutableArray*)printDataAry:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [self dataForUser:[self currentUid]];
    if (dict) {
        return [NSMutableArray arrayWithArray:[dict objectForKey:key]];
    } else {
        return [NSMutableArray arrayWithArray:[defaults objectForKey:key]];
    }
}

//保存字典类型
-(void)savaDictionary:(NSDictionary *)dataDic keyString:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * uid = [self currentUid];
    NSString *str = [NSString stringWithFormat:@"%@_%@",key,[self currentUid]];
    if (uid) {
        [defaults setObject:dataDic forKey:str];
    } else {
        [defaults setObject:dataDic forKey:key];
    }
    [defaults synchronize];
}

-(NSMutableDictionary*)printDataMutableDic:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *str = [NSString stringWithFormat:@"%@_%@",key,[self currentUid]];
    NSDictionary *dict = [defaults dictionaryForKey:str];
    NSMutableDictionary *result = nil;
    if (dict) {
        result = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:key]];
    } else {
        result = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:key]];
    }
    return result == nil ? [NSMutableDictionary dictionary] : result;
}

-(NSDictionary*)printDataDic:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uid = [self currentUid];
    NSString *str = [NSString stringWithFormat:@"%@_%@",key,[self currentUid]];
    NSDictionary *dict = nil;//[NSDictionary dictionary];
    if (uid) {
        dict = [defaults dictionaryForKey:str];
        
    }else{
        dict = [defaults dictionaryForKey:key];
    }
    return dict;
}
//保存图片到文件夹
- (void)saveImage:(UIImage *)image forUid:(NSString *)uid
{
    NSString *dir = [NSHomeDirectory() stringByAppendingString:@"/Library/renmai"];
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir]) {
        NSError *error;
        BOOL b = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if (!b) {

        }
    }
    
    NSString *fileName = [dir stringByAppendingFormat:@"/%@.png", uid];
    [UIImagePNGRepresentation(image) writeToFile:fileName atomically:YES];
}
//把数组写入文件
+(void) writeArrToFile:(NSArray *)arr FileName:(NSString *)file
{
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths    objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:file];

    [arr writeToFile:filename  atomically:YES];
}
//将网络加载的音乐Data流写到文件
+(void) writeMusicDataToFile:(NSArray *)data FileName:(NSString *)file
{
    [data writeToFile:file atomically:YES];
}
//解析文件得到数组
+(NSMutableArray *) parseArrFromFile:(NSString *)file
{
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *path=[paths   objectAtIndex:0];
	NSString *filename=[path stringByAppendingPathComponent:file];
	NSMutableArray *array=[[[NSMutableArray alloc] initWithContentsOfFile:filename] autorelease];
	return array;
}
//把字典写入文件
+(void) writeDicToFile:(NSDictionary *)dic FileName:(NSString *)file
{
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:file];

    [dic writeToFile:filename  atomically:YES];
}
//解析文件得到字典
+(NSDictionary *)parseDicFromFile:(NSString *)file
{
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *path=[paths objectAtIndex:0];
	NSString *filename=[path stringByAppendingPathComponent:file];
	NSMutableDictionary *dic= [NSMutableDictionary dictionaryWithContentsOfFile:filename];
	return dic;
}
+ (void)fileSpaceUseAmount:(NSNumber *)num
{
    NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithDictionary:[SavaData parseDicFromFile:User_File]];
    
    [userDic setObject:num forKey:@"spaceUsed"];
    [SavaData writeDicToFile:userDic FileName:User_File];
}
//- (UIImage *)imageForUid:(NSString *)uid
//{
//    
//    NSString *imgName = [NSString stringWithFormat:@"header_%@.png",uid];
//    NSString *md5Img = [PhotoCache cachePathForPathKey:imgName];
//    NSString *fileName = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/ImageCache/%@",md5Img];
//    UIImage *img = nil;
//    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
//        img = [UIImage imageWithContentsOfFile:fileName];
//    }
//    return img;
//}

//- (UIImage *)imageForUid:(NSString *)uid defaultUrl:(NSString *)url
//{
//    UIImage *img = [[SavaData shareInstance] imageForUid:uid];
//    if (img == nil) {
//        if (url == nil) {
//            return [UIImage imageNamed:@"profile"];
//        }
//        img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
//        if (img == nil) {
//            img = [UIImage imageNamed:@"profile"];
//        } else {
//            [[SavaData shareInstance] saveImage:img forUid:uid];
//        }
//    }
//    return img;
//}
//清除数据
//清除保存的数据
-(void)clearData:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [self dataForUser:[self currentUid]];
    if (dict) {
        [dict removeObjectForKey:key];
    } else {
        [defaults removeObjectForKey:key];
    }
    [defaults synchronize];
}
//选择服务器
-(void)savaServer:(NSString*)ser KeyString:(NSString*)key{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:ser forKey:BUTTON_SELECT];
    [defaults synchronize];
    
}
-(NSString*)printServer:(NSString*)key{
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:BUTTON_SELECT];
}

-(void)savaStrServer:(NSString *)str forKey:(NSString *)key{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:str forKey:SER_SELECT];
    [defaults synchronize];
    
}
-(NSString*)printStrServer:(NSString*)key{
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:SER_SELECT];
    
}


-(void)saveisAppFirstBool:(BOOL)boolData forKey:(NSString *)str{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:boolData forKey:str];
    [defaults synchronize];
}
-(BOOL)printisAppFirst:(NSString *)key{
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

-(NSArray *)getConfig:(NSString *)key{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:key];
}
//不根据userId区分
-(void)saveStrValue:(NSString *)str andKey:(NSString *)key{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:str forKey:key];
    [userDefault synchronize];
}
-(NSString *)getStrValue:(NSString *)key{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:key];

}
@end
