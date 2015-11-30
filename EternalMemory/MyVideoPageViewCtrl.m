//
//  MyVideoPageViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 13-6-5.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

#import "MyVideoPageViewCtrl.h"
#import "UploadingVideoViewCtrl.h"
#import "DownloadModel.h"
#import "FileModel.h"
#import "CommonData.h"
#import "Utilities.h"
#import "EternalMemoryAppDelegate.h"
#import "MyLifeMainViewController.h"
#import "DownloadViewCtrl.h"
#import "ShowListHeadView.h"
#import "MyHomeViewController.h"
#import "EditListCell.h"
#import "DirectionMPMoviePlayerViewController.h"
#import "GuideView.h"
#import "MyToast.h"
#define FileModel    [FileModel sharedInstance]
#define File_Size    209715200 //200M
#define File_All_Size 419430400 //400M
@implementation AddVideoView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.userInteractionEnabled = YES;
        
        UIImageView *imageViewBg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, self.bounds.size.width - 40, 110)];
        imageViewBg.backgroundColor =[UIColor whiteColor];
        imageViewBg.layer.borderWidth = 1;
        imageViewBg.layer.borderColor =  RGBCOLOR(208, 211, 209).CGColor;
        imageViewBg.layer.cornerRadius = 3;
        imageViewBg.userInteractionEnabled = YES;
        
        
        UIImageView *imageAdd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_table_Addimage"]];
        imageAdd.frame = CGRectMake(10, 15, 83, 78);
        
        UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(140, 40, 100, 30)];
        labText.text = @"上传视频";
        labText.textColor = RGBCOLOR(93.0, 102.0, 113.0);
        labText.backgroundColor = [UIColor whiteColor];
        
        
        //画线
        UIImageView *imageLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-2, self.frame.size.width, 2)];
        imageLine.image = [UIImage imageNamed:@"public_table_line.png"];
        [self addSubview:imageLine];
        [imageLine release];
        
        [imageViewBg addSubview:labText];
        [labText release];
        [imageViewBg addSubview:imageAdd];
        [imageAdd release];
        [self addSubview:imageViewBg];
        
        [imageViewBg release];
    }
    return self;
}

@end

@interface MyVideoPageViewCtrl ()
{
    DirectionMPMoviePlayerViewController *playerViewController;
    NSMutableArray *_arrVideo;
    
    ASIFormDataRequest *requestForm;
    ShowListHeadView *_viewHeader;
    
    UIImageView *_imageLine;
    UIView      *_noVideoView;
    NSInteger selectIndex;
    
    NSInteger downNum;
    BOOL isDelete;
    
    BOOL isTowDel;
    NSInteger indexDown; //判断正在下载视频是否有删除操作
    
    NSInteger indexDelect;  //标记要删除的视频
    
    NSInteger downPlayFile;//判断视频不需要重复下载
    
    //    BOOL isDocPath; //判断本地是否有上传视频路径
}
@end

@implementation MyVideoPageViewCtrl

- (void)dealloc
{
    [_arrVideo removeAllObjects],_arrVideo = nil;
    [playerViewController release];
    [_noVideoView release];
    [_imageLine release];
    [_viewHeader release];
    if (requestForm) {
        [requestForm cancel];
        [requestForm clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    [self removeObserver:self forKeyPath:@"_arrVideo" context:NULL];
    
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginRequestDataslist) name:@"upDataList" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHeadTableView:) name:@"changeVideoList" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[playerViewController moviePlayer]];
        
    }
    return self;
}

