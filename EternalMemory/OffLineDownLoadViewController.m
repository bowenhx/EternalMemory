//
//  OffLineDownLoadViewController.m
//  EternalMemory
//
//  Created by xiaoxiao on 12/6/13.
//  Copyright (c) 2013 sun. All rights reserved.
//

#import "OffLineDownLoadViewController.h"
#import "AssociatedDownLoadController.h"
#import "FailedOfflineDownLoad.h"
#import "OffLineDownLoadCell.h"
#import "OfflineDownLoad.h"
#import "DDProgressView.h"
#import "MyFamilySQL.h"
#import "MyToast.h"
@interface OffLineDownLoadViewController ()
{
    __block DDProgressView  *progressView;
    __block UILabel         *warningNameLabel;
    __block UILabel         *percentageLabel;
    UITableView             *failedTableView;
    UIImageView             *downloadBgView;
    UIView                  *bgView;//失败列表背景图
    
    //失败列表批处理试图
    UIImageView             *failedBgView;
    UIButton                *allReloadButton;
    UIButton                *allCancelButton;
    UILabel                 *showLabel;
    CGFloat                  bgOriginY;//失败列表起始位置设置（originY）
    
    //重新下载失败列表需要的数据
    __block NSInteger        downIndex;
    __block NSInteger        showNuber;//失败下载列表在不同大小屏幕上显示的个数问题
    long long int            totalBytes;
    OffLineDownLoadCell     *downLoadCell;
}
//设置失败列表批处理试图
-(void)initWarningView;
-(void)initFailedOperatorControls;
-(void)removeFailedListOjbect:(NSInteger)index;
-(void)reloadFailedListObject:(NSInteger)index;

//设置失败列表的显示问题
-(void)showFailedList;



//自动启动正在下载的失败列表的数据
-(void)startFailedListWithLoading;
//自动下载成功后启动的操作
-(void)setOfflineDownloadSuccess;
////设置模块名
//-(void)setName:(NSString *)name Model:(int)modelIndex;
////设置进度
//-(void)setPorgress:(CGFloat)progress;



//dic键值中waiting的数值含义是 ： 0表示重新下载  1表示等待中  2表示重新下载完成  4表示重新下载中

-(void)configureAlreadyDownloadInfoWithSuccess:(BOOL)success dataIndex:(int)index;
@end

#define GO_BACK_TAG         1000
#define CANCEL_TAG          2000
#define ALL_CANCLE_TAG      3000
#define ALL_RELOAD_TAG      4000
#define FAILEDLOADING_TAG   5000   //移除失败列表中正在加载的数据
#define DOWN_SUCCESS_TAG    6000   //下载成功有网、无网跳转提示
#define LOGIN_OTHER         7000

