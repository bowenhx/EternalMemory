//
//  EditPhotoAlbumsViewController.m
//  EternalMemory
//
//  Created by sun on 13-6-6.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "EditPhotoAlbumsViewController.h"
#import "NewPhotosCategoryCell.h"
#import "RMWTextView.h"
#import "DiaryPictureClassificationModel.h"
#import "DiaryPictureClassificationSQL.h"
#import "EternalMemoryAppDelegate.h"
#import "MyToast.h"
#import "PhotoAlbumsViewController.h"
#define PHOTOTEXT @"1"
#define REQUEST_FOR_MODIFYGROUP 100
#define  REQUEST_FOR_DELETGROUP 200

@interface EditPhotoAlbumsViewController ()
{
    BOOL isdelete;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, copy)   NSString *textViewText;
@property (nonatomic, retain) RMWTextView *textView;
@property (nonatomic, copy)   NSString *titleTextViewText;
@property (nonatomic, copy)   NSString *contentTextViewText;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic, retain) IBOutlet UISwitch *swith;
@property (nonatomic, copy  ) NSString *errorcodeStr ;
@property (nonatomic, retain) IBOutlet UIButton *deleteBtn;

- (IBAction)viewResignFirstResponder;
- (IBAction)deleteGroup;
@end

@implementation EditPhotoAlbumsViewController
@synthesize tableView = _tableView;
@synthesize textViewText = _textViewText;
@synthesize textView = _textView;
@synthesize selectGroupInt = _selectGroupInt;
@synthesize swith = _swith;
@synthesize titleTextViewText = _titleTextViewText;
@synthesize contentTextViewText = _contentTextViewText;
@synthesize errorcodeStr = _errorcodeStr ;
#pragma mark - object lifecycle
- (void)dealloc
{
    RELEASE_SAFELY(_titleTextViewText);
    RELEASE_SAFELY(_contentTextViewText);
    RELEASE_SAFELY(_textViewText);
    RELEASE_SAFELY(_titleTextField);
    RELEASE_SAFELY(_tableView);
    RELEASE_SAFELY(_textView);
    RELEASE_SAFELY(_swith);
    RELEASE_SAFELY(_errorcodeStr);
    RELEASE_SAFELY(_deleteBtn);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isdelete = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setViewData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
- (void)backBtnPressed
{
    if (isdelete == NO)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        for (UIViewController *controller in self.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[PhotoAlbumsViewController  class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
}
- (void)rightBtnPressed
{
    CGSize size=[_titleTextField.text sizeWithFont:[UIFont systemFontOfSize:17.0f]];
    NSString *str = [_titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (str.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入正确的分组名称" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    self.contentTextViewText = _textView.text;
    NSUInteger strLength = str.length;
    if (size.width == 0) {
        [MyToast showWithText:@"请输入相册名称" :[UIScreen mainScreen].bounds.size.height/2-40];
        return;
    }
    if (strLength > 6) {
        [MyToast showWithText:@"相册分组名最多输入六中文字符" :[UIScreen mainScreen].bounds.size.height/2-40];
        return;
    }
    if (_contentTextViewText.length>140) {
        [MyToast showWithText:@"相册描述最多输入140个汉字" :[UIScreen mainScreen].bounds.size.height/2-40];
        return;
    }
    [self editGroupRequest];

//    if (_titleTextViewText.length > 0 ) {
//        [self editGroupRequest];
//    }else{
//        [MyToast showWithText:@"请输入相册名称" :[UIScreen mainScreen].bounds.size.height/2-40];
//    }
   
}
- (void)setViewData
{
    // nevBar
    self.middleBtn.hidden = YES;
    self.titleLabel.text = @"编辑分类";
    [self.rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    self.textView.delegate = self;
}

#pragma mark - IBAction methods,public methods
- (IBAction)viewResignFirstResponder
{
    [self.textView resignFirstResponder];
}
- (IBAction)deleteGroup
{
    [self deleteGroupRequest];
}
#pragma mark - http 
- (void)editGroupRequest
{
    NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];
    DiaryPictureClassificationModel *model = [groupArray objectAtIndex:[_selectGroupInt intValue]];
    NSString  *accessLevel = @"0";
    if (_swith.on) {
        accessLevel = @"1";
    }
    NSURL *registerUrl = [[RequestParams sharedInstance] manageGroup];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:registerUrl];
    request.delegate = self;
    request.shouldAttemptPersistentConnection = NO;
    request.userInfo =[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_MODIFYGROUP],@"tag", nil] ;
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:@"modify" forKey:@"operation"];
    [request setPostValue:model.groupId forKey:@"groupid"];
    [request setPostValue:accessLevel forKey:@"accessLevel"];
    [request setPostValue:_titleTextField.text forKey:@"title"];
    [request setPostValue:_contentTextViewText forKey:@"remark"];
    [request setRequestMethod:@"POST"];
    __block typeof(self) bself = self;
    [request setTimeOutSeconds:30.0];
    [request setCompletionBlock:^{
        [bself requestSuccess:request];
    }];
    [request setFailedBlock:^{
        [bself requestFail:request];
        [_deleteBtn setEnabled:YES];
    }];
    [request setStartedBlock:^{
        [_deleteBtn setEnabled:NO];
    }];
    [request startAsynchronous];

}
- (void)deleteGroupRequest
{
    NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];
    DiaryPictureClassificationModel *model = [groupArray objectAtIndex:[_selectGroupInt intValue]];
    NSURL *registerUrl = [[RequestParams sharedInstance] manageGroup];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:registerUrl];
    request.delegate = self;
    request.shouldAttemptPersistentConnection = NO;
    request.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_DELETGROUP],@"tag", nil] ;
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:@"delete" forKey:@"operation"];
    [request setPostValue:model.groupId forKey:@"groupid"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:30.0];
    __block typeof(self) bself = self;
    [request setCompletionBlock:^{
        [bself requestSuccess:request];
    }];
    [request setFailedBlock:^{
        [bself requestFail:request];
    }];
    [request startAsynchronous];
}
#pragma mark -UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row == 0 ) {
        return 50;
    }else{
//        if (_cellHeight <50) {
//            _cellHeight = 50;
//            return 50;
//        }else{
//            return _cellHeight;
//        }
        return 100;
    }
}
#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];
    DiaryPictureClassificationModel *model = [groupArray objectAtIndex:[_selectGroupInt intValue]];
    if (indexPath.row == 0) {
        UITableViewCell *cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        for(UIView * aView in cell.contentView.subviews){
            [aView removeFromSuperview];
        }
        cell.backgroundColor=[UIColor whiteColor];
        UILabel *aLabel=[[UILabel alloc] initWithFrame:CGRectMake(22, 14, 42, 21)];
        aLabel.font=[UIFont systemFontOfSize:17.0f];
        [aLabel setBackgroundColor:[UIColor clearColor]];
        aLabel.text=@"名称";
        aLabel.textColor=[UIColor colorWithRed:118/255. green:131/255. blue:141/255. alpha:1.0];
        [cell.contentView addSubview:aLabel];
        [aLabel release];
//        
        _titleTextField=[[UITextField alloc] initWithFrame:CGRectMake(82, 6, 218, 38)];
        _titleTextField.delegate=self;
        [_titleTextField setText:model.title];
        _titleTextField.textColor=[UIColor colorWithRed:118/255. green:131/255. blue:141/255. alpha:1.0];
        _titleTextField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        _titleTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
        [cell.contentView addSubview:_titleTextField];
        
        if (_titleTextViewText.length!=0) {
            _titleTextField.text=_titleTextViewText;
        }
        return cell;
    }
    if (indexPath.row == 1) {
        static NSString *CreatePhotosCategoryViewControllerIdentifier = @"CreatePhotosCategoryViewControllerIdentifier";
        NewPhotosCategoryCell *cell = (NewPhotosCategoryCell *)[tableView dequeueReusableCellWithIdentifier:CreatePhotosCategoryViewControllerIdentifier];
        if (cell == nil) {
            cell = [[[NewPhotosCategoryCell viewForNib] retain] autorelease];
            [cell.textView setPlaceholderTextColor:[UIColor lightGrayColor]];
            cell.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
            self.textView = cell.textView;
            self.textView.delegate = self;
        }
        [self.textView setText:model.remark];
        //        [self.textView setPlaceholder:model.remark];
        [cell.lable setText:@"描述"];
        self.textView.tag = 200;
        self.contentTextViewText=self.textView.text;
        return cell;
    }
    return nil;
