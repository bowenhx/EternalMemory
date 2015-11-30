//
//  DownloadViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 06/08/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "ResumeVedioSendOperation.h"
#import "MusicSendOperation.h"
#import "VedioSendOperation.h"
#import "UploadingDebugging.h"
#import "UploadingListCell.h"
#import "DownloadViewCtrl.h"
#import "DownloadViewCell.h"
#import "DownloadModel.h"
#import "CommonData.h"
#import "Utilities.h"
#import "FileModel.h"
#import "MyToast.h"
//#import "EternalMemoryAppDelegate.h"
#define FileModel  [FileModel sharedInstance]
#define ResumeUploading [ResumeVedioSendOperation shareInstance]

@interface DownloadViewCtrl ()
{
    UIButton *uploadingBut;
    UIButton *downloadBut;
    NSMutableArray *_downloadFileArr;
    NSMutableArray *_uploadingData;
    NSInteger intCellView;
    __block NSInteger uploadIndex;//上传文件的位置
    NSTimer *upTimer;
    UILabel *_labText;
    id _downloadCell;//ios7中的下载进度条不走
    
    float reFlo;
    BOOL isDownStop;
}

//暂停回复按钮得操作
-(void)stopOrReStartUpload:(BOOL)stop Index:(int)index;

//内存空间不足提醒
-(void)spaceIsNotEnough;

//设置退出界面时上传数组的百分比数据
-(void)setUploadingInfoWithProgress:(CGFloat)progress index:(int)index Name:(NSString *)name;

//删除上传的临时文件
-(void)removeTempFileAtIndex:(int)index;
//网络断开后上传文件处理及界面刷新
    -(void)resumeSuspendWhenNetworkNoReachible:(NSNotification *)sender;

@end

@implementation DownloadViewCtrl

-(id)init
{
    self = [super init];
    if (self)
    {
        uploadIndex = -1;
    }
    return self;
}

- (void)dealloc
{
    ResumeUploading.uploadProgress = nil;
    [_downloadFileArr release],_downloadFileArr = nil;
    [_uploadingData removeAllObjects],_uploadingData = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_labText release];
    [super dealloc];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    uploadIndex = -1;
    [[SavaData shareInstance] savaArray:nil KeyString:Uploading_File];
    ResumeUploading.uploadSuccess = ^(int index){
        [[EternalMemoryAppDelegate getAppDelegate] uploadingSuccess:index];
    };
    ResumeUploading.uploadFialed = ^(NSString *identifier, int index)
    {
        [[EternalMemoryAppDelegate getAppDelegate] uploadingFailed:index];
    };
    ResumeUploading.spaceNotEnough = ^()
    {
        [[EternalMemoryAppDelegate getAppDelegate] spaceNotEnough];
    };
    ResumeUploading.unexceptedSituation = ^(NSDictionary *dict)
    {
        [[EternalMemoryAppDelegate getAppDelegate] unexceptedCrash:dict];
    };
    ResumeUploading.showProgress = NO;
}

