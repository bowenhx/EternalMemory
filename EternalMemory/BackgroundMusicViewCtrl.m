//
//  BackgroundMusicViewCtrl.m
//  EternalMemory
//
//  Created by Guibing Li on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.
//
#import "MyToast.h"
#import "FileModel.h"
#import "CommonData.h"
#import "ShowListHeadView.h"
#import "DownloadViewCtrl.h"
#import "MusicSendOperation.h"
#import "UploadingDebugging.h"
#import "BackgroundMusicViewCtrl.h"
#import "EternalMemoryAppDelegate.h"
#import "ResumeVedioSendOperation.h"
#import <CoreGraphics/CoreGraphics.h>


#define FileModel  [FileModel sharedInstance]
#define ResumeUploading [ResumeVedioSendOperation shareInstance]

@interface BackgroundMusicViewCtrl ()
{
    BOOL isDelete;
    NSMutableArray *_arrMusicDatas;
    __block AVAudioPlayer *_player;
    
    
    BOOL isPlay;
    __block UIActivityIndicatorView *activity;
    UIImageView *noVideoImage;
    ShowListHeadView *_viewHeader;
    
    dispatch_queue_t queue;//开启网络加载数据线程
    __block NSData          *_workData;//网络加载的音乐数据流
    NSString        *_playingName;//用于判断是播放哪首歌
    NSMutableArray  *_seletedArray;//判断这首网络歌曲是否之前已经选过
    
    NSInteger downNum;
    __block NSInteger playTag;
    NSInteger upMusicNum;
    ASIFormDataRequest *reqList;
    NSInteger      comeInTime;
    BOOL isNetplay;
    
    NSInteger playNum;
    __block NSInteger gcdPlayNum;
    BOOL isTouchOpenGCD;
}

//- (void)setExtraCellLineHidden: (UITableView *)tableView;
-(void)didplayMusicFileAction:(NSDictionary *)dic MusicFileName:(NSString *)fileName;//网络读取音乐，成功后写到本地
//文件上传成功
-(void)uploadSuccess:(int)index;

@end


static BOOL cancelGCD;//判断此界面是否还在来判断是否播放音乐

@implementation BackgroundMusicViewCtrl
@synthesize player = _player;