//    int row=[indexPath row];40082033333
//    static NSString *CreatePhotosCategoryViewControllerIdentifier = @"CreatePhotosCategoryViewControllerIdentifier";
//    NewPhotosCategoryCell *cell = (NewPhotosCategoryCell *)[tableView dequeueReusableCellWithIdentifier:CreatePhotosCategoryViewControllerIdentifier];
//
//    if (cell == nil) {
//        cell = [[[NewPhotosCategoryCell viewForNib] retain] autorelease];
//        [cell.textView setPlaceholderTextColor:[UIColor lightGrayColor]];
//        cell.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
//        self.textView = cell.textView;
//        self.textView.delegate = self;
//    }
//    if (row == 0) {
//        [cell.lable setText:@"名称"];
////TODO by ZGL
//        [self.textView setText:model.title];
////        [self.textView setPlaceholder:model.title];
//        self.textView.tag = 100;
//        self.titleTextViewText=self.textView.text;
//    }else{
//        [self.textView setText:model.remark];
////        [self.textView setPlaceholder:model.remark];
//        [cell.lable setText:@"描述"];
//        self.textView.tag = 200;
//        self.contentTextViewText=self.textView.text;
//    }
//    return cell;
}
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_titleTextField.isFirstResponder) {
        [_titleTextField resignFirstResponder];
    }
    RMWTextView *aTextView = (RMWTextView *)[self.view viewWithTag:200];
    if (aTextView.isFirstResponder) {
        [aTextView resignFirstResponder];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.titleTextViewText=textField.text;
}
#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.tag == 200) {
//        self.contentTextViewText = textView.text;
//        self.cellHeight = textView.contentSize.height;
//        [self.tableView beginUpdates];
//        [self.tableView endUpdates];
//        
//        static NSInteger axisY = 234;
//        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//        CGRect frame = [cell convertRect:cell.frame toView:self.view];
//        CGFloat offset = abs(274 - axisY - frame.size.height);
//        _tableView.contentOffset = CGPointMake(0, offset);
    
    }

}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
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
    if (tag == REQUEST_FOR_MODIFYGROUP) {
        
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
            NSArray *dataArray = [NSArray arrayWithObject:dataDic];
            [DiaryPictureClassificationSQL refersh:dataArray];
            [MyToast showWithText:@"编辑相册分类成功" :[UIScreen mainScreen].bounds.size.height/2-40];
            isdelete = NO;
//TODO ZGL
            NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:_titleTextField.text,@"albumName",self.contentTextViewText,@"albumContent", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"myAlbum" object:dic];