#define failedDownLoad  [FailedOfflineDownLoad shareInstance]
#define offLine         [OfflineDownLoad shareOfflineDownload]
@implementation OffLineDownLoadViewController
@synthesize cancelButton = _cancelButton;
- (void)dealloc
{
    [super dealloc];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [EternalMemoryAppDelegate getAppDelegate].enterDownload = NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    UIView *whiteBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 265)];
    whiteBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteBgView];
    [whiteBgView release];
    [self initWarningView];
    warningNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44 + 140, 320, 20)];
    warningNameLabel.text = [NSString stringWithFormat:@"共有7项，正在下载第%d项(%@)",offLine.downModelNum,offLine.styleName];
    warningNameLabel.textColor = [UIColor grayColor];
    warningNameLabel.backgroundColor = [UIColor clearColor];
    warningNameLabel.textAlignment = NSTextAlignmentCenter;
    warningNameLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.view addSubview:warningNameLabel];
    [warningNameLabel release];
    
    downloadBgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 44 + 170, 304, 34)];
    downloadBgView.image = [UIImage imageNamed:@"offline_down_bg@2x"];
    downloadBgView.userInteractionEnabled = YES;
    progressView = [[DDProgressView alloc] initWithFrame:CGRectMake(10, 6, 170, 10)];
    [progressView setProgress:offLine.percentage];
    [progressView setOuterColor: [UIColor clearColor]];
    [progressView setEmptyColor:[UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:1.0f]];
    [progressView setInnerColor: [UIColor colorWithRed:33.0f/255.0f green:121.0f/255.0f blue:208.0f/255.0f alpha:1.0f]];
    [downloadBgView addSubview:progressView];
    [progressView release];
    
    percentageLabel = [[UILabel alloc] initWithFrame:CGRectMake(181, 7, 40, 20)];
    percentageLabel.textAlignment = NSTextAlignmentCenter;
    percentageLabel.backgroundColor = [UIColor clearColor];
    percentageLabel.font = [UIFont systemFontOfSize:12.0f];
    percentageLabel.textColor = [UIColor grayColor];
    percentageLabel.text = [NSString stringWithFormat:@"%.0f%%",(offLine.percentage*100)];;
    [downloadBgView addSubview:percentageLabel];
    [percentageLabel release];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.frame = CGRectMake(220, 0, 80, 34);
    [_cancelButton setTitle:@"取消下载" forState:UIControlStateNormal];
    if (!(iOS7))
    {
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    else
    {
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelOfflineDownLoad:) forControlEvents:UIControlEventTouchUpInside];
    [downloadBgView addSubview:_cancelButton];
    [self.view addSubview:downloadBgView];
    [downloadBgView release];
    
    failedTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    failedTableView.delegate = self;
    failedTableView.dataSource = self;
    failedTableView.layer.borderWidth = 0.7f;
    failedTableView.layer.borderColor = [UIColor colorWithRed:207.0f/255.0f green:209.0f/255.0f blue:211.0f/255.0f alpha:1.0f].CGColor;
    failedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    bgView = [[UIView alloc] initWithFrame:CGRectZero];
    [bgView addSubview:failedTableView];
    [failedTableView release];
    [failedBgView release];
    [self.view addSubview:bgView];
    [bgView release];
    
}
-(void)initWarningView
{
    UIView *showBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 320, 70)];
    showBgView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake(30, 5, 60, 42)];
    imageView.image = [UIImage imageNamed:@"yuncai@2x"];
    [showBgView addSubview:imageView];
    [imageView release];
    
    UILabel *downLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 210, 20)];
    downLabel.backgroundColor = [UIColor clearColor];
    downLabel.textColor = [UIColor colorWithRed:52.0f/255.0f green:130.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
    downLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
    downLabel.text = @"正在下载所有的信息";
    [showBgView addSubview:downLabel];
    [downLabel release];
    
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 200, 15)];
    warningLabel.backgroundColor = [UIColor clearColor];
    warningLabel.textColor = [UIColor colorWithRed:108.0f/255.0f green:108.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
    warningLabel.font = [UIFont systemFontOfSize:11.0f];
    warningLabel.text = @"所有内容下载到本地后观看";
    [showBgView addSubview:warningLabel];
    [warningLabel release];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 15)];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = [UIColor colorWithRed:108.0f/255.0f green:108.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
    contentLabel.text = @"(文献、家谱、相册、家园风格、音频、录音、视频)";
    contentLabel.font = [UIFont systemFontOfSize:12.0f];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    [showBgView addSubview:contentLabel];
    [contentLabel release];
    [self.view addSubview:showBgView];
    [showBgView release];
    
    UIImageView *separateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 265, 320, 10)];
    separateImageView.image = [UIImage imageNamed:@"offline_separator_bg@2x"];
    [self.view addSubview:separateImageView];
    [separateImageView release];
}

