//
//  StaticTools.m
//  EternalMemory
//
//  Created by sun on 13-5-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import "MD5.h"
#import "MessageSQL.h"
#import "MessageModel.h"
#import "StaticTools.h"
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "RequestParams.h"
#import "DiaryGroupsSQL.h"
#import "EMAllLifeMemoDAO.h"
#import "DiaryPictureClassificationSQL.h"
#import "MylifeDetailViewController.h"
#import "MyPhotoDetailsViewController.h"
#import "NoPhotoFromWebController.h"
@implementation StaticTools
static StaticTools * _shareInstance = nil;

+(StaticTools *)shareInstance{
    if (!_shareInstance) {
        _shareInstance = [[StaticTools alloc] init];
    }
    return _shareInstance;
}

/**
 * 功能:获取指定范围的字符串
 * 参数:字符串的开始小标
 * 参数:字符串的结束下标
 */
+(NSString *)getStringWithRange:(NSString *)str Value1:(NSInteger)value1 Value2:(NSInteger )value2;
{
    return [str substringWithRange:NSMakeRange(value1 ,value2)];
}
/**
 * 功能:判断是否在地区码内
 * 参数:地区码
 */
+(BOOL)areaCode:(NSString *)code
{
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    [dic setObject:@"北京" forKey:@"11"];
    [dic setObject:@"天津" forKey:@"12"];
    [dic setObject:@"河北" forKey:@"13"];
    [dic setObject:@"山西" forKey:@"14"];
    [dic setObject:@"内蒙古" forKey:@"15"];
    [dic setObject:@"辽宁" forKey:@"21"];
    [dic setObject:@"吉林" forKey:@"22"];
    [dic setObject:@"黑龙江" forKey:@"23"];
    [dic setObject:@"上海" forKey:@"31"];
    [dic setObject:@"江苏" forKey:@"32"];
    [dic setObject:@"浙江" forKey:@"33"];
    [dic setObject:@"安徽" forKey:@"34"];
    [dic setObject:@"福建" forKey:@"35"];
    [dic setObject:@"江西" forKey:@"36"];
    [dic setObject:@"山东" forKey:@"37"];
    [dic setObject:@"河南" forKey:@"41"];
    [dic setObject:@"湖北" forKey:@"42"];
    [dic setObject:@"湖南" forKey:@"43"];
    [dic setObject:@"广东" forKey:@"44"];
    [dic setObject:@"广西" forKey:@"45"];
    [dic setObject:@"海南" forKey:@"46"];
    [dic setObject:@"重庆" forKey:@"50"];
    [dic setObject:@"四川" forKey:@"51"];
    [dic setObject:@"贵州" forKey:@"52"];
    [dic setObject:@"云南" forKey:@"53"];
    [dic setObject:@"西藏" forKey:@"54"];
    [dic setObject:@"陕西" forKey:@"61"];
    [dic setObject:@"甘肃" forKey:@"62"];
    [dic setObject:@"青海" forKey:@"63"];
    [dic setObject:@"宁夏" forKey:@"64"];
    [dic setObject:@"新疆" forKey:@"65"];
    [dic setObject:@"台湾" forKey:@"71"];
    [dic setObject:@"香港" forKey:@"81"];
    [dic setObject:@"澳门" forKey:@"82"];
    [dic setObject:@"国外" forKey:@"91"];
    
    if ([dic objectForKey:code] == nil) {
        
        return NO;
    }
    return YES;
}

/**
 * 功能:验证身份证是否合法
 * 参数:输入的身份证号
 */
/**
 *	验证身份证
 *
 *	@param	sPaperId	身份证号
 *
 *	@return	是否正确
 */