//            if (_editDelegate&&[_editDelegate respondsToSelector:@selector(popToPhotoAlbumVC)]) {
                [self.navigationController popViewControllerAnimated:NO];
//                [_editDelegate reloadPhotoes1:YES];
//            }
            
//            [self.navigationController popViewControllerAnimated:YES];
//            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"编辑成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            alert.tag=120;
//            [alert show];
//            [alert release];
        }
        
    }
    if (tag == REQUEST_FOR_DELETGROUP) {
        
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
             alter.tag = 2000;
            [alter show];
            [alter release];
        }else{
            NSDictionary *dataDic = [resultDictionary objectForKey:@"data"];
            NSArray *dataArray = [NSArray arrayWithObject:dataDic];
            [DiaryPictureClassificationSQL refersh:dataArray];
            [MyToast showWithText:@"删除相册分类成功" :[UIScreen mainScreen].bounds.size.height/2-40];
            isdelete = YES;
 //TODO ZGL
            if (_editDelegate&&[_editDelegate respondsToSelector:@selector(popToPhotoAlbumVC)]) {
                [self.navigationController popViewControllerAnimated:NO];
                [_editDelegate popToPhotoAlbumVC];
            }
//            [self.navigationController popViewControllerAnimated:YES];
//            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"删除分类成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            alert.tag=110;
//            [alert show];
//            [alert release];
            
        }
    }

}

-(void)requestFail:(ASIFormDataRequest *)request
{ if ([Utilities checkNetwork]) {
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    NSString  *text = nil;
    if (tag == REQUEST_FOR_MODIFYGROUP) {
        text=@"保存分组成功";
    }
    if (tag == REQUEST_FOR_DELETGROUP) {
        text=@"删除分组失败";
    }
    [MyToast showWithText:text :[UIScreen mainScreen].bounds.size.height/2-40];
    }
    
    [MyToast showWithText:@"网络连接异常，操作失败" :[UIScreen mainScreen].bounds.size.height/2-40];
}

#pragma mark -- alterview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1000 ||  alertView.tag == 2000) {
         if (buttonIndex == 0&&[ self.errorcodeStr isEqualToString:@"1005"]) {
             BOOL isLogin = NO;
             [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            [[EternalMemoryAppDelegate getAppDelegate]  showLoginVC];
        }
    }
//    if (alertView.tag == 110) {
//        if (_editDelegate&&[_editDelegate respondsToSelector:@selector(popToPhotoAlbumVC)]) {
//            [self.navigationController popViewControllerAnimated:NO];
//            [_editDelegate popToPhotoAlbumVC];
//        }
//    }
//    if (alertView.tag == 120) {
//        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:self.titleTextViewText,@"albumName",self.contentTextViewText,@"albumContent", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"myAlbum" object:dic];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

@end
