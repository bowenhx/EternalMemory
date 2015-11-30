//
//  StyleSendOperation.m
//  EternalMemory
//
//  Created by Guibing on 13-8-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "StyleSendOperation.h"
#import "RequestParams.h"
#import "CommonData.h"
#import "ZipArchive.h"
#import "FileModel.h"
#import "SavaData.h"
#import "MyToast.h"
#import "StyleListSQL.h"
#define FileModel    [FileModel sharedInstance]
@implementation StyleSendOperation
{
    
    long long           size;
    long long           sizeV;
   
}
@synthesize didDownStyleProgressBlock = _didDownStyleProgressBlock;
- (void)dealloc
{
    [_dicData release],_dicData = nil;
    [_styleRequest clearDelegatesAndCancel];
    [_styleRequest release];
    [super dealloc];
}
- (id)initWithStyleSendOperation:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        size = 0.0f;
        sizeV = 0.0f;
        _dicData = [[NSDictionary alloc] initWithDictionary:dic];
    }
    return self;
}

- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   //TODO 取出下载队列数据
    if (_dicData.count>0 && [_dicData isKindOfClass:[NSDictionary class]]) {
        [self beginDownloadStyleBoard:_dicData];
    }else{
        //下载文件出错
    }
    [pool release];
}
- (void)beginDownloadStyleBoard:(NSDictionary *)dic
{
    NSFileManager *fileHome = [NSFileManager defaultManager];
    NSError *error;
    //创建下载临时文件
    if(![fileHome fileExistsAtPath:[CommonData getTempFolderPath]])
    {
        [fileHome createDirectoryAtPath:[CommonData getTempFolderPath] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSString *homeUrl = dic[@"zippath"];
    NSString *typeStr = [[homeUrl componentsSeparatedByString:@"."] lastObject];
    NSString *styleName = [NSString stringWithFormat:@"style%@",dic[@"styleId"]];
    FileModel.downStyleName = styleName;

    _styleRequest=[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:homeUrl]];
    //先把下载内容放入本地临时文件
    _styleRequest.temporaryFileDownloadPath = [[CommonData getTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",styleName]];
    //再把下载完后内容归到本地文件
    _styleRequest.downloadDestinationPath = [[CommonData getTargetFloderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",styleName,typeStr]];
    
    [_styleRequest setAllowResumeForFileDownloads:YES];//允许断点
    [_styleRequest setUserInfo:dic];
    _styleRequest.allowCompressedResponse = NO;//禁止压缩
    [_styleRequest setDownloadProgressDelegate:self];
    [_styleRequest setDelegate:self];
    [_styleRequest setPersistentConnectionTimeoutSeconds:600];
    [_styleRequest setShouldAttemptPersistentConnection:NO];
    [_styleRequest setNumberOfTimesToRetryOnTimeout:2];
    
    [_styleRequest setTimeOutSeconds:30.0f];
    
    [_styleRequest startAsynchronous];

}
- (void)requestStarted:(ASIHTTPRequest *)request{
    
    //TODO:开始下载，把将下载的风格加入到表中
    [StyleListSQL addDownLoadList:[request.userInfo[@"styleId"] integerValue]];
    FileModel.styleID = [request.userInfo[@"styleId"] integerValue];
    if (self.indexHome ==1) {
         FileModel.isHomeDown = YES;
    }else {
         FileModel.isHomeDown = NO;
    }
}
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    sizeV = [[request responseHeaders][@"Content-Length"] longLongValue];
}
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    size += bytes;
    if (_didDownStyleProgressBlock) {
        _didDownStyleProgressBlock(size,sizeV);
    }
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [MyToast showWithText:@"风格模板下载成功":[UIScreen mainScreen].bounds.size.height/2-40];
    
    __block typeof(self) bself = self;
    __block NSString *styleID = @"";
    __block NSString *specificStyle = @"";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [StyleListSQL updateDownLoadState:[request.userInfo[@"styleId"] integerValue]];
        
        //在模板页面下载，删除zip压缩文件，并解压
        [CommonData beginDecompressionFile:request.userInfo];
        
        
        if (self.indexHome ==1) {
            //下载完成后再进家园保存选中的风格ID
            [[SavaData shareInstance] savadataStr:request.userInfo[@"styleId"] KeyString:[NSString stringWithFormat:@"%@homeStyle",PUBLICUID]];
            
            
            //取出本地存在的模板ID，没有保存过，默认是0
            [[[SavaData shareInstance] printDataStr:[NSString stringWithFormat:@"%@homeStyle",PUBLICUID]] integerValue];
            
            styleID = [NSString stringWithFormat:@"style%@",request.userInfo[@"styleId"]];
            [[SavaData shareInstance] savadataStr:styleID KeyString:@"styleId"];
            //根据返回的style规律来确定几套模板>> zipname = style3;
            specificStyle = request.userInfo[@"zipname"];
            specificStyle = [specificStyle substringToIndex:specificStyle.length - 4];
            [[SavaData shareInstance] savadataStr:specificStyle KeyString:@"specificStyle"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSelectHomeStyle" object:nil];
        }
        
        [FileModel.downStyleIDArr removeObjectAtIndex:0];
        
        id operation = FileModel.styleOperation[0];
        [operation isCancelled];
        [FileModel.styleOperation removeObjectAtIndex:0];
        
        
        if (FileModel.styleOperation.count>0) {
            bself = FileModel.styleOperation[0];
            [bself main];
        }
    });
    
    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    //下载失败就从下载状态的表中删除
    [StyleListSQL deleteDownLoad:[request.userInfo[@"styleId"] integerValue]];
    
    if (self.indexHome ==1) {
        FileModel.isHomeDown = NO;//记录家园模板下载失败处理
    }
    
    [MyToast showWithText:@"风格模板下载失败":[UIScreen mainScreen].bounds.size.height/2-40];

}
@end