- (void)dealloc
{
    
    FileModel.isOpenGcd = YES;
    [_arrMusicDatas release],_arrMusicDatas = nil;
    [_seletedArray release];
    _seletedArray = nil;
    
    if (reqList) {
        [reqList cancel];
        [reqList clearDelegatesAndCancel];
    }
    
    if (isNetplay) {
        if (_player != nil)
        {
            [_player stop];
            [_player release];
            if (_workData)
            {
                [_workData release];
            }
        }
    }
    if (queue)
    {
        dispatch_release(queue);
        
    }
    
    [noVideoImage release];
    [_viewHeader release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.myTableViewStype = UITableViewStylePlain;
        comeInTime = COME_FIRST;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //判断是否显示出下载headView条，并改变其坐标
    CGRect tableFrame = self.myTableView.frame;
    if (!_viewHeader.hidden) {
        tableFrame = CGRectMake(0,CGRectGetMaxY(_viewHeader.frame), self.view.frame.size.width, self.myTableView.frame.size.height);
        self.myTableView.frame = tableFrame;
    }else{
        tableFrame.origin.y = iOS7 ? 64: 44;
        self.myTableView.frame = tableFrame;
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (comeInTime == COME_FIRST)
    {
        [self didBackgroundMusicList];
    }
    comeInTime = COME_SECOND;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    FileModel.isOpenGcd = YES;
    cancelGCD = YES;
}
- (void)tableViewHeaderView
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(15, 10, self.view.bounds.size.width-20,49)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame = CGRectMake(15, 15, 22, 22);
    [but setImage:[UIImage imageNamed:@"public_addBut"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(touchViewAddMusic) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:but];
    
    UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.frame.size.width-35-10, 30)];
    labText.text = @"选择音乐";
    labText.userInteractionEnabled = YES;
    labText.font = [UIFont systemFontOfSize:16];
    labText.backgroundColor = [UIColor clearColor];
    [view addSubview:labText];
    [labText release];
    
    UITapGestureRecognizer *tapLab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchViewAddMusic)];
    tapLab.numberOfTapsRequired = 1;
    tapLab.numberOfTouchesRequired = 1;
    [labText addGestureRecognizer:tapLab];
    [tapLab release];
    
    UIImageView *imageLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, view.frame.size.height-2, 320, 2)];
    imageLine.image = [UIImage imageNamed:@"public_table_line"];
    [view addSubview:imageLine];
    [imageLine release];
    
    self.myTableView.tableHeaderView = view;
}
- (void)initListHeadView
{
    _viewHeader = [[ShowListHeadView alloc] initWithFrame:CGRectMake(0, iOS7 ? 64 : 44, self.view.bounds.size.width, 44)];
    _viewHeader.backgroundColor = RGBCOLOR(67, 72, 78);
    
    UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectUploadingListMusicPage:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [_viewHeader addGestureRecognizer:tapGes];
    [tapGes release];
    
    [self.view addSubview:_viewHeader];
    
    
    noVideoImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-90)/2, (self.view.bounds.size.height-50)/2, 90, 90)];
    noVideoImage.image = [UIImage imageNamed:@"no_music_icon"];
    
    UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(-80, 100, 280, 30)];
    labText.text = @"还没有音乐，选取音乐赶快上传吧！";
    labText.textColor = RGBCOLOR(93.0, 102.0, 113.0);
    labText.font = [UIFont systemFontOfSize:16];
    labText.backgroundColor = [UIColor clearColor];
    [noVideoImage addSubview:labText];
    [labText release];
    [self.view addSubview:noVideoImage];
    
    if (FileModel.musicNumber != 0 ) {
        [self changeTableViewSize:YES];
    }else
    {
        [self changeTableViewSize:NO];
    }
}
- (void)initData
{
    _seletedArray = [[NSMutableArray alloc] init];
    NSMutableArray *arrData = [SavaData parseArrFromFile:Music_File];
    if(arrData.count>0)
    {
        _arrMusicDatas = [[NSMutableArray alloc] initWithArray:arrData];
    }else{
        _arrMusicDatas = [[NSMutableArray alloc] initWithCapacity:0];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"音乐";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = NO;
    self.backBtn.hidden = NO;
    [self.rightBtn setTitle:@"删除" forState:UIControlStateNormal];
    FileModel.isOpenGcd = NO;
    isDelete = NO;
    isPlay = NO;
    isTouchOpenGCD = NO;
    cancelGCD = NO;
    isNetplay = NO;
    playTag = 1000000;
    downNum = 0;
    playNum = 0;
    gcdPlayNum = 0;
    upMusicNum = 0;
    
    [self tableViewHeaderView];
    
    [self initListHeadView];
    [Utilities setExtraCellLineHidden:self.myTableView];
    [self initData];
    
    //请求背景音乐列表
    
    
    playerMusic = [MPMusicPlayerController iPodMusicPlayer];
    
    pickerMusic = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    [pickerMusic setDelegate:self];
    pickerMusic.prompt = @"选择音乐开始上传";
    pickerMusic.allowsPickingMultipleItems = NO;//是否允许一次选择多个
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upLoadMusicNumberChanged:) name:@"upLoadMusicNumber" object:nil];
}


#pragma mark - NSNotificationCenter

-(void)upLoadMusicNumberChanged:(NSNotification *)sender
{
    [self didBackgroundMusicList];
    if (FileModel.musicNumber != 0)
    {
        _viewHeader.downLabText.text = [NSString stringWithFormat:@"%d个音乐正在上传",FileModel.musicNumber];
    }
    else
    {
        __block CGRect tempTab = self.myTableView.frame;
        _viewHeader.hidden = YES;
        tempTab.origin.y = iOS7 ? 64: 44 ;
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.myTableView.frame = tempTab;
                         }];
    }
    
}

