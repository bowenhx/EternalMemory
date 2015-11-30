//
//  FileModel.m
//  EternalMemory
//
//  Created by Guibing on 06/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SavaData.h"
#import "FileModel.h"
#import "MusicSendOperation.h"
#import "VedioSendOperation.h"
#define FileModel_list [FileModel sharedInstance]
@implementation FileModel
@synthesize downFileSize;
@synthesize downReceivedSize;
@synthesize upReceivedSize;
@synthesize upFileSize;
@synthesize upload_musicNum;
@synthesize download_musicNum;
@synthesize upload_videoNum;
@synthesize download_videoNum;
@synthesize upVideo_Num;
@synthesize arrDownloadList = _arrDownloadList;
@synthesize arrUplodingList = _arrUplodingList;
@synthesize fileName = _fileName;
@synthesize videoNumber,musicNumber,notificationSend;
@synthesize vedioName = _vedioName;
@synthesize videoPathArr = _videoPathArr;

static FileModel* _sharedInstance = nil;


+ (FileModel*)sharedInstance {
    if (!_sharedInstance) {
        _sharedInstance = [[FileModel alloc] init];
    }
    return _sharedInstance;
}

-(id)init {
    self = [super init];
    if (self){
        _isDownMusic = NO;
        _isUpMusic = NO;
        _isFistReceived = NO;
        _isDownVideo = NO;
        _isUpVideo = NO;
        _isDelectFile = NO;
        _isOpenGcd = NO;
        _isBackDownVideo = NO;
        
        upload_musicNum = 0;
        download_musicNum = 0;
        upload_videoNum = 0;
        download_videoNum = 0;
        upVideo_Num = 0;

        
        _arrDownloadList = [NSMutableArray  new];
        _downloadArr = [NSMutableArray new];
        _uploadingArr = [NSMutableArray new];
        _arrUplodingList = [NSMutableArray new];
        _upVideoSize = [NSMutableArray new];
//        _newMedia = [[MPMediaItemCollection alloc] initWithItems:nil];
       
        _videoPathArr = [NSMutableArray new];
        _styleNameArr = [NSMutableArray new];
        _downStyleIDArr = [NSMutableArray new];
        _downStyleArr = [[NSMutableArray alloc] init];
        _downLoadBtn = [NSMutableArray new];
        _styleOperation = [NSMutableArray new];
        _dicUserInfo = [[NSMutableDictionary alloc] init];
        
        _fileName = [NSString new];
        _downStyleName = [NSString new];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStopValueMusic) name:@"STOPMUSIC" object:nil];
        
//        _vedioName = [NSString new];
    }
    
    return self;
}

//- (void)didStopValueMusic
//{
//    if (_isOpenGcd) {
//        for (AVAudioPlayer *audioPlay in _audioPlayArr) {
//            [audioPlay release];
//            NSLog(@"FilModel     relase ======================");
//        }
//        [_audioPlayArr removeAllObjects];
//    }
//}
//存储所有的音频个数（包括已经上传的和未成功上传的）
-(NSInteger)allMusicNumber
{
    NSMutableArray *tempArr = [[SavaData shareInstance] printDataAry:Uploading_File];
    NSInteger number = 0;
    if (tempArr.count != 0)
    {
        for (NSDictionary *dicName in tempArr)
        {
            if ([dicName isKindOfClass:[NSDictionary class]])
            {
                NSString *nameStr = dicName[@"name"];
                if ([nameStr hasSuffix:@"mp3"]||[nameStr hasPrefix:@"m4a"])
                {
                    number ++;
                }
            }
        }
    }
    return self.musicNumber + number;
}

//存储所有的视频个数（包括已经上传的和未成功上传的）
-(NSInteger)allVideoNumber
{
    NSMutableArray *tempArr = [[SavaData shareInstance] printDataAry:Uploading_File];
    NSInteger number = 0;
    if (tempArr.count != 0)
    {
        for (NSString *nameStr in tempArr)
        {
            if ([nameStr hasSuffix:@"mov"])
            {
                number ++;
            }
        }
    }
    NSMutableArray *exitVideoArr = [SavaData parseArrFromFile:Video_File];
    return exitVideoArr.count + number;
}

- (void)dealloc
{
    [_arrDownloadList release],_arrDownloadList = nil;
    [_downloadArr release],_downloadArr = nil;
    [_uploadingArr release],_uploadingArr = nil;
    [_arrUplodingList release],_uploadingArr = nil;
    [_vedioName release];_vedioName = nil;
    [_videoPathArr release],_videoPathArr = nil;
    [_styleNameArr release],_styleNameArr = nil;
    [_downStyleIDArr release],_downStyleIDArr = nil;
    [_downLoadBtn release],_downLoadBtn = nil;
    [_styleOperation release],_styleOperation = nil;
    [_upVideoSize release],_upVideoSize = nil;
    [_downStyleArr release],_downStyleArr = nil;
    [_dicUserInfo release],_dicUserInfo = nil;
    [_fileName release];
    [_downStyleName release];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (void)cancleRequestDelegate
{
//    for (ASIHTTPRequest *request in FileModel_list.arrUplodingList) {
//        [request cancel];
//        [request clearDelegatesAndCancel];
//    }
    for (ASIHTTPRequest *request in FileModel_list.arrDownloadList) {
        [request cancel];
        [request clearDelegatesAndCancel];
    }
    
//    [FileModel_list.arrUplodingList removeAllObjects];
    [FileModel_list.arrDownloadList removeAllObjects];
//    [FileModel_list.uploadingArr removeAllObjects];
    [FileModel_list.downloadArr removeAllObjects];
    [FileModel_list.upVideoSize removeAllObjects];
    FileModel_list.upReceivedSize = @"0";
    FileModel_list.downReceivedSize = @"0";
    FileModel_list.upload_musicNum = 0;
    FileModel_list.upload_videoNum = 0;
    FileModel_list.download_musicNum = 0;
    FileModel_list.download_videoNum = 0;
    FileModel_list.isUpMusic = NO;
    FileModel_list.isDownMusic = NO;
    FileModel_list.isUpVideo = NO;
    FileModel_list.isDownVideo = NO;
    
}
-(NSOperationQueue *)getSendingQueue{
	if (sendingQueue==nil) {
		sendingQueue=[[NSOperationQueue alloc] init];
		[sendingQueue setMaxConcurrentOperationCount:2];
	}
	return sendingQueue;
}

@end
