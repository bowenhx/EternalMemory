 //
//  VedioSendOperation.m
//  EternalMemory
//
//  Created by yanggongfu on 7/22/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import "VedioSendOperation.h"
#import "RequestParams.h"
#import "CommonData.h"
#import "FileModel.h"
#import "BackgroundMusicViewCtrl.h"
#import "EternalMemoryAppDelegate.h"
#import "CommonData.h"
#import "ShowListHeadView.h"
#import "DownloadViewCtrl.h"
#import "SavaData.h"
#import "MyToast.h"
#import "MusicSendOperation.h"
#define FileModel     [FileModel sharedInstance]

@interface VedioSendOperation ()<UIAlertViewDelegate>
{
    NSString    *name;//视频名字
    NSString    *path;//视频路径
    NSString    *content;//视频描述
    BOOL         switchOn;
}

-(void)sendVedio;
-(void)setUplongdingDataWithLastNameSuccess:(NSString *)name;
-(void)setUplongdingDataWithLastNameFailed:(NSString *)name;
@end


@implementation VedioSendOperation

@synthesize dataRequest = _dataRequest;

- (void)dealloc
{
    [name release];
    name = nil;
    [path release];
    path = nil;
    [content release];
    content = nil;
    [super dealloc];
}

-(id)initWithVedioName:(NSString *)vedioName VedioPath:(NSString *)vedioPath VedioContent:(NSString *)vedioContent SwitchState:(BOOL)showPublic
{
    self = [super init];
    if (self)
    {
        name = [[NSString alloc] initWithFormat:@"%@",vedioName];
        path = [[NSString alloc] initWithFormat:@"%@",vedioPath];
        content = [[NSString alloc] initWithFormat:@"%@",vedioContent];
        switchOn = showPublic;
    }
    return self;
}

-(void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    FileModel.notificationSend = NO;
    [self sendVedio];
    [pool release];
}

-(void)sendVedio
{
    NSURL *url = [[RequestParams sharedInstance] commonUploadVideoURLAddress];
//    NSURL *url = [NSURL URLWithString:@"http://dev.ieternal.com/api/video/commonUploadVideo"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length ==0) {
        [MyToast showWithText:@"因文件太大,无法上传" :[UIScreen mainScreen].bounds.size.height/2-40];
        [self requestDatalengthNil];
        return;
    }
    _dataRequest = [[ASIFormDataRequest alloc] initWithURL:url];
    [_dataRequest setDelegate:self];
    _dataRequest.uploadProgressDelegate = self;
    [_dataRequest setShouldAttemptPersistentConnection:NO];
    [_dataRequest setRequestMethod:@"POST"];
    [_dataRequest setAllowResumeForFileDownloads:YES];//允许断点
    _dataRequest.allowCompressedResponse = NO;//禁止压缩
    [_dataRequest addRequestHeader:@"clienttoken" value:USER_TOKEN_GETOUT];
    [_dataRequest addRequestHeader:@"serverauth" value:USER_AUTH_GETOUT];
    
    [_dataRequest addRequestHeader:@"filesize" value:[NSString stringWithFormat:@"%d",data.length]];
    [_dataRequest setPostValue:content forKey:@"content"];
    [_dataRequest setPostValue:[NSNumber numberWithBool:switchOn] forKey:@"accessLevel"];
    [_dataRequest addData:data withFileName:name andContentType:@"Video/mov" forKey:@"upfile"];
    [_dataRequest setTimeOutSeconds:40];
    FileModel.isUploading = YES;
    FileModel.upReceivedSize = @"0";
    [_dataRequest startAsynchronous];

}

#pragma mark - ASIHTTPDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    NSDictionary *dic = [data objectFromJSONData];
    NSString *message = [NSString stringWithFormat:@"%@",[dic objectForKey:@"message"]];
    if ([[dic objectForKey:@"success"] intValue] == 1)
    {
        if ([message isEqualToString:@"没有上传文件"])
        {
            [MyToast showWithText:@"视频处理发生错误，请稍后再传" :140];
            
            FileModel.videoNumber--;
            VedioSendOperation *vedioOperation = (VedioSendOperation *)FileModel.operation;
           
            [vedioOperation.dataRequest clearDelegatesAndCancel];
            vedioOperation.dataRequest = nil;
            [vedioOperation isCancelled];
             [self requestDatalengthNil];
        }
        else
        {
            NSNumber *spaceUsed = [NSNumber numberWithLongLong:[dic[@"meta"][@"spaceused"] longLongValue]];
            [SavaData fileSpaceUseAmount:spaceUsed];
            
            [[CommonData getUploadingFile] stringByAppendingPathComponent:name];
            
            //把上传视频路径存入本地，方便下次直接播放
            NSDictionary *dicPath = @{@"videoPath":path,@"videoName":content};
            [FileModel.videoPathArr addObject:dicPath];
            //把本地视频路劲存入本地
            [[SavaData shareInstance] savaArray:FileModel.videoPathArr KeyString:@"videoPath"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataList" object:nil];
        }
        [self setUplongdingDataWithLastNameSuccess:name];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadVedioNumber" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTimerSuccess" object:nil];
    }
    else if ([dic[@"errorcode"] intValue] == 1005)
    {
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
    }else{
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
       
        FileModel.videoNumber--;
        VedioSendOperation *vedioOperation = (VedioSendOperation *)FileModel.operation;
        
        [vedioOperation.dataRequest clearDelegatesAndCancel];
        vedioOperation.dataRequest = nil;
        [vedioOperation isCancelled];
        [self requestDatalengthNil];
    }
}
- (void)requestDatalengthNil
{
    FileModel.isUploading = NO;
    FileModel.upReceivedSize = @"0";
    FileModel.videoNumber = 0;
    [FileModel.arrDownloadList removeAllObjects];
    if (FileModel.uploadingArr.count>0) {
        [FileModel.uploadingArr removeObjectAtIndex:0];
    }
    
//    NSLog(@"sdfasdfas = %@",FileModel.uploadingArr);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadVedioNumber" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTimerFailed" object:nil];
}
-(void)requestFailed:(ASIHTTPRequest *)request
{
    [self failedDispose];
}
- (void)failedDispose
{
    FileModel.isUploading = NO;
    [self setUplongdingDataWithLastNameFailed:name];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadVedioNumber" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTimerFailed" object:nil];
}
#pragma mark - Request finish or failed to do these methods

