//
//  EditCategoriesViewController.m
//  EternalMemory
//
//  Created by sun on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "EditCategoriesViewController.h"
#import "EternalMemoryAppDelegate.h"
#import "EditCategoriesCell.h"
#import "DiaryGroupsModel.h"
#import "DiaryMessageSQL.h"
#import "DiaryGroupsSQL.h"
#import "FileModel.h"
#import "MyToast.h"
#define CELL_HEIGHT 54
#define TEXTTYPE @"0"
#define REQUEST_FOR_ADDGROUP 100
#define REQUEST_FOR_DELETGROUP 200
#define REQUEST_FOR_MODIFYGROUP 300

#define kAlphaNum   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

@interface EditCategoriesViewController ()
{
    int  deletCellIndex ;
    int  deleteBtnIndexInt;
    BOOL isDeleting;
    BOOL isCreating;
    NSInteger editRow;

    NSString        *modifyIndexStr;
    NSMutableString *_oldTitle;//点击要修改的分组名

    __block ASIFormDataRequest *deleteRequest;
    __block ASIFormDataRequest *modifyRequest;
    __block ASIFormDataRequest *addRequest;
    
}
@property (nonatomic, retain) NSMutableArray  *categoriesArray;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL EditingStatus;
@property (nonatomic, retain) NSString *errorcodeStr ;
@property (nonatomic, copy)   NSMutableString *oldTitle ;

@end

@implementation EditCategoriesViewController
@synthesize  categoriesArray =_categoriesArray;
@synthesize tableView = _tableView;
@synthesize EditingStatus = _EditingStatus;
@synthesize errorcodeStr = _errorcodeStr ;
@synthesize oldTitle = _oldTitle;
#pragma mark - object lifecycle
- (void)dealloc
{
    if (deleteRequest)
    {
        [deleteRequest clearDelegatesAndCancel];
        deleteRequest = nil;
    }
    if (modifyRequest)
    {
        [modifyRequest clearDelegatesAndCancel];
        modifyRequest = nil;
    }
    if (addRequest)
    {
        [addRequest clearDelegatesAndCancel];
        addRequest = nil;
    }
    RELEASE_SAFELY(_tableView);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _EditingStatus = NO;
        _oldTitle = [[NSMutableString alloc] init];
    }
    return self;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.categoriesArray = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isDeleting = NO;
    // Do any additional setup after loading the view from its nib.
    [self setViewData];
    [Utilities setExtraCellLineHidden:self.tableView];
    self.categoriesArray = [DiaryGroupsSQL getDiaryGroups:TEXTTYPE AndUserId:USERID] ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