-(void)initFailedOperatorControls
{
    failedBgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 34 +270, 300, 60)];
    failedBgView.image = [UIImage imageNamed:@"offline_failed_bg@2x.png"];
    failedBgView.userInteractionEnabled = YES;
    
    bgOriginY = failedBgView.frame.origin.y + failedBgView.frame.size.height - 3;
    
    showLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 130, 20)];
    showLabel.backgroundColor = [UIColor clearColor];
    showLabel.font = [UIFont systemFontOfSize:15.0f];
    showLabel.text = @"以下是下载失败";
    [failedBgView addSubview:showLabel];
    [showLabel release];
    
    allReloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    allReloadButton.frame = CGRectMake(155, 15, 60, 30);
    [allReloadButton setTitle:@"全部下载" forState:UIControlStateNormal];
    [allReloadButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [allReloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [allReloadButton setBackgroundImage:[UIImage imageNamed:@"offline_but_@2x"] forState:UIControlStateNormal];
    [allReloadButton addTarget:self action:@selector(allReload:) forControlEvents:UIControlEventTouchUpInside];
    [failedBgView addSubview:allReloadButton];
    
    allCancelButton= [UIButton buttonWithType:UIButtonTypeCustom];
    allCancelButton.frame = CGRectMake(230, 15, 60, 30);
    [allCancelButton setTitle:@"全部忽略" forState:UIControlStateNormal];
    [allCancelButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [allCancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [allCancelButton setBackgroundImage:[UIImage imageNamed:@"offline_but_@2x"] forState:UIControlStateNormal];
    [allCancelButton addTarget:self action:@selector(allCancel:) forControlEvents:UIControlEventTouchUpInside];
    [failedBgView addSubview:allCancelButton];
    
    [self.view addSubview:failedBgView];
    [failedBgView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text  = @"离线下载";
    self.rightBtn.hidden  = YES;
    self.middleBtn.hidden = YES;
    downIndex = failedDownLoad.downloadIndex;
    showNuber = (iPhone5) ?4:2;
    [EternalMemoryAppDelegate getAppDelegate].enterDownload = YES;
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    __block typeof (self) bself=self;

    failedDownLoad.didDownloadCellProgressBlock = ^(CGFloat progress){
        [bself downloadFileProgress:progress];
    };
    failedDownLoad.didDownLoadFinishedSuccess = ^(BOOL success){
        [bself configureAlreadyDownloadInfoWithSuccess:success dataIndex:failedDownLoad.downloadIndex];
        [bself startFailedListDownload];
    };
    warningNameLabel.text = [NSString stringWithFormat:@"共有7项，正在下载第%d项(%@)",offLine.downModelNum,offLine.styleName];
    if (offLine.downloadFinished == NO)
    {
        [offLine startOfflineDownLoad];
    }
    else if (offLine.downloadFinished == YES && failedDownLoad.downloadFinished == NO)
    {
        _cancelButton.userInteractionEnabled = NO;
        progressView.progress = 1.0f;
        percentageLabel.text = @"100%";
        warningNameLabel.text = @"离线下载完成";
        [self showFailedList];
        [self startFailedListWithLoading];
    }
    else if (offLine.downloadFinished == YES && failedDownLoad.downloadFinished == YES)
    {
        [progressView setProgress:1.0f];
        percentageLabel.text = @"100%";
        warningNameLabel.text = @"离线下载完成";
//        [MyToast showWithText:@"您的文件已经下载成功" :200];
        [self startFailedListDownload];
    }
    offLine.downloadFinish = ^{
        [bself setOfflineDownloadSuccess];
    };
    offLine.loginOtherPlace = ^{
        UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:bself cancelButtonTitle:nil otherButtonTitles:ALERT_OK, nil];
        alter.tag = LOGIN_OTHER;
        [alter show];
        [alter release];
    };
    offLine.downloadProgress = ^(CGFloat progress){
//        [bself setPorgress:progress];
        CGFloat showProgress = progress >= 1 ? 1.0f:progress;
        [progressView setProgress:showProgress];
        percentageLabel.text = [NSString stringWithFormat:@"%.0f%%",(showProgress*100)];
    };
    
    offLine.downloadName = ^(NSString *name,int model)
    {
//        [bself setName:name Model:model];
        warningNameLabel.text = [NSString stringWithFormat:@"共有7项，正在下载第%d项(%@)",model,name];
    };
    offLine.downloadFailed = ^(){
        [bself showFailedList];
    };
    failedDownLoad.didDownLoadFailedFiles = ^(){
        [bself offlineDownLoadSuccess];
    };
}
////设置进度
//-(void)setPorgress:(CGFloat)progress
//{
//   
//}
////设置模块名
//-(void)setName:(NSString *)name Model:(int)modelIndex
//{
//}

- (void)downloadFileProgress:(CGFloat)pro
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:downIndex inSection:0];
    downLoadCell = (OffLineDownLoadCell *)[failedTableView cellForRowAtIndexPath:indexPath];
    [downLoadCell.progressView setProgress:pro];
    downLoadCell.percentageLabel.text = [NSString stringWithFormat:@"%.0f%%",(pro * 100)];
}

-(void)configureAlreadyDownloadInfoWithSuccess:(BOOL)success dataIndex:(int)index
{
    if (success == YES)
    {
        [offLine.failedArr removeObjectAtIndex:index];
        failedDownLoad.receiveBytes = 0;
        if (offLine.failedArr.count >= showNuber)
        {
            [failedTableView reloadData];
        }
        else if (offLine.failedArr.count > 0)
        {
            bgView.frame = CGRectMake(12, bgOriginY, 296,offLine.failedArr.count * 50);
            failedTableView.frame = CGRectMake(0, 0, 296, offLine.failedArr.count * 50);
            [failedTableView reloadData];
        }
        if (offLine.failedArr.count == 0)
        {
            bgView.hidden = YES;
            failedTableView.hidden = YES;
            failedBgView.hidden = YES;
        }
    }
    else
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:offLine.failedArr[index]];
        [dic setValue:[NSNumber numberWithInt:3] forKey:@"waiting"];
        [offLine.failedArr removeObjectAtIndex:index];
        [offLine.failedArr addObject:dic];
        [failedTableView reloadData];
    }
}

