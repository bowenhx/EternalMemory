//
//  EditDetailViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 13-7-10.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "EditDetailViewCtrl.h"
#import "MyToast.h"
#import "CommonData.h"
#import "MyFamilySQL.h"
#import "LimitePasteTextView.h"
@interface EditDetailViewCtrl ()<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UIButton *cardSIDBtn;
    IBOutlet UITableView *myTableView;
    IBOutlet UIImageView *lineImage;
    
    NSArray               *_arrData;//身份证扩展字母
    BOOL  isSucceedEmail;
    NSInteger     cardSIDTag;
    
}
- (IBAction)didChangeCardSIDIdentityAction:(UIButton *)sender;

@end

@implementation EditDetailViewCtrl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dicDatas = [[NSMutableDictionary alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text  = @"编辑信息";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = NO;
    isSucceedEmail = YES;
    [self.rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    NSString *strBirth = [NSString stringWithFormat:@"%@",_dicDatas[@"birthdate"]];
    
    self.addressTextView.text = [self.dicDatas objectForKey:@"addressdetail"];
    
    
    _scrollBgView.contentSize = CGSizeMake(_scrollBgView.frame.size.width, _scrollBgView.frame.size.height-50);
    [self.birthBut setTitle:[NSString stringWithFormat:@"%@",[CommonData getTimeransitionBirthDataPath:strBirth]] forState:UIControlStateNormal];
    self.scrollBgView.contentSize = CGSizeMake(self.view.bounds.size.width, self.scrollBgView.bounds.size.height+10);
    
    [self initLoadView];
}


- (void)initLoadView
{
    //判断身份证号和邮箱是否填写
    if (![self.dicDatas[@"SID"] isEqualToString:@""]) {
        //身份证号不为空时
        self.nameBgImage.hidden = YES;
        self.idTextField.hidden = YES;
        self.nameLab.hidden = YES;
        cardSIDBtn.hidden = YES;
        myTableView.hidden = YES;
        lineImage.hidden = YES;
        
        CGRect scrollViewFrame = _scrollBgView.frame;
        scrollViewFrame.origin.y = iOS7 ? 64- 50:44-50;
        _scrollBgView.frame = scrollViewFrame;
        _scrollBgView.showsHorizontalScrollIndicator = NO;
        
        if (![self.dicDatas[@"email"] isEqualToString:@""]) {
            //邮箱不为空时
            self.phoneLab.hidden = YES;
            self.emailTextField.hidden = YES;
            self.cardBgImage.hidden = YES;
            cardSIDTag = 0;
            
            CGRect scrollViewFrame = _scrollBgView.frame;
            scrollViewFrame.origin.y = iOS7 ? 64- 100:44-100;
            _scrollBgView.frame = scrollViewFrame;
            _scrollBgView.showsHorizontalScrollIndicator = NO;
        }else{
            cardSIDTag = 3;
        }
    }else{
        _arrData = [@[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I"] retain];
        cardSIDBtn.hidden = NO;
        myTableView.hidden = YES;
        
        if ([self.dicDatas[@"email"] isEqualToString:@""]) {
            //邮箱为空时
            cardSIDTag = 2;
        }else{
            //身份证号为空时
            self.nameBgImage.hidden = YES;
            self.idTextField.hidden = YES;
            self.nameLab.hidden = YES;
            
            self.phoneLab.text = @"身  份 证";
            cardSIDTag = 1;
            
            CGRect scrollViewFrame = _scrollBgView.frame;
            scrollViewFrame.origin.y = iOS7 ? 64- 50:44-50;
            _scrollBgView.frame = scrollViewFrame;
            _scrollBgView.showsHorizontalScrollIndicator = NO;
            
            CGRect lineFrame = lineImage.frame;
            lineFrame.origin.y += 49;
            lineImage.frame = lineFrame;
            
            CGRect cardSIDFrame = cardSIDBtn.frame;
            cardSIDFrame.origin.y +=50;
            cardSIDBtn.frame = cardSIDFrame;
            
            CGRect tabFrame = myTableView.frame;
            tabFrame.origin.y += 50;
            myTableView.frame = tabFrame;
        }
    }

}
//判断邮箱是否正确
- (BOOL)isValidateEmailCorrectValue
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:_emailTextField.text];
}

- (BOOL)isWriteFinishInfo
{
    if (cardSIDTag ==2) {
        if ([CommonData isTitleBlank:_idTextField.text]) {
            [MyToast showWithText:@"请输入身份证号码" :[UIScreen mainScreen].bounds.size.height/2-60];
            return NO;
        }
        if ([CommonData isTitleBlank:_emailTextField.text])
        {
            [MyToast showWithText:@"请输入邮箱地址" :[UIScreen mainScreen].bounds.size.height/2-60];
            return NO;
        }else{
            if (![self isValidateEmailCorrectValue]) {
                [MyToast showWithText:@"请填写正确邮箱" :[UIScreen mainScreen].bounds.size.height/2-60];
                return NO;
            }
        }
    }else if (cardSIDTag ==1){
        if ([CommonData isTitleBlank:_emailTextField.text]) {
            [MyToast showWithText:@"请输入身份证号码" :[UIScreen mainScreen].bounds.size.height/2-60];
            return NO;
        }
    }else if (cardSIDTag ==3){
        if ([CommonData isTitleBlank:_emailTextField.text])
        {
            [MyToast showWithText:@"请输入邮箱地址" :[UIScreen mainScreen].bounds.size.height/2-60];
            return NO;
        }else{
            if (![self isValidateEmailCorrectValue]) {
                [MyToast showWithText:@"请填写正确邮箱" :[UIScreen mainScreen].bounds.size.height/2-60];
                return NO;
            }
        }
    }else if (cardSIDTag ==0)
    {
        //邮箱和身份证都不为空
        return YES;
    }
    return YES;
}

- (void)rightBtnPressed
{
    //保存数据
    //    NSString *token = [[SavaData shareInstance] printToken:TOKEN];
    NSString *address = @"modify";
    
    NSString *addressN = [_addressTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];//去掉空掉
    
    if (![self isWriteFinishInfo]) {
        return;
    }

    NSURL *url = [[RequestParams sharedInstance] userDatasInquire];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:address forKey:@"operation"];
    [request setPostValue:_birthBut.titleLabel.text forKey:@"birthdate"];
    [request setPostValue:_dicDatas[@"realName"] forKey:@"realName"];
    [request setPostValue:addressN forKey:@"addressdetail"];
    
    if (cardSIDTag ==0)
    {
        //身份证与邮箱都不为空，都不传
    }else if (cardSIDTag ==1)
    {//身份证为空，邮箱不为空，不传邮箱
        
        NSString *sidString1 = [_emailTextField.text stringByAppendingString:cardSIDBtn.titleLabel.text];
        [request setPostValue:sidString1 forKey:@"SID"];
    }else if (cardSIDTag ==2)
    {//身份证为空，邮箱也为空
       
        NSString *sidString2 = [_idTextField.text stringByAppendingString:cardSIDBtn.titleLabel.text];
        [request setPostValue:sidString2 forKey:@"SID"];
        [request setPostValue:_emailTextField.text forKey:@"email"];
    }else if (cardSIDTag ==3)
    {//身份证不为空，邮箱为空
       
        [request setPostValue:_emailTextField.text forKey:@"email"];
    }
    
    [request setPostValue:@"1" forKey:@"flag"];
    [request setTimeOutSeconds:10];
    [request startAsynchronous];
    request.failedBlock = ^(void){
        [self networkPromptMessage:@"网络连接异常"];
    };
    
    request.completionBlock = ^(void){
        NSData *responseData = [request responseData];
        NSDictionary *dic = [responseData objectFromJSONData];
        NSInteger success = [[dic objectForKey:@"success"] integerValue];
        NSString *message = [NSString stringWithFormat:@"%@",[dic objectForKey:@"message"]];
        
        if (success == 1) {
            //修改之后的信息存入本地
            [SavaData writeDicToFile:dic[@"data"] FileName:User_File];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDatasFile" object:nil];
            [self networkPromptMessage:message];
            //同步家谱里面的数据
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:dic[@"data"][@"realName"],@"name",dic[@"data"][@"sex"],@"sex",dic[@"data"][@"birthdate"],@"birthDate",dic[@"data"][@"addressdetail"],@"address",dic[@"data"][@"userId"],@"memberId", nil];
            [MyFamilySQL updateMyinfoForData:dict];
            ///
            [self backBtnPressed];
        }else if ([dic[@"errorcode"] integerValue] == 1005)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else if ([dic[@"errorcode"] intValue] ==9000)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else
        {
            [MyToast showWithText:message :[UIScreen mainScreen].bounds.size.height/2-60];
        }
    };
}
#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self didHiddenPickerView];
    if (cardSIDTag ==2){
        if (textField.tag ==0) {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }else{
            myTableView.hidden = YES;
            textField.keyboardType = UIKeyboardTypeEmailAddress;
        }
       
    }else if (cardSIDTag ==1){
       textField.keyboardType = UIKeyboardTypeEmailAddress;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (cardSIDTag == 2 || cardSIDTag ==3) {
        myTableView.hidden = YES;
//        if (![CommonData isTitleBlank:_emailTextField.text]) {
//             [self goValidataEmailRequest:textField.text];
//        }
    }else if (cardSIDTag ==1){
        myTableView.hidden = YES;
    }
}
//去验证邮箱是否已使用
- (void)goValidataEmailRequest:(NSString *)email
{
    NSURL *url = [[RequestParams sharedInstance] getUserEmail];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setTimeOutSeconds:10];
    [request startAsynchronous];
    
    request.failedBlock = ^(void)
    {
        [self networkPromptMessage:@"网络连接异常"];
    };
    request.completionBlock = ^(void){
        NSData *responseData = [request responseData];
        NSDictionary *dic = [responseData objectFromJSONData];
        NSString *message = [NSString stringWithFormat:@"%@",[dic objectForKey:@"message"]];
        NSInteger succeed = [dic[@"success"] integerValue];
        if (succeed !=1)
        {
            isSucceedEmail = NO;
            [self networkPromptMessage:message];
        }

    };
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == _idTextField) {
      [_emailTextField becomeFirstResponder];
    }else if(textField == _emailTextField){
        [textField resignFirstResponder];
    }
    return YES;
}
#pragma  mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    myTableView.hidden = YES;
    [self didHiddenPickerView];
    if ( cardSIDTag == 2) {
        [_scrollBgView setContentOffset:CGPointMake(0, 80) animated:YES];
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
//    [self layerOutTheFrameAgain];
    
}

