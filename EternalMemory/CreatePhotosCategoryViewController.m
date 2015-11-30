//
//  CreatePhotosCategoryViewController.m
//  EternalMemory
//
//  Created by sun on 13-5-22.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CreatePhotosCategoryViewController.h"
#import "NewPhotosCategoryCell.h"
#import "RMWTextView.h"
#import "DiaryPictureClassificationSQL.h"
#import "PhotoAlbumsViewController.h"
#import "EternalMemoryAppDelegate.h"
#import "MyToast.h"
#define PHOTOTYPE @"1"
#define REQUEST_FOR_ADDGROUP 100
#define IS_CH_SYMBOL(chr)           ((int)(chr) > 127)

@interface CreatePhotosCategoryViewController ()

@property (nonatomic, retain) IBOutlet UITableView  *tableView;
@property (nonatomic, retain) IBOutlet UISwitch     *swith;
@property (nonatomic, copy)   NSString *titleTextViewText;
@property (nonatomic, copy)   NSString *contentTextViewText;
@property (nonatomic, copy)   NSString *errorcodeStr ;
@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain) RMWTextView *textView;

@property (nonatomic) CGFloat cellHeight;


@end

@implementation CreatePhotosCategoryViewController

@synthesize tableView           = _tableView;
@synthesize titleTextViewText   = _titleTextViewText;
@synthesize contentTextViewText = _contentTextViewText;
@synthesize textView            = _textView;
@synthesize swith               = _swith;
@synthesize errorcodeStr        = _errorcodeStr ;
#pragma mark - object lifecycle
- (void)dealloc
{
    RELEASE_SAFELY(_titleTextViewText);
    RELEASE_SAFELY(_contentTextViewText);
    RELEASE_SAFELY(_titleTextField);
    RELEASE_SAFELY(_tableView);
    RELEASE_SAFELY(_textView);
    RELEASE_SAFELY(_errorcodeStr);
    RELEASE_SAFELY(_swith);
    
    [self removeObserver:self forKeyPath:@"_cellHeight"];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.cellHeight = 50;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setViewData];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewResignFirstResponder)];
    [_tableView addGestureRecognizer:tapGesture];
    [tapGesture release];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testFun:) name:UIMenuControllerDidShowMenuNotification object:nil];
    [self addObserver:self forKeyPath:@"_cellHeight" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"_cellHeight"]) {
        
        CGFloat new = [change[NSKeyValueChangeNewKey] floatValue];
        CGFloat old = [change[NSKeyValueChangeOldKey] floatValue];
        if (new != old) {
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            CGRect frame = [cell convertRect:cell.frame toView:self.view];
            CGFloat eieieiei = frame.origin.y + frame.size.height;
            CGFloat offset = eieieiei - 274;
            offset < 0 ? offset = 0 : offset ;
            _tableView.contentOffset = CGPointMake(0, offset);
        }
    }
}





- (void)testFun:(NSNotification *)notification
{
    
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
    [_textView resignFirstResponder];
    [_titleTextField resignFirstResponder];
    self.contentTextViewText = _textView.text;
    NSString *str  = [_titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (str.length == 0) {
        [MyToast showWithText:@"请输入相册名称" :[UIScreen mainScreen].bounds.size.height/2-40];
        return;
    }
    if (str.length > 6) {
        [MyToast showWithText:@"相册分组名最多输入六个中文字符" :[UIScreen mainScreen].bounds.size.height/2-40];
        return;
    }
    if (_contentTextViewText.length>140) {
        [MyToast showWithText:@"相册描述最多输入140个中文字符" :[UIScreen mainScreen].bounds.size.height/2-40];
        return;
    }
    [self addGroupRequest];
}

- (void)setViewData
{
    // nevBar
    self.middleBtn.hidden = YES;
    self.titleLabel.text = @"新建相册";
    [self.rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    self.textView.delegate = self;
    
}
#pragma mark - Request
- (void)addGroupRequest
{
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
    NSString  *accessLevel = @"0";
    if (_swith.on) {
        accessLevel = @"1";
    }
    NSURL *registerUrl = [[RequestParams sharedInstance] manageGroup];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:registerUrl];
    request.delegate = self;
    request.shouldAttemptPersistentConnection = NO;
    request.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_ADDGROUP],@"tag", nil] ;
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:@"add" forKey:@"operation"];
    [request setPostValue:@"1" forKey:@"type"];
    [request setPostValue:accessLevel forKey:@"accesslevel"];
    [request setPostValue:_contentTextViewText forKey:@"remark"];
    [request setPostValue:[NSString stringWithFormat:@"%f",timestamp]
                   forKey:@"createtime"];
    [request setPostValue:[NSString stringWithFormat:@"%f",timestamp] forKey:@"lastmodifytime"];
    [request setPostValue:_titleTextField.text forKey:@"title"];
    [request setRequestMethod:@"POST"];
    [request setShouldAttemptPersistentConnection:NO];
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