- (void)didInitViewListTitle
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 36)];
    //    viewTitle.layer.borderColor = RGBCOLOR(214, 214, 214).CGColor;
    viewTitle.backgroundColor = [UIColor clearColor];
    
    uploadingBut = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadingBut.frame = CGRectMake(0, 0, 159, 36);
    [uploadingBut setBackgroundImage:[UIImage imageNamed:@"list_header"] forState:UIControlStateNormal];
    [uploadingBut setBackgroundImage:[UIImage imageNamed:@"list_header_touch"] forState:UIControlStateSelected];
    //uploadingBut.backgroundColor = [UIColor clearColor];
    //    uploadingBut.selected = YES;
    [uploadingBut setTitle:@"上传列表" forState:UIControlStateNormal];
    [uploadingBut.titleLabel setFont:[UIFont fontWithName:@"helvetica" size:16]];
    [uploadingBut setTitleColor:RGBCOLOR(99, 112, 121) forState:UIControlStateNormal];
    [uploadingBut addTarget:self action:@selector(selectListAction:) forControlEvents:UIControlEventTouchUpInside];
    uploadingBut.userInteractionEnabled = NO;
    [viewTitle addSubview:uploadingBut];
    
    downloadBut = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadBut.frame = CGRectMake(161, 0, 320/2, 36);
    [downloadBut setBackgroundImage:[UIImage imageNamed:@"list_header"] forState:UIControlStateNormal];
    [downloadBut setBackgroundImage:[UIImage imageNamed:@"list_header_touch"] forState:UIControlStateSelected];
    //downloadBut.backgroundColor = [UIColor clearColor];
    [downloadBut setTitle:@"下载列表" forState:UIControlStateNormal];
    [downloadBut.titleLabel setFont:[UIFont fontWithName:@"helvetica" size:16]];
    [downloadBut setTitleColor:RGBCOLOR(99, 112, 121) forState:UIControlStateNormal];
    [downloadBut addTarget:self action:@selector(selectListAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewTitle addSubview:downloadBut];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(159, 0, 2, 35.5)];
    image.image = [UIImage imageNamed:@"list_mid_line"];
    [viewTitle addSubview:image];
    [image release];
    self.myTableView.tableHeaderView = viewTitle;
    [viewTitle release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"上传与下载";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    reFlo = 0.0f;
    isDownStop = NO;
    
    [self didInitViewListTitle];
    [self initUpFileDatas];
    
    _labText = [[UILabel alloc] initWithFrame:CGRectMake(25, (self.view.bounds.size.height-25)/2, self.view.bounds.size.width-50, 25)];
    _labText.text = @"暂无上传数据哦！";
    _labText.textAlignment = NSTextAlignmentCenter;
    _labText.backgroundColor = [UIColor clearColor];
    _labText.font = [UIFont systemFontOfSize:16];
    _labText.textColor = RGBCOLOR(93.0, 102.0, 113.0);
    [self.view addSubview:_labText];
    [Utilities setExtraCellLineHidden:self.myTableView];
    
    __block typeof(self) this = self;
    [DownloadModel shareInstance].didDownloadCellProgressBlock = ^(long long con)
    {
        [this downloadFileProgress:con];
    };
    ResumeUploading.uploadProgress = ^(CGFloat progress,int index,NSString *identifier){
        [this uploadProgress:progress UploadIndex:index UploadFileName:identifier];
    };
    ResumeUploading.uploadSuccess = ^(int index){
        [this uploadSuccess:index];
    };
    ResumeUploading.uploadFialed = ^(NSString *identifier, int index){

        [this uploadFaield:index FailedIdentifier:identifier];
    };
    ResumeUploading.spaceNotEnough = ^(){
        [this spaceIsNotEnough];
    };
    ResumeUploading.unexceptedSituation = ^(NSDictionary *dic){
        [this deleteDataWhenUnexceptedSituation:dic];
    };
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resumeSuspendWhenNetworkNoReachible:) name:@"resumeSuspendWhenNetworkNoReachible" object:nil];
//    [uploadFailedNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFialedBackGroup:) name:@"uploadFailedNotification" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    ResumeUploading.showProgress = YES;
    [self.myTableView reloadData];
}
    
//网络断开后上传文件处理及界面刷新
-(void)resumeSuspendWhenNetworkNoReachible:(NSNotification *)sender
{
    [self.myTableView reloadData];
}
-(void)uploadFialedBackGroup:(NSNotification *)sender
{
    [self.myTableView reloadData];
}
//意外情况发生直接删除数据（暂时处理方法）
-(void)deleteDataWhenUnexceptedSituation:(NSDictionary *)dic
{
    if ([dic[@"3077"] length]!= 0)
    {
        [MyToast showWithText:dic[@"3077"] :200];
    }
    else
    {
        [MyToast showWithText:@"网络问题，该文件无法正常上传" :200];
    }
    [UploadingDebugging goOnUploadingAfterSuccessOrFailed];
    [self.myTableView reloadData];
}

//内存空间不足提醒
-(void)spaceIsNotEnough
{
    [self.myTableView reloadData];
    [MyToast showWithText:@"内存空间不够" :200];
    [UploadingDebugging goOnUploadingAfterSuccessOrFailed];
}

