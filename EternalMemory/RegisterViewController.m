//
//  RegisterViewController.m
//  EternalMemory
//
//  Created by sun on 13-5-10.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegisterSecondStepViewController.h"
#import "StaticTools.h"
#import "RequestParams.h"
#import "MyToast.h"
#import <QuartzCore/QuartzCore.h>
#define REQUEST_FOR_REGISTER   100
#define WARM_ALERT @"友情提示"
@interface RegisterViewController ()
{
    NSInteger sexValue;
}
@property (retain, nonatomic) IBOutlet UIView *popView;

@property(nonatomic, retain) IBOutlet UITextField *userNameTextField;
@property(nonatomic, retain) IBOutlet UITextField *passWordTextField;
@property(nonatomic, retain) IBOutlet UITextField *peopleNumberTextField;
@property(nonatomic, retain) IBOutlet UITextField *tureNameTextField;
- (IBAction)onNextBtnClicked;
- (void)registeRequest;
@end

@implementation RegisterViewController

@synthesize userNameTextField = _userNameTextField;
@synthesize passWordTextField = _passWordTextField;
@synthesize peopleNumberTextField = _peopleNumberTextField;
@synthesize tureNameTextField = _tureNameTextField;
@synthesize dataDic = _dataDic;

#pragma mark - private methods
- (void)backBtnPressed
{
    [self dismissViewControllerAnimated:NO completion:nil];

    if (_registDelegate && [_registDelegate respondsToSelector:@selector(turnViewtoLogo)]) {
        [_registDelegate turnViewtoLogo];
    }
}

- (void)backToLogo
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if (_registDelegate && [_registDelegate respondsToSelector:@selector(turnViewtoLogo)]) {
        [_registDelegate turnViewtoLogo];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logoViewToLogin" object:nil];
}
- (void)setViewData
{
    self.middleBtn.hidden = YES;
    self.titleLabel.text = @"用户注册";
    self.rightBtn.hidden = YES;
    
    [_sexMan setImage:[UIImage imageNamed:@"icon_noselect_state"] forState:UIControlStateNormal];
    [_sexWoman setImage:[UIImage imageNamed:@"icon_noselect_state"] forState:UIControlStateNormal];

    [_sexMan setImage:[UIImage imageNamed:@"icon_select_state"] forState:UIControlStateSelected];
    [_sexWoman setImage:[UIImage imageNamed:@"icon_select_state"] forState:UIControlStateSelected];
    [_sexMan setImageEdgeInsets:UIEdgeInsetsMake(0, 10,0, 0)];
    [_sexMan setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    _sexMan.selected = YES;
    sexValue = 1;
    
    //TextField
    UIColor *_color = RGBCOLOR(118,131,141);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        _userNameTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"用户名(字母、数字或下划线)" attributes:@{NSForegroundColorAttributeName: _color}] autorelease];
        _passWordTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"最少8位字符密码" attributes:@{NSForegroundColorAttributeName: _color}] autorelease];
        _peopleNumberTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"身份证号码" attributes:@{NSForegroundColorAttributeName: _color}] autorelease];
        _tureNameTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"真实姓名(注册成功后不可修改)" attributes:@{NSForegroundColorAttributeName: _color}] autorelease];
    }else{
        
        _userNameTextField.placeholder = @"用户名(字母、数字或下划线)";
        _passWordTextField.placeholder = @"最少8位字符密码";
        _peopleNumberTextField.placeholder = @"身份证号码";
        _tureNameTextField.placeholder = @"真实姓名(注册成功后不可修改)";
        
    }
    _userNameTextField.returnKeyType = UIReturnKeyNext;
    _passWordTextField.returnKeyType = UIReturnKeyNext;
    _tureNameTextField.returnKeyType = UIReturnKeyNext;
    _peopleNumberTextField.returnKeyType = UIReturnKeyDone;
}