- (BOOL)Chk18PaperId:(NSString *)sPaperId
{
    
    //判断位数
    if ([sPaperId length] < 15 ||[sPaperId length] > 18) {
        
        return NO;
    }
    
    NSString *carid = sPaperId;
    long lSumQT =0;
    //加权因子
    int R[] ={7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 };
    //校验码
    unsigned char sChecker[11]={'1','0','X', '9', '8', '7', '6', '5', '4', '3', '2'};
    
    //将15位身份证号转换成18位
    
    NSMutableString *mString = [NSMutableString stringWithString:sPaperId];
    if ([sPaperId length] == 15) {
        
        
        [mString insertString:@"19" atIndex:6];
        
        long p = 0;
        const char *pid = [mString UTF8String];
        for (int i=0; i<=16; i++)
        {
            p += (pid[i]-48) * R[i];
        }
        
        int o = p%11;
        NSString *string_content = [NSString stringWithFormat:@"%c",sChecker[o]];
        [mString insertString:string_content atIndex:[mString length]];
        carid = mString;
        
    }
    
    //判断地区码
    NSString * sProvince = [carid substringToIndex:2];
    
    if (![StaticTools areaCode:sProvince]) {
        
        return NO;
    }
    
    //判断年月日是否有效
    
    //年份
    int strYear = [[StaticTools getStringWithRange:carid Value1:6 Value2:4] intValue];
    //月份
    int strMonth = [[StaticTools getStringWithRange:carid Value1:10 Value2:2] intValue];
    //日
    int strDay = [[StaticTools getStringWithRange:carid Value1:12 Value2:2] intValue];
    
    
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeZone:localZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d 12:01:01",strYear,strMonth,strDay]];
    if (date == nil) {
        
        return NO;
    }
    
    const char *PaperId  = [carid UTF8String];
    
    //检验长度
    if( 18 != strlen(PaperId)) return -1;
    //校验数字
    for (int i=0; i<18; i++)
    {
        if ( !isdigit(PaperId[i]) && !(('X' == PaperId[i] || 'x' == PaperId[i]) && 17 == i) )
        {
            return NO;
        }
    }
    //验证最末的校验码
    for (int i=0; i<=16; i++)
    {
        lSumQT += (PaperId[i]-48) * R[i];
    }
    if (sChecker[lSumQT%11] != PaperId[17] )
    {
        return NO;
    }
    
    return YES;
}

