//
//  DiaryDetailsViewController.m
//  EternalMemory
//
//  Created by sun on 13-6-3.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "DiaryDetailsViewController.h"
#import "WriteWordsViewController.h"
#import "MyBlogListViewController.h"
#import "EternalMemoryAppDelegate.h"
#import "DiaryGroupsModel.h"
#import "DiaryMessageSQL.h"
#import "DiaryGroupsSQL.h"
#import "RMWTextView.h"
#import "CommonData.h"
#import "MyToast.h"

#define REQUEST_FOR_GETDIARYDETAIL 100
#define REQUEST_FOR_DELETEDIARY 200
#define SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
@interface DiaryDetailsViewController ()
{
    ASIFormDataRequest *deleteRequest;
}

@property (nonatomic, retain) IBOutlet UILabel *diaryTitleLable;
@property (nonatomic, retain) IBOutlet UILabel *detailLable;
@property (nonatomic, retain) IBOutlet RMWTextView *textView;
@property (nonatomic, retain) IBOutlet UIImageView *bgImgView;
@property (nonatomic, retain) NSString *errorcodeStr ;
@property (retain, nonatomic) IBOutlet UIView *containerView;
@property (retain, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation DiaryDetailsViewController
@synthesize diaryTitleLable = _diaryTitleLable;
@synthesize detailLable = _detailLable;
@synthesize textView = _textView;
@synthesize model = _model;
@synthesize categoryLabel = _categoryLabel;
@synthesize errorcodeStr = _errorcodeStr ;

#pragma mark - object lifecycle
- (void)dealloc
{
    if (deleteRequest)
    {
        [deleteRequest clearDelegatesAndCancel];
        [deleteRequest release];
        deleteRequest = nil;
    }
    [_request clearDelegatesAndCancel];
    [_request release];
    RELEASE_SAFELY(_diaryTitleLable);
    RELEASE_SAFELY(_textView);
    RELEASE_SAFELY(_bgView);
    RELEASE_SAFELY(_detailLable);
    RELEASE_SAFELY(_model);
    RELEASE_SAFELY(_errorcodeStr);
    RELEASE_SAFELY(_bgView);
    [_bgView release];
    [_containerView release];
    [_categoryLabel release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [Utilities adjustUIForiOS7WithViews:@[_containerView]];
    NSInteger containView_height = iPhone5? 504:415;
    if (iOS7)
    {
        _containerView.frame = CGRectMake(0, 64, 320, containView_height);
    }
    else
    {
        _containerView.frame = CGRectMake(0, 44, 320, containView_height);
    }
    [self setViewData];//有缓存，读取缓存
    
    if (![self.model.localVer isEqualToString:self.model.serverVer]&&self.model.blogId != NULL&&self.model.blogId != nil) {
         [self getDiaryDetailsRequest];
    } else if(self.model.blogId != NULL&&self.model.blogId != nil) {
        if (self.model.summary.length > self.model.content.length || self.model.summary.length == self.model.summary.length) {
           [self getDiaryDetailsRequest];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"DiaryDetail" object:nil];
}
-(void)refreshData:(NSNotification *)obj{
    NSDictionary *dic=[obj object];
    [_diaryTitleLable setText:[dic objectForKey:@"title"]];
    NSArray *groupArray = [DiaryGroupsSQL getDiaryGroupsByGroupId:self.model.groupId];
    if (groupArray && [groupArray count]>0) {
        [groupArray objectAtIndex:0];
        DiaryGroupsModel *groupModel = [groupArray objectAtIndex:0];
        self.model.groupname = groupModel.title;
    }
    
    NSString *datailStr = nil;
    if ([self.model.lastModifyTime isEqualToString:@"(null)"] || [self.model.lastModifyTime isEqualToString:@""]|| self.model.lastModifyTime == nil||[self.model.createTime isEqualToString:self.model.lastModifyTime] )
    {
        datailStr = [NSString stringWithFormat:@"创建于: %@ ",[CommonData getTimeransitionPath:[dic objectForKey:@"createTime"]]];
    }
    else
    {
        datailStr = [NSString stringWithFormat:@"更新于: %@ ",[CommonData getTimeransitionPath:self.model.lastModifyTime]];
    }
    [self.detailLable setText:datailStr];
    [self.categoryLabel setText:self.model.groupname];
    _textView.text = [dic objectForKey:@"content"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MyBlogList" object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 设置标题栏的数据、界面和日记内容信息
- (void)setViewData
{
    self.rightBtn.hidden = NO;
    [self.titleLabel setText:@"详情"];
    self.middleBtn.hidden = YES;
    [self.rightBtn setTitle:@"更多" forState:UIControlStateNormal];
    [_diaryTitleLable setNumberOfLines:0];
    _diaryTitleLable.lineBreakMode = NSLineBreakByWordWrapping;
    [self reloadViews];
}
- (void)reloadViews
{
    [_diaryTitleLable setText:self.model.title];
        NSArray *groupArray = [DiaryGroupsSQL getDiaryGroupsByGroupId:self.model.groupId];
    if (groupArray && [groupArray count]>0)
    {
        [groupArray objectAtIndex:0];
        DiaryGroupsModel *groupModel = [groupArray objectAtIndex:0];
        self.model.groupname = groupModel.title;
    }
    NSString *datailStr = nil;
    if ([self.model.lastModifyTime isEqualToString:@"(null)"]|| [self.model.lastModifyTime isEqualToString:@""] ||[self.model.createTime isEqualToString:self.model.lastModifyTime])
    {
        NSString *dateStr = [CommonData getTimeransitionPath:_model.createTime];
        datailStr = [NSString stringWithFormat:@"创建于: %@ ",dateStr];
    }
    else
    {
        NSString *dateStr = [CommonData getTimeransitionPath:_model.lastModifyTime];
        datailStr = [NSString stringWithFormat:@"更新于: %@ ",dateStr];
    }

    [self.detailLable setText:datailStr];
    [self.categoryLabel setText:self.model.groupname];
    if (self.model.summary && self.model.content && self.model.content > 0 )
    {
        _textView.text = self.model.content;
    }
    else if (self.model.summary)
    {
        _textView.text = self.model.summary;
    }
    _textView.scrollEnabled = YES;
}

- (CGSize)caculateTextSize:(NSString *)text width:(float)width
{
    CGSize size = [text sizeWithFont:_textView.font constrainedToSize:CGSizeMake(310, 100000) lineBreakMode:NSLineBreakByCharWrapping];
    return size;
}

- (void)rightBtnPressed
{
    self.rightBtn.userInteractionEnabled = NO;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle: @"删除"otherButtonTitles:@"编辑", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}
- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma  mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSArray *blogArray = [NSArray arrayWithObject:_model];
        if (![Utilities checkNetwork]) {
            //无网络
            if (self.model.blogId != NULL&&self.model.blogId != nil && self.model.blogId.length != 0)
            {
                _model.status = @"3";
                _model.deletestatus = YES;
                _model.needSyn = YES;
                _model.needUpdate = YES;
                //有BLOGID标志同步。
                [DiaryMessageSQL refershMessagesByMessageModelArray:blogArray];
            }
            else
            {
                //无BLOGID直接删除。
                [DiaryMessageSQL deleteLocalMessage:blogArray];
            }
            [DiaryGroupsSQL deleteDiarysFromGroupIdArr:[NSArray arrayWithObject:_model.groupId]];

            [MyToast showWithText:@"删除日记成功" :[UIScreen mainScreen].bounds.size.height/2-40];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MyBlogList" object:nil];
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[ MyBlogListViewController class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }
        }
        else
        {
             //有网络
            if (self.model.blogId != NULL&&self.model.blogId != nil) {
                [self deleteDiaryRequest:self.model.blogId];
            }else{
                [DiaryMessageSQL deletePhoto:blogArray];
                [DiaryGroupsSQL changeDiaryCountWithGroupId:_model.groupId OperateStyle:@"deleteDiary" OperateCount:1];
                [MyToast showWithText:@"删除日记成功" :[UIScreen mainScreen].bounds.size.height/2-40];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyBlogList" object:nil];
                for (UIViewController *controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[MyBlogListViewController class]]) {
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                }
            }
        }
    }
    if (buttonIndex == 1) {
        {
        NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"ETMemory"] stringByAppendingPathComponent:@"Diarys"];
        NSString *usernameStr = [[SavaData  parseDicFromFile:User_File] objectForKey:@"userName"];
        NSString *fullPath = [path stringByAppendingPathComponent:usernameStr] ;
        BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSAssert(bo,@"创建Diarys目录失败");
        NSString *result = [fullPath stringByAppendingPathComponent:@"DiatyDic"];
        [[NSFileManager defaultManager] removeItemAtPath:result error:nil];
        }

        WriteWordsViewController *writeWordsViewController = [[WriteWordsViewController alloc] init ];
        writeWordsViewController.blogModel = self.model;
        writeWordsViewController.groupName = self.model.groupname;
        [self.navigationController pushViewController:writeWordsViewController animated:YES];
        RELEASE_SAFELY(writeWordsViewController);
    }
    actionSheet.userInteractionEnabled = NO;
    self.rightBtn.userInteractionEnabled = YES;
}
- (void)getDiaryDetailsRequest
{
    NSURL *registerUrl = [[RequestParams sharedInstance] blogDetails];
    _request = [[ASIFormDataRequest alloc] initWithURL:registerUrl];
    _request.shouldAttemptPersistentConnection = NO;
    _request.delegate = self;
    _request.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_GETDIARYDETAIL],@"tag", nil]  ;
    [_request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_request setPostValue:self.model.blogId forKey:@"blogid"];
    [_request setRequestMethod:@"POST"];
    [_request setTimeOutSeconds:15.0];
    [_request startAsynchronous];
}
- (void)deleteDiaryRequest:(NSString *)blogId
{
    if (deleteRequest)
    {
        [deleteRequest clearDelegatesAndCancel];
        [deleteRequest release];
        deleteRequest = nil;
    }
    NSURL *registerUrl = [[RequestParams sharedInstance] deleteBlog];
    deleteRequest = [[ASIFormDataRequest alloc ]initWithURL:registerUrl];
    deleteRequest.shouldAttemptPersistentConnection = NO;
    deleteRequest.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_DELETEDIARY],@"tag", nil];
    [deleteRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [deleteRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [deleteRequest setPostValue:blogId forKey:@"blogid"];
    [deleteRequest setRequestMethod:@"POST"];
    [deleteRequest setTimeOutSeconds:30.0];

    __block typeof (self) bself=self;
    [deleteRequest setCompletionBlock:^{
        [bself requestSuccess:deleteRequest];
    }];
    [deleteRequest setFailedBlock:^{
        [bself requestFail:deleteRequest];
    }];
    [deleteRequest startAsynchronous];
}

#pragma mark -ASIFormDataRequestDelegate

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    self.errorcodeStr = [NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"errorcode"]];
    
    //异地登陆和封存提示信息   lgb
    if ([self.errorcodeStr isEqualToString:@"1005"]) {
        UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        [alter release];
        return;
    }else if ([self.errorcodeStr isEqualToString:@"9000"]) {
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        return;
    }
    
    if (tag == REQUEST_FOR_GETDIARYDETAIL) {
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            NSDictionary *dataDic = [resultDictionary objectForKey:@"data"];
            NSArray *blogDataArray = [NSArray arrayWithObject:dataDic];
            [DiaryMessageSQL synchronizeBlog:blogDataArray WithUserID:USERID];
            DiaryMessageModel *model = [DiaryMessageSQL getBlogByBlogId:[dataDic objectForKey:@"blogId"]];
            self.model = model;
            [self reloadViews];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    if ([Utilities checkNetwork])
    {
        [MyToast showWithText:@"请求错误，请检查网络" :140];
    }
}


