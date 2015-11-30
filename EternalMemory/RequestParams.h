//
//  RequestParams.h
//  EternalMemory
//
//  Created by Guibing Li on 13-5-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"

@class ASIFormDataRequest;
@interface RequestParams : NSObject
+(RequestParams*)sharedInstance;

- (void)setCommonDataForRequest:(ASIFormDataRequest *)request;
#pragma mark -登录&注册url
//第一步注册校验
- (NSURL *)userRegister;
//注册
- (NSURL *)userRegister1;
//登陆
- (NSURL *)log;
//自动登陆
- (NSURL *)authlogin;
#pragma mark -更多url
//身份证验证
-(NSURL *)usrCheckId;
//邮箱验证
- (NSURL *)getUserEmail;
//获取手机验证码
-(NSURL *)userCheckMobile;
//查询个人资料
- (NSURL *)userDatasInquire;
//生成授权码
- (NSURL *)gainUserGenerateauthcode;
//修改密码
- (NSURL *)changePassword;
//授权码登录
- (NSURL *)getAuthCodeLogin;


//获取blog列表
- (NSURL *)getBlogList;
//获取blog列表的详细信息
-(NSURL *)getAllBlogs;
//增加blog
- (NSURL *)addblog;
//获得blog详情
- (NSURL *)blogDetails;
//删除blog
- (NSURL *)deleteBlog;
//编辑blog
- (NSURL *)editBlog;
//改变分组
- (NSURL *)changeBlogGroup;
//分类
- (NSURL *)manageGroup;
//相册列表
- (NSURL *)photoAlbums;
//相册图片列表
- (NSURL *)photolist;
//上传图片
- (NSURL *)uploadPhoto;
//批量上传图片
- (ASIFormDataRequest* )uploadPhotoes:(NSArray *)photoes;
//获取图片信息
- (NSURL *)photoDetail;
//修改图片信息
- (NSURL *)updatePhotoDetail;
//修改图片说明信息（针对单张图片）
- (NSURL *)updatePhotoDescription;
//删除图片
- (NSURL *)deletePhoto;

//忘记密码: 获取安全问题
- (NSURL *)getSecurityquestion;
//设置密保问题
- (NSURL *)setPrivacyProblemAction;
//普通上传视频的请求
- (NSURL *)commonUploadVideoURLAddress;
//上传视频
- (NSURL *)uploadingVideoFirstRequest;
//断点上传视频
-(NSURL *)breakPointUploadVedio;

- (NSString *)uploadingVideoAction:(NSString *)fileSize sourceid:(NSString *)sourID;
//查询视频列表
- (NSURL *)listVideoLockAction;
/**
 *	记忆码访问家园的接口
 *
 *	@return	返回接口地址
 */
- (NSURL *)ListVideoInHome;
//删除一个视频
- (NSURL *)didDeleteVideoAction;
//查询最新客户端版本信息
- (NSURL *)getClientVersion;
//增加背景音乐
- (NSURL *)uplodingMusicAction;
//断点添加音乐
- (NSURL *)resumeUploadMusic;

//获取背景音乐列表 /删除背景音乐
- (NSURL *)didMusicManageAction;
//家谱成员列表
- (NSURL *)didObtainMoreenealogyMember;
//新家谱成员列表
- (NSURL *)newFamilyTree;
//新家谱其他成员列表
- (NSURL *)otherNewFamilyTree:(NSDictionary *)dic;
//修改家谱成员信息
- (NSURL *)changeObtainMoreenealogyMember;
//删除家谱成员
- (NSURL *)delectObtainMoreenealogyMember;
//新增家谱成员
- (NSURL *)addObtainMoreenealogyMember;
//封存访问
-(NSURL *)forbidVisitUrl;
//家园访问
-(NSURL *)visitHomeUrl;
//记忆码访问家园
-(NSURL *)memoryVisitHomeUrl:(NSString*)eternalCode;
//永恒号访问家园
-(NSURL *)accreditVisitHomeUrl:(NSString*)associatekey AndAssociatevalue:(NSString*)associatevalue AndAssociateauthcode:(NSString*)associateauthcode;
//家园留言
-(NSURL *)leaveMessage;
//提交 意见反馈
- (NSURL *)getIdeaFeedbackUrl;

//获取家园风格列表
- (NSURL *)getHomeStyleList;

/**
 *  修改家谱成员信息
 *
 *  @return NSURL 修改家谱成员的接口URL
 */
- (NSURL *)modifyMemberInfo;
/**
 *  添加家族成员
 *
 *  @return NSURL 添加家族成员接口的URL
 */
- (NSURL *)addFamilyMember;

/**
 *  删除家族成员
 *
 *  @return NSURL 删除成员API接口的URL地址
 */
- (NSURL *)deleteMember;
/**
 *  获取关联成员数据
 *
 *  @return NSURL 关联成员API接口的URL地址
 */
-(NSURL *)getAssociatedData;

/**
 *  修改成员头像
 *
 *  @return NSURL 修改成员头像API接口的URL地址
 */
- (NSURL *)modifyMemberHeader;

/**
 *  通过授权码关联的url
 *
 *  @return url
 */
- (NSURL *)associateMember;

/**
 *  上传头像接口的URL
 *
 *  @return url
 */
- (NSURL *)addHeaderImage;

/**
 *  退出登录
 *
 *  @return url
 */
- (NSURL *)loginOut;

/**
 *  上传音频文件
 *
 *  @return 音频接口的URL
 */
- (NSURL *)uploadAudio;

//上传一生记忆相册录音文件
- (NSURL *)uploadLifePhotoAudio;

/**
 *  删除音频文件
 *
 *  @return 删除音频文件的URL
 */
- (NSURL *)deleteAudio;

//删除一生相册录音文件
- (NSURL *)deleteLifePhotoAudio;

//照片排序
- (NSURL *)sortForLifePhoto;

- (NSURL *)getUserData;

-(NSURL *)getServerConfig:(NSString *)str;
//设置网络请求的公共部分
+(void)setRequestCommonData:(ASIFormDataRequest *)request;

//捕获异常bug提交到服务器
- (NSURL *)uploadBugInfo;

+ (NSURL *)urlForAllLifeMemoTemplate;

@end