#pragma mark - private methods
- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightBtnPressed
{
    if (isCreating == YES)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"分类正在创建中，请等待" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        return;
    }
    else if (isDeleting == YES)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"分类正在删除中，请等待" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    if (_EditingStatus) {
        [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        _EditingStatus = NO;
        
    }else{
        [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
        
        _EditingStatus = YES;
    }
    [_tableView reloadData];
}
- (void)setViewData
{
    [self.titleLabel setText:@"撰记分类"];
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = NO;
    [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
}
- (void)addGroupRequest:(NSString *)groupName
{
    isCreating = YES;
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
    NSURL *registerUrl = [[RequestParams sharedInstance] manageGroup];
    addRequest = [[ASIFormDataRequest alloc]initWithURL:registerUrl];
    addRequest.delegate = self;
    addRequest.shouldAttemptPersistentConnection = NO;
    addRequest.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_ADDGROUP],@"tag", nil] ;
    [addRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [addRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [addRequest setPostValue:@"add" forKey:@"operation"];
    [addRequest setPostValue:@"0" forKey:@"type"];
    [addRequest setPostValue:@"0" forKey:@"accesslevel"];
    [addRequest setPostValue:@"" forKey:@"remark"];
    [addRequest setPostValue:[NSString stringWithFormat:@"%f",timestamp]forKey:@"createtime"];
    [addRequest setPostValue:[NSString stringWithFormat:@"%f",timestamp] forKey:@"lastmodifytime"];
    [addRequest setPostValue:groupName forKey:@"title"];
    [addRequest setRequestMethod:@"POST"];
    [addRequest setTimeOutSeconds:30.0];
    __block typeof (self) bself=self;
    [addRequest setCompletionBlock:^{
        [bself requestSuccess:addRequest];
    }];
    [addRequest setFailedBlock:^{
        [bself requestFail:addRequest];
    }];
    [addRequest startAsynchronous];
}
- (void)modifyGroupRequest:(NSString *)groupName  groupId:(NSString *)groupId
{
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
    NSURL *registerUrl = [[RequestParams sharedInstance] manageGroup];
    modifyRequest = [[ASIFormDataRequest alloc]initWithURL:registerUrl];
    modifyRequest.delegate = self;
    modifyRequest.shouldAttemptPersistentConnection = NO;
    modifyRequest.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_MODIFYGROUP],@"tag", nil] ;
    [modifyRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [modifyRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [modifyRequest setPostValue:@"modify" forKey:@"operation"];
    [modifyRequest setPostValue:@"-1" forKey:@"type"];
    [modifyRequest setPostValue:[NSString stringWithFormat:@"%f",timestamp] forKey:@"lastmodifytime"];
    [modifyRequest setPostValue:groupName forKey:@"title"];
    [modifyRequest setPostValue:groupId forKey:@"groupid"];
    [modifyRequest setRequestMethod:@"POST"];
    [modifyRequest setTimeOutSeconds:30.0];
    __block typeof (self) bself=self;
    [modifyRequest setCompletionBlock:^{
        [bself requestSuccess:modifyRequest];
    }];
    [modifyRequest setFailedBlock:^{
        [bself requestFail:modifyRequest];
    }];
    [modifyRequest startAsynchronous];
}
- (void)deletGroupRequest:(NSString *)groupId
{
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
    NSURL *registerUrl = [[RequestParams sharedInstance] manageGroup];
    deleteRequest = [[ASIFormDataRequest alloc]initWithURL:registerUrl];
    deleteRequest.delegate = self;
    deleteRequest.shouldAttemptPersistentConnection = NO;
    deleteRequest.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_DELETGROUP],@"tag", nil] ;
    [deleteRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [deleteRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [deleteRequest setPostValue:@"delete" forKey:@"operation"];
    [deleteRequest setPostValue:@"-1" forKey:@"type"];
    [deleteRequest setPostValue:[NSString stringWithFormat:@"%f",timestamp] forKey:@"lastmodifytime"];
    [deleteRequest setPostValue:groupId forKey:@"groupid"];
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
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    editRow = indexPath.row;
    if ([indexPath row] == 0) {
        if (isCreating == NO)
        {
            if ([Utilities checkNetwork]) {
                [self showAlert];
            }else{
                [MyToast showWithText:@"请检查网络" :140];
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"分类正在创建中，请等待" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
            return;
        }
        
    }
    if (_EditingStatus ==YES &&[indexPath row] != 0) {
       
            DiaryGroupsModel *model = [self.categoriesArray objectAtIndex:indexPath.row-1];
            modifyIndexStr = model.groupId;
            self.oldTitle = (NSMutableString *)model.title;
            [self showRefleshAlert:model.title];

    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.categoriesArray count] == 1) {
        self.rightBtn.hidden=YES;
        [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        _EditingStatus = NO;
    }else{
        self.rightBtn.hidden = NO;
    }
    return [self.categoriesArray count] + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *EditCategoriesCellIdentifier = @"EditCategoriesCellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:EditCategoriesCellIdentifier];
    EditCategoriesCell *deletecell = (EditCategoriesCell *)[tableView dequeueReusableCellWithIdentifier:EditCategoriesCellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] init] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.selectionStyle = UITableViewCellStateDefaultMask;
        UIColor *selectedColor = RGBCOLOR(118,131,141);
        cell.textLabel.textColor = selectedColor;
        [cell.textLabel setText:@"新建分类"];
        cell.userInteractionEnabled = YES;
    }
    if (deletecell == nil) {
        deletecell = [[[EditCategoriesCell viewForNib] retain] autorelease];
        deletecell.selectionStyle = UITableViewCellStateDefaultMask;
        deletecell.delegate = self;
        
    }
    
    if ([indexPath row] != 0) {
        cell.userInteractionEnabled = YES;
        DiaryGroupsModel *model = [self.categoriesArray objectAtIndex:indexPath.row-1];
        [deletecell.titleTF setText:[NSString stringWithFormat:@"%@  (共%@篇)",model.title,model.blogcount]];
        deletecell.deleteBtn.btnIndex = [model.groupId integerValue];
        if ([indexPath row] == 1) {
            deletecell.deleteBtn = nil;
            deletecell.userInteractionEnabled = NO;
        }
        if (_EditingStatus) {
            deletecell.deleteBtn.hidden = NO;
        }else
        {
            deletecell.deleteBtn.hidden = YES;
        }
        return deletecell;
        
    }else{
        cell.imageView.image = [UIImage imageNamed:@"xj.png"];
    }
    return cell;
    
}
#pragma mark - EditCategoriesCellDelegate
- (void)editCategories:(NSInteger)deleteBtnIndex
{
    if (isDeleting == YES)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"分类正在删除中，请等待" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        return;
    }
    for ( DiaryGroupsModel *model in self.categoriesArray) {
        if ([model.groupId integerValue] == deleteBtnIndex) {
            NSMutableArray *blogsArr = [DiaryMessageSQL getGroupIDMessages:model.groupId AndUserId:USERID];
            if (blogsArr.count == 0)
            {
                isDeleting = YES;
                [_tableView reloadData];
                deleteBtnIndexInt = deleteBtnIndex;
                [self deletGroupRequest:model.groupId];
            }
            else
            {
                 [MyToast showWithText:@"请去日记列表页删除日记" :380];
            }

            deletCellIndex =  [self.categoriesArray indexOfObject:model];
        }
    }
}
-(void)showAlert{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新建分类名"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"保存", nil];
    alertView.tag = 100;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textfield = [alertView textFieldAtIndex:0];
    textfield.delegate = self;
    textfield.placeholder = @"新建分类名(不超过6个汉字的长度)";
    if (!(iOS7))
    {
        textfield.font = [UIFont systemFontOfSize:15.0f];
    }
    [alertView show];
    [alertView release];
}
-(void)showRefleshAlert:(NSString *)title{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改组名"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"保存", nil];
    alertView.tag = 200;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.delegate = self;
    textField.text = title;
    [alertView show];
    [alertView release];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length == 0)
    {
        if (string.length != 0)
        {
            NSString * toBeString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSUInteger charLen = [self lenghtWithString:toBeString];
            if (charLen > 16)
            {
                textField.text = [toBeString substringToIndex:16];
                return NO;
            }
        }
    }
    else if (textField.text != 0)
    {
        if (string.length != 0)
        {
            string = [textField.text stringByAppendingString:string];
            NSString * toBeString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSUInteger charLen = [self lenghtWithString:toBeString];
            if (charLen > 16)
            {
                textField.text = [toBeString substringToIndex:7];
                return NO;
            }
        }
        else
        {
            NSString * toBeString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSUInteger charLen = [self lenghtWithString:toBeString];
            if (charLen > 16)
            {
                return NO;
            }
        }
    }
    return YES;
}

