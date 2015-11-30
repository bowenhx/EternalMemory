//
//  WriteWordsViewController.m
//  EternalMemory
//
//  Created by sun on 13-5-24.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "DiaryDetailsViewController.h"
#import "DiaryGroupsSQL.h"
#import "DiaryMessageModel.h"
#import "DiaryMessageSQL.h"
#import "DiaryGroupsModel.h"
#import "WriteWordsViewController.h"
#import "EternalMemoryAppDelegate.h"
#import "MyBlogListViewController.h"
#import "ActionSheetStringPicker.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "StaticTools.h"
#import "RMWTextView.h"
#import "BaseDatas.h"
#import "MyToast.h"

#define REQUEST_FOR_ADDDIARY 200
#define TEXTViEWX 4
#define TEXTViEWY 49
#define TEXTViEWHEIGHT
#define TEXTViEWWIDTH 305
#define TOOLBARHEIGHT 65
#define REQUEST_FOR_UPDATADIARY 300
#define TEXTVIEWMOSTHEIGHT      (iPhone5)? 400: 312

@interface WriteWordsViewController ()
{
    //    sqlite_int64  lastId;
    NSString     *originGroupId;
    NSString     *originalTitle;
    NSString     *originalcontent;
    NSString     *originalCategory;
    BOOL          originalSwitch;
}
@property (nonatomic, retain) IBOutlet RMWTextView *rMWTextView;
@property (nonatomic, retain) IBOutlet UIView *toolBarView;
@property (nonatomic, retain) IBOutlet UILabel *wordCountLable;
@property (nonatomic, retain) IBOutlet UILabel *journalCategoryLable;
@property (nonatomic, retain) IBOutlet UITextField *titleTextField;
@property (nonatomic, retain) IBOutlet UIButton *JournalCategoryBtn;
@property (nonatomic, retain) IBOutlet UIView   *containerView;
@property (nonatomic, retain) NSArray *JournalCategoryArray;
@property (nonatomic, retain) NSMutableArray *pickerDataArray;
@property (nonatomic, retain) IBOutlet UISwitch *swith;
@property (nonatomic, retain) NSString *errorcodeStr ;
@property (retain, nonatomic) IBOutlet UILabel *showLabel;

@end

@implementation WriteWordsViewController
@synthesize rMWTextView = _rMWTextView;
@synthesize toolBarView = _toolBarView;
@synthesize wordCountLable = _wordCountLable;
@synthesize titleTextField = _titleTextField;
@synthesize selectedIndex = _selectedIndex;
@synthesize JournalCategoryBtn = _JournalCategoryBtn;
@synthesize JournalCategoryArray = _JournalCategoryArray;
@synthesize swith = _swith;
@synthesize blogModel = _blogModel;
@synthesize pickerDataArray = _pickerDataArray;
@synthesize errorcodeStr = _errorcodeStr ;
@synthesize groupId = _groupId;
@synthesize groupName = _groupName;

#pragma mark - object lifecycle
- (void)dealloc
{
    [_request clearDelegatesAndCancel];
    [_request release];
    RELEASE_SAFELY(_rMWTextView);
    RELEASE_SAFELY(_toolBarView);
    RELEASE_SAFELY(_wordCountLable);
    RELEASE_SAFELY(_titleTextField);
    RELEASE_SAFELY(_JournalCategoryBtn);
    RELEASE_SAFELY(_swith);
    RELEASE_SAFELY(_pickerDataArray);
    RELEASE_SAFELY(_containerView);
    if (originalTitle)
    {
        [originalTitle release];
        [originalCategory release];
        [originalcontent release];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_showLabel release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedIndex = 0;
        _pickerDataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.JournalCategoryArray = [DiaryGroupsSQL getDiaryGroups:@"0" AndUserId:USERID];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToMainVC) name:@"popToMain" object:nil];
    [self setViewData];
    self.containerView.frame = (CGRect){
        .origin.x = 0,
        .origin.y = iOS7 ? 64 : 44,
        .size.width  = SCREEN_WIDTH,
        .size.height = self.containerView.frame.size.height
    };
    
    
    self.showLabel.hidden = YES;
    self.swith.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.groupName == nil)
    {
        self.groupId = @"-1";
        originGroupId = @"-1";
        DiaryGroupsModel *model = (DiaryGroupsModel *)self.JournalCategoryArray[0];
        self.journalCategoryLable.text = [NSString stringWithFormat:@"默认日记(%@篇)",model.blogcount];
    }
    NSInteger count = self.JournalCategoryArray.count;
    if (count != 0)
    {
        for (int i = 0; i < count; i ++)
        {
            DiaryGroupsModel *model = (DiaryGroupsModel *)self.JournalCategoryArray[i];
            if ([model.title isEqualToString:self.groupName])
            {
                self.selectedIndex = i;
                self.journalCategoryLable.text = [NSString stringWithFormat:@"%@(%@篇)",self.groupName,model.blogcount];
                self.groupId = model.groupId;
                originGroupId = model.groupId;
                break;
            }
        }
    }
}