#pragma mark - UIScrollViewDelegate

- (void)didResignFirstResponder
{
    [_idTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    if ([scrollView isEqual:_scrollBgView])
    {
        [self didResignFirstResponder];
        [self didHiddenPickerView];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([_addressTextView isFirstResponder]) {
        [_addressTextView resignFirstResponder];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL isLogin = NO;
    [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
    [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
}

- (IBAction)didChangeCardSIDIdentityAction:(UIButton *)sender
{
    if (myTableView.hidden) {
        [myTableView setHidden:NO];
    }else{
        [myTableView setHidden:YES];
    }
    [self didResignFirstResponder];
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
    [cardSIDBtn setTitle:_arrData[indexPath.row] forState:UIControlStateNormal];
    [myTableView setHidden:YES];
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


- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_nameLab release];
    [_addressLab release];
    [_phoneLab release];
    [_dicDatas release];
    [_nameBgImage release];
    [_addressBgImage release];
    [_cardBgImage release];
    [_scrollBgView release];
    [_addressTextView release];
    [_birthBut release];
    [_pickerDate release];
    [_myPickerView release];
    [_birthImage release];
    [_birthLab release];
    [_idTextField release];
    [_emailTextField release];
    [cardSIDBtn release];
    [myTableView release];
    [_arrData release],_arrData = nil;
    [lineImage release];
    [super dealloc];
}
- (IBAction)didSelectBirthAction:(UIButton *)sender
{
    if ([_addressTextView isFirstResponder]) {
         [_addressTextView resignFirstResponder];
    }
    myTableView.hidden = YES;
    [self didResignFirstResponder];
    CGRect rect = _myPickerView.frame;
    rect.origin.x = 0;
    rect.origin.y = SCREEN_HEIGHT;
    _myPickerView.frame = rect;
    if (!_myPickerView.superview) {
        [self.view addSubview:_myPickerView];
    }
    
    [_pickerDate setMinimumDate:[self getDateFromDateButton:@"1000-01-01"]];
    
    if (_birthBut.titleLabel.text.length != 0) {
        [_pickerDate setDate:[self getDateFromDateButton:[_birthBut titleLabel].text]];
     }
    
    [_pickerDate setMaximumDate:[NSDate date]];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _myPickerView.frame;
        frame.origin.x = 0;
        frame.origin.y = SCREEN_HEIGHT - _myPickerView.frame.size.height;
        _myPickerView.frame = frame;
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
        [_myPickerView removeFromSuperview];
    }];

}

- (IBAction)didSelectFinishAction:(UIBarButtonItem *)sender
{
    
    [self didHiddenPickerView];
    [_birthBut setTitle:[self getDateFromDatePicker] forState:UIControlStateNormal];

}
- (IBAction)didSelectChangeDateTime:(UIDatePicker *)sender
{
    NSDate *date = [sender date];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    [_birthBut setTitle:dateStr forState:UIControlStateNormal];
}
- (IBAction)setSexAction:(UIButton *)sender {
}

@end
