//
//  MusicSendOperation.m
//  EternalMemory
//
//  Created by yanggongfu on 7/19/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import "MusicSendOperation.h"
#import "RequestParams.h"
#import "CommonData.h"
#import "FileModel.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "BackgroundMusicViewCtrl.h"
#import "EternalMemoryAppDelegate.h"
#import "CommonData.h"
#import "FileModel.h"
#import "ShowListHeadView.h"
#import "DownloadViewCtrl.h"
#import "CustomNavBarController.h"
#import "SavaData.h"
#import "VedioSendOperation.h"
#import "MyToast.h"
#define FileModel  [FileModel sharedInstance]

@interface MusicSendOperation  ()<UIAlertViewDelegate>
{
    NSString *exportFile;
}

-(void)setUplongdingDataWithLastNameSuccess:(NSString *)name;
-(void)setUplongdingDataWithLastNameFailed:(NSString *)name;

@end


@implementation MusicSendOperation

@synthesize dataRequest = _dataRequest;

-(id)initWithName:(NSString *)name WithmediaItem:(MPMediaItemCollection *)mediaitem
{
    self = [super init];
    if (self)
    {
        mediaItem = [mediaitem retain];
        nameStr = [[NSString alloc] initWithFormat:@"%@",name];
    }
    return self;
}


-(void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    FileModel.notificationSend = NO;
    FileModel.fileName = nameStr;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopOperation:) name:@"stopOperation" object:nil];
    [self sendMusic];
    [pool release];
}

-(void)sendMusic
{
    NSString *musicName = [NSString stringWithFormat:@"%@.m4a",[mediaItem valueForProperty:MPMediaItemPropertyTitle]];
    NSString *musicArtist = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
    NSString *musicIntro = [mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    NSURL *assetURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVAssetExportSession *exporter = [[[AVAssetExportSession alloc] initWithAsset: urlAsset presetName: AVAssetExportPresetAppleM4A] autorelease];
    
    exporter.outputFileType = @"com.apple.m4a-audio";
    
    NSString *strName = [NSString stringWithFormat:@"%@.m4a",[mediaItem valueForProperty:MPMediaItemPropertyTitle]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path =  [paths objectAtIndex:0];
    exportFile = [[path stringByAppendingPathComponent:strName] retain];
    
    if ([CommonData isExistFile:exportFile])
    {
        NSURL *path_url = [NSURL fileURLWithPath:exportFile];
        exporter.outputURL = path_url;
        
        NSData *data = [NSData dataWithContentsOfURL:path_url];
        [self uplodingMusic:data musicName:musicName musicArtist:musicArtist musicIntro:musicIntro];
        
    } else
    {
        
        NSURL *path_url = [NSURL fileURLWithPath:exportFile];
        exporter.outputURL = path_url;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            int exportStatus = exporter.status;
            switch (exportStatus)
            {
                case AVAssetExportSessionStatusFailed:
                {
                    // log error to text view
//                    NSError *exportError = exporter.error;
                    break;
                }
                case AVAssetExportSessionStatusCompleted:
                {
                    NSData *data = [NSData dataWithContentsOfURL:path_url];
                    BOOL upload = NO;
                    for (NSDictionary *dic in FileModel.uploadingArr)
                    {
                        if ([nameStr isEqualToString:dic[@"name"]])
                        {
                            upload = YES;
                        }
                    }
                    if (upload == YES)
                    {
                        [self uplodingMusic:data musicName:musicName musicArtist:musicArtist musicIntro:musicIntro];
                    }
                    break;
                }
                case AVAssetExportSessionStatusUnknown:
                {
                    break;
                }
                case AVAssetExportSessionStatusExporting:
                {
                    break;
                }
                case AVAssetExportSessionStatusCancelled:
                {
                    break;
                }
                case AVAssetExportSessionStatusWaiting:
                {
                    break;
                }
                default:
                {
                    break;
                }
            }
        }];
    }
}