- (void)registeRequest
{
    //110228198409128165
    NSURL *_registerUrl = [[RequestParams sharedInstance] userRegister];
    ASIFormDataRequest *_request = [ASIFormDataRequest requestWithURL:_registerUrl];
    [_request setRequestMethod:@"POST"];
    _request.userInfo=[ NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_REGISTER],@"tag", nil] ;
    [_request setPostValue:_userNameTextField.text forKey:@"username"];
    [_request setPostValue:_peopleNumberTextField.text forKey:@"sid"];
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
#pragma mark - object lifecycle
- (void)dealloc
{
    RELEASE_SAFELY(_userNameTextField);
    RELEASE_SAFELY(_passWordTextField);
    RELEASE_SAFELY(_peopleNumberTextField);
    RELEASE_SAFELY(_tureNameTextField);
    [_popView release];
    [_sureBtn release];
    [_cancelBtn release];
    [_RtextView release];
    [_bgView release];
    [_nameLab release];
    [_pswLab release];
    [_realNameLab release];
    [_identifierLab release];
    [_regisFirstImgV release];
    [_sexMan release];
    [_sexWoman release];
    [_birthBut release];
    [_datePicker release];
    [_myPickerDateView release];
    [_myScrollView release];
    [_dataDic release];
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
    }
    return self;
}
//设置popView
-(void)setpopConfirmRegisterInfoView{
    
    _regisFirstImgV.layer.masksToBounds = YES;
    _regisFirstImgV.layer.cornerRadius = 0.5;
    [_RtextView setBackgroundColor:[UIColor clearColor]];
    _popView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+20);
    if (iPhone5) {
        _popView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 1136);
    }
    [self.view addSubview:_popView];
    [_popView bringSubviewToFront:self.view];
    self.sureBtn.backgroundColor = [UIColor blueColor];
    self.cancelBtn.backgroundColor = [UIColor blueColor];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [Utilities adjustUIForiOS7WithViews:@[_myScrollView]];