//判断文本信息长度
+ (NSUInteger) lenghtWithString:(NSString *)string
{
    NSUInteger len = string.length;
    // 汉字字符集
    NSString * pattern  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 计算中文字符的个数
    NSInteger numMatch = [regex numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    return len + numMatch;
}

//判断一生记忆的图片本地是否存在
+(NSString *)getMemoPhoto:(MessageModel *)model
{
    NSString *filePath = nil;
    if (!model.paths || model.paths.length == 0) {
        NSString *localImageName = [MD5 md5:model.attachURL];
        NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Caches"] stringByAppendingPathComponent:@"ImageCache"];
        filePath = [path stringByAppendingPathComponent:localImageName];
         return filePath;
    }
    NSString *localImageName = [MD5 md5:model.paths];
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Caches"] stringByAppendingPathComponent:@"ImageCache"];
    filePath = [path stringByAppendingPathComponent:localImageName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager  fileExistsAtPath:filePath isDirectory:NO];
    if (result == YES)
    {
        return filePath;
    }
    else
    {
        NSString *fileName = [Utilities fileNameOfURL:model.paths];
        if (model.blogId.length > 0)
        {
            filePath = [[Utilities lifeMemoPathOfUserUploaded] stringByAppendingPathComponent:fileName];
        }
        else
        {
            filePath = [[Utilities lifeMemoPathOfTemplate] stringByAppendingPathComponent:fileName];
        }
        result = [fileManager  fileExistsAtPath:fileName isDirectory:NO];
        if (result == YES)
        {
            return filePath;
        }
    }
    return filePath;
}

//横竖屏时设置相关尺寸
+(void)setViewRect:(UIImageView *)imageView image:(UIImage *)image
{
    CGSize imageSize = image.size;
    BOOL StatusHidden = [UIApplication sharedApplication].statusBarHidden;
    CGSize imageViewSize = CGSizeZero;
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationPortrait)
    {
        CGFloat winHeight = iPhone5? (StatusHidden ? 568 :548) : (StatusHidden ? 480:460);
        if (imageSize.height >  imageSize.width)
        {
            if (imageSize.height > winHeight)
            {
                CGFloat scale = winHeight / 320;
                CGFloat imageScale = imageSize.height / imageSize.width;
                if (imageScale < scale)
                {
                    CGFloat imageViewSizeHeight = 320 / imageSize.width * imageSize.height;
                    imageViewSize = CGSizeMake(320, imageViewSizeHeight);
                }
                else
                {
                    CGFloat imageViewSizeWidth = winHeight / imageSize.height * imageSize.width;
                    imageViewSize = CGSizeMake(imageViewSizeWidth, winHeight);
                }
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height < imageSize.width)
        {
            if (imageSize.width > 320)
            {
                CGFloat imageViewSizeHeight = 320 / imageSize.width * imageSize.height;
                imageViewSize = CGSizeMake(320, imageViewSizeHeight);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height == imageSize.width)
        {
            if (imageSize.width > 320)
            {
                imageViewSize = CGSizeMake(320, 320);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        CGFloat originX = (320 - imageViewSize.width) / 2;
        CGFloat originY = (winHeight - imageViewSize.height) / 2;
        imageView.bounds = CGRectMake(originX, originY, imageViewSize.width, imageViewSize.height);
    }
    else if (currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight)
    {
        CGFloat winWidth = iPhone5? 568 : 480;
        CGFloat winHeight = StatusHidden ? 320 : 300;
        
        if (imageSize.height == imageSize.width)
        {
            if (imageSize.width > 320)
            {
                imageViewSize = CGSizeMake(320, 320);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height > imageSize.width)
        {
            if (imageSize.height > 320)
            {
                CGFloat imageViewSizeWidth = 320 / imageSize.height * imageSize.width;
                imageViewSize = CGSizeMake(imageViewSizeWidth, 320);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height < imageSize.width)
        {
            if (imageSize.width > winWidth)
            {
                CGFloat scale = winWidth / 320;
                CGFloat imageScale = imageSize.height / imageSize.width;
                if (imageScale < scale)
                {
                    CGFloat imageViewSizeWidth = 320 / imageSize.height * imageSize.width;
                    if (iPhone5)
                    {
                        imageViewSize = CGSizeMake(imageViewSizeWidth, 320);
                    }
                    else
                    {
                        imageViewSize = CGSizeMake(imageViewSizeWidth, 300);
                    }
                }
                else
                {
                    CGFloat imageViewSizeHeight = winWidth / imageSize.width * imageSize.height;
                    imageViewSize = CGSizeMake(winWidth, imageViewSizeHeight);
                }
            }
            else
            {
                imageViewSize = imageSize;
            }
        }

        CGFloat originX = (winWidth - imageViewSize.width)/ 2;
        CGFloat originY= 0;
        originY = (winHeight - imageViewSize.height) / 2;

        imageView.bounds = CGRectMake(originX, originY, imageViewSize.width, imageViewSize.height);
    }
}


+(void)setViewOldRect:(UIImageView *)imageView image:(UIImage *)image
{
    CGSize imageSize = image.size;
    BOOL StatusHidden = [UIApplication sharedApplication].statusBarHidden;
    CGSize imageViewSize = CGSizeZero;
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationPortrait)
    {
        CGFloat winWidth = iPhone5? 568 : 480;
        CGFloat winHeight = StatusHidden ? 320 : 300;
        
        if (imageSize.height == imageSize.width)
        {
            if (imageSize.width > 320)
            {
                imageViewSize = CGSizeMake(320, 320);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height > imageSize.width)
        {
            if (imageSize.height > 320)
            {
                CGFloat imageViewSizeWidth = 320 / imageSize.height * imageSize.width;
                imageViewSize = CGSizeMake(imageViewSizeWidth, 320);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height < imageSize.width)
        {
            if (imageSize.width > winWidth)
            {
                CGFloat scale = winWidth / 320;
                CGFloat imageScale = imageSize.height / imageSize.width;
                if (imageScale < scale)
                {
                    CGFloat imageViewSizeWidth = 320 / imageSize.height * imageSize.width;
                    if (iPhone5)
                    {
                        imageViewSize = CGSizeMake(imageViewSizeWidth, 320);
                    }
                    else
                    {
                        imageViewSize = CGSizeMake(imageViewSizeWidth, 300);
                    }
                }
                else
                {
                    CGFloat imageViewSizeHeight = winWidth / imageSize.width * imageSize.height;
                    imageViewSize = CGSizeMake(winWidth, imageViewSizeHeight);
                }
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        
        CGFloat originX = (winWidth - imageViewSize.width)/ 2;
        CGFloat originY= 0;
        originY = (winHeight - imageViewSize.height) / 2;
        imageView.bounds = CGRectMake(originX, originY, imageViewSize.width, imageViewSize.height);
    }
    else if (currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight)
    {
        CGFloat winHeight = iPhone5? (StatusHidden ? 568 :548) : (StatusHidden ? 480:460);
        if (imageSize.height >  imageSize.width)
        {
            if (imageSize.height > winHeight)
            {
                CGFloat scale = winHeight / 320;
                CGFloat imageScale = imageSize.height / imageSize.width;
                if (imageScale < scale)
                {
                    CGFloat imageViewSizeHeight = 320 / imageSize.width * imageSize.height;
                    imageViewSize = CGSizeMake(320, imageViewSizeHeight);
                }
                else
                {
                    CGFloat imageViewSizeWidth = winHeight / imageSize.height * imageSize.width;
                    imageViewSize = CGSizeMake(imageViewSizeWidth, winHeight);
                }
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height < imageSize.width)
        {
            if (imageSize.width > 320)
            {
                CGFloat imageViewSizeHeight = 320 / imageSize.width * imageSize.height;
                imageViewSize = CGSizeMake(320, imageViewSizeHeight);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height == imageSize.width)
        {
            if (imageSize.width > 320)
            {
                imageViewSize = CGSizeMake(320, 320);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        CGFloat originX = (320 - imageViewSize.width) / 2;
        CGFloat originY = (winHeight - imageViewSize.height) / 2;
        imageView.bounds = CGRectMake(originX, originY, imageViewSize.width, imageViewSize.height);
    }
}

/*
+(void)setViewOldRect:(UIImageView *)imageView image:(UIImage *)image
{
    CGSize imageSize = image.size;
    CGSize imageViewSize = CGSizeZero;
    BOOL StatusHidden = [UIApplication sharedApplication].statusBarHidden;
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight)
    {
        CGFloat winWdith = iPhone5? 568 : 480;
        CGFloat winHeight = StatusHidden ? 320 : 300;
        if (imageSize.height >  imageSize.width)
        {
            if (imageSize.height > winWdith)
            {
                CGFloat scale = winWdith / 320;
                CGFloat imageScale = imageSize.height / imageSize.width;
                if (imageScale < scale)
                {
                    CGFloat imageViewSizeHeight = 320 / imageSize.width * imageSize.height;
                    imageViewSize = CGSizeMake(320, imageViewSizeHeight);
                }
                else
                {
                    CGFloat imageViewSizeWidth = winWdith / imageSize.height * imageSize.width;
                    imageViewSize = CGSizeMake(imageViewSizeWidth, winWdith);
                }
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height < imageSize.width)
        {
            if (imageSize.width > 320)
            {
                CGFloat imageViewSizeHeight = 320 / imageSize.width * imageSize.height;
                imageViewSize = CGSizeMake(320, imageViewSizeHeight);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height == imageSize.width)
        {
            if (imageSize.width > 320)
            {
                imageViewSize = CGSizeMake(320, 320);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        CGFloat originX = (winHeight - imageViewSize.width) / 2;
        CGFloat originY = (winWdith - imageViewSize.height) / 2;
        imageView.bounds = CGRectMake(originX, originY, imageViewSize.width, imageViewSize.height);
    }
    else if (currentOrientation == UIInterfaceOrientationPortrait)
    {
//        CGFloat winWidth = iPhone5? 568 : 480;
        CGFloat winHeight = iPhone5? (StatusHidden ? 568 :548) : (StatusHidden ? 480:460);

        
        if (imageSize.height == imageSize.width)
        {
            if (imageSize.width > 320)
            {
                imageViewSize = CGSizeMake(320, 320);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height > imageSize.width)
        {
            if (imageSize.height > 320)
            {
                CGFloat imageViewSizeWidth = 320 / imageSize.height * imageSize.width;
                imageViewSize = CGSizeMake(imageViewSizeWidth, 320);
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        else if (imageSize.height < imageSize.width)
        {
            if (imageSize.width > winHeight)
            {
                CGFloat scale = winHeight / 320;
                CGFloat imageScale = imageSize.height / imageSize.width;
                if (imageScale < scale)
                {
                    CGFloat imageViewSizeWidth = 320 / imageSize.height * imageSize.width;
                    imageViewSize = CGSizeMake(imageViewSizeWidth, 320);
                }
                else
                {
                    CGFloat imageViewSizeHeight = winHeight / imageSize.width * imageSize.height;
                    imageViewSize = CGSizeMake(winHeight, imageViewSizeHeight);
                }
            }
            else
            {
                imageViewSize = imageSize;
            }
        }
        
        CGFloat originX = (winHeight - imageViewSize.width)/ 2;
        CGFloat originY = (320 - imageViewSize.height) / 2;
        imageView.bounds = CGRectMake(originX, originY, imageViewSize.width, imageViewSize.height);
    }
}
 */

+(void)updateDiaryAndPhotoGroup:(NSArray *)groupArray WithUserID:(NSString *)UserID
{
    NSMutableArray *diaryArr = [NSMutableArray array];
    NSMutableArray *photoArr = [NSMutableArray array];
    
    for (NSDictionary * dic in groupArray)
    {
        if ([dic[@"blogType"] intValue] == 0)
        {
            [diaryArr addObject:dic];
        }
        else
        {
            DiaryPictureClassificationModel *model = [[DiaryPictureClassificationModel alloc] initWithDict:dic];
            model.latestPhotoPath = [[Utilities relativePathForSavingPhotos] stringByAppendingPathComponent:[MD5 md5:[NSString stringWithFormat:@"simg_%@.png",model.latestPhotoURL]]];
            [photoArr addObject:model];
            [model release];
        }
    }
    [DiaryGroupsSQL refershDiaryGroups:diaryArr WithUserID:UserID];
    [DiaryPictureClassificationSQL addDiaryPictureClassificationes:photoArr];
}

//更新图片数据库问题
+(void)insertDBPhotos:(NSArray *)photoArray
{
    NSMutableArray *memoArray = [NSMutableArray array];
    NSMutableArray *normalArray = [NSMutableArray array];
    
    for (NSDictionary *dic in photoArray)
    {
        if ([dic[@"photowall"] intValue] == 0)
        {
            [normalArray addObject:dic];
        }
        else
        {
            MessageModel *photoModel = [[MessageModel alloc] initWithDict:dic];
            [memoArray addObject:photoModel];
            [photoModel release];
        }
    }
    [MessageSQL synchronizeBlog:normalArray WithUserID:USERID];
    [EMAllLifeMemoDAO insertMemoModels:memoArray];
}

+ (void)getPhotoFromLocal:(id)obj
{
    NSMutableArray *arr = [MessageSQL getAllPhotosWithUserId:USERID];
    if (!arr || arr.count == 0) {
//        MBProgressHUD *hud = [StaticTools hubWithMessage:@"暂无照片" controller:obj];
//        hud.mode = MBProgressHUDModeText;
//        [hud show:YES];
//        [hud hide:YES afterDelay:1.0f];
//        __block typeof(MylifeDetailViewController *) bself = (MylifeDetailViewController *)obj;
        MylifeDetailViewController *myLifeCtrl = (MylifeDetailViewController *)obj;
        NoPhotoFromWebController *noPhotoCtrl = [[NoPhotoFromWebController alloc] init];
        [myLifeCtrl presentViewController:noPhotoCtrl animated:NO completion:^{
        }];
        [noPhotoCtrl release];

    } else {
        __block typeof(MylifeDetailViewController *) bself = (MylifeDetailViewController *)obj;
        [[NSNotificationCenter defaultCenter] addObserver:bself selector:@selector(addJSToWebviewPhoto) name:@"HomeContinueMusic" object:nil];

        MyPhotoDetailsViewController *photoDetail = [[MyPhotoDetailsViewController alloc] init];
        photoDetail.selectPhotoIndex = 0;
        photoDetail.blogs = arr;
        photoDetail.hideRecordButtonForNoAudio = YES;
        photoDetail.shouldRightButtonHidden = YES;
        photoDetail.comeFrom = @"Home";
        photoDetail.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        __block MyPhotoDetailsViewController *b_photoDetail = photoDetail;
        [bself presentViewController:photoDetail animated:YES completion:^{
            b_photoDetail.rightBtn.hidden = YES;
        }];
        [photoDetail release];
    }
}


//通过家园浏览全部的图片
+(void)getPhotoFromServer:(id)obj
{
    NSURL *url = [[RequestParams sharedInstance] getUserData];
    NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
    NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:User_File];
    NSDictionary *userDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString *userID = userDic[@"userId"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:userID forKey:@"userid"];
    [request setPostValue:@"photo" forKey:@"userdata"];
    [request setPostValue:@"1" forKey:@"grouptype"];
    [request setPostValue:@"normal" forKey:@"struct"];
    [request startAsynchronous];
    
//    MBProgressHUD *hud = [[StaticTools hubWithMessage:@"正在载入..." c] retain];
    MBProgressHUD *hud = [StaticTools hubWithMessage:@"正在载入..." controller:obj];
    [hud show:YES];
    
    __block typeof(MylifeDetailViewController *) bself = (MylifeDetailViewController *)obj;
    request.completionBlock = ^{
        NSData *responseData = request.responseData;
        NSError *error = nil;
        NSDictionary *JSONDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if (!error) {
            NSInteger success = [JSONDic[@"success"] integerValue];
            NSString *errorMsg = JSONDic[@"message"];
            if (success == 1) {
                NSArray *blogsData = JSONDic[@"meta"][@"photos"];
                NSMutableArray *photos = [[NSMutableArray alloc] init];
                for (NSDictionary *blog in blogsData) {
                    if ([blog[@"photowall"] intValue] == 0)
                    {
                        MessageModel *model = [[MessageModel alloc] initWithDict:blog];
                        MessageModel *loaclModel = [MessageSQL getBlogByBlogId:model.blogId];
                        model.paths = loaclModel.paths;
                        [photos addObject:model];
                        [model release];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.mode = MBProgressHUDModeText;
                    if (!photos || photos.count == 0) {
//                        hud.labelText = @"暂无照片";
                        NoPhotoFromWebController *noPhotoCtrl = [[NoPhotoFromWebController alloc] init];
                        [bself presentViewController:noPhotoCtrl animated:NO completion:^{
                        }];
                        [noPhotoCtrl release];
                    } else {
                       

//
                        hud.labelText = @"载入成功!";
                        MyPhotoDetailsViewController *photoDetail = [[MyPhotoDetailsViewController alloc] init];
                        photoDetail.selectPhotoIndex = 0;
                        photoDetail.blogs = photos;
                        photoDetail.hideRecordButtonForNoAudio = YES;
                        photoDetail.shouldRightButtonHidden = YES;
                        photoDetail.comeFrom = @"Home";
                        photoDetail.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                        __block MyPhotoDetailsViewController *b_photoDetail = photoDetail;
                        [bself presentViewController:photoDetail animated:NO completion:^{
                            b_photoDetail.rightBtn.hidden = YES;
                        }];
                        [photoDetail release];
                        [photos release];
                    }
                    
                    [hud hide:YES afterDelay:1.f];
                    [hud release];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.labelText = errorMsg;
                    [hud hide:YES];
                    [hud release];
                });
            }
        } else {
        }
        
    };
    [request setFailedBlock:^{
        [hud hide:YES afterDelay:1.f];
    }];
}

+ (MBProgressHUD *)hubWithMessage:(NSString *)message controller:(id)obj
{
    MylifeDetailViewController *lifeDetailCtrl = (MylifeDetailViewController *)obj;
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:lifeDetailCtrl.view];
    [[EternalMemoryAppDelegate getAppDelegate].window addSubview:HUD];
    HUD.labelText = message;
    HUD.mode = MBProgressHUDModeIndeterminate;
    return [HUD autorelease];
}

@end







