#pragma mark - IBAction methods,public methods
- (IBAction)textViewResignFirstResponder
{
    [_textView resignFirstResponder];
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
        return 44;
    }else{
//        if (_cellHeight <44) {
//            _cellHeight = 44;
//            return 44;
//        }else{
//            return _cellHeight;
//        }
        
        return 100;
    }
}
#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row=[indexPath row];
    
    if (row == 0) {
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
        
        _titleTextField=[[UITextField alloc] initWithFrame:CGRectMake(82, 6, 218, 38)];
        _titleTextField.delegate=self;
        _titleTextField.placeholder=@"最多输入六个字";
        _titleTextField.textColor=[UIColor lightGrayColor];
        _titleTextField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        _titleTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
        [cell.contentView addSubview:_titleTextField];
        
        
        if (_titleTextViewText.length!=0) {
            _titleTextField.text=_titleTextViewText;
        }
        
        
        return cell;
    }
    if (row == 1) {
        static NSString *CreatePhotosCategoryViewControllerIdentifier = @"CreatePhotosCategoryViewControllerIdentifier";
        NewPhotosCategoryCell *cell = (NewPhotosCategoryCell *)[tableView dequeueReusableCellWithIdentifier:CreatePhotosCategoryViewControllerIdentifier];
        if (cell == nil) {
            cell = [[[NewPhotosCategoryCell viewForNib] retain] autorelease];
            [cell.textView setPlaceholderTextColor:[UIColor lightGrayColor]];
            cell.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
            
            
            self.textView = cell.textView;
            self.textView.delegate = self;
            
            [self.textView setPlaceholder:@"分类描述，最多140个字"];
            [cell.lable setText:@"描述"];
            self.textView.tag = 200;
            if (_contentTextViewText.length!=0) {
                cell.textView.text=_contentTextViewText;
            }

        }
        return cell;
    }
    return nil;

}
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * toBeString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUInteger charLen = [self lenghtWithString:toBeString];
    self.titleTextViewText = [toBeString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (charLen >= 20)
    {
        return NO;
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    self.titleTextViewText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//    if (self.titleTextViewText.length > 6)
//    {
//        textField.text = [[self.titleTextViewText substringToIndex:6] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    }

}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.tag == 200) {
//        self.contentTextViewText = textView.text;
//        self.cellHeight = textView.contentSize.height;
//        if (self.cellHeight > 100) {
//            self.cellHeight = 100;
//        }
//        [self setValue:@(textView.contentSize.height) forKeyPath:@"_cellHeight"];
//        [self.tableView beginUpdates];
//        [self.tableView endUpdates];
        
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_titleTextField resignFirstResponder];
    //[[self.textView viewWithTag:100] resignFirstResponder];
    [[self.textView viewWithTag:200] resignFirstResponder];
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
            NSArray *dataArray = [NSArray arrayWithObject:dataDic];
            [DiaryPictureClassificationSQL addDiaryPictureClassificationes:dataArray];
//            NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTYPE AndUserId:USERID] ;
            [MyToast showWithText:@"新建相册成功" :[UIScreen mainScreen].bounds.size.height/2-40];
//TODO ZGL
            [[NSNotificationCenter defaultCenter] postNotificationName:@"photoAlbum" object:nil];

            [self.navigationController popViewControllerAnimated:YES];
//TODO by ZGL
//            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"新建相册成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            alert.tag=110;
//            [alert show];
//            [alert release];
//
//            PhotoAlbumsViewController *photoAlbumsViewController = [[PhotoAlbumsViewController alloc] init];
//            [self.navigationController pushViewController:photoAlbumsViewController animated:YES];
//            [photoAlbumsViewController release];
        }
    }
}
-(void)requestFail:(ASIFormDataRequest *)request
{
//    [MyToast showWithText:@"网络连接异常,新建相册失败" :[UIScreen mainScreen].bounds.size.height/2-40];
}
#pragma mark -- alterview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//TODO by ZGL 
    if (alertView.tag == 110) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"photoAlbum" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
//
    
     if (buttonIndex == 0&&[ self.errorcodeStr isEqualToString:@"1005"]) {
         BOOL isLogin = NO;
         [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate]  showLoginVC];
    }
}

@end