//    _dataDic = [[NSDictionary alloc]init];
    _myScrollView.scrollEnabled = YES;
    _myScrollView.userInteractionEnabled = YES;
    
    [self setViewData];
    [self setpopConfirmRegisterInfoView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self textFieldResignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - public methods


- (void)textFieldResignFirstResponder
{
    [_userNameTextField     resignFirstResponder];
    [_passWordTextField     resignFirstResponder];
    [_tureNameTextField     resignFirstResponder];
    [_peopleNumberTextField resignFirstResponder];
    
}

- (IBAction)onNextBtnClicked
{
    if([[_tureNameTextField.text stringByReplacingOccurrencesOfString:@" "  withString:@""] length] > 0){
        BOOL result = [self matchRealName:[_tureNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
        if (!result) {
            return;
        }
    }
    
    if (_userNameTextField.text.length < 3 || _userNameTextField.text.length > 17){
        [self networkPromptMessage:@"用户名必须在3～17位之间"];
        return;
    }else if (_passWordTextField.text.length < 8)
    {
        [self networkPromptMessage:@"密码长度不能小于8位"];
        return;
    }else if ([_userNameTextField.text length] >= 3 && _userNameTextField.text.length <= 17 && [_passWordTextField.text length] >= 8 && [_tureNameTextField.text length] != 0 && [_peopleNumberTextField.text length] != 0)
    {
        if ([[StaticTools shareInstance] Chk18PaperId:_peopleNumberTextField.text])
        {
            [self registeRequest];
            
        }else
        {
            [self networkPromptMessage:@"请输入正确身份证号码"];
            return;
        }
    }else
    {
        [self networkPromptMessage:@"注册项不能为空"];
        return;
    }
    
    _nameLab.text = [NSString stringWithFormat:@"用户名：%@",_userNameTextField.text];
    _realNameLab.text = [NSString stringWithFormat:@"真实姓名：%@",_tureNameTextField.text];
    _identifierLab.text = [NSString stringWithFormat:@"身份证号码：%@",_peopleNumberTextField.text];
    _pswLab.text = [NSString stringWithFormat:@"密码：%@",_passWordTextField.text];
}

#pragma mark - 正则判断真实姓名只能为汉字和字母
-(BOOL)matchRealName:(NSString *)str{
    
    NSString * regex = @"^[A-Za-z\u4E00-\u9FA5]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (!isMatch) {
        [MyToast showWithText:@"真实姓名只能是汉字和字母" :150];
        return NO;
    }
    return YES;
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag==3){
        [_myScrollView setContentOffset:CGPointMake(0, 20) animated:YES];
    }else if (textField.tag ==4)
    {
        [textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [_myScrollView setContentOffset:CGPointMake(0, 40) animated:YES];
    }else{
        [_myScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    [self hiddenPickerView];
    
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{

    return YES;
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 3 && textField.text.length > 0) {
        
        [self matchRealName:[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }
    if (textField.tag == 4 && textField.text.length>15) {
        //获取用户生日信息
        NSString *birthStr = [textField.text substringWithRange:NSMakeRange(6,8)];
        NSString *birthYear = [birthStr substringWithRange:NSMakeRange(0, 4)];
        NSString *birthBut = [NSString stringWithFormat:@"%@-%@-%@",birthYear,[birthStr substringWithRange:NSMakeRange(4, 2)],[birthStr substringWithRange:NSMakeRange(6, 2)]];
        [_birthBut setTitle:birthBut forState:UIControlStateNormal];
        
        //获取用户性别
        if (textField.text.length >17) {
            NSInteger sexTag = [[textField.text substringWithRange:NSMakeRange(16, 1)] integerValue];
            if (sexTag % 2 ==1) {
                _sexMan.selected = YES;
                _sexWoman.selected = NO;
                sexValue = 1;
            }else{
                _sexWoman.selected = YES;
                _sexMan.selected = NO;
                sexValue = 2;
            }
        }
        
    }
}
#pragma mark - request
-(void)requestSuccess:(ASIFormDataRequest *)request
{
    NSData *_responseData = [request responseData];
    JSONDecoder *_jSONDecoder = [JSONDecoder decoder];
    NSDictionary *_dataDictionary = [_jSONDecoder objectWithData:_responseData];
    NSString *_resultStr=[NSString stringWithFormat:@"%@",[_dataDictionary objectForKey:@"success"]];
    if ([_resultStr isEqualToString:@"0"]) {
        NSString *_errorStr=[NSString stringWithFormat:@"%@",[_dataDictionary objectForKey:@"message"]];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.labelText = _errorStr;
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(2);
        } completionBlock:^{
            [HUD removeFromSuperview];
            [HUD release];
        }];
    }else{
       
        _dataDic = @{@"userName":_userNameTextField.text,
                     @"passWord":_passWordTextField.text,
                     @"tureName":_tureNameTextField.text,
                     @"peopleNumber":_peopleNumberTextField.text,
                     @"birth":_birthBut.titleLabel.text,
                     @"sex":@(sexValue)
                     };
        [_dataDic retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToLogo) name:@"registFirst" object:nil];
        
        [_popView setHidden:NO];
        [_peopleNumberTextField resignFirstResponder];
    }
}
-(void)requestFail:(ASIFormDataRequest *)request
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"网络连接失败";
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [HUD removeFromSuperview];
        [HUD release];
    }];
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == _userNameTextField) {
        [_passWordTextField becomeFirstResponder];
        
    }
    if (textField == _passWordTextField) {
        [_tureNameTextField becomeFirstResponder];
        
    }
    if (textField == _tureNameTextField) {
        
        [_peopleNumberTextField becomeFirstResponder];
       
    }
    if (textField == _peopleNumberTextField) {
        [_myScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [textField resignFirstResponder];
    }
    return YES;
}



- (IBAction)clickSureBtn:(id)sender {
    
    if (iPhone5) {
        RegisterSecondStepViewController *registerSecondStepViewController =
        [[RegisterSecondStepViewController alloc] initWithNibName:@"RegisterSecondStepViewController-5" bundle:nil];
        registerSecondStepViewController.dataDictionary = self.dataDic;
        [self.navigationController pushViewController:registerSecondStepViewController animated:YES];
        RELEASE_SAFELY(registerSecondStepViewController);
    }else{
        RegisterSecondStepViewController *registerSecondStepViewController =
        [[RegisterSecondStepViewController alloc] initWithNibName:@"RegisterSecondStepViewController" bundle:nil];
        registerSecondStepViewController.dataDictionary = self.dataDic;
        [self.navigationController pushViewController:registerSecondStepViewController animated:YES];
        RELEASE_SAFELY(registerSecondStepViewController);
    }
    
    
}