- (void)changeTableViewSize:(BOOL)show
{
    __block CGRect tempTab = CGRectMake(0, self.myTableView.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-44);
    __block typeof(self) bself = self;
    if (show) {
        _viewHeader.hidden = NO;
        tempTab.origin.y = CGRectGetMaxY(_viewHeader.frame)+20;
        if (FileModel.musicNumber != 0 )//&& FileModel.download_musicNum ==0 )
        {
            _viewHeader.downLabText.text = [NSString stringWithFormat:@"%d个音乐正在上传",FileModel.musicNumber];
        }
    }else{
        _viewHeader.hidden = YES;
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         bself.myTableView.frame = tempTab;
                     }];
    
}
- (void)selectUploadingListMusicPage:(UITapGestureRecognizer *)tap
{
    DownloadViewCtrl *download = [[DownloadViewCtrl alloc] init];
    [self.navigationController pushViewController:download animated:YES];
    [download release];
}
- (void)didBackgroundMusicList
{
    NSURL *url = [[RequestParams sharedInstance] didMusicManageAction];
    
    reqList = [[ASIFormDataRequest alloc] initWithURL:url];
    [reqList setRequestMethod:@"POST"];
    [reqList setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [reqList setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [reqList setPostValue:@"list" forKey:@"operation"];
    [reqList setTimeOutSeconds:10];
    [reqList setDelegate:self];
    [reqList setUserInfo:[NSDictionary dictionaryWithObject:@"100" forKey:@"tag"]];
    [reqList setShouldAttemptPersistentConnection:NO];
    [reqList startAsynchronous];
}
#pragma mark conveniences
NSString* myDocumentsDirectory() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

void myDeleteFile (NSString *path){
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *deleteErr = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&deleteErr];
        if (deleteErr) {
        }
    }
}

#pragma mark MPMediaPickerControllerDelegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    MPMediaItemCollection *mediaItem = [[mediaItemCollection items] objectAtIndex:0];
    NSString *musicName = [NSString stringWithFormat:@"%@.m4a",[mediaItem valueForProperty:MPMediaItemPropertyTitle]];
    
    NSMutableArray *netArr = [SavaData parseArrFromFile:Music_File];
    if (netArr.count != 0)
    {
        for (NSDictionary *dic in netArr)
        {
            if ([musicName hasPrefix:dic[@"musicName"]])
            {
                [self networkPromptMessage:@"该音乐您之前已经上传到网络中"];
                return;
            }
        }
    }
    
    NSMutableArray *tempArr = [[SavaData shareInstance] printDataAry:Uploading_File];
    
    if (tempArr.count != 0)
    {
        for (NSString * nameStr in tempArr)
        {
            if ([musicName isEqualToString:nameStr])
            {
                [self networkPromptMessage:@"该音乐您之前已经上传成功"];
                return;
            }
        }
    }
    if (FileModel.uploadingArr.count != 0)
    {
        for (NSDictionary *dic in FileModel.uploadingArr)
        {
            if ([musicName isEqualToString:dic[@"name"]])
            {
                [self networkPromptMessage:@"该音乐已经存在于上传列表中"];
                return;
            }
        }
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if([mediaItemCollection count] < 1){
        return;
    }
    if ([FileModel allMusicNumber] == 6)
    {
        [self networkPromptMessage:@"音乐最多上传6首"];
        return;
    }
    FileModel.musicNumber ++;
    [self changeTableViewSize:YES];
    
    NSString *strName = [NSString stringWithFormat:@"%@.m4a",[mediaItem valueForProperty:MPMediaItemPropertyTitle]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path =  [paths objectAtIndex:0];
    NSString *exportFile = [path stringByAppendingPathComponent:strName];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:musicName,@"name",mediaItem,@"mediaItem",[NSNumber numberWithBool:YES],@"first",exportFile,@"path",[NSNumber numberWithInt:0],@"state",[NSNumber numberWithFloat:0],@"progress",@"等待上传...",@"stateDescription",@"music",@"type",[NSNumber numberWithBool:NO],@"completeConvet",[NSNumber numberWithLongLong:0],@"receiveSize", nil];
    [FileModel.uploadingArr addObject:infoDic];

    BOOL uploading = NO;
    for (NSDictionary *dic in FileModel.uploadingArr)
    {
        if ([dic[@"state"] intValue] == 1)
        {
            uploading = YES;
            break;
        }
    }
    if (uploading == YES)
    {
        
    }
    else
    {
        [infoDic setObject:@"解码上传中..." forKey:@"stateDescription"];
        [infoDic setObject:[NSNumber numberWithInt:1] forKey:@"state"];
        [FileModel.uploadingArr replaceObjectAtIndex:(FileModel.uploadingArr.count - 1) withObject:infoDic];
        [ResumeUploading startOrResumeUploadingWithFileIndex:(FileModel.uploadingArr.count - 1)];
        
        ResumeUploading.uploadSuccess = ^(int index){
            [[EternalMemoryAppDelegate getAppDelegate] uploadingSuccess:index];
        };
        ResumeUploading.uploadFialed = ^(NSString *identifier, int index)
        {
            [[EternalMemoryAppDelegate getAppDelegate] uploadingFailed:index];
        };
        ResumeUploading.spaceNotEnough = ^()
        {
            [[EternalMemoryAppDelegate getAppDelegate] spaceIsNotEnough];
        };
        ResumeUploading.unexceptedSituation = ^(NSDictionary *dic){
        };

    }
    [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];
}