- (void)uplodingMusic:(NSData *)data musicName:(NSString *)name musicArtist:(NSString *)artist musicIntro:(NSString *)intro
{
    NSURL *url = [[RequestParams sharedInstance] uplodingMusicAction];
    
    _dataRequest = [[ASIFormDataRequest alloc] initWithURL:url];
    [_dataRequest setRequestMethod:@"POST"];
    [_dataRequest setShouldAttemptPersistentConnection:NO];
    [_dataRequest setUploadProgressDelegate:self];
    [_dataRequest addRequestHeader:@"clienttoken" value:USER_TOKEN_GETOUT];
    [_dataRequest addRequestHeader:@"serverauth" value:USER_AUTH_GETOUT];
    [_dataRequest setPostValue:name forKey:@"musicName"];
    [_dataRequest addData:data withFileName:name andContentType:@"music/m4a" forKey:@"styleType"];
    [_dataRequest setTimeOutSeconds:30.f];
    FileModel.isUploading = YES;
    FileModel.upReceivedSize = @"0";
    _dataRequest.delegate = self;
    [_dataRequest startAsynchronous];
}

#pragma mark - ASIHttpDelegate

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *reqData = [request responseData];
    NSDictionary *dict = [reqData objectFromJSONData];
    if ([dict[@"success"] integerValue] == 1)
    {
        NSNumber *spaceUsed = [NSNumber numberWithLongLong:[dict[@"meta"][@"spaceused"] longLongValue]];
        [SavaData fileSpaceUseAmount:spaceUsed];
        FileModel.isUploading = NO;
        
        [self setUplongdingDataWithLastNameSuccess:nameStr];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadMusicNumber" object:nil];//通知背景音乐界面刷新上传音乐数
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTimerSuccess" object:nil];//通知上传列表界面刷新界面
    } else if ([dict[@"errorcode"] intValue] == 1005)
    {
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
    }else{
        UIAlertView *allert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:dict[@"message"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        allert.tag =100;
        [allert show];
        [allert release];
        
    }
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    FileModel.isUploading = NO;
    [self setUplongdingDataWithLastNameFailed:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadMusicNumber" object:nil];//通知背景音乐界面刷新上传音乐数
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTimerFailed" object:nameStr];
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
        FileModel.upReceivedSize = @"0";
        FileModel.musicNumber = 0;
        [FileModel.arrDownloadList removeAllObjects];
        [FileModel.uploadingArr removeAllObjects];
    }

}

-(void)setUplongdingDataWithLastNameSuccess:(NSString *)name
{
    FileModel.musicNumber --;
//    FileModel.upReceivedSize = @"0";
    NSMutableArray *tempArr = (NSMutableArray *)[[SavaData shareInstance] printDataAry:Uploading_File];
    [tempArr addObject:name];
    [[SavaData shareInstance] savaArray:tempArr KeyString:Uploading_File];
    if (FileModel.arrUplodingList.count == 0)
    {
        [FileModel.uploadingArr removeObjectAtIndex:0];
    }
    else
    {
        FileModel.operation = [FileModel.arrUplodingList objectAtIndex:0];
        [FileModel.operation main];
        [FileModel.uploadingArr removeObjectAtIndex:0];
        [FileModel.arrUplodingList removeObjectAtIndex:0];
    }
    
    [[SavaData shareInstance] savaArray:FileModel.uploadingArr KeyString:Uploading_File];
}

-(void)setProgress:(float)newProgress
{
    FileModel.fileName = nameStr;
    FileModel.upReceivedSize = [NSString stringWithFormat:@"%f",newProgress];
}

-(void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    //File_upData.upFileSize = [NSString stringWithFormat:@"%lld",bytes];
}

-(void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength
{
    FileModel.isUploading = YES;
    
}

- (BOOL)isUploadingFile:(NSString *)name
{
    for (NSString *str in [[SavaData shareInstance] printDataAry:Uploading_File])
    {
        [FileModel.uploadingArr addObject:str];
    }
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==100) {
        FileModel.isUploading = NO;
//        [self setUplongdingDataWithLastNameFailed:nil];
        FileModel.upReceivedSize = @"0";
        FileModel.musicNumber = 0;
        [FileModel.arrDownloadList removeAllObjects];
        [FileModel.uploadingArr removeAllObjects];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadMusicNumber" object:nil];//通知背景音乐界面刷新上传音乐数
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTimerFailed" object:nameStr];
        
    }else{
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];

    }
}

- (void)dealloc
{
    [exportFile release];
    [nameStr release];
    [mediaItem release];
//    if (_dataRequest != nil) {
//        [_dataRequest release];
//        self.dataRequest = nil;
//    }
    [super dealloc];
}

@end
