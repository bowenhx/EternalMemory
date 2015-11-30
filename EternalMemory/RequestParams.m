//
//  RequestParams.m
//  EternalMemory
//
//  Created by Guibing Li on 13-5-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "RequestParams.h"
#import "SavaData.h"
#import "Config.h"
@implementation RequestParams

static RequestParams* _sharedInstance = nil;
+ (RequestParams*)sharedInstance {
    if (!_sharedInstance) {
        _sharedInstance = [[RequestParams alloc] init];
    }
    return _sharedInstance;
}
- (void)setCommonDataForRequest:(ASIFormDataRequest *)request {
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
}

- (NSURL *)setupRequestUrlWithAddress:(NSString *)address
{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}


//第一步注册校验
- (NSURL *)userRegister
{
   
    NSString *address = @"user/checkexists";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//注册
- (NSURL *)userRegister1
{
    NSString *address = @"user/register";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",PUBLIC_SERVER_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//登陆
- (NSURL *)log
{
    NSString *address = @"user/login";                                                                           //
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",PUBLIC_SERVER_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;

}
//自动登陆
- (NSURL *)authlogin
{
    NSString *address = @"user/authlogin";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",PUBLIC_SERVER_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//身份证验证
-(NSURL *)usrCheckId
{
    NSString *address = @"user/checksid";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//邮箱验证
- (NSURL *)getUserEmail
{
    NSString *address = @"user/checkEmail";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//获取手机验证码
-(NSURL *)userCheckMobile
{
    NSString *address = @"user/checkMobile";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

//查询个人资料
- (NSURL *)userDatasInquire
{
    NSString *address = @"user/manageuserinfo";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//生成授权码
- (NSURL *)gainUserGenerateauthcode
{
    NSString *address = @"user/generateauthcode";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

//修改密码
- (NSURL *)changePassword
{
    NSString *address = @"user/modifypassword";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

//授权码登录
- (NSURL *)getAuthCodeLogin
{
    NSString *address = @"user/authCodeLogin";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",PUBLIC_SERVER_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

//获取blog列表
- (NSURL *)getBlogList
{
    NSString *address = @"blog/listsummary";

    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//获取blog列表的详细信息
-(NSURL *)getAllBlogs
{
    NSString *address = @"blog/listblog";
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//增加blog
- (NSURL *)addblog
{
    NSString *address = @"blog/addblog";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//获得blog详情
- (NSURL *)blogDetails
{
    NSString *address = @"blog/getblog";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//删除Blog
- (NSURL *)deleteBlog
{
    NSString *address = @"blog/deleteblog";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//编辑blog
- (NSURL *)editBlog
{
    NSString *address = @"blog/updateblog";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//改变分组
- (NSURL *)changeBlogGroup
{
    NSString *address = @"blog/move";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

//分类
- (NSURL *)manageGroup
{
    NSString *address = @"group/managegroup";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//相册图片列表
- (NSURL *)photolist
{
    NSString *address = @"photo/photolist";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//上传图片
- (NSURL *)uploadPhoto
{
    NSString *address = @"photo/upload";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

/**
 *	批量上传图片
 *
 *	@param	photoes	要上传的照片
 *
 *	@return ASIFormDataRequest 封装的reqeust
 */
#pragma mard -
- (ASIFormDataRequest* )uploadPhotoes:(NSArray *)photoes
{
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[self uploadPhoto]];
    
    
    
    return request;
}
//相册列表
- (NSURL *)photoAlbums {
    NSString *address = @"group/managegroup";
    NSString *urlStr  = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL, address];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    return url;
}
//获取图片信息
- (NSURL *)photoDetail
{
    NSString *address = @"photo/detail";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//修改图片信息
- (NSURL *)updatePhotoDetail
{
    NSString *address = @"photo/update";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//修改图片说明信息（针对单张图片）
- (NSURL *)updatePhotoDescription{
    
    NSString *address = @"photo/updateContent";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//删除图片
- (NSURL *)deletePhoto
{
    NSString *address = @"photo/delete";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//忘记密码: 获取安全问题
- (NSURL *)getSecurityquestion
{
    NSString *address = @"wap/findpw/forgotPassWord?platform=ios";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SET_PRIVACY_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//设置密保问题
- (NSURL *)setPrivacyProblemAction
{
    NSString *address = @"clientweb/user/showSecurityQuestion";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?clienttoken=%@&serverauth=%@",SET_PRIVACY_URL,address,USER_TOKEN_GETOUT,USER_AUTH_GETOUT];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//普通上传视频的请求
- (NSURL *)commonUploadVideoURLAddress
{
    NSString *address = @"video/commonUploadVideo";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

//<断点续传接口>上传视频
- (NSURL *)uploadingVideoFirstRequest
{
    NSString *address = @"video/uploadvideo";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//断点上传视频
-(NSURL *)breakPointUploadVedio
{
    NSString *address = @"video/httpUploadvideo";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}


- (NSString *)uploadingVideoAction:(NSString *)fileSize sourceid:(NSString *)sourID
{
    NSString *address = @"POST /blog/api/video/httpUploadvideo HTTP/1.1\r\n";
    NSString *host = @"Host: 192.168.7.183:8080\r\n";
    NSString *accept = @"Accept: text/html\r\n";
    NSString *connection = @"Connection: Close\r\n";
    NSString *content_Lenth = [NSString stringWithFormat:@"Content-Length: %@\r\n",fileSize];
    NSString *content_Type = @"Content-Type: multipart/form-data\r\n";
    NSString *filesSize = [NSString stringWithFormat:@"filesize: %@\r\n",fileSize];
    NSString *sourceid =  [NSString stringWithFormat:@"sourceid: %@\r\n",sourID];

    NSString *strUrl = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",address,host,accept,connection,content_Lenth,content_Type,filesSize, USER_TOKEN_GETOUT, USER_AUTH_GETOUT,sourceid];
//    NSURL *url = [NSURL URLWithString:strUrl];
    return strUrl;


}

//查询视频列表
- (NSURL *)listVideoLockAction
{
    NSString *address = @"video/listVideo";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//授权码请求视频列表
- (NSURL *)ListVideoInHome
{
    NSString *address = [NSString stringWithFormat:@"%@more/userdata",PUBLIC_SERVER_URL];
    NSURL    *url     = [NSURL URLWithString:address];
    
    return url;
}
//删除一个视频
- (NSURL *)didDeleteVideoAction
{
    NSString *address = @"video/deleteVideo";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

//查询最新客户端版本信息
- (NSURL *)getClientVersion
{
    NSString *address = @"version/getClientVersion";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//增加背景音乐
- (NSURL *)uplodingMusicAction
{
    NSString *address = @"music/uploadMusic";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

//断点添加音乐
- (NSURL *)resumeUploadMusic
{
    NSString *address = @"music/socketuploadMusic";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

//获取背景音乐列表 /删除背景音乐
- (NSURL *)didMusicManageAction
{
    NSString *address = @"music/manageMusic";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//家谱成员列表
- (NSURL *)didObtainMoreenealogyMember
{
    NSString *address = @"more/listmember";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

//新家谱成员列表

- (NSURL *)newFamilyTree{
    
    NSString *address = @"family/listmember";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//新家谱其他成员列表
- (NSURL *)otherNewFamilyTree:(NSDictionary *)dic{
    
    
    NSString *address = @"family/listmember";
    NSString *associatekey = dic[@"associateKey"];
    NSString *associatevalue = dic[@"associateValue"];
    NSString *associateauthcode = dic[@"associateAuthCode"];
    NSString *eternalnum = dic[@"eternalnum"];
    NSString *eternalCode = dic[@"eternalCode"];
    NSString *associateuserid = dic[@"associateUserId"];
    NSString *strUrl = [NSString stringWithFormat:@"%@%@associatekey=%@&associatevalue=%@&associateauthcode=%@&associateuserid=%@&eternalnum=%@&eternalcode=%@",SERVER_WEB_URL,address,associatekey,associatevalue,associateauthcode,associateuserid,eternalnum,eternalCode];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;

}
//修改家谱成员信息
- (NSURL *)changeObtainMoreenealogyMember
{
    NSString *address = @"more/updatemember";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//删除家谱成员
- (NSURL *)delectObtainMoreenealogyMember
{
    NSString *address = @"more/deletemember";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//新增家谱成员
- (NSURL *)addObtainMoreenealogyMember
{
    NSString *address = @"more/addmember";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//封存访问
-(NSURL *)forbidVisitUrl{
    NSString *address = @"user/applyStorage";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//memoryCode家园访问
-(NSURL *)memoryVisitHomeUrl:(NSString*)eternalCode{
//    http://192.168.7.183:8080/blog/home/accesshome? identifiedby=eternalcode&eternalcode=1111111111111111&success=http://192.168.7.183:8080/blog/home/success&failure=http://192.168.7.183:8080/blog/home/failure
    NSString *requstUrl = [NSString stringWithFormat:@"%@identifiedby=eternalcode&eternalcode=%@&success=%@&failure=%@",VISIT_HOME_URL,eternalCode,MEMORY_SUCCESS_URL,MEMORY_FAILURE_URL];
    NSURL *url = [NSURL URLWithString:requstUrl];
    return url;
  
}

//永恒号和授权码访问家园
-(NSURL *)accreditVisitHomeUrl:(NSString*)associatekey AndAssociatevalue:(NSString*)associatevalue AndAssociateauthcode:(NSString*)associateauthcode{
    //http://dev3.ieternal.com:80/home/accesshome?identifiedby=authcode&associatekey=eternalnum&associatevalue=sdssdsf&associateauthcode=sdsd&eternalcode=&success=http://dev3.ieternal.com:80/home/success&failure=http://dev3.ieternal.com:80/home/failure
    NSString *requstUrl = [NSString stringWithFormat:@"%@identifiedby=authcode&associatekey=%@&associatevalue=%@&associateauthcode=%@&eternalcode=&success=%@&failure=%@",VISIT_HOME_URL,associatekey,associatevalue,associateauthcode,MEMORY_SUCCESS_URL,MEMORY_FAILURE_URL];
    NSURL *url = [NSURL URLWithString:requstUrl];
    return url;
    
}
//token家园访问
-(NSURL *)visitHomeUrl{
    //http://192.168.7.183:8080/blog/home/accesshome?identifiedby=anthtoken &clienttoken=1233123414&serverauth=1432412312&success=http://192.168.7.183:8080/blog/home/success&failure=http://192.168.7.183:8080/blog/home/failure
    NSString *requstUrl = [NSString stringWithFormat:@"%@identifiedby=authtoken&clienttoken=%@&serverauth=%@&success=%@&failure=%@",VISIT_HOME_URL,USER_TOKEN_GETOUT,USER_AUTH_GETOUT,MEMORY_SUCCESS_URL,MEMORY_FAILURE_URL];
    NSURL *url = [NSURL URLWithString:requstUrl];
    return url;

}
//提交 意见反馈
- (NSURL *)getIdeaFeedbackUrl
{
    NSString *address = @"more/feedback";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}

//获取家园风格列表
- (NSURL *)getHomeStyleList
{
    NSString *address = @"style/manageStyle";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;

}
//家园留言
-(NSURL *)leaveMessage{
   
    NSString *address = @"more/leaveMessage";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",@"http://m.ieternal.com:80/api/",address];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
- (NSURL *)modifyMemberInfo
{
    NSString *address = @"family/updatemember";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    return url;
}

- (NSURL *)addFamilyMember
{
    NSString *address = @"family/addmember";
    NSString *urlStr  = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,address];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    return url;
}

- (NSURL *)deleteMember
{
    NSString *address = @"family/deletemember";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL, address];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    return url;

}
-(NSURL *)getAssociatedData
{
    NSString *address = @"more/userdata";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",PUBLIC_SERVER_URL, address];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    return url;

}

- (NSURL *)modifyMemberHeader
{
    NSString *addr = @"family/updateportrait";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL, addr];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    return url;
}

- (NSURL *)associateMember
{
    NSURL *url = [self setupRequestUrlWithAddress:@"family/associate"];
    
    return url;
}

- (NSURL *)addHeaderImage
{
    return [self setupRequestUrlWithAddress:@"family/uploadHeadImage"];
}

- (NSURL *)loginOut{
    
    NSString *addr = @"user/logout";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL, addr];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    return url;
}
-(NSURL *)getServerConfig:(NSString *)str{
    NSString *api = @"getconfig.js";
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",str,api];
    NSURL *url = [NSURL URLWithString:strUrl];
    return url;
}
//设置网络请求的公共部分
+(void)setRequestCommonData:(ASIFormDataRequest *)request
{
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setTimeOutSeconds:10];
}

- (NSURL *)getUserData
{
    NSString *str = @"more/getuserdata";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL,str];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url;
}

/**
 *  上传音频文件
 *
 *  @return 音频接口的URL
 */
- (NSURL *)uploadAudio {
    NSString *str = @"photo/uploadVoice";
    NSString *URLStr = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL, str];
    NSURL *url = [NSURL URLWithString:URLStr];
    
    return url;
}
//上传一生记忆相册录音
- (NSURL *)uploadLifePhotoAudio{
    
    NSString *str = @"group/uploadVoice";
    NSString *URLStr = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL, str];
    NSURL *url = [NSURL URLWithString:URLStr];
    
    return url;
}

//照片排序
- (NSURL *)sortForLifePhoto{
    
    NSString *str = @"photo/sort";
    NSString *URLStr = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL, str];
    NSURL *url = [NSURL URLWithString:URLStr];
    
    return url;
}

/**
 *  删除音频文件
 *
 *  @return 删除音频文件的URL
 */
- (NSURL *)deleteAudio {
    
    NSString *str = @"photo/deleteVoice";
    NSString *URLStr = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL, str];
    NSURL *url = [NSURL URLWithString:URLStr];
    
    return url;
}

//删除一生相册录音文件
- (NSURL *)deleteLifePhotoAudio{
    
    NSString *str = @"group/deleteVoice";
    NSString *URLStr = [NSString stringWithFormat:@"%@%@",SERVER_WEB_URL, str];
    NSURL *url = [NSURL URLWithString:URLStr];
    
    return url;
}

//捕获异常bug提交到服务器
- (NSURL *)uploadBugInfo{
    
    NSString *str = @"more/addBugInfo";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",PUBLIC_SERVER_URL,str];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url;
    
}

+ (NSURL *)urlForAllLifeMemoTemplate {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PUBLIC_SERVER_URL,@"photo/photolist"]];
}
@end
