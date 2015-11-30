//
//  CompleteLoginInfoViewController.m
//  EternalMemory
//
//  Created by SuperAdmin on 13-11-29.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "CompleteLoginInfoViewController.h"
#import "VerifyCodeViewController.h"
#import "StaticTools.h"
#import "MyToast.h"
#import "LoginViewController.h"
#import "FindBackIDViewController.h"
#import "CommonData.h"
#import "FileModel.h"

#define FileUserInfo  [FileModel sharedInstance]
@interface CompleteLoginInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray             *_arrData;//身份证扩展字母
    NSInteger            sex;// 0 表示没选择  1 表示男  2 表示女
    NSInteger            hiddenKeyBd;// 0 表示隐藏  1 表示展示
    UIButton            *doneInKeyboardButton;
    UITextField         *_myTextField;
    ASIFormDataRequest  *formRequest;
    BOOL                 isSucceedEmail;
    NSString            *_emailString;
}
@property (retain, nonatomic) IBOutlet UIButton *womanButton;
@property (retain, nonatomic) IBOutlet UIButton *manButton;
@property (retain, nonatomic) IBOutlet UIScrollView *bgScorllView;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;
@property (retain, nonatomic) IBOutlet UITextField *phoneTextField;
@property (retain, nonatomic) IBOutlet UITextField *IDTextField;
@property (retain, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (retain, nonatomic) IBOutlet UIView *myPickerView;
@property (retain, nonatomic) IBOutlet UIDatePicker *pickerDate;
@property (retain, nonatomic) IBOutlet UIButton *IDExpandButton;
@property (retain, nonatomic) IBOutlet UITableView *downListTabView;


- (IBAction)didSelectChangeDateTime:(id)sender;
- (IBAction)didSelectFinishAction:(id)sender;
- (IBAction)expandID:(id)sender;



//身份证不为空时完善信息的判断操作
-(void)completeInfoWithID;
//手机号码验证请求
-(void)checkPhone;

@end

#define CHECK_SID   1000
#define CHECK_PHONE 2000
#define CHECK_EMAIL 3000

@implementation CompleteLoginInfoViewController
@synthesize comeInStyle;


- (void)dealloc {
    if (formRequest)
    {
        [formRequest clearDelegatesAndCancel];
        [formRequest release];
        formRequest = nil;
    }
    if (doneInKeyboardButton.superview)
    {
        [doneInKeyboardButton removeFromSuperview];
    }
    [_nameTextField release];
    [_phoneTextField release];
    [_IDTextField release];
    [_birthdayLabel release];


    [_pickerDate release];
    [_bgScorllView release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_IDExpandButton release];
    [_emailTextField release];
    [_downListTabView release];
    [_arrData release],_arrData = nil;
    [super dealloc];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate
{
    return NO;
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
    self.middleBtn.hidden = YES;
    isSucceedEmail = YES;
//    [self.rightBtn setTitle:@"跳过" forState:UIControlStateNormal];
    if (!_registToLogin) {
        self.rightBtn.hidden = YES;
    }else{
        self.backBtn.hidden = YES;
        [self.rightBtn setTitle:@"跳过" forState:UIControlStateNormal];
    }
    self.titleLabel.text = @"信息完善";
    sex = 0;
    hiddenKeyBd = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IDBecomefirstResponder) name:@"findID" object:nil];
   
    if (iPhone5)
    {
        self.bgScorllView.frame = CGRectMake(0, self.bgScorllView.frame.origin.y + 20, 320, SCREEN_HEIGHT - 64);
    }
    self.bgScorllView.contentSize = CGSizeMake(320, SCREEN_HEIGHT -44);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPickView:)];
    _birthdayLabel.userInteractionEnabled = YES;
    [_birthdayLabel addGestureRecognizer:tapGesture];
    [tapGesture release];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfoSuccess:) name:@"updateInfoSuccess" object:nil];
    
    
    _arrData = [@[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I"] retain];
    _downListTabView.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_nameTextField becomeFirstResponder];
    
    [self initData];
}
- (void)initData
{
    [FileUserInfo.dicUserInfo setDictionary:[SavaData parseDicFromFile:User_Infor]];
    if (FileUserInfo.dicUserInfo.count >0) {
        _nameTextField.text = FileUserInfo.dicUserInfo[@"userName"];
        _IDTextField.text = FileUserInfo.dicUserInfo[@"userIDCard"];
        _emailTextField.text = FileUserInfo.dicUserInfo[@"email"];
        _birthdayLabel.text = FileUserInfo.dicUserInfo[@"birthday"];
        _phoneTextField.text = FileUserInfo.dicUserInfo[@"phoneNum"];
        NSUInteger sexTag = [FileUserInfo.dicUserInfo[@"sex"] integerValue];
        if (sexTag % 2 ==1) {
            [self clickManButton:nil];
        }else{
            [self clickWomanButton:nil];
        }
        
    }
}
-(void)IDBecomefirstResponder{
    [_IDTextField becomeFirstResponder];
    _IDTextField.text = @"";
}
- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    if (doneInKeyboardButton.superview)
    {
        [doneInKeyboardButton removeFromSuperview];
    }
}