-(void)setUplongdingDataWithLastNameFailed:(NSString *)name
{
    BOOL network = [Utilities checkNetwork];
    if (network)
    {
        FileModel.upReceivedSize = @"0";
        if (FileModel.arrUplodingList.count == 0)
        {
            [FileModel.operation main];
        }
        else
        {
            [FileModel.arrUplodingList addObject:FileModel.operation];
            FileModel.operation = [FileModel.arrUplodingList objectAtIndex:0];
            [FileModel.operation main];
            id obj = [FileModel.uploadingArr objectAtIndex:0] ;
            [FileModel.uploadingArr addObject:obj];
            [FileModel.uploadingArr removeObjectAtIndex:0];
            [FileModel.arrUplodingList removeObjectAtIndex:0];
        }
    }
    else
    {
        [self cancelRequest];

    }
}
//重新登录清除下载数据
- (void)cancelRequest
{
    VedioSendOperation *vedioOperation = (VedioSendOperation *)FileModel.operation;
    if (vedioOperation !=nil) {
        [vedioOperation.dataRequest clearDelegatesAndCancel];
        vedioOperation.dataRequest = nil;
        [vedioOperation isCancelled];
    }
    FileModel.isUploading = NO;
    FileModel.upReceivedSize = @"0";
    FileModel.videoNumber = 0;
    [FileModel.arrDownloadList removeAllObjects];
    [FileModel.uploadingArr removeAllObjects];
}
-(void)setUplongdingDataWithLastNameSuccess:(NSString *)name1
{
    FileModel.videoNumber --;
//    FileModel.upReceivedSize = @"0";
    NSMutableArray *tempArr = (NSMutableArray *)[[SavaData shareInstance] printDataAry:Uploading_File];
    [tempArr addObject:[NSString stringWithFormat:@"%@.mov",content]];
    [[SavaData shareInstance] savaArray:tempArr KeyString:Uploading_File];
    [FileModel.upVideoSize removeObjectAtIndex:0];//去掉一个视频大小数据
    if (FileModel.arrUplodingList.count == 0)
    {
        [FileModel.uploadingArr removeObjectAtIndex:0];
    }
    else
    {
        FileModel.operation = [FileModel.arrUplodingList objectAtIndex:0];
        [FileModel.operation main];
        [FileModel.uploadingArr removeObjectAtIndex:0];
//        NSLog(@"FileModel:uploadingArr = %@",FileModel.uploadingArr);
        [FileModel.arrUplodingList removeObjectAtIndex:0];
    }
    [[SavaData shareInstance] savaArray:FileModel.uploadingArr KeyString:Uploading_File];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if (alertView.tag ==100) {
//        if (buttonIndex ==1) {
//            FileModel.upReceivedSize = 0;
//            FileModel.isUploading = NO;
//            [self setUplongdingDataWithLastNameFailed:name];
//        }else
//        {
//            FileModel.videoNumber--;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadVedioNumber" object:nil];
//            VedioSendOperation *vedioOperation = (VedioSendOperation *)FileModel.operation;
//            [FileModel.uploadingArr removeObjectAtIndex:0];
//            [vedioOperation.dataRequest clearDelegatesAndCancel];
//            vedioOperation.dataRequest = nil;
//            [vedioOperation isCancelled];
//        }
//    }else{
        BOOL isLogin = NO;
        [self cancelRequest];
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
//    }
    
}
-(void)setProgress:(float)newProgress
{
    FileModel.fileName = [NSString stringWithFormat:@"%@.mov",content];
    FileModel.upReceivedSize = [NSString stringWithFormat:@"%f",newProgress];
    if (newProgress == 1.0f) {
        FileModel.isUploading = NO;
    }
//    NSLog(@"fileModel.upReceivedSize is %@",FileModel.upReceivedSize);
}


@end