#pragma mark - 设置失败列表显示问题
-(void)showFailedList
{
    NSInteger failedCount = offLine.failedArr.count;
    if (failedBgView == nil)
    {
        [self initFailedOperatorControls];
    }
    else
    {
        bgView.hidden = NO;
        failedBgView.hidden = NO;
        failedTableView.hidden = NO;
    }
    if (failedCount >= showNuber)
    {
        bgView.frame = CGRectMake(12, bgOriginY, 296, showNuber * 50);
        failedTableView.frame = CGRectMake(0, 0, 296, showNuber * 50);
    }
    else
    {
        bgView.frame = CGRectMake(12, bgOriginY, 296,failedCount * 50);
        failedTableView.frame = CGRectMake(0, 0, 296, failedCount * 50);
    }
    [failedTableView reloadData];
}

#pragma mark - UIButtonEvents

-(void)allReload:(id)sender
{
    [failedDownLoad setsupendOfflineDownLoad];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否将全部失败列表将进入自动下载等待中？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = ALL_RELOAD_TAG;
    [alertView show];
    [alertView release];
}

-(void)allCancel:(id)sender
{
    [failedDownLoad setsupendOfflineDownLoad];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否删除失败列表中所有的数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = ALL_CANCLE_TAG;
    [alertView show];
    [alertView release];
}