-(void)uploadSuccess:(int)index
{
    [ResumeUploading stopUploading];
    if ([FileModel.uploadingArr[index][@"type"] isEqualToString:@"music"])
    {
        FileModel.musicNumber --;
        if (FileModel.musicNumber != 0)
        {
            _viewHeader.downLabText.text = [NSString stringWithFormat:@"%d个音乐正在上传",FileModel.musicNumber];
        }
        else
        {
            __block CGRect tempTab = self.myTableView.frame;
            _viewHeader.hidden = YES;
            tempTab.origin.y = iOS7 ? 64: 44;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.myTableView.frame = tempTab;
                             }];
        }
        
    }
    [FileModel.uploadingArr removeObjectAtIndex:index];
    
    NSInteger count = FileModel.uploadingArr.count;
    if (count != 0)
    {
        for (int i = 0; i < count; i ++)
        {
            NSDictionary *dic = FileModel.uploadingArr[i];
            if ([dic[@"state"] intValue] == 0 || [dic[@"state"] intValue] == 4)
            {
                [ResumeUploading startOrResumeUploadingWithFileIndex:i];
                break;
            }
        }
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *reqData = [request responseData];
    NSDictionary *dict = [reqData objectFromJSONData];
    
    //请求音乐列表
    NSInteger requestTag = [request.userInfo[@"tag"] integerValue];
    if (requestTag ==100) {
        reqList = nil;
        if([dict[@"success"] integerValue] == 1)
        {
            _arrMusicDatas = [dict[@"data"] retain];
            //[self setExtraCellLineHidden:self.myTableView];
            //音乐列表写入文件
            [SavaData writeArrToFile:_arrMusicDatas FileName:Music_File];
            [self.myTableView reloadData];
            
        } else if ([dict[@"errorcode"] intValue] == 1005)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        } else if ([dict[@"errorcode"] intValue] == 9000)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else
        {
            [self networkPromptMessage:@"服务器出错"];
        }
        
    }
    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if ([request.userInfo[@"tag"] integerValue] == 100)
    {
        reqList = nil;
    }
    [self networkPromptMessage:@"网络连接异常"];
    
}
- (void)isUploadingFile:(NSString *)name
{
    for (NSString *str in [[SavaData shareInstance] printDataAry:Uploading_File])
    {
        if (![str isEqualToString:name]) {
            [FileModel.uploadingArr addObject:str];
        }
    }
    [[SavaData shareInstance] savaArray:FileModel.uploadingArr KeyString:Uploading_File];
}
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBtnPressed
{
    isDelete = !isDelete;
    if(isDelete)
    {
        [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    } else
    {
        [self.rightBtn setTitle:@"删除" forState:UIControlStateNormal];
    }
    isPlay = NO;
    if (_player != nil) {
        [_player stop];
    }
    activity.hidden = YES;
    [activity stopAnimating];
    FileModel.isOpenGcd = YES;
    //[self setExtraCellLineHidden:self.myTableView];
    [self.myTableView reloadData];
    
}
- (void)didDeleteActionSheetBut:(NSInteger)index
{
    NSString *name = _arrMusicDatas[index][@"musicName"];
    NSURL *url = [[RequestParams sharedInstance] didMusicManageAction];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:@"delete" forKey:@"operation"];
    [request setPostValue:_arrMusicDatas[index][@"mId"] forKey:@"mId"];
    [request setTimeOutSeconds:10];
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
    
    [request setFailedBlock:^(void){
        [self networkPromptMessage:@"网络连接异常"];
    }];
    
    [request setCompletionBlock:^(void){
        NSData *data = [request responseData];
        NSDictionary *dicData = [data objectFromJSONData];
        
        if([dicData[@"success"] integerValue] == 1)
        {
            
            NSMutableArray *tempArr = [[SavaData shareInstance] printDataAry:Uploading_File];
            [[SavaData shareInstance] savaArray:tempArr KeyString:Uploading_File];
            [self networkPromptMessage:dicData[@"message"]];
            NSNumber *spaceUsed = [NSNumber numberWithLongLong:[dicData[@"meta"][@"spaceused"] longLongValue]];
            [SavaData fileSpaceUseAmount:spaceUsed];
            NSMutableArray *deleteArr = [_arrMusicDatas mutableCopy];
            [deleteArr removeObjectAtIndex:index];
            _arrMusicDatas = deleteArr;
            //[self setExtraCellLineHidden:self.myTableView];
            [self.myTableView reloadData];
            
            //音乐列表写入文件
            [SavaData writeArrToFile:_arrMusicDatas FileName:Music_File];
            [self deldectFilePath:name];
        } else if ([dicData[@"errorcode"] intValue] == 1005)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else if ([dicData[@"errorcode"] intValue] == 9000)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else
        {
            //[self networkPromptMessage:@"服务器出错"];
        }
    }];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag ==100) {
        if (buttonIndex == 1) {
            NSDictionary *dic = _arrMusicDatas[playNum];
            NSString *musicName = [NSString stringWithFormat:@"%@.m4a",dic[@"musicName"]];
            NSString *exportFile = [myDocumentsDirectory() stringByAppendingPathComponent:musicName];
            _playingName = [[NSString stringWithFormat:@"%@",exportFile] mutableCopy];
            [self didShowActivityIndicatorView:playNum];
            [self didplayMusicFileAction:dic MusicFileName:exportFile];
        }
    }else{
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
    }
    
}
- (void)deldectFilePath:(NSString *)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *filePath = [myDocumentsDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",name]];//[[CommonData getTargetFloderPath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",name]];
    
    if ([CommonData isExistFile:filePath]) {
        [fileManager removeItemAtPath:filePath error:&error];
        if (!error) {
        }
    }
}
#pragma mark---
#pragma mark----updateMusic---get

