//
//  EternalMemoryAppDelegate.h
//  EternalMemory
//
//  Created by sun on 13-5-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "ResumeVedioSendOperation.h"
#import "SynDataBackstage.h"
#import <UIKit/UIKit.h>
@class LogoMPMoviewPlayViewCtl;
@interface EternalMemoryAppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,AVAudioPlayerDelegate,ASIHTTPRequestDelegate,ResumeVedioSendOperationDelegate>
{
    LogoMPMoviewPlayViewCtl  *playerViewController;
    NSMutableDictionary      *_notifyDict;
    NSInteger                _index;
    NSMutableArray           *_configAry;
    NSString                 *bugContent;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (assign)BOOL isLogin;
@property (assign)BOOL enterDownload;
@property (assign)NSInteger photoNumberInt;
@property (assign)NSInteger synDataCount;
@property(nonatomic,retain)SynDataBackstage *synData;


+ (EternalMemoryAppDelegate *)getAppDelegate;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)showLoginVC;
-(void)alertShow;
- (void)showEternalViewController;
//后台上传成功
-(void)uploadingSuccess:(NSInteger)index;
//后台上传失败
-(void)uploadingFailed:(NSInteger)index;
//内存空间不足提醒
-(void)spaceIsNotEnough;
//异常情况
-(void)unexceptedCrash:(NSDictionary *)dic;

@end