//动态显示上传进度
-(void)uploadProgress:(CGFloat)progress UploadIndex:(int)index UploadFileName:(NSString *)identifier
{
//    if (uploadIndex == -1)
//    {
        index = [UploadingDebugging uploadingIndex:identifier];
//    }
    uploadIndex = index;
    UploadingListCell *cell = (UploadingListCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell.progress setProgress:progress];
    cell.labStopDown.text = @"正在上传...";
    cell.labNum.text = [NSString stringWithFormat:@"%d%%",(int)(progress * 100)];
}

//设置退出界面时上传数组的百分比数据
-(void)setUploadingInfoWithProgress:(CGFloat)progress index:(int)index Name:(NSString *)name
{
    index = [UploadingDebugging uploadingIndex:name];
    NSMutableDictionary *replaceDict = [NSMutableDictionary dictionaryWithDictionary:FileModel.uploadingArr[index]];
    [replaceDict setObject:[NSNumber numberWithFloat:progress] forKey:@"progress"];
    [FileModel.uploadingArr replaceObjectAtIndex:index withObject:replaceDict];
    [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];
}
//文件上传成功
-(void)uploadSuccess:(int)index
{
    [MyToast showWithText:@"文件上传成功" :200];
    [self didDelectUploadingFileAction:index];
}

//文件上传失败
-(void)uploadFaield:(int)index FailedIdentifier:(NSString *)identifier
{
    [ResumeUploading stopUploading];
    if ([Utilities checkNetwork])
    {
        NSMutableDictionary *replaceDict = [NSMutableDictionary dictionaryWithDictionary:FileModel.uploadingArr[index]];
        [replaceDict setObject:identifier forKey:@"identifier"];
        [replaceDict setObject:[NSNumber numberWithInt:4] forKey:@"state"];
        [replaceDict setObject:@"上传失败，请重新上传" forKey:@"stateDescription"];
        [FileModel.uploadingArr removeObjectAtIndex:index];
        [FileModel.uploadingArr addObject:replaceDict];
        [UploadingDebugging goOnUploadingAfterSuccessOrFailed];
        [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];
        [self.myTableView reloadData];
    }
    else
    {
        [MyToast showWithText:@"网络异常，请检查网络" :200];
    }
}

//暂停回复按钮的操作
-(void)stopOrReStartUpload:(BOOL)stop Index:(int)index
{
    uploadIndex = index;
    BOOL uploading = NO;
    int  uploadingIndex = -1;
    NSInteger count = FileModel.uploadingArr.count;
    for ( int i = 0 ; i < count; i++)
    {
        if ([FileModel.uploadingArr[i][@"state"] intValue] == 1)
        {
            uploading = YES;
            uploadingIndex = i;
            break;
        }
    }
    if (uploading == YES)
    {
        if (uploadingIndex == index)
        {
            [ResumeUploading suspendUploadingWithFileIndex:uploadIndex];
            
            NSInteger count = FileModel.uploadingArr.count;
            if (count != 0)
            {
                [UploadingDebugging goOnUploadingAfterSuccessOrFailed];
            }
            else
            {
                ResumeUploading.isUploading = NO;
            }
        }
        else
        {
            [UploadingDebugging setWaitingDataStateAtIndex:index];
        }
    }
    else if (uploading == NO)
    {
        [UploadingDebugging resumeUploading:index];
    }
    [self.myTableView reloadData];
}

- (void)initUpFileDatas
{
    if (FileModel.isDownVideo || FileModel.isBackDownVideo) {
        intCellView =101;
        downloadBut.selected = YES;
        uploadingBut.selected = NO;
    }else
    {
        intCellView =100;
        downloadBut.selected = NO;
        uploadingBut.selected = YES;
    }
    [self didDownloadFile];
}
- (void)didDownloadFile
{
    _downloadFileArr = [[NSMutableArray alloc] init];
    if (FileModel.isDownVideo || FileModel.isBackDownVideo) {
        
        if (FileModel.downloadArr.count > 0) {
            NSDictionary *dic = FileModel.downloadArr[0];
            NSString *url = dic[@"attachURL"];
            NSString *fileType = [[url componentsSeparatedByString:@"."] lastObject];
            NSString *fileName = [NSString stringWithFormat:@"%@.%@",dic[@"content"],fileType];
            [_downloadFileArr insertObject:fileName atIndex:0];
        }
    }
}

