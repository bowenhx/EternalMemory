//
//  network.h
//  EternalMemory
//
//  Created by Guibing Li on 13-5-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import "SavaData.h"
#import "Utilities.h"
#ifndef EternalMemory_network_h
#define EternalMemory_network_h

//===================================================线上IP

#define APPLE_ID            @"714751061"

#define SER_SELECT          @"SERVER_SELECT"
#define BUTTON_SELECT       @"button_select"

//用户所在服务器配置

#define INLAND_PORT         [[SavaData shareInstance] printDataStr:@"specifiedport"]
#define SERVER_WEB_URL      [NSString stringWithFormat:@"%@api/",INLAND_SERVER]
#define INLAND_SERVER       [NSString stringWithFormat:@"http://%@:%@/",[[SavaData shareInstance] printDataStr:@"specifiedhost"],INLAND_PORT]


//取出验证码
#define USER_AUTH_GETOUT    [[SavaData shareInstance] printDataStr:USER_AUTH_SAVA]
//取出手机token
#define USER_TOKEN_GETOUT   [[SavaData shareInstance] printToken:TOKEN]
//保存UID
#define USERID              [[SavaData shareInstance] printDataStr:USER_ID_SAVA]
#define USERID_ORIGINAL     [[SavaData shareInstance] printDataStr:USER_ID_ORIGINAL]
#define USERNAME            [[SavaData shareInstance] getStrValue:USER_NAME_SAVE]

//日志版本号
#define DIARYVERSION        [NSString stringWithFormat:@"%@_DIARYVERSION",USERID]
//相册版本号
#define PHOTOVERSION        [NSString stringWithFormat:@"%@_PHOTOVERSION",USERID]
//视频版本号
#define VEDIOVERSION        [NSString stringWithFormat:@"%@_VEDIOVERSION",USERID]


//用户信息的缓存文件plist
#define User_File           [NSString stringWithFormat:@"%@.plist",USERID]
//用户信息的缓存文件plist
#define User_Uploading_File [NSString stringWithFormat:@"%@_Uploading.plist",USERID]
//用户关联成员的缓存文件plist
#define User_AssocaitedInfo_File   [NSString stringWithFormat:@"%@_AssocaitedInfo.plist",USERID]
//视频列表plist
#define Video_File          [NSString stringWithFormat:@"UserVideo%@.plist",USERID]
//背景音乐plist
#define Music_File          [NSString stringWithFormat:@"UserMusic%@.plist",USERID]
//家谱plist
#define Family_File         [NSString stringWithFormat:@"familyInfo%@.plist",USERID]
//上传文件
#define Uploading_File      [NSString stringWithFormat:@"up%@",USERID]
//下载文件
#define Download_File       [NSString stringWithFormat:@"down%@",USERID]
//完善信息用户
#define User_Infor          [NSString stringWithFormat:@"userInfo_%@.plist",USERID]

#define USER_IS_LOGIN       [[SavaData shareInstance]printBoolData:ISLOGIN]
#define USER_IS_HANDLOGIN   [[SavaData shareInstance]printBoolData:ISHANDLOGIN]

//检查网络
#define CHECK_NETWORK       [Utilities checkNetwork]
//用户是否首次登录,断网日记、文献可操作
#define NOT_NOTIFY          [[SavaData shareInstance]printDataStr:NO_NOTICE]
#define WHOFAMILYID         [[SavaData shareInstance] printDataStr:WHOFAMILY]

//UserDefault的键值
#define kAlbumServerVersion  @"kAlbumServerVersion"     //服务器返回的相册列表的版本号



#endif