- (IBAction)clickCancelBtn:(id)sender
{
    _popView.hidden = YES;
}
- (void)showAlertView
{
    [[[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"性别一旦选择，则不能修改" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil]autorelease ]show];
}
- (IBAction)didSelectSexMan:(UIButton *)sender
{
    if (_sexWoman.selected) {
        _sexWoman.selected = NO;
        sender.selected = YES;
        sexValue = 1;
    }
    [self showAlertView];
}

- (IBAction)didSelectSexWoman:(UIButton *)sender
{
    if (_sexMan.selected) {
        _sexMan.selected = NO;
        sender.selected = YES;
        sexValue = 2;
    }
    [self showAlertView];
}
- (NSString *)getDateFromDatePicker
{
    NSDate *date = [_datePicker date];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}
- (NSDate *)getDateFromDateButton
{
    NSString *dateStr = [_birthBut titleLabel].text;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    return date;
    
}
-(BOOL)checkIDBirthTime{
    
//    if ([[_birthBut.titleLabel.text substringToIndex:3] integerValue] <= 1000) {
//        return NO;
//    }//不能小于系统时间1000年
    NSDate *date = [self getDateFromDateButton];
    NSDate *date1 = [NSDate date];
    
    NSInteger result = [date compare:date1];
    
    if (result == 1) {//不能大于系统时间
        return NO;
    }
    
    return YES;
}
- (IBAction)didSelectBirthTimeData:(UIButton *)sender
{
    if (_peopleNumberTextField.text.length == 0) {
        [MyToast showWithText:@"请输入身份证号码" :150];
        return;
    }
    [self textFieldResignFirstResponder];
    [_myScrollView setContentOffset:CGPointMake(0, 0)];
    if (![[StaticTools shareInstance] Chk18PaperId:_peopleNumberTextField.text] || ![self checkIDBirthTime]) {
        
        [MyToast showWithText:@"请输入正确的身份证号码" :150];
        return;
    }
    [_myScrollView setContentOffset:CGPointMake(0, 100) animated:YES];
    CGRect rect = _myPickerDateView.frame;
    rect.origin.x = 0;
    rect.origin.y = SCREEN_HEIGHT;
    _myPickerDateView.frame = rect;
    if (!_myPickerDateView.superview) {
        [self.view addSubview:_myPickerDateView];
    }
    if (_birthBut.titleLabel.text.length != 0) {
        [_datePicker setDate:[self getDateFromDateButton]];
    }
    
    [_datePicker setMaximumDate:[NSDate date]];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _myPickerDateView.frame;
        frame.origin.x = 0;
        frame.origin.y = SCREEN_HEIGHT - _myPickerDateView.frame.size.height;
        _myPickerDateView.frame = frame;
    }];
    
}
- (void)hiddenPickerView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _myPickerDateView.frame;
        rect.origin.x = 0;
        rect.origin.y = SCREEN_HEIGHT;
        _myPickerDateView.frame = rect;
        
        
    } completion:^(BOOL finished) {
        [_myPickerDateView removeFromSuperview];
    }];
}
- (IBAction)didSelectFinishBirthDateAction:(UIBarButtonItem *)sender
{
    [_myScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [self hiddenPickerView];
    
    [_birthBut setTitle:[self getDateFromDatePicker] forState:UIControlStateNormal];
}
- (IBAction)didSelectChangeBirthDate:(UIDatePicker *)sender
{
    NSDate *date = [sender date];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    [_birthBut setTitle:dateStr forState:UIControlStateNormal];
}
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    [_tureNameTextField resignFirstResponder];
//    [_userNameTextField resignFirstResponder];
//    [_passWordTextField resignFirstResponder];
//    [_peopleNumberTextField resignFirstResponder];
//    [_datePicker resignFirstResponder];
//    [_myScrollView setContentOffset:CGPointMake(0, 0)];
//}
@end