- (NSUInteger) lenghtWithString:(NSString *)string
{
    NSUInteger len = string.length;
    // 汉字字符集
    NSString * pattern  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 计算中文字符的个数
    NSInteger numMatch = [regex numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    return len + numMatch;
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
    if (tag == REQUEST_FOR_ADDGROUP) {
        [addRequest release];
        addRequest = nil;
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
             alter.tag = 1000;
            [alter show];
            [alter release];
        }else{
            NSDictionary *dataDic = [resultDictionary objectForKey:@"data"];
//            NSArray *dataArray = [NSArray arrayWithObject:dataDic];
            [DiaryGroupsSQL addDiaryGroups:dataDic];
            self.categoriesArray = [DiaryGroupsSQL getDiaryGroups:TEXTTYPE AndUserId:USERID] ;
            isCreating = NO;
            [self.tableView reloadData];
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            HUD.mode = MBProgressHUDModeText;
            [self.view addSubview:HUD];
            [HUD release];
            HUD.labelText = @"新建分组成功";
            [HUD showAnimated:YES whileExecutingBlock:^{
                sleep(1);
            } completionBlock:^{
                [HUD removeFromSuperview];
                
            }];
        }
    }
    
    if (tag == REQUEST_FOR_DELETGROUP) {
        [deleteRequest release];
        deleteRequest = nil;
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
             alter.tag = 2000;
            [alter show];
            [alter release];
        } else {
            NSDictionary *dataDic = [resultDictionary objectForKey:@"data"];
            [DiaryGroupsSQL deleteDiaryGroup:dataDic];
            [self.categoriesArray removeObjectAtIndex:deletCellIndex];
//            self.titleLabel.text = @"默认日志";
            NSArray *array =[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deletCellIndex + 1 inSection:0]];
            [_tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
            isDeleting = NO;
            [MyToast showWithText:@"分组删除成功" :200];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removeCategoryFromSelectList" object:nil];

        }
    }
    if (tag == REQUEST_FOR_MODIFYGROUP) {
        [modifyRequest release];
        modifyRequest = nil;
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alter.tag = 3000;
            [alter show];
            [alter release];
        }else{
            NSDictionary *dataDic = [resultDictionary objectForKey:@"data"];
            [DiaryGroupsSQL changeDiaryGroup:dataDic];
            self.categoriesArray = [DiaryGroupsSQL getDiaryGroups:TEXTTYPE AndUserId:USERID] ;
            [self.tableView reloadData];
            [MyToast showWithText:@"分组名修改成功" :200];
            if ([FileModel sharedInstance].editSort == editRow) {
                //发通知修改title值
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BtnTitle" object:@{@"btnTitle":dataDic[@"title"]}];
            }
        }
    }
}