- (void)beginRequestDataslist
{
    __block typeof (self) bSelf = self;
    NSURL *url = [[RequestParams sharedInstance] listVideoLockAction];
    requestForm = [[ASIFormDataRequest alloc]initWithURL:url];
    [requestForm setRequestMethod:@"POST"];
    [requestForm setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [requestForm setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [requestForm setTimeOutSeconds:20];
    [requestForm setShouldAttemptPersistentConnection:NO];
    [requestForm setDelegate:self];
    [requestForm startAsynchronous];
    
    requestForm.failedBlock = ^(void)
    {
        [bSelf networkPromptMessage:@"网络连接异常"];
    };
    requestForm.completionBlock = ^(void){
        NSData *data = [requestForm responseData];
        NSDictionary *dic = [data objectFromJSONData];
        NSString *message = [dic objectForKey:@"message"];
        
        if ([[dic objectForKey:@"success"] intValue] == 1)
        {
            _arrVideo = [[dic objectForKey:@"data"] copy];
            
            [bSelf.myTableView reloadData];
            
            //把数据写入文件
            FileModel.getVedioInfo = YES;
            [SavaData writeArrToFile:_arrVideo FileName:Video_File];
            
        } else if ([dic[@"errorcode"] intValue] ==1005)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:AUTO_RELOGIN delegate:bSelf cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1005;
            [alert show];
            [alert release];
        } else if ([dic[@"errorcode"] intValue] ==9000)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:POINT_OUTMES delegate:bSelf cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 9000;
            [alert show];
            [alert release];
        } else
        {
            [bSelf networkPromptMessage:message];
        }
        
    } ;
    
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
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.titleLabel.text = @"电视";
    self.middleBtn.hidden = YES;
    self.rightBtn.frame=CGRectMake(SCREEN_WIDTH - 72, 6, 60, 31);
    if (iOS7) {
        self.rightBtn.frame=CGRectMake(SCREEN_WIDTH - 72, 26, 60, 31);
    }
    [self.rightBtn setTitle:@"选择视频" forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upLoadVedioNumberChanged:) name:@"upLoadVedioNumber" object:nil];
    
    isDelete = NO;
    isTowDel = NO;
    indexDown = 3;
    indexDelect = 0;
    downNum = 0;
    downPlayFile = 100;
    
    [self initWithData];
    [self initWithShowView];

    //请求上传列表
    [self beginRequestDataslist];
    // Do any additional setup after loading the view.
}
- (void)initWithData
{
    _arrVideo = [[NSMutableArray alloc]init];

    NSMutableArray *arrDatas = [SavaData parseArrFromFile:Video_File];
    if (arrDatas.count >0)
    {
        _arrVideo = [arrDatas retain];
    }
    
}
- (void)initWithShowView
{
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    self.myTableView.tableHeaderView = viewHeader;
    [viewHeader release];
    
    //没视频文件的说明View
    CGRect noViewFrame = self.myTableView.frame;
    noViewFrame.origin.y = iOS7?64:44;
    self.myTableView.frame = noViewFrame;//定义表示图视频ios7起始坐标
    _noVideoView = [[UIView alloc] initWithFrame:noViewFrame];
    UIImageView *imageText = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-120)/2, (self.view.bounds.size.height-60)/2 - 70, 120, 17)];
    imageText.image = [UIImage imageNamed:@"video_list_normal_text"];
    [_noVideoView addSubview:imageText];
    [imageText release];
    
    UIImageView *noVideoImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-185)/2, CGRectGetMaxY(imageText.frame)+30, 185, 122)];
    noVideoImage.image = [UIImage imageNamed:@"video_list_normal"];
    [_noVideoView addSubview:noVideoImage];
    [noVideoImage release];
    [self.view addSubview:_noVideoView];
    
    _viewHeader = [[ShowListHeadView alloc] initWithFrame:CGRectMake(0, iOS7 ? 64 : 44, self.view.bounds.size.width, 44)];
    _viewHeader.backgroundColor = RGBCOLOR(67, 72, 78);
    
    UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectUploadingListPage:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [_viewHeader addGestureRecognizer:tapGes];
    [tapGes release];
    
    [self.view addSubview:_viewHeader];
    {
        NSInteger vedioUploadingCount = 0;
        for (NSDictionary * dic in FileModel.uploadingArr)
        {
            if ([dic[@"type"] isEqualToString:@"vedio"])
            {
                vedioUploadingCount++;
            }
        }
        FileModel.videoNumber =vedioUploadingCount;
    }
    if (FileModel.videoNumber != 0 || FileModel.download_videoNum != 0)
    {
        [self changeTableViewSize:YES];
    }else{
        [self changeTableViewSize:NO];
    }
}

-(void)upLoadVedioNumberChanged:(NSNotification *)sender
{
    [self beginRequestDataslist];
    if (FileModel.videoNumber != 0 || FileModel.download_videoNum != 0)
    {
        [self changeTableViewSize:YES];
    }
    else
    {
        [self changeTableViewSize:NO];
    }
    
}