-(void)popToMainVC{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods
- (void)actionPickerCancelled:(id)sender {
    
}
- (void)journalCategoryWasSelected:(NSNumber *)selectedIndex element:(id)element {
    self.selectedIndex = [selectedIndex intValue];
    DiaryGroupsModel *model = [self.JournalCategoryArray objectAtIndex:self.selectedIndex];
    self.groupId = model.groupId;
    self.journalCategoryLable.text = [NSString stringWithFormat:@"%@(%@篇)",model.title,model.blogcount];
    
}
- (void)showAlter
{
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"是否保存为编辑内容"
                                                       delegate:self
                                              cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alterView.tag = 1000;
    [alterView show];
    [alterView release];
}
- (void)backBtnPressed
{
    NSString *str = [_titleTextField.text stringByReplacingOccurrencesOfString:@"" withString:@""];
    if (originalTitle != nil && !([originalCategory isEqualToString:_journalCategoryLable.text] && [originalcontent isEqualToString:self.rMWTextView.text] && originalSwitch == self.swith.on && [originalTitle isEqualToString:self.titleTextField.text]))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的日记有所改动，是否取消改动？" delegate:self cancelButtonTitle:@"继续修改" otherButtonTitles:@"取消改动", nil];
        [alertView show];
        alertView.tag = 1001;
        [alertView release];
        return;
    }
    
    else if (str.length == 0  && _rMWTextView.text.length == 0 && originalTitle == nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (!_blogModel){
        if (![_titleTextField.text isEqualToString:_blogModel.title] ||![self.rMWTextView.text isEqualToString:self.blogModel.content] ||![self.rMWTextView.text isEqualToString:self.blogModel.summary]) {
            [self showAlter];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    NSString *diaPathStr = [self dataPath:@"DiatyDic"];
    NSDictionary *diaryDic = [NSDictionary dictionaryWithContentsOfFile:diaPathStr];
    if (diaryDic)
    {
        if (![_titleTextField.text isEqualToString:[diaryDic objectForKey:@"title"]] &&! [_rMWTextView.text isEqualToString:[diaryDic objectForKey:@"content"]]) {
            [self showAlter];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)rightBtnPressed
{
    [_titleTextField resignFirstResponder];
    [_rMWTextView resignFirstResponder];
    [_rMWTextView resignFirstResponder];
    _rMWTextView.frame = CGRectMake(TEXTViEWX, TEXTViEWY, TEXTViEWWIDTH, TEXTVIEWMOSTHEIGHT);
    NSString *str = [_titleTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (str.length == 0)
    {
        [MyToast showWithText:@"请填写日记标题":140];
    }
    else if(str.length >15)
    {
        [MyToast showWithText:@"标题最多为15个字":140];
    }
    else
    {
        self.JournalCategoryBtn.userInteractionEnabled = NO;
        if ([self.titleLabel.text isEqualToString:@"写日记"])
        {
            if (![Utilities checkNetwork])
            {
                netType = 1;
                //无网写入数据库 跳转
                [self addDiaryToMessageTable];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyBlogList" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            else
            {
                //有网添加请求
                netType = 0;
                [self addDiaryRequest:nil andType:0];
            }
        }
        else
        {
            NSDate *date = [NSDate date];
            NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
            NSString *deleteStatusStr = [NSString stringWithFormat:@"0"];
            NSString *dateStr = [NSString stringWithFormat:@"%f",timestamp];
            NSString  *accessLevel = [NSString stringWithFormat:@"0"];
            DiaryGroupsModel *model = [self.JournalCategoryArray objectAtIndex:self.selectedIndex];
            if (_swith.on) {
                accessLevel = [NSString stringWithFormat:@"1"];
            }
            self.blogModel.needDownL = YES;
            self.blogModel.needSyn = YES;
            self.blogModel.needUpdate = YES;
            if ([self.blogModel.blogId isEqualToString:@"(null)"]||self.blogModel.blogId ==nil)
            {
                ;
            }
            else
            {
                self.blogModel.status = @"4";
            }
            self.blogModel.deletestatus = [deleteStatusStr integerValue];
            self.blogModel.accessLevel = accessLevel;
            self.blogModel.lastModifyTime = dateStr;
            self.blogModel.title = _titleTextField.text;
            self.blogModel.content = _rMWTextView.text;
            self.blogModel.groupId = self.groupId;
            self.blogModel.groupname = model.title;
            
            NSString *summaryStr =nil;
            NSMutableString *contentStr = [[[NSMutableString alloc] initWithFormat:@"%@",_rMWTextView.text] autorelease];
            if (contentStr.length > 50) {
                summaryStr = [contentStr substringWithRange:NSMakeRange(0, 50)];
            }else{
                summaryStr = contentStr;
            }
            self.blogModel.summary = summaryStr;
            NSArray *blogArray = [NSArray arrayWithObject:self.blogModel];
            
            if ([Utilities checkNetwork])
            {
                self.rightBtn.userInteractionEnabled = NO;
                self.backBtn.userInteractionEnabled = NO;
                if (self.blogModel.blogId != NULL&&self.blogModel.blogId != nil) {
                    [self upDateDiaryRequest:self.blogModel];
                }else{
                    netType = 1;
                    updateOradd = @"updateToadd";
                    [DiaryMessageSQL deletePhoto:[NSArray arrayWithObject:self.blogModel]];
                    [self addDiaryRequest:self.blogModel andType:1];
                }
            }
            else
            {
                [DiaryMessageSQL refershMessagesByMessageModelArray:blogArray];
                if (![originGroupId isEqualToString:self.groupId])
                {
                    [DiaryGroupsSQL moveDiaryFrom:[NSArray arrayWithObject:originGroupId] To:self.groupId];
                }
                NSDictionary *dataDic=[NSDictionary dictionaryWithObjectsAndKeys:self.blogModel.title,@"title",self.blogModel.content,@"content",self.blogModel.groupname,@"groupName",self.blogModel.createTime,@"createTime", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DiaryDetail" object:dataDic];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}
- (void)setViewData
{
    // nevBar
    self.middleBtn.hidden = YES;
    self.titleLabel.text = @"写日记";
    [self.rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    [_rMWTextView setPlaceholderTextColor:[UIColor lightGrayColor]];
    _rMWTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    _rMWTextView.placeholder = @"正文";
    if (iPhone5) {
        [_toolBarView setFrame:CGRectMake(0, 478, 320, TOOLBARHEIGHT)];
    }else {
        [_toolBarView setFrame:CGRectMake(0, self.view.frame.size.height - TOOLBARHEIGHT, 320, TOOLBARHEIGHT)];
    }
    if (_blogModel) {
        self.titleTextField.text = _blogModel.title;
        originalTitle = [[NSString alloc] initWithString:_blogModel.title];
        self.titleLabel.text = @"编辑日记";
        //        self.rMWTextView.text = _blogModel.content;
        if (self.blogModel.summary && self.blogModel.content && self.blogModel.content.length > 0) {
            self.rMWTextView.text = self.blogModel.content;
        }else if (self.blogModel.summary) {
            self.rMWTextView.text  = self.blogModel.summary;
        }
        originalcontent = [[NSString alloc] initWithString:self.rMWTextView.text];
        if ([_blogModel.accessLevel isEqualToString:@"0"]) {
            self.swith.on = NO;
        }else if ([_blogModel.accessLevel isEqualToString:@"1"]) {
            self.swith.on = YES;
        }
        originalSwitch = self.swith.on;
        for (DiaryGroupsModel *groupModel in self.JournalCategoryArray) {
            if ([groupModel.groupId isEqualToString:_blogModel.groupId]) {
                //                [_JournalCategoryBtn setTitle:groupModel.title forState:UIControlStateNormal];
                [_journalCategoryLable setText:groupModel.title];
                self.selectedIndex = [self.JournalCategoryArray indexOfObject:groupModel];
            }
        }
        originalCategory = [[NSString alloc] initWithString:_journalCategoryLable.text];
        
    }
    NSString *diaPathStr = [self dataPath:@"DiatyDic"];
    NSDictionary *diaryDic = [NSDictionary dictionaryWithContentsOfFile:diaPathStr];
    
    if (diaryDic)
    {
        [_titleTextField setText:[diaryDic objectForKey:@"title"]];
        [_rMWTextView setText:[diaryDic objectForKey:@"content"]];
        NSString *accesslevelStr = [diaryDic objectForKey:@"accesslevel"];
        if ([accesslevelStr isEqualToString:@"0"]) {
            _swith.on = NO;
        }else{
            _swith.on = YES;
        }
        NSArray *groupArray = [DiaryGroupsSQL getDiaryGroupsByGroupId:[diaryDic objectForKey:@"groupId"]];
        DiaryGroupsModel *group = [groupArray objectAtIndex:0];
        for (DiaryGroupsModel *groupModel in self.JournalCategoryArray) {
            
            if ([groupModel.groupId isEqualToString:group.groupId]) {
                [_journalCategoryLable setText:groupModel.title];
                self.selectedIndex = [self.JournalCategoryArray indexOfObject:groupModel];
            }
        }
        [[NSFileManager defaultManager] removeItemAtPath:diaPathStr error:nil];
    }
    [self.view addSubview:_toolBarView];
    [_titleTextField becomeFirstResponder];
    
    for (int i = 0; i < [self.JournalCategoryArray count]; i++) {
        DiaryGroupsModel *model = [self.JournalCategoryArray objectAtIndex:i];
        [ _pickerDataArray addObject:[NSString stringWithFormat:@"%@ (共%@篇)",model.title,model.blogcount]];
    }
    NSString *_wordCountLableStr = [NSString stringWithFormat:@"%i/%i",_rMWTextView.text.length,20000 - _rMWTextView.text.length];
    [_wordCountLable setText:_wordCountLableStr];
}
- (void)addDiaryToMessageTable
{
    NSString * doc = PATH_OF_DOCUMENT;
    NSString * path = [doc stringByAppendingPathComponent:@"memory.db"];
    FMDatabase * db = [FMDatabase databaseWithPath:path];
    db.logsErrors = YES;
    if ([db open]) {
        NSString  *tableName = [NSString stringWithFormat:@"DiaryMessage_%@",USERID];
        NSString  *status=@"2";//noExchange 是1 ，add是2 、delete是3 、update是4
        
        NSString  *blogType = @"0";//0是日记 1是相片
        bool needSyn = 1;
        bool needUpdate = 1;
        bool needDownL = 1;
        
        NSDate *date = [NSDate date];
        NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
        NSString *deleteStatusStr = [NSString stringWithFormat:@"0"];
        NSString  *accessLevel = [NSString stringWithFormat:@"0"];
        NSString *summaryStr = nil;
        NSMutableString *contentStr = [[[NSMutableString alloc] initWithFormat:@"%@",_rMWTextView.text] autorelease];
        if (contentStr.length > 50) {
            summaryStr = [contentStr substringWithRange:NSMakeRange(0, 50)];
        }else{
            summaryStr = contentStr;
        }
        
        if (_swith.on) {
            accessLevel = [NSString stringWithFormat:@"1"];;
        }
        NSNumber *accessLevelNum = [NSNumber numberWithBool:[accessLevel boolValue]];
        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (blogType,blogId,summary,content,groupid,groupname,title,accessLevel,status,needSyn,needUpdate,needDownL,createTime,deleteStatus,size,lastModifyTime,syncTime,remark,userId) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
        if ([db executeUpdate:sqlStr,blogType,@"",summaryStr,contentStr,self.groupId,self.groupName,_titleTextField.text,accessLevelNum,status,[NSNumber numberWithBool:needSyn] ,[NSNumber numberWithBool:needUpdate], [NSNumber numberWithBool:needDownL],[NSString stringWithFormat:@"%f",timestamp],deleteStatusStr,@"",@"",@"",@"",USERID])
        {
            //            lastId=[db lastInsertRowId];
            [DiaryGroupsSQL changeDiaryCountWithGroupId:self.groupId OperateStyle:@"addDiary" OperateCount:1];
        }
        else{
        }
        
    }
    [db close];
}

/**
 *	写日记请求
 *
 *	@param	messageModel	数据模型
 *	@param	a	类型
 */
- (void)addDiaryRequest:(DiaryMessageModel *)messageModel andType:(NSInteger)a
{
    [_titleTextField resignFirstResponder];
    if (_titleTextField.text.length == 0) {
        [MyToast showWithText:@"请填写日记标题":140];
        
    }else{
        [self showMBProgressHud:@"正在保存..."];
        self.rightBtn.userInteractionEnabled = NO;
        self.backBtn.userInteractionEnabled = NO;
        NSDate *date = [NSDate date];
        NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
        //        DiaryPictureClassificationModel *model = [self.JournalCategoryArray objectAtIndex:self.selectedIndex];
        NSString *accesslevelStr;
        if (_swith.on == YES) {
            accesslevelStr = [NSString stringWithFormat:@"1"];
        }else{
            accesslevelStr = [NSString stringWithFormat:@"0"];
        }
        NSURL *registerUrl = [[RequestParams sharedInstance] addblog];
        _request = [[ASIFormDataRequest alloc] initWithURL:registerUrl];
        _request.shouldAttemptPersistentConnection = NO;
        _request.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_ADDDIARY],@"tag", nil] ;
        [_request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
        [_request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
        [_request setPostValue:@"0" forKey:@"blogtype"];
        if (a == 0) {
            //            lastId=[MessageSQL getMaxId]+1;
            DiaryGroupsModel *model = [self.JournalCategoryArray objectAtIndex:self.selectedIndex];
            [_request setPostValue:model.groupId forKey:@"groupid"];
            //            [_request setPostValue:[NSString stringWithFormat:@"%lld",lastId] forKey:@"clientid"];
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *creatDate=[dateFormatter dateFromString:messageModel.createTime];
            NSDate *modifyDate=[dateFormatter dateFromString:messageModel.lastModifyTime];
            NSTimeInterval timeStamp1=[creatDate timeIntervalSince1970]*1000;
            NSTimeInterval timeStamp2=[modifyDate timeIntervalSince1970]*1000;
            [dateFormatter release];
            [_request setPostValue:[NSString stringWithFormat:@"%f",timeStamp1]forKey:@"createtime"];
            [_request setPostValue:[NSString stringWithFormat:@"%f",timeStamp2] forKey:@"lastmodifytime"];
        }else if (a == 1){
            [_request setPostValue:messageModel.groupId forKey:@"groupid"];
            [_request setPostValue:[NSString stringWithFormat:@"%d",messageModel.ID] forKey:@"clientid"];
            [_request setPostValue:[NSString stringWithFormat:@"%f",timestamp]forKey:@"createtime"];
            [_request setPostValue:[NSString stringWithFormat:@"%f",timestamp] forKey:@"lastmodifytime"];
        }
        [_request setPostValue:accesslevelStr forKey:@"accesslevel"];
        [_request setPostValue:_titleTextField.text forKey:@"title"];
        [_request setPostValue:_rMWTextView.text forKey:@"content"];
        [_request setPostValue:@"" forKey:@"remark"];
        [_request setRequestMethod:@"POST"];
        [_request setTimeOutSeconds:30.0];
        __block typeof(self) bself=self;
        [_request setCompletionBlock:^{
            [bself requestSuccess:_request];
        }];
        [_request setFailedBlock:^{
            [bself requestFail:_request];
        }];
        [_request startAsynchronous];
        
    }
}
- (void)showMBProgressHud:(NSString *)message
{
    _mb = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_mb];
    _mb.labelText = message;
    _mb.mode = MBProgressHUDModeText;
    _mb.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
    [_mb showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [_mb removeFromSuperview];
        [_mb release];
    }];
    
}
- (void)upDateDiaryRequest:(DiaryMessageModel *)blog
{
    [self showMBProgressHud:@"更新中..."];
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
    
    NSString *dateStr = [NSString stringWithFormat:@"%f",timestamp];
    DiaryGroupsModel *model = [self.JournalCategoryArray objectAtIndex:self.selectedIndex];
    NSString  *accessLevel =[NSString stringWithFormat:@"0"];
    if (_swith.on) {
        accessLevel = [NSString stringWithFormat:@"1"];
    }
    
    self.blogModel.accessLevel = accessLevel;
    self.blogModel.lastModifyTime = dateStr;
    self.blogModel.title = _titleTextField.text;
    self.blogModel.content = _rMWTextView.text;
    self.blogModel.groupId = model.groupId;
    self.blogModel.groupname = model.title;
    
    NSURL *registerUrl = [[RequestParams sharedInstance] editBlog];
    _request = [[ASIFormDataRequest alloc] initWithURL:registerUrl];
    _request.shouldAttemptPersistentConnection = NO;
    _request.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_UPDATADIARY],@"tag", nil] ;
    [_request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_request setPostValue:@"0" forKey:@"blogtype"];
    [_request setPostValue:self.blogModel.groupId forKey:@"groupid"];
    [_request setPostValue:accessLevel forKey:@"accesslevel"];
    [_request setPostValue:self.blogModel.title forKey:@"title"];
    [_request setPostValue:self.blogModel.content forKey:@"content"];
    [_request setPostValue:@"" forKey:@"remark"];
    [_request setPostValue:dateStr forKey:@"lastmodifytime"];
    [_request setPostValue:self.blogModel.blogId forKey:@"blogid"];
    [_request setRequestMethod:@"POST"];
    [_request setTimeOutSeconds:30.0];
    __block typeof (self) bself=self;
    [_request setCompletionBlock:^{
        [bself requestSuccess:_request];
    }];
    [_request setFailedBlock:^{
        [bself requestFail:_request];
    }];
    [_request startAsynchronous];
    
}


#pragma mark - IBAction methods
- (IBAction)selectABlock:(UIControl *)sender
{
    [ActionSheetStringPicker showPickerWithTitle:@"请选择分组" rows: _pickerDataArray   initialSelection:self.selectedIndex target:self successAction:@selector(journalCategoryWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.2 animations:^{
        NSDictionary *info = [notification userInfo];
        NSValue* value = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
        CGSize keyboardSize = [value CGRectValue].size;
        [_toolBarView setFrame:CGRectMake(0,  self.view.frame.size.height - keyboardSize.height - TOOLBARHEIGHT, 320, TOOLBARHEIGHT)];
        if (iPhone5)
        {
            [_rMWTextView setFrame:CGRectMake(TEXTViEWX, TEXTViEWY, TEXTViEWWIDTH,  self.view.frame.size.height - keyboardSize.height - TOOLBARHEIGHT - 44 - TEXTViEWY - 20)];
        }
        else
        {
            [_rMWTextView setFrame:CGRectMake(TEXTViEWX, TEXTViEWY, TEXTViEWWIDTH,  self.view.frame.size.height - keyboardSize.height - TOOLBARHEIGHT - 44 - TEXTViEWY)];
        }
        [self.view addSubview:_toolBarView];
    }];
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.2 animations:^{
        [_toolBarView setFrame:CGRectMake(0, self.view.frame.size.height - TOOLBARHEIGHT, 320, TOOLBARHEIGHT)];
        [_rMWTextView setFrame:CGRectMake(TEXTViEWX, TEXTViEWY, TEXTViEWWIDTH, 280)];
        [self.view addSubview:_toolBarView]; 
    }];
}
#pragma mark - textView

- (void)textViewDidChange:(UITextView *)textView
{
    if (_rMWTextView.text.length > 20000)
    {
        _rMWTextView.frame = CGRectMake(TEXTViEWX, TEXTViEWY, TEXTViEWWIDTH, TEXTVIEWMOSTHEIGHT);
        @try {
            _rMWTextView.text = [_rMWTextView.text substringToIndex:20000];
        }
        @catch (NSException *exception) {
        }
        @finally {
            NSString *_wordCountLableStr = [NSString stringWithFormat:@"%i/%i",_rMWTextView.text.length,0];
            [_wordCountLable setText:_wordCountLableStr];
            [MyToast showWithText:@"您编辑的日记超过了最大长度":140];
        }
        [_rMWTextView resignFirstResponder];
    }
    else
    {
        NSString *_wordCountLableStr = [NSString stringWithFormat:@"%i/%i",_rMWTextView.text.length,20000 - _rMWTextView.text.length];
        [_wordCountLable setText:_wordCountLableStr];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if (_rMWTextView.text.length > 20000)
    {
        return NO;
    }
    else
    {
        NSInteger leftLength = 20000 - _rMWTextView.text.length;
        if (text.length > leftLength)
        {
            _rMWTextView.text = [_rMWTextView.text stringByAppendingString:[text substringToIndex:leftLength]];
        }
        return YES;
    }
    return YES;
}
#pragma mark - textField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length == 0)
    {
        if (string.length != 0)
        {
            NSRange textrange = [string rangeOfString:string];
            if (textrange.length > 15)
            {
                [MyToast showWithText:@"标题最多为15个汉字的长度":140];
                _titleTextField.text = [string substringWithRange:NSMakeRange(0, 15)];
                return NO;
            }
        }
    }
    else
    {
        if (string.length != 0)
        {
            string = [textField.text stringByAppendingString:string];
            NSRange textrange = [string rangeOfString:string];
            
            if (textrange.length > 15)
            {
                [MyToast showWithText:@"标题最多为15个汉字的长度":140];
                _titleTextField.text = [string substringWithRange:NSMakeRange(0, 15)];
                return NO;
            }
        }
        else
        {
            NSRange textrange = [textField.text rangeOfString:textField.text];
            if (textrange.length > 15)
            {
                [MyToast showWithText:@"标题最多为15个汉字的长度":140];
                _titleTextField.text = [_titleTextField.text substringWithRange:NSMakeRange(0, 15)];
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - ASIHTTPRequest
-(void)requestSuccess:(ASIFormDataRequest *)request
{
    self.rightBtn.userInteractionEnabled = YES;
    self.backBtn.userInteractionEnabled = YES;
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    self.errorcodeStr = [NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"errorcode"]];
    if (tag == REQUEST_FOR_ADDDIARY) {
        
        if ([resultStr isEqualToString:@"0"])
        {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }
        else
        {
            NSDictionary *dataDic =[resultDictionary objectForKey:@"data"];
            NSArray *blogArray = [NSArray arrayWithObject:dataDic];
            [DiaryMessageSQL synchronizeBlog:blogArray WithUserID:USERID];
            [DiaryGroupsSQL changeDiaryCountWithGroupId:self.groupId OperateStyle:@"addDiary" OperateCount:1];
            if ([updateOradd isEqualToString:@"updateToadd"]) {
                NSDictionary *data=[NSDictionary dictionaryWithObjectsAndKeys:[dataDic objectForKey:@"title"],@"title",[dataDic objectForKey:@"content"],@"content",_journalCategoryLable.text,@"groupName",[dataDic objectForKey:@"createTime"],@"createTime", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DiaryDetail" object:data];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyBlogList" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    if (tag == REQUEST_FOR_UPDATADIARY) {
        
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            NSMutableDictionary *dataDic =[[NSMutableDictionary alloc] initWithCapacity:0];
            [dataDic addEntriesFromDictionary:[resultDictionary objectForKey:@"data"]];
            NSArray *blogArray = [NSArray arrayWithObject:dataDic];
            [DiaryMessageSQL synchronizeBlog:blogArray WithUserID:USERID];
            if (![originGroupId isEqualToString:self.groupId])
            {
                [DiaryGroupsSQL moveDiaryFrom:[NSArray arrayWithObject:originGroupId] To:self.groupId];
            }
            [dataDic setObject:_journalCategoryLable.text forKey:@"groupName"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DiaryDetail" object:dataDic];
            [dataDic release];
            [MyToast showWithText:@"修改日记成功" :[UIScreen mainScreen].bounds.size.height/2-40];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
-(void)requestFail:(ASIFormDataRequest *)request
{
    self.rightBtn.userInteractionEnabled = YES;
    self.backBtn.userInteractionEnabled = YES;
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [[EternalMemoryAppDelegate getAppDelegate].window addSubview:HUD];
    HUD.labelText = @"请检查网络";
    HUD.mode = MBProgressHUDModeText;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        [HUD release];
    }];
    
    if ([Utilities checkNetwork]) {
        [MyToast showWithText:@"请求错误，请检查网络" :140];
    }
}
#pragma mark -- alterview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        if (buttonIndex == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            ;
        }
    }
    else
    {
        if (buttonIndex == 0) {
            
            if ([ self.errorcodeStr isEqualToString:@"1005"]) {
                BOOL isLogin = NO;
                [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
                [[EternalMemoryAppDelegate getAppDelegate]  showLoginVC];
            }
            if (alertView.tag == 1000) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *dicPath = [self dataPath:@"DiatyDic"];
                [fileManager removeItemAtPath:dicPath error:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        if ( buttonIndex == 1 && alertView.tag == 1000) {
            DiaryGroupsModel *model = [self.JournalCategoryArray objectAtIndex:self.selectedIndex];
            NSString *accesslevelStr;
            if (_swith.on == YES) {
                accesslevelStr = [NSString stringWithFormat:@"1"];
            }else{
                accesslevelStr = [NSString stringWithFormat:@"0"];
            }
            NSArray *objectsArray  = [NSArray arrayWithObjects:_titleTextField.text,_rMWTextView.text,accesslevelStr,model.groupId,model.title,nil];
            NSString *titleStr = [NSString stringWithFormat:@"title"];
            NSString *contentStr = [NSString stringWithFormat:@"content"];
            NSString *accessStr = [NSString stringWithFormat:@"accesslevel"];
            NSString *groupIdStr = [NSString stringWithFormat:@"groupId"];
            NSString *groupNameStr = [NSString stringWithFormat:@"groupName"];
            NSArray *keysArray  = [NSArray arrayWithObjects:titleStr,contentStr,accessStr,groupIdStr,groupNameStr,nil];
            NSDictionary *diaryDic = [[NSDictionary alloc] initWithObjects:objectsArray forKeys:keysArray];
            [self saveDiary:diaryDic withName:@"DiatyDic"];
            [diaryDic release];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - 保存日志至沙盒
- (void) saveDiary:( NSDictionary *)currentDiaryInfo withName:(NSString *)diaryName
{
    NSString *fullPath = [self dataPath:diaryName];
    [currentDiaryInfo writeToFile:fullPath atomically:NO];
}
- (NSString *)dataPath:(NSString *)file
{
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"ETMemory"] stringByAppendingPathComponent:@"Diarys"];
    NSString *usernameStr = [[SavaData  parseDicFromFile:User_File] objectForKey:@"userName"];
    NSString *fullPath = [path stringByAppendingPathComponent:usernameStr] ;
    BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSAssert(bo,@"创建Diarys目录失败");
    NSString *result = [fullPath stringByAppendingPathComponent:file];
    return result;
}
@end