-(void)finishAction:(id)sender
{
    _IDTextField.text = [_IDTextField.text stringByAppendingString:@"X"];
}

-(void)backBtnPressed
{
    [SavaData writeDicToFile:FileUserInfo.dicUserInfo FileName:User_Infor];
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)rightBtnPressed{
    [_bgScorllView removeFromSuperview];
    _bgScorllView = nil;
    if (FileUserInfo.dicUserInfo.count >0) {
        [SavaData writeDicToFile:FileUserInfo.dicUserInfo FileName:User_Infor];
    }
    for(UIViewController *controller in self.navigationController.viewControllers){
        if ([controller isKindOfClass:[LoginViewController class]]) {
            [self.navigationController popToViewController:controller animated:NO];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ToSecondWay" object:nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (doneInKeyboardButton.superview)
    {
        doneInKeyboardButton.hidden = YES;
    } else if (_myPickerView.frame.origin.y != SCREEN_HEIGHT)
    {
        [self didHiddenPickerView];
    }
    if (hiddenKeyBd ==2) {
        [_myTextField resignFirstResponder];
    }
}
//身份证扩展
- (IBAction)expandID:(UIButton *)btn
{
    if (_downListTabView.hidden) {
        [_downListTabView setHidden:NO];
    }else{
        [_downListTabView setHidden:YES];
    }
    
    [self hiddenTextresignFirstResponder];
}

-(void)showPickView:(id)sender
{
    [_downListTabView setHidden:YES];
    [self hiddenTextresignFirstResponder];
    CGRect rect = _myPickerView.frame;
    rect.origin.x = 0;
    rect.origin.y = SCREEN_HEIGHT;
    _myPickerView.frame = rect;
    if (!_myPickerView.superview) {
        [self.view addSubview:_myPickerView];
        [_myPickerView release];
    }
    
    [_pickerDate setMinimumDate:[self getDateFromDateButton:@"1000-01-01"]];

    if (_birthdayLabel.text.length != 0)
    {
        [_pickerDate setDate:[self getDateFromDateButton:_birthdayLabel.text]];
    }
    
    [_pickerDate setMaximumDate:[NSDate date]];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _myPickerView.frame;
        frame.origin.x = 0;
        frame.origin.y = SCREEN_HEIGHT - _myPickerView.frame.size.height;
        _myPickerView.frame = frame;
    }];}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _myTextField = textField;
    [_downListTabView setHidden:YES];
    
    if (textField == _nameTextField)
    {
        _nameTextField.returnKeyType = UIReturnKeyNext;
        hiddenKeyBd = 2;
        if (doneInKeyboardButton.superview)
        {
            doneInKeyboardButton.hidden = YES;
        }
    }else if (textField == _IDTextField)
    {
        _IDTextField.keyboardType = UIKeyboardTypeNumberPad;
        hiddenKeyBd = 2;
        if (doneInKeyboardButton == nil)
        {
            doneInKeyboardButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            
            doneInKeyboardButton.frame = CGRectMake(0, SCREEN_HEIGHT - 53, 106, 53);
            
            doneInKeyboardButton.adjustsImageWhenHighlighted = NO;
            [doneInKeyboardButton setImage:[UIImage imageNamed:@"keyboard_X.png"] forState:UIControlStateNormal];
            [doneInKeyboardButton setImage:[UIImage imageNamed:@"keyboard_X.png"] forState:UIControlStateHighlighted];
            [doneInKeyboardButton addTarget:self action:@selector(finishAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        // locate keyboard view
        UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
        if (doneInKeyboardButton.superview == nil)
        {
            [tempWindow addSubview:doneInKeyboardButton];    // 注意这里直接加到window上
        }
        else
        {
            if (doneInKeyboardButton.superview)
            {
                doneInKeyboardButton.hidden = NO;
            }
        }
    }else if (textField ==_emailTextField)
    {
        _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        if (doneInKeyboardButton.superview)
        {
            doneInKeyboardButton.hidden = YES;
        }
        if (iPhone5) {
            
        }else{
            [UIView animateWithDuration:0.3f animations:^{
                [_bgScorllView setContentOffset:CGPointMake(0, 100)];
            } completion:^(BOOL isKeyBoard){
                hiddenKeyBd = 2;
            }];
        }
        
    }else if (textField == _phoneTextField)
    {
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        if (iPhone5)
        {
            [UIView animateWithDuration:0.3f animations:^{
                [_bgScorllView setContentOffset:CGPointMake(0, 100)];
            } completion:^(BOOL isKeyBoard){
                hiddenKeyBd = 2;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3f animations:^{
                [_bgScorllView setContentOffset:CGPointMake(0, 150)];
            } completion:^(BOOL isKeyBoard){
                hiddenKeyBd = 2;
            }];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _nameTextField)
    {
        [_IDTextField becomeFirstResponder];
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag ==0 && textField.text.length >0) {
         [FileUserInfo.dicUserInfo setObject:textField.text forKey:@"userName"];
    }else if (textField.tag ==3 && textField.text.length >0)
    {
         [FileUserInfo.dicUserInfo setObject:textField.text forKey:@"phoneNum"];
    }
    if (textField == _IDTextField )
    {
        if ([[StaticTools shareInstance] Chk18PaperId:_IDTextField.text])
        {
            NSString *birthStr = [textField.text substringWithRange:NSMakeRange(6,8)];
            NSString *birthYear = [birthStr substringWithRange:NSMakeRange(0, 4)];
            NSString *birthBut = [NSString stringWithFormat:@"%@-%@-%@",birthYear,[birthStr substringWithRange:NSMakeRange(4, 2)],[birthStr substringWithRange:NSMakeRange(6, 2)]];
            _birthdayLabel.text = birthBut;
            [FileUserInfo.dicUserInfo setObject:birthBut forKey:@"birthday"];
            [FileUserInfo.dicUserInfo setObject:textField.text forKey:@"userIDCard"];
            
            if (_IDTextField.text.length >17) {
                
                NSInteger sexTag = [[_IDTextField.text substringWithRange:NSMakeRange(16, 1)] integerValue];
                if (sexTag % 2 ==1) {
                    [FileUserInfo.dicUserInfo setObject:@(1) forKey:@"sex"];
                    [self clickManButton:nil];
                }else{
                     [FileUserInfo.dicUserInfo setObject:@(2) forKey:@"sex"];
                    [self clickWomanButton:nil];
                }
            }
        }
    }else if (textField == _emailTextField)
    {
        //验证邮箱请求
        if (![CommonData isTitleBlank:textField.text]) {
            [FileUserInfo.dicUserInfo setObject:textField.text forKey:@"email"];
            [self goValidataEmailRequest:textField.text];
        }
    }
}

//隐藏键盘
-(void)hiddenTextresignFirstResponder
{
    if (doneInKeyboardButton.superview)
    {
        doneInKeyboardButton.hidden = YES;
    }
    [_myTextField resignFirstResponder];
}

- (IBAction)manButton:(id)sender
{
    
}
- (IBAction)clickManButton:(id)sender
{
    [_downListTabView setHidden:YES];
    if (!_manButton.selected)
    {
        sex = 1;
        [_manButton setImage:[UIImage imageNamed:@"icon_select_state.png"] forState:UIControlStateNormal];
        [_womanButton setImage:[UIImage imageNamed:@"icon_noselect_state.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)clickWomanButton:(id)sender
{
    [_downListTabView setHidden:YES];
    if (!_womanButton.selected)
    {
        sex = 2;
        [_womanButton setImage:[UIImage imageNamed:@"icon_select_state.png"] forState:UIControlStateNormal];
        [_manButton setImage:[UIImage imageNamed:@"icon_noselect_state.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)ClickToGoOn:(id)sender
{
//    if (_nextBtn.selected) {
//        [MyToast showWithText:@"正在提交" :150];
//        return;
//    }
    _nextBtn.selected = YES;
    if (_nameTextField.text.length == 0)
    {
        [MyToast showWithText:@"请输入姓名" :200];
        [_nameTextField becomeFirstResponder];
        _nextBtn.selected = NO;
        return;
    }
    
    NSString *regex = @"^[^\\s]{1,}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [predicate evaluateWithObject:_nameTextField.text];
    if (!isMatch) {
        [MyToast showWithText:@"姓名不能包含空格" :150];
        _nextBtn.selected = NO;
        return;
    }else if (_emailTextField.text.length !=0){
        if (![self isValidateEmail:_emailTextField.text]) {
            [MyToast showWithText:@"请填写正确邮箱" :200];
            _nextBtn.selected = NO;
            return;
        }else if (isSucceedEmail == NO){
            [MyToast showWithText:_emailString :200];
            return;
        }
    }
    
    if (_IDTextField.text.length == 0)
    {
        if (_birthdayLabel.text.length == 0)
        {
            [MyToast showWithText:@"请选择生日" :200];
            [self showPickView:nil];
            _nextBtn.selected = NO;
            return;
        }
        else if (_phoneTextField.text.length == 0)
        {
            [MyToast showWithText:@"请输入手机号" :200];
            [_phoneTextField becomeFirstResponder];
            _nextBtn.selected = NO;
            return;
        }
        else if (_phoneTextField.text.length != 0)
        {
            NSString *mobilephoneRegex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0-2,5-9]))\\d{8}$";//验证手机号是否正确
            NSString *telephoneRegex = @"^0(10|2[0-5789]|\\d{3})\\d{7}$";
            NSPredicate *mobilePhonePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobilephoneRegex];
            NSPredicate *telephonePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",telephoneRegex];
            
            BOOL mobileIsMatch = [mobilePhonePred evaluateWithObject:_phoneTextField.text];
            BOOL teleIsMatch = [telephonePred evaluateWithObject:_phoneTextField.text];
            if (!mobileIsMatch && !teleIsMatch) {
                [MyToast showWithText:@"请输入正确的手机号" :[UIScreen mainScreen].bounds.size.height/2-60];
                [_phoneTextField becomeFirstResponder];
                _nextBtn.selected = NO;
                return;
            }
            else if (sex == 0)
            {
                [MyToast showWithText:@"请选择性别" :200];
                _nextBtn.selected = NO;
                
            }else{
                [self checkPhone];
            }
        }
        
    }
    else if (_IDTextField.text.length != 0)
    {
        if (![[StaticTools shareInstance] Chk18PaperId:_IDTextField.text])
        {
            [MyToast showWithText:@"请输入正确身份证号码" :200];
            [_IDTextField becomeFirstResponder];
            _nextBtn.selected = NO;
            return;
        }
        else if (_birthdayLabel.text.length == 0)
        {
            [MyToast showWithText:@"请输入身份证号" :200];
            [self showPickView:nil];
            _nextBtn.selected = NO;
            return;
        }
        else
        {
            [self completeInfoWithID];
        }
    }

}
//身份证不为空时完善信息的判断操作
-(void)completeInfoWithID
{
    if (_phoneTextField.text.length == 0)
    {
        [MyToast showWithText:@"请输入手机号" :200];
        [_phoneTextField becomeFirstResponder];
        _nextBtn.selected = NO;
        return;
    }
    else if (_phoneTextField.text.length != 0)
    {
        NSString *mobilephoneRegex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0-2,5-9]))\\d{8}$";//验证手机号是否正确
        
        NSString *telephoneRegex = @"^0(10|2[0-5789]|\\d{3})\\d{7}$";//@"^(0[0-9]{2,3}\\-)?([2-9][0-9]{6,7})$";
        
        NSPredicate *mobilePhonePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobilephoneRegex];
        NSPredicate *telephonePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",telephoneRegex];
        
        BOOL mobileIsMatch = [mobilePhonePred evaluateWithObject:_phoneTextField.text];
        BOOL teleIsMatch = [telephonePred evaluateWithObject:_phoneTextField.text];
        if (!mobileIsMatch && !teleIsMatch) {
            [MyToast showWithText:@"请输入正确的手机号" :[UIScreen mainScreen].bounds.size.height/2-60];
            [_phoneTextField becomeFirstResponder];
            _nextBtn.selected = NO;
            return;
        }else if (sex == 0)
        {
            [MyToast showWithText:@"请选择性别" :200];
            _nextBtn.selected = NO;
        }
        else
        {
            _nextBtn.userInteractionEnabled = NO;
            NSString *sidString = [_IDTextField.text stringByAppendingString:_IDExpandButton.titleLabel.text];
            NSURL *url = [[RequestParams sharedInstance] usrCheckId];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [RequestParams setRequestCommonData:request];
            request.delegate = self;

            request.userInfo = @{@"tag": [NSNumber numberWithInt:CHECK_SID]};
            [request setPostValue:@"perfect" forKey:@"flag"];
            [request setPostValue:sidString forKey:@"sid"];
            [request startAsynchronous];
        }
    }
}
//判断邮箱是否正确
- (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
//去验证邮箱是否已使用
- (void)goValidataEmailRequest:(NSString *)email
{
    NSURL *url = [[RequestParams sharedInstance] getUserEmail];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [RequestParams setRequestCommonData:request];
    request.delegate = self;
    request.userInfo = @{@"tag":@(CHECK_EMAIL)};
    [request setPostValue:email forKey:@"email"];
    [request startAsynchronous];
}
-(void)requestFinished:(ASIHTTPRequest *)request
{
    _nextBtn.selected = NO;
    _nextBtn.userInteractionEnabled = YES;
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    
    NSInteger tag = [request.userInfo[@"tag"] intValue];
    if (tag == CHECK_SID)
    {
        if ([resultDictionary[@"success"] intValue] == 1)
        {
            [self checkPhone];
            
        }else if ([resultDictionary[@"errorcode"] integerValue] == 2002){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"身份证号被使用,是否要找回？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"找回", nil];
            alert.tag = 2002;
            [alert show];
            [alert release];
            
        }
        else
        {
            [MyToast showWithText:resultDictionary[@"message"] :200];
            [_IDTextField becomeFirstResponder];
        }
    }
    else if (tag == CHECK_PHONE)
    {
        if ([resultDictionary[@"success"] intValue] == 1)
        {
            if (_myPickerView.frame.origin.y != SCREEN_HEIGHT)
            {
                [self didHiddenPickerView];
            }
            [self hiddenTextresignFirstResponder];
            VerifyCodeViewController *verfyCodeViewController = [[VerifyCodeViewController alloc] init];
            NSString *emailStr = _emailTextField.text.length >0 ? _emailTextField.text:@"";
            if (_IDTextField.text.length == 0) {
                verfyCodeViewController.userInfo = @{@"realname":_nameTextField.text,
                                                     @"sid":@"null",
                                                     @"email":emailStr,
                                                     @"sex":[NSString stringWithFormat:@"%d",sex],
                                                     @"mobile":_phoneTextField.text,
                                                     @"birthdate":_birthdayLabel.text};
            }else{
                NSString *sidString = [_IDTextField.text stringByAppendingString:_IDExpandButton.titleLabel.text];
                verfyCodeViewController.userInfo = @{@"realname":_nameTextField.text,
                                                     @"sid":sidString,
                                                     @"email":emailStr,
                                                     @"sex":[NSString stringWithFormat:@"%d",sex],
                                                     @"mobile":_phoneTextField.text,
                                                     @"birthdate":_birthdayLabel.text};
            }
            
            if (comeInStyle == 0)
            {
                verfyCodeViewController.comeInStyle = 0;
                [self.navigationController pushViewController:verfyCodeViewController animated:YES];
            }
            else
            {
                verfyCodeViewController.comeInStyle = 1;
                [self presentViewController:verfyCodeViewController animated:YES completion:NULL];
            }
            [verfyCodeViewController release];
        }
        else
        {
            [MyToast showWithText:resultDictionary[@"message"] :200];
        }
    }
    else if (tag == CHECK_EMAIL)
    {
        if ([resultDictionary[@"success"] intValue] == 1)
        {
            isSucceedEmail = YES;
        }else{
            isSucceedEmail = NO;
            _emailString = [resultDictionary[@"message"] copy];
            [MyToast showWithText:_emailString :200];
        }
        [_phoneTextField becomeFirstResponder];
    }
    else
    {
        [MyToast showWithText:resultDictionary[@"message"] :200];
        [_phoneTextField becomeFirstResponder];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    _nextBtn.userInteractionEnabled = YES;
    _nextBtn.selected = NO;
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD release];
    HUD.labelText = @"网络连接异常";
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [HUD removeFromSuperview];
        
    }];

}

- (NSString *)getDateFromDatePicker
{
    NSDate *date = [_pickerDate date];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    return dateStr;
}
- (NSDate *)getDateFromDateButton:(NSString *)birth
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:birth];
    
    return date;
}
- (void)didHiddenPickerView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _myPickerView.frame;
        rect.origin.x = 0;
        rect.origin.y = SCREEN_HEIGHT;
        _myPickerView.frame = rect;
        
    } completion:^(BOOL finished) {
//        [_myPickerView removeFromSuperview];
    }];
}