- (void)uploadingFileProgress:(long long)pro
{
    for (id obj in self.myTableView.subviews) {
        if ([obj isKindOfClass:[UploadingListCell class]]) {
            UploadingListCell *cell = obj;
            if (cell.progress.tag ==0) {
                [cell.progress setProgress:pro];
            }
        }
    }
}
- (void)downloadFileProgress:(long long)pro
{
    DownloadViewCell *cell = (DownloadViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    float flo = [CommonData getProgress:[FileModel.downFileSize floatValue] currentSize:[FileModel.downReceivedSize floatValue]];
    
    [cell.progress setProgress:flo];
    float fl = cell.progress.progress *100;
    cell.fileNum.text = [NSString stringWithFormat:@"%d%%",(int) fl];
    if (cell.progress.progress > 0.97f) {
        FileModel.isDownVideo = NO;
        cell.downloadBut.enabled = NO;
    }
}
- (void)selectListAction:(UIButton *)but
{
    if (but==uploadingBut)
    {
        uploadingBut.userInteractionEnabled = NO;
        downloadBut.userInteractionEnabled = YES;
        intCellView =100;
        [self.myTableView reloadData];
        
        uploadingBut.selected = YES;
        downloadBut.selected = NO;
    }
    else if(but == downloadBut)
    {
        uploadingBut.userInteractionEnabled = YES;
        downloadBut.userInteractionEnabled = NO;
        intCellView =101;
        [self.myTableView reloadData];
        uploadingBut.selected = NO;
        downloadBut.selected = YES;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (intCellView ==101 &&_downloadFileArr.count>0) {
        
        _labText.hidden = YES;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }else if (intCellView ==100 && FileModel.uploadingArr.count>0){
        
        _labText.hidden = YES;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }else
    {
        if (intCellView ==101){
            _labText.text = @"暂无下载数据！";
        }else
        {
            _labText.text = @"暂无上传数据！";
        }
        _labText.hidden = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return intCellView ==101 ?  _downloadFileArr.count : FileModel.uploadingArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    static NSString *CellUploading = @"CellUploading";
    UITableViewCell *cell = nil;
    if (intCellView ==100)
    {
        UploadingListCell *uploding=(UploadingListCell *)[tableView dequeueReusableCellWithIdentifier:CellUploading];
        if(uploding==nil)
        {
            NSArray *objlist=[[NSBundle mainBundle] loadNibNamed:@"UploadingListCell" owner:self options:nil];
            for(id obj in objlist)
            {
                if([obj isKindOfClass:[UploadingListCell class]])
                {
                    uploding=(UploadingListCell *)obj;
                }
            }
        }
        uploding.selectionStyle = UITableViewCellSelectionStyleNone;
        uploding.delectBut.tag = indexPath.row;
        uploding.selected = NO;
        uploding.progress.tag = indexPath.row;
        NSArray *arrType = nil;
        
        if ([FileModel.uploadingArr[indexPath.row] isKindOfClass:[NSDictionary class]])
        {
            if ([FileModel.uploadingArr[indexPath.row][@"size"] longLongValue] != 0)
            {
                float flo = ([FileModel.uploadingArr[indexPath.row][@"receiveSize"] floatValue] / [FileModel.uploadingArr[indexPath.row][@"size"] longLongValue]);
                [uploding.progress setProgress:flo];
                uploding.labNum.text = [NSString stringWithFormat:@"%.0f%%",flo * 100];
            }
            else
            {
                [uploding.progress setProgress:0];
                uploding.labNum.text = @"0%";
            }
//            arrType = [FileModel.uploadingArr[indexPath.row][@"name"] componentsSeparatedByString:@"."];
            NSString *name = FileModel.uploadingArr[indexPath.row][@"name"];
            if ([name hasSuffix:@"m4a"])
            {
                uploding.labTitle.text = FileModel.uploadingArr[indexPath.row][@"name"];
            }
            else
            {
                uploding.labTitle.text = [NSString stringWithFormat:@"%@.mov",FileModel.uploadingArr[indexPath.row][@"content"]];
            }
        }
        else
        {
//            arrType = [FileModel.uploadingArr[indexPath.row] componentsSeparatedByString:@"."];
            uploding.labTitle.text = FileModel.uploadingArr[indexPath.row];
            [uploding.progress setProgress:1];
            uploding.labNum.text = @"100%";
        }
        __block typeof (self) this=self;
        if ([FileModel.uploadingArr[indexPath.row][@"state"] intValue] == 2 ||[FileModel.uploadingArr[indexPath.row][@"state"] intValue] == 4)
        {
            [uploding.resumeButton setImage:[UIImage imageNamed:@"list_stop.png"] forState:UIControlStateNormal];
        }
        else
        {
            [uploding.resumeButton setImage:[UIImage imageNamed:@"list_uploding.png"] forState:UIControlStateNormal];
        }
        uploding.labStopDown.hidden = NO;
        uploding.labStopDown.text = FileModel.uploadingArr[indexPath.row][@"stateDescription"];
        uploding.resumeButton.tag = indexPath.row;
        uploding.StopOrResume = ^(BOOL stop,int index){
            [this stopOrReStartUpload:stop Index:index];
        };
        uploding.removeUpLoadFile = ^(int index){
            [this removeTempFileAtIndex:index];
            [this didDelectUploadingFileAction:index];
        };
        return uploding;
    }
    else
    {
        DownloadViewCell *downCell=(DownloadViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(downCell==nil)
        {
            NSArray *objlist=[[NSBundle mainBundle] loadNibNamed:@"DownloadViewCell" owner:self options:nil];
            for(id obj in objlist)
            {
                if([obj isKindOfClass:[DownloadViewCell class]])
                {
                    downCell=(DownloadViewCell *)obj;
                }
            }
        }
        _downloadCell = [downCell retain];
        
        downCell.selectionStyle = UITableViewCellSelectionStyleNone;
        downCell.downloadBut.tag = indexPath.row;
        downCell.delectBut.tag = indexPath.row;
        downCell.progress.tag = indexPath.row;
        
        [downCell.downloadBut addTarget:self action:@selector(fileDownloadStop:) forControlEvents:UIControlEventTouchUpInside];
        [downCell.delectBut addTarget:self action:@selector(didFileDelectAction:) forControlEvents:UIControlEventTouchUpInside];
        float flo = [CommonData getProgress:[FileModel.downFileSize floatValue] currentSize:[FileModel.downReceivedSize floatValue]];
        [downCell.progress setProgress:flo];
        float fl = downCell.progress.progress *100;
        downCell.fileNum.text = [NSString stringWithFormat:@"%d%%",(int) fl];
        downCell.fileName.text = _downloadFileArr[indexPath.row];
        
        if (FileModel.isBackDownVideo == NO)
        {
            downCell.downloadBut.enabled = YES;
            [downCell.downloadBut setImage:[UIImage imageNamed:@"list_download"] forState:UIControlStateNormal];
            
        }else {
            [downCell.downloadBut setImage:[UIImage imageNamed:@"list_stop"] forState:UIControlStateNormal];
        }
        return downCell;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (BOOL)fileDataType:(NSDictionary *)dic
{
    NSString *musicPath = [NSString stringWithFormat:@"%@",dic[@"musicName"]];
    // NSString *videoPath = dic[@"attachURL"];
    
    if ([musicPath isEqualToString:@"(null)"] || [musicPath isEqualToString:@""]) {
        return YES;
    }else
    {
        return NO;
    }
}
- (void)fileUploadingStop:(UIButton *)but
{
    if (but.selected) {
        but.selected = NO;
        [but setImage:[UIImage imageNamed:@"list_uploding"] forState:UIControlStateNormal];
    }else{
        but.selected = YES;
        [but setImage:[UIImage imageNamed:@"list_stop"] forState:UIControlStateSelected];
    }
}
//删除上传的临时文件
-(void)removeTempFileAtIndex:(int)index
{
    uploadIndex = -1;
    NSString *tmpPath = FileModel.uploadingArr[index][@"path"];
   [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
}


- (void)didDelectUploadingFileAction:(int)index
{
    [UploadingDebugging uploadSuccessOrDeleteFileNotification:index];
    if ([FileModel.uploadingArr[index][@"state"] intValue] == 1)
    {
        [ResumeUploading stopUploading];
        [FileModel.uploadingArr removeObjectAtIndex:index];
        [UploadingDebugging goOnUploadingAfterSuccessOrFailed];
    }
    else
    {
        [FileModel.uploadingArr removeObjectAtIndex:index];
    }
    
    NSInteger count = FileModel.uploadingArr.count;
    if (count != 0)
    {
        for (int i = 0; i < count; i++)
        {
            if ([FileModel.uploadingArr[i][@"name"] isEqualToString:ResumeUploading.name])
            {
                ResumeUploading.fileIndex = i;
                break;
            }
        }
    }
    else
    {
        [ResumeUploading stopUploading];
    }
    [self.myTableView reloadData];
    [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];
}
//下载过程中的临时文件
- (void)delectDocumentTempDirectoryFile
{
    NSString *fileName = [NSString stringWithFormat:@"%@.mov",FileModel.downloadArr[0][@"content"]] ;
    NSString *targetPath =  [[CommonData getMovieTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    
    if ([CommonData isExistFile:targetPath]) {
        [fileManager removeItemAtPath:targetPath error:&error];
        if (!error) {
        }
    }
    
}
//删除视频下载本地缓存路径
-(void)delectDocumentDirectoryFile
{
    NSString *fileName = [NSString stringWithFormat:@"%@",FileModel.downloadArr[0][@"content"]] ;
    
    NSString *targetPath = [[CommonData getMovieTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",fileName]];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    
    if ([CommonData isExistFile:targetPath]) {
        [fileManager removeItemAtPath:targetPath error:&error];
        if (!error) {
        }
    }
}

- (void)didFileDelectAction:(UIButton *)but
{
    [[[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"删除后,本地不会保留,是否确定删除!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] autorelease] show];
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (FileModel.isDownVideo) {
            ASIHTTPRequest *request = FileModel.arrDownloadList[0];
            [request cancel];
            [request clearDelegatesAndCancel];
            [request release],request = nil;
            [self delectDocumentTempDirectoryFile];
            [FileModel.arrDownloadList removeAllObjects];
        }
        else
        {
            [self delectDocumentDirectoryFile];
        }
        isDownStop = NO;
        //    [FileModel.arrDownloadList removeAllObjects];
        FileModel.isDownVideo = NO;
        FileModel.download_videoNum = 0;
        FileModel.downReceivedSize = @"0";
        FileModel.downFileSize = @"0";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeVideoList" object:[NSNumber numberWithBool:NO]];
        
        
        NSMutableArray *remoArr = [_downloadFileArr mutableCopy];
        
        [remoArr removeObjectAtIndex:0];
        _downloadFileArr = remoArr;
        [self.myTableView reloadData];
    }
}
- (void)fileDownloadStop:(UIButton *)but
{
    if (FileModel.isDownVideo) {
        for (ASIHTTPRequest *request in FileModel.arrDownloadList) {
            [request cancel];
            [request clearDelegatesAndCancel];
        }
        isDownStop = YES;
        FileModel.isDownVideo = NO;
        FileModel.isBackDownVideo = YES;                    //  暂停后会退到上一级页面处理
        [self delectDocumentTempDirectoryFile];
        //        FileModel.downReceivedSize = @"0";
        //        FileModel.downFileSize = @"0";
        
    }else
    {
        isDownStop = NO;
        FileModel.isDownVideo = YES;
        FileModel.isBackDownVideo = NO;
        NSDictionary *downDic = FileModel.downloadArr[0];
        
        [[DownloadModel shareInstance] dicDownloadListAction:downDic downloadType:@"Video" isBeginDown:YES];
        
    }
    
    if (FileModel.isDownVideo)
    {
        [but setImage:[UIImage imageNamed:@"list_download"] forState:UIControlStateNormal];
    }else{
        [but setImage:[UIImage imageNamed:@"list_stop"] forState:UIControlStateNormal];
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