#pragma mark - ASIHTTPRequest
-(void)requestSuccess:(ASIFormDataRequest *)request
{
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    self.errorcodeStr = [NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"errorcode"]];
    
    //异地登陆和封存提示信息   lgb
    if ([self.errorcodeStr isEqualToString:@"1005"]) {
        UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        [alter release];
        return;
    }else if ([self.errorcodeStr isEqualToString:@"9000"]) {
         [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        return;
    }
/*
    if (tag == REQUEST_FOR_GETDIARYDETAIL) {
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            NSDictionary *dataDic = [resultDictionary objectForKey:@"data"];
            NSArray *blogDataArray = [NSArray arrayWithObject:dataDic];
            [DiaryMessageSQL synchronizeBlog:blogDataArray];
            MessageModel *model = [DiaryMessageSQL getBlogByBlogId:[dataDic objectForKey:@"blogId"]];
            self.model = model;
             [self reloadViews];
        }
    }
 */
    if (tag == REQUEST_FOR_DELETEDIARY) {
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            NSDictionary *metaDic = [resultDictionary objectForKey:@"meta"];
            NSString *versionsStr = [metaDic objectForKey:@"versions"];
            NSDate *date = [NSDate date];
            NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
            NSString *timeStr = [NSString stringWithFormat:@"%f",timestamp];
            _model.status = @"1";
            _model.needSyn = NO;
            _model.needUpdate = NO;
            _model.lastModifyTime = timeStr;
            _model.syncTime = timeStr;
            _model.localVer = versionsStr;
            _model.serverVer = versionsStr;
            NSArray *blogArray = [NSArray arrayWithObject:_model];
//            [DiaryMessageSQL refershMessagesByMessageModelArray:blogArray];
            [DiaryMessageSQL deletePhoto:blogArray];
            [DiaryGroupsSQL changeDiaryCountWithGroupId:_model.groupId OperateStyle:@"deleteDiary" OperateCount:1];

           [[NSNotificationCenter defaultCenter] postNotificationName:@"MyBlogList" object:nil];
            [MyToast showWithText:@"删除日记成功" :[UIScreen mainScreen].bounds.size.height/2-40];
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[ MyBlogListViewController class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }
        }
    }
}

-(void)requestFail:(ASIFormDataRequest *)request
{
    if ([Utilities checkNetwork])
    {
     [MyToast showWithText:@"请求错误，请检查网络" :140];
    }
}

#pragma mark -- alterview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
     if (buttonIndex == 0&&[self.errorcodeStr isEqualToString:@"1005"]) {
         BOOL isLogin = NO;
         [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate]  showLoginVC];
    }
}

- (void)viewDidUnload {
    [self setBgView:nil];
    [super viewDidUnload];
}
@end