#pragma mark -UITableViewDelegate and DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return offLine.failedArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierStr = @"failedIdentifier";
    __block OffLineDownLoadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStr];
    if (cell == nil)
    {
        cell = [[[OffLineDownLoadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr] autorelease];
    }
    __block NSDictionary *dic = offLine.failedArr[indexPath.row];
    __block typeof (self) bself=self;

    cell.nameLabel.text = [NSString stringWithFormat:@"%@.%@",dic[@"fileName"],dic[@"fileType"]];
    cell.downlingNameLable.text = [NSString stringWithFormat:@"%@.%@",dic[@"fileName"],dic[@"fileType"]];
    if ([dic[@"waiting"] intValue] == 2)
    {
        cell.percentageLabel.text = @"100%";
        cell.progressView.progress =1.0f;
    }
    else if ([dic[@"waiting"] intValue] == 0 ||[dic[@"waiting"] intValue] == 1)
    {
        cell.percentageLabel.text = @"0%";
        cell.progressView.progress = 0.0f;
    }
    [cell setWaitingLoad:[dic[@"waiting"] intValue]];
    cell.Dismiss = ^{
        [bself removeFailedListOjbect:indexPath.row];
    };
    cell.Reload = ^{
        [bself reloadFailedListObject:indexPath.row];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)removeFailedListOjbect:(NSInteger)index
{
    [failedDownLoad setsupendOfflineDownLoad];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:offLine.failedArr[index]];
    if ([dic[@"waiting"] intValue] == 4)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否忽略移除正在下载的文件" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alertView.tag = FAILEDLOADING_TAG;
        [alertView show];
        [alertView release];
        return;
    }
    [offLine.failedArr removeObjectAtIndex:index];
    if (offLine.failedArr.count >= showNuber)
    {
        [failedTableView reloadData];
    }
    else if (offLine.failedArr.count > 0)
    {
        bgView.frame = CGRectMake(12, bgOriginY, 296,offLine.failedArr.count * 50);
        failedTableView.frame = CGRectMake(0, 0, 296, offLine.failedArr.count * 50);
        [failedTableView reloadData];
    }
    if (offLine.failedArr.count == 0)
    {
        bgView.hidden = YES;
        failedTableView.hidden = YES;
        failedBgView.hidden = YES;
    }
}
-(void)reloadFailedListObject:(NSInteger)index
{
    BOOL failedloading = NO;
    for (NSDictionary *dic in offLine.failedArr)
    {
        if ([dic[@"waiting"] intValue] == 4)
        {
            failedloading = YES;
            break;
        }
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:offLine.failedArr[index]];
    if (failedloading == YES)
    {
        if ([dic[@"waiting"] intValue] == 0)
        {
            [dic setValue:[NSNumber numberWithInt:1] forKey:@"waiting"];
        }
        else if ([dic[@"waiting"] intValue] == 1)
        {
            [dic setValue:[NSNumber numberWithInt:0] forKey:@"waiting"];
        }
        
        [offLine.failedArr replaceObjectAtIndex:index withObject:dic];
        [failedTableView reloadData];
    }
    else
    {
        if ([dic[@"waiting"] intValue] == 0 ||[dic[@"waiting"] intValue] == 1)
        {
            [dic setValue:[NSNumber numberWithInt:4] forKey:@"waiting"];
            [offLine.failedArr replaceObjectAtIndex:index withObject:dic];
            [failedTableView reloadData];
            downIndex = index;
            failedDownLoad.downloadIndex = index;
            failedDownLoad.totalBytes = [dic[@"size"] longLongValue];
            totalBytes = [dic[@"size"] longLongValue];
            [failedDownLoad dicDownloadListAction:dic downloadType:dic[@"style"]];
        }
    }
}

-(void)cancelOfflineDownLoad:(id)sender
{
    if (offLine.downloadFinished == NO)
    {
        [offLine setsupendOfflineDownLoad];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"取消下载将删除正在下载的资料，是否取消下载？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alertView.tag = CANCEL_TAG;
    [alertView show];
    [alertView release];
}

-(void)backBtnPressed
{
    if ((offLine.downloadFinished == YES && failedDownLoad.downloadFinished == YES) || ![Utilities checkNetwork])
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self offlineDownLoadSuccess];
}