-(void)requestFail:(ASIFormDataRequest *)request
{
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    if (tag == REQUEST_FOR_ADDGROUP)
    {
        [addRequest release];
        addRequest = nil;
    }
    if (tag == REQUEST_FOR_DELETGROUP)
    {
        [deleteRequest release];
        deleteRequest = nil;
    }
    if (tag == REQUEST_FOR_MODIFYGROUP)
    {
        [modifyRequest release];
        modifyRequest = nil;
    }
     if ([Utilities checkNetwork]) {
         [MyToast showWithText:@"请求错误，请检查网络" :140];
     }
}

#pragma mark -- alterview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 200 && buttonIndex == 1)
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSInteger length = [self lenghtWithString:textField.text];
        
        if (length == 0)
        {
            [self networkPromptMessage:@"组名请至少包含一个有效字符"];
        }
        else if([self.oldTitle isEqualToString:textField.text])
        {
            return;
        }
        else if (self.oldTitle.length != 0 && length > 12)
        {
            [self networkPromptMessage:@"分组名称不能超过六个汉字的长度"];
        }
        else if (length > 0 && length <=12)
        {
            [self modifyGroupRequest:textField.text groupId:modifyIndexStr];
        }
        
        return;
    }
    
    if (alertView.tag == 1000 ||alertView.tag == 2000 ||alertView.tag == 3000 ) {
         if (buttonIndex == 0&&[ self.errorcodeStr isEqualToString:@"1005"]) {
             BOOL isLogin = NO;
             [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
             [[EternalMemoryAppDelegate getAppDelegate]  showLoginVC];
        }
    }
    if (alertView.tag == 100)
    {
        if (buttonIndex != 1) {
            return;
        }
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        NSString * blanks = @"";
        if (textField.text.length > 0)
        {
            for (int i = 0; i < textField.text.length; i ++)
            {
                blanks = [blanks stringByAppendingString:@" "];
            }
        }
        if ([textField.text isEqualToString:blanks])
        {
            [self networkPromptMessage:@"分组名不能全为空格"];
            return;
        }
        
        NSInteger length = [self lenghtWithString:textField.text];
        if (length == 0 || [textField.text isEqualToString:nil])
        {
            [self networkPromptMessage:@"分组名不能为空"];
            return;
        }
        if (length > 12) {
            [self networkPromptMessage:@"分组名称不能超过六个汉字的长度"];
            return;
        }
        if (alertView.tag != 200) {
            [self addGroupRequest:textField.text];
        }

    }
}

@end