- (void)showHeadTableView:(NSNotification *)info
{
    NSNumber *number = [info object];
    if ([number integerValue] == 1) {
        [self changeTableViewSize:YES];
    } else
    {
        [self changeTableViewSize:NO];
    }
}
- (void)changeTableViewSize:(BOOL)show
{
    __block CGRect tempTab = CGRectMake(0, self.myTableView.frame.origin.y, self.view.bounds.size.width, self.myTableView.bounds.size.height);
    __block typeof(self) bSelf = self;
    //让下载headerView条出现
    if (show) {
        _viewHeader.hidden = NO;
        tempTab.origin.y = CGRectGetMidY(_viewHeader.frame)+20;
        if (iPhone5) {
            tempTab.size.height = iOS7 ? 504 - 44 :504-20-44;
        }else{
            tempTab.size.height = iOS7 ? 436 - 44 :416-44;
        }
        
        
        if (FileModel.download_videoNum != 0 && FileModel.videoNumber == 0) {
            _viewHeader.downLabText.text = [NSString stringWithFormat:@"%d个视频正在下载",FileModel.download_videoNum];
        }else if (FileModel.videoNumber != 0 && FileModel.download_videoNum ==0 )
        {
            _viewHeader.downLabText.text = [NSString stringWithFormat:@"%d个视频正在上传",FileModel.videoNumber];
        }else if (FileModel.download_videoNum != 0 && FileModel.videoNumber != 0 )
        {
            _viewHeader.downLabText.text = [NSString stringWithFormat:@"%d个视频正在上传,%d个视频正在下载",FileModel.videoNumber,FileModel.download_videoNum];
        }
        
    }else{
        _viewHeader.hidden = YES;
        tempTab.origin.y = iOS7 ? 64: 44;
        if (iPhone5) {
            tempTab.size.height = iOS7 ? 504:504-20;
        }else{
            tempTab.size.height = iOS7 ? 436:416;
        }
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         bSelf.myTableView.frame = tempTab;
                     }];
    
}

- (void)didUploadingVideoActionPath:(NSString *)videoPath videoImage:(UIImage *)image videoSize:(long)size        //上传视频页面
{
    
    
    UploadingVideoViewCtrl *uploadingVideo = [UploadingVideoViewCtrl new];
    //
    uploadingVideo.strVideoPath = videoPath;
    uploadingVideo.imageVideo = image;
    uploadingVideo.allSize = size;
    uploadingVideo.isHome = NO;
    [self.navigationController pushViewController:uploadingVideo animated:YES];
    //    [self presentViewController:uploadingVideo animated:YES completion:nil];
    [uploadingVideo release];
}
- (void)selectUploadingListPage:(UITapGestureRecognizer *)tap
{
    DownloadViewCtrl *download = [[DownloadViewCtrl alloc] init];
    [self.navigationController pushViewController:download animated:YES];
    [download release];
}

- (void)rightBtnPressed
{
    if (![Utilities checkNetwork])
    {
        [self networkPromptMessage:@"网络连接异常"];
    }else
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker.navigationBar setBackgroundImage:[UIImage imageNamed:@"top"] forBarMetrics:0];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.navigationBar.translucent = YES;
        imagePicker.navigationBar.barStyle = UIBarStyleBlack;
        imagePicker.mediaTypes =  [[[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil] autorelease];
        [self presentViewController:imagePicker animated:YES completion:nil];
        [imagePicker release];
    }
}
- (long long)allVideoFileSize
{
    long long int size = 0;
    //取出上传成功后的视频总大小
    for (NSDictionary *dic in _arrVideo) {
        size += [dic[@"attachSize"] integerValue];
    }
    //累加正在上传的视频总大小
    for (NSNumber *numSize in FileModel.upVideoSize) {
        size +=[numSize integerValue];
    }
    return size;
}