//离线下载结束调用
-(void)offlineDownLoadSuccess
{
    [offLine setsupendOfflineDownLoad];
    UIAlertView *alertView = nil;
    if (offLine.downloadFinished == NO)
    {
        alertView = [[UIAlertView alloc] initWithTitle:nil message:@"返回将会暂停离线下载，是否返回?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"返回", nil];
        alertView.tag = GO_BACK_TAG;
    }
    if (offLine.downloadFinished == YES && failedDownLoad.downloadFinished == NO)
    {
        [failedDownLoad setsupendOfflineDownLoad];
        alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您有下载失败的数据尚未下载，是否返回?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"返回", nil];
        alertView.tag = GO_BACK_TAG;
    }
    if (offLine.downloadFinished == YES && failedDownLoad.downloadFinished == YES)
    {
        if (TARGET_VERSION_LITE == 1)
        {
            alertView = [[UIAlertView alloc] initWithTitle:nil message:@"离线下载成功,是否进入家园?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        }
        else
        {
            NSArray * assocaitedArr = [MyFamilySQL getAssociatedMembers];
            if (assocaitedArr.count == 0)
            {
                alertView = [[UIAlertView alloc] initWithTitle:nil message:@"离线下载成功,是否进入家园?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            }
            else
            {
                alertView = [[UIAlertView alloc] initWithTitle:nil message:@"检测到家谱中有关联成员，是否查看关联用户资料？" delegate:self cancelButtonTitle:@"查看" otherButtonTitles:@"进入家园", nil];
            }
        }
        alertView.tag = DOWN_SUCCESS_TAG;
    }
    [alertView show];
    [alertView release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (alertView.tag == GO_BACK_TAG)
        {
            if (offLine.downloadFinished == NO)
            {
                [offLine setsupendOfflineDownLoad];
            }
            else
            {
                [failedDownLoad setsupendOfflineDownLoad];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (alertView.tag == CANCEL_TAG)
        {
            [offLine stopOfflineDownLoad];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (alertView.tag == ALL_CANCLE_TAG)
        {
            [failedDownLoad stopOfflineDownLoad];
            [offLine.failedArr removeAllObjects];
            failedDownLoad.downloadFinished = YES;
            bgView.hidden = YES;
            failedTableView.hidden = YES;
            failedBgView.hidden = YES;
            [self offlineDownLoadSuccess];
            return;
        }
        else if (alertView.tag == ALL_RELOAD_TAG)
        {
            allReloadButton.userInteractionEnabled = NO;
            NSInteger count = offLine.failedArr.count;
            for (int i = 0; i < count; i++)
            {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:offLine.failedArr[i]];
                if ([dic[@"waiting"] intValue] == 0)
                {
                    [dic setValue:[NSNumber numberWithInt:1] forKey:@"waiting"];
                    [offLine.failedArr replaceObjectAtIndex:i withObject:dic];
                }
            }
            [failedTableView reloadData];
            if (downIndex != 0)
            {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:offLine.failedArr[downIndex]];
                failedDownLoad.downloadIndex = downIndex;
                failedDownLoad.totalBytes = [dic[@"size"] longLongValue];
                totalBytes = [dic[@"size"] longLongValue];
                [failedDownLoad dicDownloadListAction:dic downloadType:dic[@"style"]];
            }
            else
            {
                [self startFailedListDownload];
            }
        }
        else if (alertView.tag == FAILEDLOADING_TAG)
        {
            [failedDownLoad stopOfflineDownLoad];
            [offLine.failedArr removeObjectAtIndex:downIndex];
            if (offLine.failedArr.count >= showNuber)
            {
                [failedTableView reloadData];
            }
            else if (offLine.failedArr.count > 0)
            {
                bgView.frame = CGRectMake(12, bgOriginY, 296,offLine.failedArr.count * 50);
                failedTableView.frame = CGRectMake(0, 0, 296, offLine.failedArr.count * 50);
                [failedTableView reloadData];
            }
            if (offLine.failedArr.count == 0)
            {
                bgView.hidden = YES;
                failedTableView.hidden = YES;
                failedBgView.hidden = YES;
            }
            [self startFailedListDownload];
        }
        else if (alertView.tag == DOWN_SUCCESS_TAG)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"offLineDownloadSuccess" object:nil];
        }
    }
    else if (buttonIndex == 0)
    {
        if (alertView.tag == LOGIN_OTHER)
        {
            BOOL isLogin = NO;
            [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
        }
        if (alertView.tag == GO_BACK_TAG)
        {
            if (offLine.downloadFinished == NO)
            {
                [offLine resumeOfflineDownLoad];
            }
            else if (offLine.downloadFinished == YES && failedDownLoad.downloadFinished == NO)
            {
                [self startFailedListDownload];
            }
        }
        if (alertView.tag == CANCEL_TAG)
        {
            [offLine resumeOfflineDownLoad];
        }
        if (alertView.tag == ALL_CANCLE_TAG || alertView.tag == ALL_RELOAD_TAG ||alertView.tag == FAILEDLOADING_TAG)
        {
            [self startFailedListDownload];
        }
        if (alertView.tag == DOWN_SUCCESS_TAG)
        {
            if (TARGET_VERSION_LITE == 1)
            {
                ;
            }
            else
            {
                NSArray * assocaitedArr = [MyFamilySQL getAssociatedMembers];
                if (assocaitedArr.count == 0)
                {
                    //                [[NSNotificationCenter defaultCenter] postNotificationName:@"offLineDownloadSuccess" object:nil];
                }
                else
                {
                    [self.navigationController popViewControllerAnimated:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAssociatedMembers" object:nil];
                }
            }
        }
    }
}
//自动启动自动下载
-(void)startFailedListDownload
{
    _cancelButton.userInteractionEnabled = NO;
    NSInteger count = offLine.failedArr.count;
    if (count == 0)
    {
        failedDownLoad.downloadFinished = YES;
        failedDownLoad.downloading = YES;
        [offLine clearData];
        [failedDownLoad clearData];
        UIAlertView *alertView = nil;
        if ([Utilities checkNetwork])
        {
            if (TARGET_VERSION_LITE == 1)
            {
                alertView = [[UIAlertView alloc] initWithTitle:nil message:@"离线下载成功,是否进入家园?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            }
            else
            {
                NSArray * assocaitedArr = [MyFamilySQL getAssociatedMembers];
                if (assocaitedArr.count == 0)
                {
                    alertView = [[UIAlertView alloc] initWithTitle:nil message:@"离线下载成功,是否进入家园?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                }
                else
                {
                    alertView = [[UIAlertView alloc] initWithTitle:nil message:@"检测到家谱中有关联成员，是否查看关联用户资料？" delegate:self cancelButtonTitle:@"查看" otherButtonTitles:@"进入家园", nil];
                }
            }
        }
        else
        {
            alertView = [[UIAlertView alloc] initWithTitle:nil message:@"离线下载成功,是否进入工具箱?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        }
        alertView.tag = DOWN_SUCCESS_TAG;
        [alertView show];
        [alertView release];
        return;
    }
    else
    {
        [failedDownLoad resumeOfflineDownLoad];
    }
}
//自动下载成功后启动的操作
-(void)setOfflineDownloadSuccess
{
    [progressView setProgress:1.0f];
    percentageLabel.text = @"100%";
//    [MyToast showWithText:@"您的文件已经下载成功" :200];
    _cancelButton.userInteractionEnabled = NO;
    if (offLine.failedArr.count == 0)
    {
        failedDownLoad.downloadFinished = YES;
        [self offlineDownLoadSuccess];
        [offLine clearData];
    }
    else
    {
        [self startFailedListDownload];
    }
}

//自动启动正在下载的失败列表的数据
-(void)startFailedListWithLoading
{
    BOOL failedloading = NO;
    NSInteger index = 0;
    NSInteger count = offLine.failedArr.count;
    for ( int i = 0; i < count; i++)
    {
        NSDictionary *dic = offLine.failedArr[i];
        if ([dic[@"waiting"] intValue] == 4)
        {
            index = i;
            failedloading = YES;
            break;
        }
    }
    if (failedloading == YES)
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:offLine.failedArr[index]];
        downIndex = index;
        failedDownLoad.downloadIndex = index;
        failedDownLoad.totalBytes = [dic[@"size"] longLongValue];
        totalBytes = [dic[@"size"] longLongValue];
        [failedDownLoad dicDownloadListAction:dic downloadType:dic[@"style"]];
    }
    else
    {
        [self startFailedListDownload];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