- (void)touchViewAddMusic
{
    
    if (![Utilities checkNetwork])
    {
        [self networkPromptMessage:@"网络连接异常"];
    }else
    {
        if (reqList != nil)
        {
            [MyToast showWithText:@"音乐列表正在获取中，请等待" :200];
            return;
        }
        else
        {
            if ((FileModel.musicNumber + _arrMusicDatas.count) >= 6)
            {
                [self networkPromptMessage:@"您已经上传了6首歌曲"];
            }
            else
            {
                [self presentViewController:pickerMusic animated:YES completion:nil];
            }
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle==UITableViewCellEditingStyleDelete) {
 	}
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_arrMusicDatas.count>0) {
        tableView.scrollEnabled = YES;
        self.rightBtn.hidden = NO;
        noVideoImage.hidden = YES;
    }else
    {
        tableView.scrollEnabled = NO;
        self.rightBtn.hidden = YES;
        noVideoImage.hidden = NO;
        isDelete = NO;
    }
    
    return _arrMusicDatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    MusicViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell){
        cell = [[[MusicViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
       
    }
    cell.deleteBut.tag = indexPath.row;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"public_table_line"]];
    cell.playImage.tag = indexPath.row;
    cell.musicName.text = _arrMusicDatas[indexPath.row][@"musicName"];
    
    //音乐大小
    NSString *sizeNum = [NSString stringWithFormat:@"%@",_arrMusicDatas[indexPath.row][@"attachSize"]];
    //音乐播放时长
    //NSString *playTim = [NSString stringWithFormat:@"%@",_arrMusicDatas[indexPath.row][@"duration"]];
    
    float flo = [[CommonData getFileSizeString:sizeNum] floatValue];
    
    cell.playTime.text = [NSString stringWithFormat:@"%.2fM",flo];
    if (isDelete) {
        cell.deleteBut.hidden = NO;
    }else
    {
        cell.deleteBut.hidden = YES;
    }
    
    if (playTag == indexPath.row) {
        if (!isPlay) {
            [cell.playImage setImage:[UIImage imageNamed:@"play_but"]];
            
        }else
        {
            [cell.playImage setImage:[UIImage imageNamed:@"stop_but"]];//play_but
        }
    }else
    {
        [cell.playImage setImage:[UIImage imageNamed:@"play_but"]];
    }
    
    return cell;
}
- (void)didShowActivityIndicatorView:(NSInteger)index
{
    if (activity == nil) {
        activity = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    }
    activity.hidden = NO;
    activity.frame = CGRectMake(self.view.bounds.size.width - 35, 60+ index * 50 , 20, 20);//
    [activity startAnimating];
    [self.myTableView addSubview:activity];
    
}
- (BOOL)didPlayMusicNum:(NSInteger)index
{
    //判断是否是上传本地音乐.路径是存在沙河文件.m4a
    NSDictionary *dic = _arrMusicDatas[index];
    NSString *musicName = [NSString stringWithFormat:@"%@.m4a",dic[@"musicName"]];
    NSString *exportFile = [myDocumentsDirectory() stringByAppendingPathComponent:musicName];
    _playingName = [[NSString stringWithFormat:@"%@",exportFile] mutableCopy];
    if ([CommonData isExistFile:exportFile]) {
        return YES;
    }else
    {
        return NO;
    }
    
}
- (BOOL)didDownloadingMusic:(NSInteger)index
{
    //判断是否是已下载音乐
    NSDictionary *dic = _arrMusicDatas[index];
    NSString *fileType = [[dic[@"fullURL"] componentsSeparatedByString:@"."] lastObject];
    NSString *musicName = dic[@"musicName"];
    NSString *musicPath = [Utilities dataPath:[NSString stringWithFormat:@"%@.%@",musicName,fileType] FileType:@"Music" UserID:USERID];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:musicPath isDirectory:NO])
    {
        NSURL *url = [NSURL fileURLWithPath:musicPath];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [self didplayMusicLocalityFileData:data];//开始播放
        return YES;
    }else {
        return NO;
    }
}
- (void)isSelectPlay
{
    if (!isPlay)
    {
        [_player play];
    }
    else
    {
        [_player stop];
        cancelGCD = YES;
    }
    isPlay = !isPlay;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    playNum = indexPath.row;
    cancelGCD = NO;
    if (!isDelete) {
        NSDictionary *dic = _arrMusicDatas[indexPath.row];
        if (![_player play])
        {
            if (playTag == indexPath.row) {
                [self isSelectPlay];
            }else{
                isPlay = YES;
                [_player stop];
                
                //判断音乐是否本地存在
                if ([self didPlayMusicNum:indexPath.row])
                {
                    NSURL *url = [NSURL fileURLWithPath:_playingName];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    [self didplayMusicLocalityFileData:data];
                }else if ([self didDownloadingMusic:indexPath.row])
                {
                    playTag = indexPath.row;
                    [self.myTableView reloadData];
                    return;
                }else
                {
                    BOOL alreadyHave = NO;
                    if (_seletedArray.count != 0)
                    {
                        for (NSString *exitName in _seletedArray)
                        {
                            if ([exitName isEqualToString:_playingName])
                            {
                                alreadyHave = YES;
                                break;
                            }
                        }
                    }
                    if (alreadyHave == YES)
                    {
                        [self networkPromptMessage:@"您选择的这首歌正在努力加载中"];
                    }else
                    {   //判断网络，播放网络音乐
                        if ([self didForHaveNetWork]) {
                            //                            if (isTouchOpenGCD == NO) {
                            [self networkPromptMessage:@"正在努力加载,请稍等..."];
                            gcdPlayNum = indexPath.row;
                            [_seletedArray addObject:_playingName];
                            [self didShowActivityIndicatorView:indexPath.row];
                            [self didplayMusicFileAction:dic MusicFileName:_playingName];
                            isTouchOpenGCD = YES;
                            //                            }
                        }else{
                            return;
                        }
                    }
                }
            }
        }
        else
        {
            //如果点的同一首歌，这里控制播放和暂停
            if (playTag == indexPath.row) {
                [self isSelectPlay];
            }else{
                isPlay = YES;
                [_player stop];
                
                //判断音乐是否本地存在
                if ([self didPlayMusicNum:indexPath.row]) {
                    NSURL *url = [NSURL fileURLWithPath:_playingName];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    [self didplayMusicLocalityFileData:data];
                }else if ([self didDownloadingMusic:indexPath.row])
                {
                    playTag = indexPath.row;
                    [self.myTableView reloadData];
                    return;
                }
                else{
                    if (queue)
                    {
                        dispatch_release(queue);
                        [_player stop];
                        [_player release];
                        _player = nil;
                        
                    }
                    //判断网络，播放网络音乐
                    if ([self didForHaveNetWork]) {
                        //                        if (isTouchOpenGCD == NO) {
                        [self networkPromptMessage:@"正在努力加载,请稍等..."];
                        gcdPlayNum = indexPath.row;
                        [self didShowActivityIndicatorView:indexPath.row];
                        [self didplayMusicFileAction:dic MusicFileName:_playingName];
                        //                        }
                    }else{
                        return;
                    }
                    
                }
            }
        }
        playTag = indexPath.row;
        [self.myTableView reloadData];
    }else
    {
        [self networkPromptMessage:@"编辑状态,不可播放"];
    }
    
    
}
- (BOOL)didForHaveNetWork
{
    //判断网络是否是2G/3G 给提示
    NSString *message = @"当前使用的网络链接类型是WWAN（2G/3G）";
    //    __block NSString *strNetwork;
    //    __block typeof (self) bSelf = self;
    //    __block BOOL isYES;
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *strNetwork = [Utilities GetCurrntNet];
    if ([strNetwork isEqualToString:@"没有网络链接"]) {
        [self networkPromptMessage:@"没有网络链接"];
        return NO;
    }
    else if ([strNetwork isEqualToString:message]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续",nil];
        alert.tag = 100;
        [alert show];
        [alert release];
        return NO;
    }else if ([strNetwork isEqualToString:@"1"])
    {
        return YES;
    }
    //    });
    
    return NO;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}