#pragma mark  UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    UIImage *imageVideo = nil;//取视频图片
    NSString *videoPath = nil;//取视频路径
    videoPath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path];
    NSFileManager *FM = [NSFileManager defaultManager];
    NSDictionary *dic = [FM attributesOfItemAtPath:videoPath error:nil];
    [FileModel.upVideoSize addObject:@([dic[@"NSFileSize"] longValue])];
    
    //判断单个视频不能超过200M，一共不超过400M
    long long allSize = [self allVideoFileSize];//112
    if ([dic[@"NSFileSize"] longValue] <=File_Size) {
        if (allSize > File_All_Size) {
            [MyToast showWithText:@"您上传的视频已超过上传限制400M了,请重新选取":[UIScreen mainScreen].bounds.size.height/2-40];
            [picker dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        NSURL *urlPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@",videoPath]];
        FileModel.vedioName = [videoPath substringFromIndex:75];
        NSMutableArray *tempArr = [[SavaData shareInstance] printDataAry:Uploading_File];
        
        if (tempArr.count != 0)
        {
            for (NSString * nameStr in tempArr)
            {
                if ([FileModel.vedioName isEqualToString:nameStr])
                {
                    [self networkPromptMessage:@"该视频您之前已经上传成功"];
                    [picker dismissViewControllerAnimated:YES completion:nil];
                    return;
                }
            }
        }
        if (FileModel.uploadingArr.count != 0)
        {
            for (NSDictionary *dic in FileModel.uploadingArr)
            {
                if ([FileModel.vedioName isEqualToString:dic[@"name"]])
                {
                    [self networkPromptMessage:@"该视频已经存在于上传列表中"];
                    [picker dismissViewControllerAnimated:YES completion:nil];
                    return;
                }
            }
        }
        
        MPMoviePlayerController *_moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:urlPath];
        
        [_moviePlayerController setShouldAutoplay:NO];
        
        [_moviePlayerController setControlStyle:MPMovieControlStyleNone];
        
        NSTimeInterval startTime = 2;
        imageVideo = [_moviePlayerController thumbnailImageAtTime:(NSTimeInterval)startTime timeOption:MPMovieTimeOptionNearestKeyFrame];
        CGSize size = CGSizeMake(288.f, 512.f);
        UIGraphicsBeginImageContext(size);
        [imageVideo drawInRect:CGRectMake(0, 0, size.width, size.height)];
        
        
        [_moviePlayerController release];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        [self didUploadingVideoActionPath:videoPath videoImage:imageVideo videoSize:[dic[@"NSFileSize"] longValue]];
    }else{
        [self networkPromptMessage:@"上传单个视频不能超过200M"];
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}
//删除视频操作
- (void)didDeleteVideoSheetBut:(NSInteger)index
{
    indexDelect = index;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"删除后,服务器不会保留,是否确定删除!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 110;
    [alert show];
    [alert release];
    
}
- (void) didDeleteVideoAlertView:(NSInteger)index
{
    __block typeof (self) bSelf = self;
   
    NSURL *url = [[RequestParams sharedInstance] didDeleteVideoAction];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:index<_arrVideo.count ? _arrVideo[index][@"blogId"]:@"" forKey:@"blogId"];
    [request setTimeOutSeconds:10];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
    [request setDelegate:self];
    [request setFailedBlock:^(void){
        [bSelf networkPromptMessage:@"网络连接异常"];
    }];
    
    [request setCompletionBlock:^(void){
        NSData *data = [request responseData];
        NSDictionary *dicData = [data objectFromJSONData];
        
        if([dicData[@"success"] integerValue] == 1)
        {
            NSMutableArray *videoAr = [_arrVideo mutableCopy];
            
            [videoAr removeObjectAtIndex:index];
            _arrVideo = videoAr;
            
            [self removeDocVideoPath:index];
            
            NSNumber *spaceUsed = [NSNumber numberWithLongLong:[dicData[@"meta"][@"spaceused"] longLongValue]];
            [SavaData fileSpaceUseAmount:spaceUsed];
            //            NSString *name = _arrVideo[index][@"title"];
            
           
            
            isTowDel = YES;
            //[self willChangeValueForKey:@"_arrVideo"];
            
            //[self didChangeValueForKey:@"_arrVideo"];
            
            [bSelf.myTableView reloadData];
            
            [SavaData writeArrToFile:_arrVideo FileName:Video_File];
            [bSelf networkPromptMessage:dicData[@"message"]];
        }else if ([dicData[@"errorcode"] intValue] ==1005)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:AUTO_RELOGIN delegate:bSelf cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1005;
            [alert show];
            [alert release];
        }else if ([dicData[@"errorcode"] intValue] == 9000)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:POINT_OUTMES delegate:bSelf cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1005;
            [alert show];
            [alert release];
            
        }else
        {
            [bSelf networkPromptMessage:dicData[@"message"]];
        }
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_arrVideo.count>0) {
        tableView.scrollEnabled = YES;
        _noVideoView.hidden = YES;
        if (_arrVideo.count ==1) {
            _imageLine.hidden = YES;
        }else
        {
            _imageLine.hidden = NO;
        }
    }
    else
    {
        tableView.scrollEnabled = NO;
        isDelete = NO;
        _imageLine.hidden = YES;
        _noVideoView.hidden = NO;
    }
    
    return _arrVideo.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    static NSString *CellIdentifier = @"CellIdentifier";
    VideoPageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell){
        cell = [[[VideoPageViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }
    cell.deleteBut.tag = indexPath.row;
//    [cell.deleteBut setTitle:[NSString stringWithFormat:@"%d",indexPath.row] forState:UIControlStateNormal];
//    [cell.deleteBut setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    NSString *strTitle = [_arrVideo[indexPath.row] objectForKey:@"content"];
    
    cell.labText.text = strTitle;
    
    
    NSString *videoNum = [_arrVideo[indexPath.row] objectForKey:@"attachSize"];
    cell.labTextNum.text = [CommonData getFileSizeString:videoNum];
    cell.editing = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{//播放视频
    //    if (!isDelete) {
    selectIndex = indexPath.row;
    if ([self isDocVideoPath:indexPath.row isPlay:YES] == NO) {
        [self beginPlayVideo];
        //播放网络视频，同时去下载
        /*if (downPlayFile !=selectIndex) {
         [self didSelectDownloadingVideo:selectIndex isHint:NO];
         }*/
        
    }
    
}
//判断上视频是否是存在本地，继而无需请求网络
- (BOOL)isDocVideoPath:(NSInteger)index isPlay:(BOOL)play
{
    NSString *strName = index < _arrVideo.count ? _arrVideo[index][@"content"] :@"";
    NSMutableArray *arrPath = [[SavaData shareInstance] printDataAry:@"videoPath"];
    
    if (arrPath.count >0) {
        for (NSDictionary *dic in arrPath) {
            NSString *pathName = dic[@"videoName"];
            NSString *strPath = dic[@"videoPath"];
            if ([pathName isEqualToString:strName]) {
                if (play) {
                    NSURL *rul = [NSURL fileURLWithPath:strPath];
                    [self didplayVideoFileAction:rul];
                }
                return YES;
            }
        }
    }
    return NO;
}
//删除掉本地视频路径缓存
- (void)removeDocVideoPath:(NSInteger)index
{
    NSString *strName = index<_arrVideo.count ? _arrVideo[index][@"content"]:@"";
    NSMutableArray *arrPath = [[SavaData alloc] printDataAry:@"videoPath"];
    
    if (arrPath.count >0) {
        for (int i=0; i<arrPath.count; i++) {
            NSString *pathName = arrPath[i][@"videoName"];
            if ([pathName isEqualToString:strName])
            {
                [arrPath removeObjectAtIndex:i];
            }
        }
        [[SavaData shareInstance]savaArray:arrPath KeyString:@"videoPath" ];
    }
}
- (void)networkPromptMessage:(NSString *)message
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = message;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        [HUD release];
    }];  //    [promptMB setHidden:YES];
    
}
- (void)didSelectDownloadingVideo:(NSInteger)index isHint:(BOOL)isHint
{
    
    indexDown = index;
    if (![Utilities checkNetwork]) {
        [self networkPromptMessage:@"请检查网络"];
        return;
    }
    if([CommonData isExistFile:[CommonData strPathGetTargetFloderTranscodingPath:_arrVideo[index]]])//已经下载过一次该视频
    {
        if (isHint) {
            [self networkPromptMessage:@"已下载过该视频!"];
        }
        return;
    }else if ([self isDocVideoPath:index isPlay:NO] == YES)
    {
        if (isHint) {
            [self networkPromptMessage:@"本地视频,无需下载！"];
        }
        return;
    }else
    {
        if (FileModel.isDownVideo) {
            if (isHint) {
                [self networkPromptMessage:@"正在下载,请稍等"];
            }
            return;
        }else{
            downPlayFile = index;
            downNum ++;
            FileModel.isDownVideo = YES;
            FileModel.download_videoNum ++;
            [self changeTableViewSize:YES];
            //[self networkPromptMessage:@"已开始下载"];
            //下载视频
            [[DownloadModel shareInstance] dicDownloadListAction:_arrVideo[index] downloadType:@"Video" isBeginDown:YES];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==1005 ||alertView.tag == 9000) {
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
        return;
    }else if (alertView.tag == 110)
    {
        if (buttonIndex == 1) {
            if (indexDelect<_arrVideo.count) {
                [self didDeleteVideoAlertView:indexDelect];
            }else{
                [self networkPromptMessage:@"删除视频出错"];
            }
            
        }
    }
    else if (buttonIndex==1) {
        NSString *strPuth = [CommonData getMovVideoPath:_arrVideo[selectIndex]];//取出原视频路径，主要是mov视频
        NSURL *rulPath = [NSURL URLWithString:strPuth];
        [self didplayVideoFileAction:rulPath];
    }
}
- (void)beginPlayVideo
{//播放视频
    
    NSString *strPuth = [CommonData getMovVideoPath:_arrVideo[selectIndex]];//取出原视频路径，主要是mov视频
    if ([strPuth isEqualToString:@""]) {
        [self networkPromptMessage:@"视频正在处理，请稍后观看"];
        return;
    }
    //得到视频路径，主要判断是否已下载，或者是上传视频，从而无需请求网络即可播放
    NSString *path = [CommonData strPathGetTargetFloderTranscodingPath:_arrVideo[selectIndex]];
    if([CommonData isExistFile:path])//如果已下载，播放本地视频
    {
        NSURL *urlPath = [NSURL fileURLWithPath:path];
        [self didplayVideoFileAction:urlPath];
        
    }else{
        //判断网络是否是2G/3G 给提示
        NSString *message = @"当前使用的网络链接类型是WWAN（2G/3G）";
        NSString *strNetwork = [Utilities GetCurrntNet];
        if ([strNetwork isEqualToString:@"没有网络链接"]) {
            [self networkPromptMessage:@"没有网络链接"];
        }
        else if ([strNetwork isEqualToString:message]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续",nil];
            alert.tag = 100;
            [alert show];
            [alert release];
        }else if ([strNetwork isEqualToString:@"1"])
        {
            [self networkPromptMessage:@"视频正在努力加载..."];
            NSURL *rulPath = [NSURL URLWithString:strPuth];
            [self didplayVideoFileAction:rulPath];
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}
//开始播放视频
- (void)didplayVideoFileAction:(NSURL *)tmpUrl
{
    //    playerViewController = [[DirectionMPMoviePlayerViewController alloc] initWithDirectionMPMoviePlayerViewController:tmpUrl];//音频路径
    //    playerViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //    [self presentViewController:playerViewController animated:YES completion:nil];
    //    [playerViewController release];
    
    if (playerViewController.view != nil) {
        [playerViewController.view removeFromSuperview];
        [playerViewController moviePlayer].contentURL = tmpUrl;
    }else
    {
        playerViewController = [[DirectionMPMoviePlayerViewController alloc] initWithContentURL:tmpUrl];//音频路径
    }
    [playerViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];//自动适应屏幕大小；
    playerViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [playerViewController.view setFrame:[UIScreen mainScreen].bounds];
    
    playerViewController.view.transform = CGAffineTransformMakeRotation((M_PI / 2.0));
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    
    [self presentViewController:playerViewController animated:YES completion:nil];
    MPMoviePlayerController *player = [playerViewController moviePlayer];
    [player play];
    
}
//当点击Done按键或者播放完毕时调用此函数
- (void) playVideoFinished:(NSNotification *)theNotification
{
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    }
}
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
////    return YES;
//    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
////    return UIDeviceOrientationIsLandscape(interfaceOrientation);
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    [self performSelector:@selector(fixStatusBar) withObject:nil afterDelay:0];
//}
- (void)fixStatusBar {
    [[UIApplication sharedApplication] setStatusBarOrientation:[self interfaceOrientation] animated:NO];
}
//- (BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
//{
//
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}
@end
