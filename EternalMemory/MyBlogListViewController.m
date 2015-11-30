//
//  MyBlogListViewController.m
//  EternalMemory
//
//  Created by sun on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "SelectListCategoriesViewController.h"
#import "EditCategoriesViewController.h"
#import "DiaryDetailsViewController.h"
#import "MyBlogListViewController.h"
#import "MyLifeMainViewController.h"
#import "WriteWordsViewController.h"
#import "EternalMemoryAppDelegate.h"
#import "ActionSheetStringPicker.h"
#import "MyHomeViewController.h"
#import "DownlaodDebugging.h"
#import "DiaryMessageModel.h"
#import "DiaryGroupsModel.h"
#import "DiaryMessageSQL.h"
#import "NewBlogListCell.h"
#import "MyBlogListCell.h"
#import "DiaryGroupsSQL.h"
#import "EditListCell.h"
#import "GuideView.h"
#import "MyToast.h"

#define CELL_HEIGHT 175
#define REQUEST_FOR_GETBLOGLIST 100
#define REQUEST_FOR_CHANGEBLOGGROUP 200
#define REQUEST_FOR_DELETBLOG 300
#define TEXTTYPE @"0"
#define kCameraToolBarHeight 54


@interface MyBlogListViewController ()
{
    __block NSInteger      comeInTime;
    __block int viewHeight;
    NSInteger selectedIndexInt;
    NSInteger selectGroupId;
    EGORefreshTableHeaderView *_refreshHeaderView;
    __block ASIFormDataRequest *getBlogRequest;
    BOOL _reloading;
    __block UIToolbar *_toolBar;
    BOOL isNOtification;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *noBlogImg;
@property (nonatomic, retain) IBOutlet UIImageView *noBlogTextImg;
@property (nonatomic, retain) NSMutableArray *blogArray;
@property (nonatomic, retain) NSMutableArray *blogEditArray;
@property (nonatomic, assign) BOOL EditingStatus;
@property (nonatomic, retain) DiaryGroupsModel *currentGroupModel;
@property (nonatomic, retain) NSString *errorcodeStr ;

-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;
@end

@implementation MyBlogListViewController
@synthesize tableView = _tableView;
@synthesize blogArray = _blogArray;
@synthesize EditingStatus = _EditingStatus;
//@synthesize toolBar = _toolBar;
@synthesize blogEditArray = _blogEditArray;
@synthesize currentGroupModel = _currentGroupModel;
@synthesize noBlogImg = _noBlogImg;
@synthesize errorcodeStr = _errorcodeStr ;
#pragma mark - object lifecycle
- (void)dealloc
{
    
    RELEASE_SAFELY(_tableView);
    RELEASE_SAFELY(_currentGroupModel);
    RELEASE_SAFELY(_noBlogImg);
    RELEASE_SAFELY(_noBlogTextImg);
    RELEASE_SAFELY(_toolBar);
    RELEASE_SAFELY(_fromView);
    RELEASE_SAFELY(_blogArray);
    RELEASE_SAFELY(_blogEditArray);
    RELEASE_SAFELY(_errorcodeStr);
    RELEASE_SAFELY(_refreshHeaderView);
    [getBlogRequest clearDelegatesAndCancel];
    [getBlogRequest release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _blogEditArray = [[NSMutableArray alloc] init];
        _EditingStatus = NO;
        _currentGroupModel = [[DiaryGroupsModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    viewHeight = iPhone5 ? 548:460;
    
    if (iOS7)
    {
        viewHeight += 20.0f;
    }
    selectGroupId = -1;
    self.rightBtn.hidden = NO;
    [self.middleBtn setTitle:@"书籍" forState:UIControlStateNormal];
    [self.middleImage setImage:[UIImage imageNamed:@"jt_fl_xz.png"]];
    [self.rightBtn setTitle:@"编辑"  forState:UIControlStateNormal];
    _noBlogImg.hidden = YES;
    _noBlogTextImg.hidden = YES;
    [self setupToolbar];
//    BOOL notFirst = [[SavaData shareInstance] printisAppFirst:@"textFirst"];
//    if (!notFirst) {
//        [GuideView guideViewAddToWindow:@"text"];
//        [[SavaData shareInstance] saveisAppFirstBool:YES forKey:@"textFirst"];
//    }
    [Utilities adjustUIForiOS7WithViews:@[_tableView]];
    
    self.view.backgroundColor = RGB(242, 242, 242);
    self.tableView.backgroundColor = RGB(242, 242, 242);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"MyBlogList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMiddleBtnTitle:) name:@"BtnTitle" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSelectCategory:) name:@"removeCategoryFromSelectList" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!isNOtification) {
        if (comeInTime != COME_FORTH)
        {
            [self setViewData];
        }
    }
    comeInTime = COME_SECOND;
}
-(void)refreshData{
    if ([self.middleBtn.titleLabel.text isEqualToString:@"书籍"]) {
        self.blogArray = [DiaryMessageSQL getMessages:TEXTTYPE AndUserId:USERID];
    }
    else{
        self.blogArray =[DiaryMessageSQL getGroupIDMessages:_currentGroupModel.groupId AndUserId:USERID];
    }
    [_tableView reloadData];
}
- (void)refreshMiddleBtnTitle:(NSNotification *)info
{
    NSDictionary *dic = [info object];
    isNOtification = YES;
    [self.middleBtn setTitle:dic[@"btnTitle"] forState:UIControlStateNormal];
}
-(void)removeSelectCategory:(NSNotification *)sender
{
    [self EditCategories:NO selectedGroup:nil selectedIndex:0];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
- (void)backBtnPressed
{
    if (_EditingStatus) {
        [self rightBtnPressed];
    }
    if ([self.fromView isEqualToString:@"write"]) {
        
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[MyLifeMainViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)middleBtnPressed
{
    _EditingStatus = NO;
    [self.rightBtn setTitle:@"编辑"  forState:UIControlStateNormal];
    for (DiaryMessageModel *blogModel in self.blogArray) {
        blogModel.editStatus = NO;
    }
    [UIView animateWithDuration:.2f animations:^{
        _toolBar.frame = CGRectMake(0, viewHeight, 320, 54);
    }];
    [_tableView reloadData];
    comeInTime = COME_FORTH;

    SelectListCategoriesViewController *selectListCategoriesViewController = [[[SelectListCategoriesViewController alloc] init] autorelease];
    selectListCategoriesViewController.selectListCategoriesDelegate = self;
    selectListCategoriesViewController.currentIndex = selectedIndexInt;
    [self presentViewController:selectListCategoriesViewController animated:YES completion:nil];
}
-(void)rightBtnPressed
{
    _EditingStatus = !_EditingStatus;
    if (!_EditingStatus) {
        [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [UIView animateWithDuration:.2f animations:^{
            _toolBar.frame = CGRectMake(0, viewHeight, 320, 54);
        }];
        _refreshHeaderView.hidden = NO;
        [self.blogEditArray removeAllObjects];
        for (DiaryMessageModel *blogModel in self.blogArray) {
            
            blogModel.editStatus = NO;
        }
    }else{
        if (![self.middleBtn.titleLabel.text isEqualToString:@"书籍"]) {
            self.blogArray =[DiaryMessageSQL getGroupIDMessages:_currentGroupModel.groupId AndUserId:USERID];
            if ([self.blogArray count] > 0) {
                [UIView animateWithDuration:.2f animations:^{
                    _toolBar.frame = CGRectMake(0, viewHeight - 54, 320, 54);
                }];
                [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
                _refreshHeaderView.hidden = YES;
                for (DiaryMessageModel *model in self.blogArray) {
                    model.editStatus = NO;
                }
            }else{
                UIAlertView *alter = [[UIAlertView alloc] initWithTitle:nil message:@"没有可操作日记" delegate:self  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alter.tag = 10000;
                [alter show];
                [alter release];
            }
            
        }else{
            self.blogArray = [DiaryMessageSQL getMessages:TEXTTYPE AndUserId:USERID];
            if ([self.blogArray count] > 0) {
                [UIView animateWithDuration:.2f animations:^{
                    _toolBar.frame = CGRectMake(0, viewHeight - 54, 320, 54);
                }];
                [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
                _refreshHeaderView.hidden = YES;
            }else{
                UIAlertView *alter = [[UIAlertView alloc] initWithTitle:nil message:@"没有可操作日记" delegate:self  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alter.tag = 10000;
                [alter show];
                [alter release];
            }
        }
    }
    [self.tableView reloadData];
}
// add by zgl
-(void)addTableHeaderView{//写文章按钮
    
    UIView  *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 75)];
    aView.backgroundColor = [UIColor clearColor];
    
    UIButton *writeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    writeBtn.frame = CGRectMake(30, 20, 260, 44);
    [writeBtn setBackgroundImage:[UIImage imageNamed:@"sj_but"] forState:UIControlStateNormal];
    [writeBtn setBackgroundImage:[UIImage imageNamed:@"sj_but_change"] forState:UIControlStateSelected];
    [writeBtn addTarget:self action:@selector(writeBlog) forControlEvents:UIControlEventTouchUpInside];
    [aView addSubview:writeBtn];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(90, 7, 30, 30)];
    img.image = [UIImage imageNamed:@"sj_ic"];
    [writeBtn addSubview:img];
    [img release];
    
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 7, 60, 30)];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.textColor = [UIColor colorWithRed:94/255. green:102/255. blue:112/255. alpha:1.0];
    aLabel.text = @"写文章";
    aLabel.font = [UIFont systemFontOfSize:15.0f];
    [writeBtn addSubview:aLabel];
    [aLabel release];
    
    self.tableView.tableHeaderView = aView;
    [aView release];
}
-(void)writeBlog{
    
    comeInTime = COME_FORTH;
    WriteWordsViewController *writeWords = [[WriteWordsViewController alloc] initWithNibName:@"WriteWordsViewController" bundle:nil];
    writeWords.groupId = _currentGroupModel.groupId;
    writeWords.groupName = _currentGroupModel.title;
    [self.navigationController pushViewController:writeWords animated:YES];
    [writeWords release];
    if ([self.rightBtn.titleLabel.text isEqualToString:@"完成"])
    {
        [self rightBtnPressed];
    }
}
- (void)setViewData
{
    [self addTableHeaderView];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
        [self.tableView addSubview:_refreshHeaderView];
//        _refreshHeaderView = headView;
//        [headView release];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    self.blogArray = [DiaryMessageSQL getMessages:TEXTTYPE AndUserId:USERID];
    
    if ([Utilities checkNetwork]) {
        [self getBlogListRequest];
    }else{
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
    }
    
    
}
- (void)synchronizeDiary
{
    if ([Utilities checkNetwork]) {
        [self getBlogListRequest];
    }else{
        self.blogArray = [DiaryMessageSQL getMessages:TEXTTYPE AndUserId:USERID];
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
    }
}
- (void)getBlogListRequest
{
    NSURL *registerUrl = [[RequestParams sharedInstance] getBlogList];
    if (getBlogRequest)
    {
        [getBlogRequest clearDelegatesAndCancel];
        [getBlogRequest release];
        getBlogRequest = nil;
    }
    getBlogRequest = [[ASIFormDataRequest alloc] initWithURL:registerUrl];
    getBlogRequest.delegate = self;
    getBlogRequest.shouldAttemptPersistentConnection = NO;
//    NSString *clientversionStr = [[SavaData  parseDicFromFile:User_File] objectForKey:@"DiaryVerson"];
    getBlogRequest.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_GETBLOGLIST],@"tag", nil];
    [getBlogRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [getBlogRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [getBlogRequest setPostValue:@"0" forKey:@"groupid"];
//    [getBlogRequest setPostValue:[NSString stringWithFormat:@"%d",versionStr] forKey:@"clientversion"];
    [getBlogRequest setPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:DIARYVERSION] forKey:@"clientversion"];

    [getBlogRequest setRequestMethod:@"POST"];
    [getBlogRequest setPostValue:@"1" forKey:@"getdeleted"];
    [getBlogRequest setTimeOutSeconds:30.0];
//    __block typeof(self) bself=self;
//    [getBlogRequest setCompletionBlock:^{
//        [bself requestSuccess:getBlogRequest];
//    }];
//    [getBlogRequest setFailedBlock:^{
//        [bself requestFail:getBlogRequest];
//    }];
    [getBlogRequest startAsynchronous];
    
}
- (void)changeBlogGroupRequest:(NSString *)blogid toGroup:(NSString *)groupid fromGroup:(NSArray *)fromGroup
{
    NSURL *registerUrl = [[RequestParams sharedInstance] changeBlogGroup];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:registerUrl];
//    request.delegate = self;
    request.shouldAttemptPersistentConnection = NO;
    request.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_CHANGEBLOGGROUP],@"tag",groupid,@"groupId",fromGroup,@"fromGroup", nil];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:groupid forKey:@"groupid"];
    [request setPostValue:blogid forKey:@"blogid"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:30.0];
    __block typeof (self) bself=self;
    [request setCompletionBlock:^{
        [bself requestSuccess:request];
    }];
    [request setFailedBlock:^{
        [bself requestFail:request];
    }];
    [request startAsynchronous];
}
- (void)deleteBlogsReauest:(NSString *)blogArrayStr GroupIdArr:(NSMutableArray *)groupIdArr
{
    NSURL *registerUrl = [[RequestParams sharedInstance] deleteBlog];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:registerUrl];
//    request.delegate = self;
    request.shouldAttemptPersistentConnection = NO;
    request.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_DELETBLOG],@"tag", groupIdArr,@"groupIdArr",nil];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:blogArrayStr forKey:@"blogid"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:30.0];
    __block typeof (self) bself=self;
    [request setCompletionBlock:^{
        [bself requestSuccess:request];
    }];
    [request setFailedBlock:^{
        [bself requestFail:request];
    }];
    [request startAsynchronous];
    
}
- (void)setupToolbar
{
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewHeight, self.view.bounds.size.width, kCameraToolBarHeight)];
    [_toolBar setBackgroundImage:[UIImage imageNamed:@"camera-bottom-bar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *moveButton = nil;
    UIBarButtonItem *deleteButton = nil;
    if (iOS7)
    {
        UIButton *moveButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        moveButton1.frame = CGRectMake(0, 0, 46, 46);
        [moveButton1 setImage:[UIImage imageNamed:@"bj_yd"] forState:UIControlStateNormal];
        moveButton1.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 20, 0);
        [moveButton1 setTitle:@"移动" forState:UIControlStateNormal];
        [moveButton1 addTarget:self action:@selector(moveBlogs:) forControlEvents:UIControlEventTouchUpInside];
        [moveButton1 setTitleEdgeInsets:UIEdgeInsetsMake(20, -20, 0, 0)];
        [moveButton1.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
        moveButton = [[UIBarButtonItem alloc] initWithCustomView:moveButton1];
        
        UIButton *deleteButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton1.frame = CGRectMake(0, 0, 46, 46);
        [deleteButton1 setImage:[UIImage imageNamed:@"bj_del"] forState:UIControlStateNormal];
        deleteButton1.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 20, 0);
        [deleteButton1 setTitle:@"删除" forState:UIControlStateNormal];
        [deleteButton1 addTarget:self action:@selector(deleteBlogs:) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton1 setTitleEdgeInsets:UIEdgeInsetsMake(20, -20, 0, 0)];
        [deleteButton1.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
        deleteButton = [[UIBarButtonItem alloc] initWithCustomView:deleteButton1];
    }
    else
    {
        moveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bj_yd"] style:UIBarButtonItemStylePlain target:self action:@selector(moveBlogs:)];
        moveButton.title = @"移动" ;
        moveButton.accessibilityLabel = @"Return to Frame Adjustment View";
        
        
        deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bj_del"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteBlogs:)];
        deleteButton.title = @"删除";
        deleteButton.accessibilityLabel = @"Confirm adjusted Image";
    }
    
    
    UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    [fixedSpace setWidth:77.0f];
    
    [_toolBar setItems:[NSArray arrayWithObjects:fixedSpace,moveButton,flexibleSpace,deleteButton,fixedSpace, nil]];
    
    [moveButton release];
    [deleteButton release];
    [self.view addSubview:_toolBar];
    
    [Utilities adjustUIForiOS7WithViews:@[_toolBar]];
}
#pragma mark - toolBarBtn
- (void)moveBlogs:(UIControl *)sender
{
    if (self.blogEditArray.count == 0) {
        [MyToast showWithText:@"请选择要移动的日志" :380];
        return;
    }
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSArray *categoryArray = [DiaryGroupsSQL getDiaryGroups:@"0" AndUserId:USERID];
    for (int i = 0; i < [categoryArray count]; i++) {
        DiaryGroupsModel *model = [categoryArray objectAtIndex:i];
        [dataArray addObject:[NSString stringWithFormat:@"%@ (共%@篇)",model.title,model.blogcount]];
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"请选择分组" rows:dataArray  initialSelection:0 target:self successAction:@selector(journalCategoryWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    RELEASE_SAFELY(dataArray);
    
}
- (void)deleteBlogs:(UIControl *)sender
{
    if ([self.blogEditArray count] == 0) {
        [MyToast showWithText:@"请选择要删除的日志" :380];
        return;
    }
    else
    {
        NSMutableArray *refershMessagesArray = [[NSMutableArray alloc] init];
        NSMutableArray *refreshLocalArray = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableString *blogArrayStr = [NSMutableString stringWithFormat:@""];
        NSMutableArray *groupIdArr = [NSMutableArray array];
        for (DiaryMessageModel *blogModel in self.blogEditArray)
        {
            NSDate *date = [NSDate date];
            NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
            NSString *timeStr = [NSString stringWithFormat:@"%f",timestamp];
//            if ([blogModel.blogId isEqualToString:@"(null)"]||blogModel.blogId ==nil)
            if(blogModel.blogId.length == 0)
            {
                [refreshLocalArray addObject:blogModel];
            }
            else
            {
                [blogArrayStr appendString:blogModel.blogId];
                [blogArrayStr appendString:@","];
                blogModel.status = @"3";
                blogModel.deletestatus = YES;
                blogModel.needSyn = YES;
                blogModel.needUpdate = YES;
                blogModel.lastModifyTime = timeStr;
                blogModel.syncTime = timeStr;
                [refershMessagesArray addObject:blogModel];
            }
            [groupIdArr addObject:blogModel.groupId];
        }
        if ([Utilities checkNetwork])
        {
            if ([refreshLocalArray count] != 0)
            {
                [DiaryMessageSQL deleteLocalMessage:refreshLocalArray];
            }
            if (blogArrayStr.length > 0 ) {
                [blogArrayStr deleteCharactersInRange:NSMakeRange(blogArrayStr.length - 1, 1)];
                [self deleteBlogsReauest:blogArrayStr GroupIdArr:groupIdArr];
            }
        }
        else
        {
            if ([refreshLocalArray count] != 0)
            {
                [DiaryMessageSQL deleteLocalMessage:refreshLocalArray];
            }
            if (refershMessagesArray.count != 0)
            {
                [DiaryMessageSQL  refershMessagesByMessageModelArray:refershMessagesArray];
            }
            [DiaryGroupsSQL deleteDiarysFromGroupIdArr:groupIdArr];
            [self rightBtnPressed];
            [self reloadTableData];
        }
        [refershMessagesArray release];
        [refreshLocalArray release];
    }
    
}
#pragma mark - private methods
- (void)reloadTableData
{
    if (_currentGroupModel.title) {
        self.blogArray =[DiaryMessageSQL getGroupIDMessages:_currentGroupModel.groupId AndUserId:USERID];
        [self.middleBtn setTitle:_currentGroupModel.title forState:UIControlStateNormal];
        
    }else{
        self.blogArray = [DiaryMessageSQL getMessages:TEXTTYPE AndUserId:USERID];
        [self.middleBtn setTitle:@"书籍" forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
    
}
- (void)actionPickerCancelled:(id)sender {
    
    
}
- (void)journalCategoryWasSelected:(NSNumber *)selectedIndex element:(id)element
{
    if ([self.blogEditArray count] == 0)
    {
        [MyToast showWithText:@"请选择移动的日志" :380];
    }
    else
    {
        NSMutableArray *moveArr = [NSMutableArray array];
        NSArray *categoryArray = [DiaryGroupsSQL getDiaryGroups:@"0" AndUserId:USERID];
        DiaryGroupsModel *groupModel = [categoryArray objectAtIndex:[selectedIndex intValue]];
        if ([self.currentGroupModel.groupId isEqualToString:groupModel.groupId])
        {
            [MyToast showWithText:@"您要移动的日志已经在这个分组中" :280];
            return;
        }
        NSMutableArray *refershMessagesArray = [[NSMutableArray alloc] init];
        NSMutableString *blogArrayStr = [NSMutableString stringWithFormat:@""];
        NSMutableArray *refreshLocalAry = [[NSMutableArray alloc] init];
        for (DiaryMessageModel *blogModel in self.blogEditArray) {
            NSDate *date = [NSDate date];
            NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
            NSString *timeStr = [NSString stringWithFormat:@"%f",timestamp];
            [moveArr addObject:blogModel.groupId];
            if ([blogModel.blogId isEqualToString:@"(null)"]||blogModel.blogId ==nil || blogModel.blogId.length == 0)
            {
                [refreshLocalAry addObject:blogModel];
            }
            else
            {
                blogModel.groupId = groupModel.groupId;
                blogModel.groupname = groupModel.title;
                blogModel.status = @"4";
                blogModel.deletestatus = NO;
                blogModel.needSyn = YES;
                blogModel.needUpdate = YES;
                blogModel.lastModifyTime = timeStr;
                blogModel.syncTime = timeStr;
                [refershMessagesArray addObject:blogModel];
                [blogArrayStr appendString:blogModel.blogId];
                [blogArrayStr appendString:@","];
            }
        }
        if ([Utilities checkNetwork])
        {
            if (refreshLocalAry.count == self.blogEditArray.count)
            {
                [MyToast showWithText:@"移动分组成功" :140];
                [DiaryMessageSQL  refershMessagesByMessageModelArray:refreshLocalAry];
                [DiaryMessageSQL refreshLocalMessages:refreshLocalAry ToGroupId:groupModel.groupId];
                [DiaryGroupsSQL moveDiaryFrom:moveArr To:groupModel.groupId];
                [self rightBtnPressed];
                [self reloadTableData];
                [refershMessagesArray release];
                [refreshLocalAry release];
                return;
            }
            else if ([refreshLocalAry count] != 0)
            {
                [DiaryMessageSQL refreshLocalMessages:refreshLocalAry ToGroupId:groupModel.groupId];
            }
            if (blogArrayStr.length>0) {
                [blogArrayStr deleteCharactersInRange:NSMakeRange(blogArrayStr.length - 1, 1)];
                [self changeBlogGroupRequest:blogArrayStr toGroup:groupModel.groupId fromGroup:moveArr];
            }
            [refershMessagesArray release];
            [refreshLocalAry release];
        }
        else
        {
            [DiaryMessageSQL refreshLocalMessages:refreshLocalAry ToGroupId:groupModel.groupId];
            [DiaryMessageSQL  refershMessagesByMessageModelArray:refershMessagesArray];
            [DiaryGroupsSQL moveDiaryFrom:moveArr To:groupModel.groupId];
            [MyToast showWithText:@"移动分组成功" :140];
            [self rightBtnPressed];
            [self reloadTableData];
            [refershMessagesArray release];
            [refreshLocalAry release];
        }
    }
}
#pragma mark - IBAction public methods

#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DiaryMessageModel *model = [self.blogArray objectAtIndex:[indexPath row]];
    if (_EditingStatus)
    {
        NewBlogListCell *cell = (NewBlogListCell*)[tableView cellForRowAtIndexPath:indexPath];
        if (model.editStatus == YES)
        {
            [cell setChecked:NO];
            model.editStatus = NO;
            [self.blogEditArray removeObject:model];
        }
        else
        {
            [cell setChecked:YES];
            model.editStatus = YES;
            [self.blogEditArray addObject:model];
        }
    }else
    {
        comeInTime = COME_FORTH;
        DiaryDetailsViewController *diaryDetailsViewController = [[DiaryDetailsViewController alloc] init ];
        diaryDetailsViewController.model = model;
        [self.navigationController pushViewController:diaryDetailsViewController animated:YES];
        [diaryDetailsViewController release];
    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.blogArray count] == 0) {
        self.view.backgroundColor =  RGBCOLOR(238.0, 242.0, 245.0);
        self.tableView.backgroundColor =  [UIColor clearColor];
        _noBlogImg.hidden = NO;
        _noBlogTextImg.hidden = NO;
        self.rightBtn.hidden=YES;
        [self.view sendSubviewToBack:_noBlogImg];
        
    }else{
        self.tableView.backgroundColor =  [UIColor whiteColor];
        self.view.backgroundColor =  [UIColor whiteColor];
        _noBlogImg.hidden = YES;
        _noBlogTextImg.hidden = YES;
        self.rightBtn.hidden=NO;
        
    }
    return [self.blogArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyBlogListViewControllerIdentifier = @"MyBlogListViewControllerIdentifier";
    DiaryMessageModel *model = [self.blogArray objectAtIndex:indexPath.row];

    NewBlogListCell *cell = (NewBlogListCell *)[tableView dequeueReusableCellWithIdentifier:MyBlogListViewControllerIdentifier];
    if (!cell)
    {
        cell = [[[NewBlogListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyBlogListViewControllerIdentifier] autorelease];
    }
    [cell setIsEditing:_EditingStatus];
    [cell setChecked:model.editStatus];
    [cell configCellWithModel:model];
    
    return cell;
}

#pragma mark - SelectListCategoriesDelegate

- (void)EditCategories:(BOOL)isEditGroup selectedGroup:(DiaryGroupsModel *)Model selectedIndex:(NSInteger)selectedIndex
{
    
    if (isEditGroup) {
        EditCategoriesViewController *editCategoriesViewController =[[EditCategoriesViewController alloc] init];
        [self.navigationController pushViewController:editCategoriesViewController animated:YES];
        [editCategoriesViewController release];
    }
    else{
        CGSize middleBtnSize;
        if (Model)
        {
            selectGroupId = [Model.groupId intValue];
            selectedIndexInt = selectedIndex;
            if (_currentGroupModel)
            {
                [_currentGroupModel release];
                _currentGroupModel = nil;
            }
            _currentGroupModel = [Model retain];
            self.blogArray =[DiaryMessageSQL getGroupIDMessages:_currentGroupModel.groupId AndUserId:USERID];
            [self.tableView reloadData];
            middleBtnSize = [_currentGroupModel.title sizeWithFont:[UIFont systemFontOfSize:18.0f]];
            [self.middleBtn setTitle:_currentGroupModel.title forState:UIControlStateNormal];
        }
        else
        {
            _currentGroupModel = nil;
            selectGroupId = -1;
            selectedIndexInt = selectedIndex;
            self.blogArray = [DiaryMessageSQL getMessages:TEXTTYPE AndUserId:USERID];
            [self.tableView reloadData];
            middleBtnSize = [@"书籍" sizeWithFont:[UIFont systemFontOfSize:18.0f]];
            [self.middleBtn setTitle:@"书籍" forState:UIControlStateNormal];
        }
        if (iOS7)
        {
            self.middleBtn.frame = CGRectMake((320 - middleBtnSize.width) / 2, 27, middleBtnSize.width, 30);
        }
        else
        {
            self.middleBtn.frame = CGRectMake((320 - middleBtnSize.width) / 2, 7, middleBtnSize.width, 30);
        }
        CGRect frame = self.middleImage.frame;
        frame.origin.x = self.middleBtn.frame.origin.x + middleBtnSize.width + 2;
        self.middleImage.frame = frame;
    }
}

#pragma mark - ASIFormatDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [UIView animateWithDuration:.2f animations:^{
        _toolBar.frame = CGRectMake(0, viewHeight, 320, 54);
    }];
    [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    
    NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    self.errorcodeStr = [NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"errorcode"]];
    if (tag == REQUEST_FOR_GETBLOGLIST)
    {
        if ([resultStr isEqualToString:@"0"])
        {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"])
            {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }
        else
        {
            if (resultDictionary[@"data"][@"serverversion"] != nil)
            {
                [[NSUserDefaults standardUserDefaults] setValue:resultDictionary[@"data"][@"serverversion"] forKey:DIARYVERSION];
            }
            [DownlaodDebugging synsynchronizeBlogVersionStr:[NSString stringWithFormat:@"%@",[[resultDictionary objectForKey:@"data"] objectForKey:@"serverversion"]] ClientVersionStr:[NSString stringWithFormat:@"%@",[[resultDictionary objectForKey:@"data"] objectForKey:@"clientversion"]] Meta:resultDictionary[@"meta"] synchronizeArr:(NSArray *)[[resultDictionary objectForKey:@"data"] objectForKey:@"list"]];
            [self reloadTableData];
            [self doneLoadingTableViewData];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    if ([Utilities checkNetwork])
    {
        [MyToast showWithText:@"网络链接错误，请检查网络" :140];
    }
}

#pragma mark - ASIHTTPRequest
-(void)requestSuccess:(ASIFormDataRequest *)request
{
    [UIView animateWithDuration:.2f animations:^{
        _toolBar.frame = CGRectMake(0, viewHeight, 320, 54);
    }];
    [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];

    NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    self.errorcodeStr = [NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"errorcode"]];
    if (tag == REQUEST_FOR_CHANGEBLOGGROUP) {

        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            NSDictionary *metaDic = [resultDictionary objectForKey:@"meta"];
            NSString *versionsStr = [metaDic objectForKey:@"versions"];
            NSMutableArray *refershMessagesArray = [[[NSMutableArray alloc] init] autorelease];
            
            for (DiaryMessageModel *blogModel in self.blogEditArray) {
                if ([blogModel.blogId isEqualToString:@"(null)"]||blogModel.blogId ==nil || blogModel.blogId.length == 0)
                {
                    ;
                }
                else
                {
                    NSDate *date = [NSDate date];
                    NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
                    NSString *timeStr = [NSString stringWithFormat:@"%f",timestamp];
                    blogModel.status = @"1";
                    blogModel.needSyn = NO;
                    blogModel.needUpdate = NO;
                    blogModel.lastModifyTime = timeStr;
                    blogModel.syncTime = timeStr;
                    blogModel.localVer = versionsStr;
                    blogModel.serverVer = versionsStr;
                    blogModel.groupId = metaDic[@"groupid"];
                    [refershMessagesArray addObject:blogModel];
                }
            }
            [DiaryMessageSQL  refershMessagesByMessageModelArray:refershMessagesArray];
            [DiaryGroupsSQL moveDiaryFrom:request.userInfo[@"fromGroup"] To:request.userInfo[@"groupId"]];
            [self rightBtnPressed];
            [self reloadTableData];
            __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.mode = MBProgressHUDModeText;
            [self.view addSubview:HUD];
            [HUD release];
            HUD.labelText = @"移动分组成功";
            [HUD showAnimated:YES whileExecutingBlock:^{
                sleep(1);
            } completionBlock:^{
                [HUD removeFromSuperview];
            }];
        }
    }
    if (tag == REQUEST_FOR_DELETBLOG) {
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            NSDictionary *metaDic = [resultDictionary objectForKey:@"meta"];
            NSString *versionsStr = [metaDic objectForKey:@"versions"];
            NSMutableArray *refershMessagesArray = [[NSMutableArray alloc] init];
            for (DiaryMessageModel *blogModel in self.blogEditArray) {
                NSDate *date = [NSDate date];
                NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
                NSString *timeStr = [NSString stringWithFormat:@"%f",timestamp];
                blogModel.status = @"1";
                blogModel.needSyn = NO;
                blogModel.needUpdate = NO;
                blogModel.lastModifyTime = timeStr;
                blogModel.syncTime = timeStr;
                blogModel.localVer = versionsStr;
                blogModel.serverVer = versionsStr;
                [refershMessagesArray addObject:blogModel];
            }
            [DiaryMessageSQL deletePhoto:refershMessagesArray];
            if (selectGroupId == -1)
            {
                [DiaryGroupsSQL deleteDiarysFromGroupIdArr:request.userInfo[@"groupIdArr"]];
            }
            else
            {
                [DiaryGroupsSQL changeDiaryCountWithGroupId:[NSString stringWithFormat:@"%d",selectGroupId] OperateStyle:@"deleteDiary" OperateCount:refershMessagesArray.count];
            }
            [refershMessagesArray release];
            [self rightBtnPressed];
            [self reloadTableData];
         }
    }
}
-(void)requestFail:(ASIFormDataRequest *)request
{
    if ([Utilities checkNetwork])
    {
    [MyToast showWithText:@"网络链接错误，请检查网络" :140];
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	[self synchronizeDiary];
    
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!_EditingStatus) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerat
{
	if (!_EditingStatus) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
        
    }
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
#pragma mark -- alterview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if (buttonIndex == 0) {
        
        if (alertView.tag == 10000 || alertView.tag == 20000) {
            _EditingStatus = NO;
        }
        if ([ self.errorcodeStr isEqualToString:@"1005"]) {
            BOOL isLogin = NO;
            [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            [[EternalMemoryAppDelegate getAppDelegate]  showLoginVC];
        }
        
    }
    
}


@end