//这是播放本地上传过的音乐--->前提是之前已经转过码
- (void)didplayMusicLocalityFileData:(NSData *)data
{
    [activity setHidden:YES];
    [activity stopAnimating];
    //    cancelGCD = YES;
    NSError *error;
    //        _playingName = [musicPath mutableCopy];
    if (_player != nil) {
        [_player release];
    }
    _player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    isNetplay = YES;
    //    isTouchOpenGCD = NO;
    if (!_player) {
        return ;
    }
    
    [_player play];
    
}
//播放网络音乐
- (void)didplayMusicFileAction:(NSDictionary *)dic MusicFileName:(NSString *)fileName
{
    {
        isNetplay = NO;
        NSString *tmpUrl = dic[@"fullURL"];
        
        __block typeof(self) bSelf = self;
        
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(queue, ^{
            if (_workData != nil)
            {
                _workData = nil;
            }
            //在线播放音乐
            NSURL *workUrl = [NSURL URLWithString:tmpUrl];
            _workData = [[NSData dataWithContentsOfURL:workUrl] retain];
            
            if (FileModel.isOpenGcd == NO) {
                [bSelf didplayMusicLocalityFileData:_workData];
                
                playTag = gcdPlayNum;
                [bSelf.myTableView reloadData];
            }
            
            if (_workData.length != 0)
            {
                NSString *savePath = [Utilities dataPath:[[fileName componentsSeparatedByString:@"/"] lastObject] FileType:@"Music" UserID:USERID];

                [SavaData writeMusicDataToFile:_workData FileName:savePath];
                
            }
        });
        
    }
    
}
-(void)backBtnPressed {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