- (IBAction)didSelectFinishAction:(UIBarButtonItem *)sender
{
    [self didHiddenPickerView];
}


- (IBAction)didSelectChangeDateTime:(UIDatePicker *)sender
{
    NSDate *date = [sender date];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    _birthdayLabel.text = dateStr;
    [FileUserInfo.dicUserInfo setObject:dateStr forKey:@"birthday"];
}

-(void)updateInfoSuccess:(NSNotification *)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateInfoSuccessSecond" object:nil];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        NSString *urlStr = [NSString stringWithFormat:@"%@/wap/findsid/uploadSIDImage?platform=ios&clienttoken=%@&serverauth=%@",INLAND_SERVER_HOME,USER_TOKEN_GETOUT,USER_AUTH_GETOUT];
        FindBackIDViewController *findBackIDVC = [[FindBackIDViewController alloc] init];
        findBackIDVC.url = [NSURL URLWithString:urlStr];
        [self.navigationController pushViewController:findBackIDVC animated:YES];
        [findBackIDVC release];
    }
    
}
//手机号码验证请求
-(void)checkPhone
{
    _nextBtn.userInteractionEnabled = NO;
    if (formRequest)
    {
        [formRequest clearDelegatesAndCancel];
        [formRequest release];
        formRequest = nil;
    }
    NSURL *url = [[RequestParams sharedInstance] userCheckMobile];
    formRequest = [[ASIFormDataRequest alloc]initWithURL:url];
    [RequestParams setRequestCommonData:formRequest];
    [formRequest setPostValue:@"get" forKey:@"flag"];
    formRequest.userInfo = @{@"tag": [NSNumber numberWithInt:CHECK_PHONE]};
    [formRequest setPostValue:_phoneTextField.text forKey:@"mobile"];
    formRequest.delegate = self;
    [formRequest startAsynchronous];
}

#pragma  mark TabViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *defineTab = @"defineTab";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:defineTab];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:defineTab] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    for (UILabel *lab in cell.contentView.subviews) {
        [lab removeFromSuperview];
    }
    
    [cell.contentView addSubview:[self cellTextBackLab:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_IDExpandButton setTitle:_arrData[indexPath.row] forState:UIControlStateNormal];
    [_downListTabView setHidden:YES];
}

- (UILabel *)cellTextBackLab:(NSInteger)index
{
    UILabel *lab = [[[UILabel alloc] initWithFrame:CGRectMake(18, 5, 20, 20)]autorelease];
    lab.text = _arrData[index];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:15];
    return lab;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
