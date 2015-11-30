//
//  UserDetailViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 13-7-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "UserDetailViewCtrl.h"
#import "EditIntroViewCtrl.h"
#import "EditDetailViewCtrl.h"
#import "CommonData.h"
#import "QRCodeGenerator.h"
#import "TwoDimCodeViewController.h"
#import "MyToast.h"
#import "MD5.h"

#define GET_USERDATA_TAG  100
#define GET_EMAIL_TAG_VERIFY    200
#define GET_EMAIL_TAG_CHANGE    300
#define GET_PHONE_TAG_VERIFY    400
#define GET_PHONE_TAG_CHANGE    500


@interface UserDetailViewCtrl ()<UITextFieldDelegate>
{
    NSDictionary *_dicDatas;
    CGSize         addressLabelSize;
    CGFloat        addHeight;
    UIImage      *twoDimCodeImage;
    ASIFormDataRequest *_userRequest;
    
    IBOutlet UIView *subPopView;
    IBOutlet UILabel *popViewTitleLab;
    IBOutlet UITextField *messageTextField;
    IBOutlet UITextField *pawTextField;
    IBOutlet UITextField *getCodeTextField;
    IBOutlet UILabel *getTextLab;
    IBOutlet UIButton *getCodeBtn;
    IBOutlet UILabel *title2Lab;
    IBOutlet UIButton *confirmBtn;
    IBOutlet UIImageView *virifyImage;
    IBOutlet UIImageView *getVerifyImage;
    
    NSTimer  *_timer;
    UITextField  *_myTextFiled;
    NSInteger   emailTimer;
}

- (IBAction)didDelectSubPopViewAction:(UIButton *)sender;

@end

@implementation UserDetailViewCtrl

- (void)dealloc {
    if (_userRequest) {
        [_userRequest clearDelegatesAndCancel],_userRequest = nil;
    }
    [_userNameBut release];
    [_userNameLab release];
    [_nameBut release];
    [_nameLab release];
    [_addressBut release];
    [_addressLab release];
    [_cardNumberBut release];
    [_cardNumberLab release];
    [_hphoneNumberBut release];
    [_hphoneNumberLab release];
    [_introBut release];
    [_introLab release];
    [_myScrollView release];
    [_dicDatas release],_dicDatas = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_introMorkImage release];
    [_nameBgImage release];
    [_addressBgImage release];
    [_hphoneBgImage release];
    [_introduceBgImage release];
    [_cardBgImage release];
    [_nameArrImage release];
    [_addressArrImage release];
    [_cardArrImage release];
    [_hphoneArrImage release];
    [_memoryCodeText release];
    [_memoryText release];
    [_makerText release];
    [_authCode release];
    [_sexBut release];
    [_birthBut release];
    [_sexLab release];
    [_birthLab release];
    [_authCodeLab release];
    [twoDimCodeImage release];
    [_towCodeBtn release];
    [_hiddenCodeViewBg release];
    [_email release];
    [_emailLab release];
    [subPopView release];
    [getTextLab release];
    [pawTextField release];
    [getCodeTextField release];
    [getCodeBtn release];
    [title2Lab release];
    [messageTextField release];
    [confirmBtn release];
    [popViewTitleLab release];
    [_verifyBtn release];
    [virifyImage release];
    [getVerifyImage release];
    [_letterLab release];
    [_myTextView release];
    [_lineImage1 release];
    [_lineImage2 release];
    [_changeEmailBtn release];
    [_changePhoneBtn release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
         _dicDatas = [[NSDictionary alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    subPopView.hidden = YES;
    self.titleLabel.text = @"个人资料";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    self.addressLab.numberOfLines = 0;
    self.introLab.numberOfLines = 0;
    self.introLab.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.userNameLab        setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.memoryCodeText     setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.authCodeLab        setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.makerText          setTextColor:[UIColor orangeColor]];
    [self.memoryText         setTextColor:[UIColor orangeColor]];
    [self.nameLab            setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.sexLab             setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.birthLab           setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.addressLab         setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.emailLab           setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.cardNumberLab      setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.hphoneNumberLab    setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    [self.introLab           setTextColor:RGBCOLOR(93.0, 102.0, 113.0)];
    
    
    [self.changeEmailBtn   setTitleColor:   [UIColor orangeColor] forState:UIControlStateNormal];
    [self.changePhoneBtn   setTitleColor:   [UIColor orangeColor] forState:UIControlStateNormal];
    [self.userNameBut setTitleColor:    RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.sexBut setTitleColor:         RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.birthBut setTitleColor:       RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.authCode setTitleColor:       RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.towCodeBtn setTitleColor:     RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.nameBut setTitleColor:        RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.addressBut setTitleColor:     RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.cardNumberBut setTitleColor:  RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.hphoneNumberBut setTitleColor:RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    [self.introBut setTitleColor:       RGBCOLOR(93.0, 102.0, 113.0) forState:UIControlStateNormal];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDataPersonFile) name:@"upDatasFile" object:nil];
    
    //读取本地数据并加载
    [self upDataPersonFile];
    
    //请求接口刷新UI
    [self requestDatas];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)requestDatas
{
    NSURL *url = [[RequestParams sharedInstance] userDatasInquire];
    NSString *address = @"show";
    _userRequest = [[ASIFormDataRequest alloc]initWithURL:url];
    [_userRequest setRequestMethod:@"POST"];
    [_userRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_userRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_userRequest setPostValue:address forKey:@"operation"];
    [_userRequest setUserInfo:@{@"tag":@(GET_USERDATA_TAG)}];
    [_userRequest setDelegate:self];
    [_userRequest setTimeOutSeconds:10];
    [_userRequest startAsynchronous];
}
- (void)initViewUpData
{
    
    self.userNameLab.text = [_dicDatas objectForKey:@"userName"];
    self.nameLab.text = [_dicDatas objectForKey:@"realName"];

    
    NSString *memoryText = [NSString stringWithFormat:@"%@",_dicDatas[@"eternalnum"]];
    if ([CommonData isTitleBlank:memoryText]) {
        self.memoryText.text = @"";
    }else{
        self.memoryText.text = memoryText;
    }
    
    [self showTowCodeView:YES];

    NSString *SID = [NSString stringWithFormat:@"%@",_dicDatas[@"SID"]];
    NSString *NEWSID = @"";
    if (SID.length != 0) {
       _letterLab.text = [SID substringWithRange:NSMakeRange(SID.length-1, 1)];
        NSString *sidString2 = [SID substringWithRange:NSMakeRange(0, SID.length-1)];
        NEWSID = [sidString2 stringByReplacingCharactersInRange:NSMakeRange(10, 4) withString:@"****"];
        _letterLab.hidden = NO;
        _lineImage2.hidden = NO;
    }else{
        _lineImage2.hidden = YES;
        _letterLab.hidden = YES;
    }
    self.cardNumberLab.text = NEWSID;
    self.hphoneNumberLab.text = [_dicDatas objectForKey:@"mobile"];
    NSString *addr = [_dicDatas objectForKey:@"addressdetail"];
    self.addressLab.text = [addr stringByReplacingOccurrencesOfString:@" " withString:@""];
    _emailLab.hidden = YES;
    if ([CommonData isTitleBlank:_dicDatas[@"email"]]) {
        _myTextView.hidden = YES;
        _lineImage1.hidden = YES;
        _verifyBtn.hidden = YES;
        _changeEmailBtn.hidden = YES;
    }else{
        _myTextView.hidden = NO;
        _lineImage1.hidden = NO;
        _verifyBtn.hidden = NO;
        _changeEmailBtn.hidden = NO;
        //_emailLab.hidden = NO;
        //self.emailLab.text = _dicDatas[@"email"];
        self.myTextView.text = _dicDatas[@"email"];
        BOOL isVerify = [_dicDatas[@"emailverified"] boolValue];
        if (isVerify) {
            _verifyBtn.userInteractionEnabled = NO;
            [_verifyBtn setTitle:@"已验证" forState:UIControlStateNormal];
            [_verifyBtn setTitleColor:RGBCOLOR(200, 46, 46) forState:UIControlStateNormal];
        }else
        {
            _verifyBtn.userInteractionEnabled = YES;
             emailTimer = 60;
            [_verifyBtn setTitle:@"点击验证" forState:UIControlStateNormal];
            [_verifyBtn setTitleColor:RGBCOLOR(46, 154, 222) forState:UIControlStateNormal];
        }
    }
    
    self.sexLab.text = [_dicDatas[@"sex"] integerValue] == 1 ? @"男" : @"女";
    NSString *strBirth = [NSString stringWithFormat:@"%@",_dicDatas[@"birthdate"]];
    self.birthLab.text = [CommonData getTimeransitionBirthDataPath:strBirth];
   
    NSString *str = _dicDatas[@"intro"];
    self.introLab.text = [CommonData isTitleBlank:str] ? @"这家伙很懒，什么都没留下！" :str;
    CGFloat introHeight;
    introHeight = [self tableTextHeitht:self.introLab.text];
    
    CGRect temp = self.introLab.frame;
    temp.origin.y = temp.origin.y-3 ;
    temp.size.height = introHeight;
    self.introLab.frame = temp;
//    _introLab.layer.borderWidth = 2;
//    _introLab.layer.borderColor = [UIColor redColor].CGColor;
    
    CGRect tempBut = self.introBut.frame;
    tempBut.size.height = introHeight + 18;
    self.introBut.frame = tempBut;
    [self.introBut setBackgroundImage:[[UIImage imageNamed:@"public_table_fullBg.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:2]forState:UIControlStateNormal];
//    _introBut.layer.borderWidth = 2;
//    _introBut.layer.borderColor = [UIColor yellowColor].CGColor;
    
    tempBut.origin.y = CGRectGetMaxY(self.introBut.frame) - self.introBut.frame.size.height/2 - 8;
    tempBut.origin.x = self.introMorkImage.frame.origin.x;
    tempBut.size.width = 8;
    tempBut.size.height = 12;
    self.introMorkImage.frame = tempBut;
    self.introMorkImage.image = [UIImage imageNamed:@"jt_right.png"];
    
    NSInteger hight = iOS7 ? 40:90;
    if (!iPhone5) {
        hight = iOS7 ? 100:150;
    }
    self.myScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+introHeight + addHeight+hight);
//    self.myScrollView.layer.borderWidth = 2;
//    self.myScrollView.layer.borderColor = [UIColor redColor].CGColor;
    
}
- (void)showTowCodeView:(BOOL)isHidden
{
   //当有二维码去添加view
    _hiddenCodeViewBg.hidden = NO;
    //_hiddenCodeViewBg.backgroundColor = [UIColor yellowColor];
    _hiddenCodeViewBg.backgroundColor = RGBCOLOR(238, 242, 245);//_authCode
    _hiddenCodeViewBg.frame = CGRectMake(0, CGRectGetMaxY(_memoryCodeText.frame)+20, self.view.bounds.size.width, _hiddenCodeViewBg.frame.size.height+100);
    _twoCodeImg.image = twoDimCodeImage;
    [_myScrollView addSubview:_hiddenCodeViewBg];
   
}

- (void)upDataPersonFile
{
    NSDictionary *dic = [SavaData parseDicFromFile:User_File];
    if (dic.count >0) {
        _dicDatas = [dic retain];
        //更新数据
        
        addressLabelSize = [_dicDatas[@"addressdetail"] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(190, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        
        addHeight = (addressLabelSize.height - 18) > 0 ? (addressLabelSize.height - 18):0;
        if (addHeight == 0)
        {
            self.addressLab.textAlignment = NSTextAlignmentRight;
        }
        else
        {
            self.addressLab.textAlignment = NSTextAlignmentLeft;
        }
        [self initViewUpData];
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    BOOL isLogin = NO;
    [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
    [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
    
}
-(CGFloat)tableTextHeitht:(NSString *)str
{
    CGSize size =[str sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(250, 3000) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height<20 ? 26 : size.height+20;
}
//二维码页面
- (IBAction)didSelectInTowCodeActio:(UIButton *)sender {
    
    TwoDimCodeViewController *twodimcodeVC = [[TwoDimCodeViewController alloc] init];
    twodimcodeVC.twoDimCodeImg = twoDimCodeImage;
    [self.navigationController pushViewController:twodimcodeVC animated:YES];
    [twoDimCodeImage release];
}

- (IBAction)didSelectIntroDetailAction:(UIButton *)sender {
    EditIntroViewCtrl *editIntro = [EditIntroViewCtrl new];
    editIntro.strIntro = [_dicDatas objectForKey:@"intro"];
    [self.navigationController pushViewController:editIntro animated:YES];
    [editIntro release];
}

#pragma mark  UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _myTextFiled = textField;
    if (!messageTextField.hidden ) {
        if (textField.tag ==1 || textField.tag ==2) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }
    }else if (textField.tag ==1){
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (messageTextField.hidden) {
        if (textField.tag ==0) {
            [getCodeTextField becomeFirstResponder];
            [getCodeTextField setKeyboardType:UIKeyboardTypeEmailAddress];
        }else{
            [textField resignFirstResponder];
        }
    }else{
        if (textField.tag ==0) {
            [getCodeTextField becomeFirstResponder];
            [getCodeTextField setKeyboardType:UIKeyboardTypeNumberPad];
        }else if (textField.tag ==1){
            [messageTextField becomeFirstResponder];
            [messageTextField setKeyboardType:UIKeyboardTypeNumberPad];
        }
        
    }
    
    return YES;
}
#pragma mark 修改电话、邮箱弹出popView

//去验证邮箱/修改邮箱
- (void)goValidataEmailRequest:(NSInteger)index
{
    NSURL *url = [[RequestParams sharedInstance] getUserEmail];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    if (index ==1) {
        request.userInfo = @{@"tag":@(GET_EMAIL_TAG_VERIFY)};
        [request setPostValue:@"send" forKey:@"op"];
    }else{
        request.userInfo = @{@"tag":@(GET_EMAIL_TAG_CHANGE)};
        [request setPostValue:@"update" forKey:@"op"];
        [request setPostValue:getCodeTextField.text forKey:@"email"];
        [request setPostValue:[MD5 md5:pawTextField.text] forKey:@"password"];
    }
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setTimeOutSeconds:20];
    [request startAsynchronous];
}
//获取手机验证码、修改手机号码
- (void)getGoChangePhoneRequest:(NSInteger)index
{
    NSURL *url = [[RequestParams sharedInstance] userCheckMobile];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setPostValue:getCodeTextField.text forKey:@"mobile"];
    if (index ==1) {
        [request setPostValue:@"get" forKey:@"flag"];
        request.userInfo = @{@"tag": @(GET_PHONE_TAG_VERIFY)};
    }else{
        [request setPostValue:@"update" forKey:@"flag"];
        [request setPostValue:[MD5 md5:pawTextField.text] forKey:@"password"];
        [request setPostValue:messageTextField.text forKey:@"mobilecode"];
        request.userInfo = @{@"tag": @(GET_PHONE_TAG_CHANGE)};
    }
    [request setTimeOutSeconds:20];
    [request startAsynchronous];
}
//验证邮箱操作
- (IBAction)didSelectVerifyEmailAction:(UIButton *)sender
{
    if (emailTimer < 60) {
        [MyToast showWithText:@"时间间隔太短，请稍后再试" :200];
    }else{
        NSTimer *timerEmail = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(didBeginTimerEmail:) userInfo:nil repeats:YES];
        [timerEmail fire];
        [self goValidataEmailRequest:1];
    }
}
//验证邮箱计时器
- (void)didBeginTimerEmail:(NSTimer *)temp
{
    emailTimer --;
    if (emailTimer ==0) {
        emailTimer = 60;
        [temp invalidate];
    }
}
//获取手机验证码操作
- (IBAction)didGetVerifyCodePhoneAction:(UIButton *)sender
{
    if ([self isTextTitleString:1]) {
         [self getGoChangePhoneRequest:1];
        
        [sender setTitle:@"60s" forState:UIControlStateNormal];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(didTimereRefreshSendBtn) userInfo:nil repeats:YES];
        [_timer fire];
    }
    

}
//点击邮箱判断是否为空，为空进入编辑页面
- (IBAction)didSelectEmailAction:(UIButton *)sender {
    if ([CommonData isTitleBlank:_myTextView.text]) {
        [self didEditData];
    }
}
//计时器
-(void)didTimereRefreshSendBtn{
    
    NSInteger str =[[getCodeBtn.titleLabel.text substringToIndex:getCodeBtn.titleLabel.text.length - 1] integerValue] - 1;
    [getCodeBtn setTitle:[NSString stringWithFormat:@"%ds",str] forState:UIControlStateNormal];
    if ([getCodeBtn.titleLabel.text isEqualToString:@"0s"]) {
        [_timer invalidate];
        [getCodeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        getCodeBtn.userInteractionEnabled = YES;
    }else if ([[getCodeBtn.titleLabel.text substringToIndex:getCodeBtn.titleLabel.text.length - 1] integerValue] >= 1) {
        getCodeBtn.userInteractionEnabled = NO;
    }
}
//修改电话号码操作
- (IBAction)didSelectUserDetailAction:(UIButton *)sender
{
    pawTextField.secureTextEntry = YES;
    popViewTitleLab.text = @"修改手机号码";
    getTextLab.text = @"请输入您的新手机号码";
    pawTextField.text = @"";
    getCodeTextField.text = @"";
    messageTextField.text = @"";
    title2Lab.hidden = YES;
    [getCodeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [getCodeBtn setTitleColor:RGBCOLOR(231, 231, 231) forState:UIControlStateSelected];
    getCodeBtn.layer.borderWidth = 0.8f;
    getCodeBtn.layer.borderColor = RGBCOLOR(212, 212, 212).CGColor;
//    getCodeBtn.layer.borderColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"public_table_middleeBg"]].CGColor;
    
    CGRect getCodeFrame = getCodeTextField.frame;
    getCodeFrame.size.width = 270;
    getCodeTextField.frame = getCodeFrame;
    
    CGRect getVerifyFrame = getVerifyImage.frame;
    getVerifyFrame.size.width = 275;
    getVerifyImage.frame = getVerifyFrame;
    
    CGRect confirmBtnFrame = confirmBtn.frame;
    confirmBtnFrame.origin.x = 200;
    confirmBtn.frame = confirmBtnFrame;
    
    getCodeBtn.hidden = NO;
    virifyImage.hidden = NO;
    messageTextField.hidden = NO;
    
    [self showSubPopView];
    

}
//修改邮箱操作
- (IBAction)didSelectChangeEmailAction:(UIButton *)sender
{
    pawTextField.secureTextEntry = YES;
    popViewTitleLab.text = @"修改邮箱地址";
    getTextLab.text = @"请输入您的新邮箱地址";
    getCodeBtn.hidden = YES;
    title2Lab.hidden = NO;
    virifyImage.hidden = YES;
    messageTextField.hidden = YES;
    pawTextField.text = @"";
    getCodeTextField.text = @"";
    messageTextField.text = @"";
    
    
    CGRect getCodeFrame = getCodeTextField.frame;
    getCodeFrame.size.width = pawTextField.frame.size.width;
    getCodeTextField.frame = getCodeFrame;
    
    CGRect getVerifyFrame = getVerifyImage.frame;
    getVerifyFrame.size.width = 275;
    getVerifyImage.frame = getVerifyFrame;
    
    CGRect confirmBtnFrame = confirmBtn.frame;
    confirmBtnFrame.origin.x = 110;
    confirmBtn.frame = confirmBtnFrame;
    
    
    [self showSubPopView];
}
//判断手机号密码验证码是否为空并提示
- (BOOL)isTextTitleString:(NSInteger)send
{
    if (messageTextField.hidden) {
        if (![CommonData isTitleBlank:pawTextField.text] && ![CommonData isTitleBlank:getCodeTextField.text]) {
            if (![self isValidateEmailCorrect]) {
                [MyToast showWithText:@"请填写正确邮箱" :200];
                return NO;
            }else{
                confirmBtn.userInteractionEnabled = NO;
                return YES;
            }
        }else if ([CommonData isTitleBlank:getCodeTextField.text]){
            [MyToast showWithText:@"邮箱地址不能为空" :200];
            return NO;
        }else if ([CommonData isTitleBlank:pawTextField.text]){
            [MyToast showWithText:@"密码不能为空" :200];
            return NO;
        }
    }else {
        if (send ==1) {
            if (![CommonData isTitleBlank:pawTextField.text] && ![CommonData isTitleBlank:getCodeTextField.text]) {
                if ([self phoneNumberCorrect]) {
                    confirmBtn.userInteractionEnabled = NO;
                    return YES;
                }
            }else if ([CommonData isTitleBlank:getCodeTextField.text]){
                [MyToast showWithText:@"手机号不能为空" :200];
                return NO;
            }else if([CommonData isTitleBlank:messageTextField.text]){
                [MyToast showWithText:@"验证码不能为空" :200];
                return NO;
            }
        }else if (send ==2){
            if (![CommonData isTitleBlank:pawTextField.text] && ![CommonData isTitleBlank:getCodeTextField.text] && ![CommonData isTitleBlank:messageTextField.text]) {
                if ([self phoneNumberCorrect]) {
                    confirmBtn.userInteractionEnabled = NO;
                    return YES;
                }
            }else if ([CommonData isTitleBlank:messageTextField.text]){
                [MyToast showWithText:@"验证码不能为空" :200];
                return NO;
            }else if ([CommonData isTitleBlank:getCodeTextField.text]){
                [MyToast showWithText:@"手机号不能为空" :200];
                return NO;
            }else if ([CommonData isTitleBlank:pawTextField.text]){
                [MyToast showWithText:@"密码不能为空" :200];
                return NO;
            }
        }
    }
    return NO;
}
//验证手机号是否正确
- (BOOL)phoneNumberCorrect
{
    NSString *mobilephoneRegex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0-2,5-9]))\\d{8}$";//验证手机号是否正确
    NSString *telephoneRegex = @"^0(10|2[0-5789]|\\d{3})\\d{7}$";
    NSPredicate *mobilePhonePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobilephoneRegex];
    NSPredicate *telephonePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",telephoneRegex];
    
    BOOL mobileIsMatch = [mobilePhonePred evaluateWithObject:getCodeTextField.text];
    BOOL teleIsMatch = [telephonePred evaluateWithObject:getCodeTextField.text];
    if (!mobileIsMatch && !teleIsMatch) {
        [MyToast showWithText:@"请输入正确的手机号" :[UIScreen mainScreen].bounds.size.height/2-60];
        return NO;
    }else{
        return YES;
    }
}
//判断邮箱是否正确
- (BOOL)isValidateEmailCorrect
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:getCodeTextField.text];
}
//确定去修改操作（邮箱和电话操作）
- (IBAction)didSelectConfrimChangeAction:(UIButton *)sender
{
    [_myTextFiled resignFirstResponder];
    if (messageTextField.hidden)
    { //修改邮箱操作
        if ([self isTextTitleString:2]) {
            [self goValidataEmailRequest:2];
        }
    }
    else
    {//修改手机号
        if ([self isTextTitleString:2]) {
            [self getGoChangePhoneRequest:2];
        }
    }
   
}


//出现popView动画
- (void)showSubPopView
{
    subPopView.hidden = NO;
    _hiddenCodeViewBg.userInteractionEnabled = NO;
    [_myScrollView bringSubviewToFront:subPopView];
    [_myScrollView setContentOffset:CGPointMake(0, 55) animated:YES];
    self.view.backgroundColor = [UIColor grayColor];
    _myScrollView.backgroundColor = [UIColor grayColor];
    _hiddenCodeViewBg.backgroundColor = [UIColor grayColor];
    _nameArrImage.backgroundColor = [UIColor grayColor];
    _nameArrImage.alpha = 0.5f;
    _hiddenCodeViewBg.alpha = 0.5f;
    subPopView.backgroundColor = [UIColor whiteColor];
    
    
    [UIView animateWithDuration:0.3f animations:
     ^(void){
         subPopView.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.1f, 1.1f);
     }completion:^(BOOL finished){
         [self bounceOutAnimationStoped];
     }];
}
- (void)bounceOutAnimationStoped
{
    [UIView animateWithDuration:0.1f animations:
     ^(void){
         subPopView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.85f, 0.85f);
     }
                     completion:^(BOOL finished){
                         [self bounceInAnimationStoped];
                     }];
}
- (void)bounceInAnimationStoped
{
    [UIView animateWithDuration:0.1 animations:
     ^(void){
         subPopView.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.f, 1.f);
     }completion:nil];
}
//隐藏popView
- (IBAction)didDelectSubPopViewAction:(UIButton *)sender
{
    subPopView.hidden = YES;
    
    //当在计时时暂停计时器
    if (!getCodeBtn.userInteractionEnabled) {
        [_timer invalidate];
    }
    if ([_myTextFiled isFirstResponder]) {
        [_myTextFiled resignFirstResponder];
    }
    getCodeBtn.userInteractionEnabled = YES;
    [getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_hiddenCodeViewBg setUserInteractionEnabled:YES];
    
    self.view.backgroundColor =  RGBCOLOR(238, 242, 245);
    _myScrollView.backgroundColor = [UIColor clearColor];
    _nameArrImage.backgroundColor = [UIColor whiteColor];
    _hiddenCodeViewBg.backgroundColor = RGBCOLOR(238, 242, 245);
    _hiddenCodeViewBg.alpha = 1.f;
}
//进入编辑信息页面
- (void)didEditData
{
    EditDetailViewCtrl *editnews = [[EditDetailViewCtrl alloc] initWithNibName:@"EditDetailViewCtrl" bundle:nil];
    [editnews.dicDatas setDictionary:_dicDatas];
    [self.navigationController pushViewController:editnews animated:YES];
    [editnews release];
}

#pragma mark ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    NSDictionary *requestDic = [data objectFromJSONData];
    NSInteger tag = [request.userInfo[@"tag"] integerValue];
    NSInteger success = [requestDic[@"success"] integerValue];
    NSString *maessage = requestDic[@"message"];
    confirmBtn.userInteractionEnabled = YES;
    
    if (tag == GET_USERDATA_TAG)
    {//个人资料信息
        if (success == 1) {
            _dicDatas = [[requestDic objectForKey:@"data"] retain];
            [SavaData writeDicToFile:_dicDatas FileName:User_File];
            
            [self initViewUpData];
        }
    }else if (tag == GET_EMAIL_TAG_VERIFY)
    {//验证邮箱
       [MyToast showWithText:maessage :200];
    }else if (tag == GET_EMAIL_TAG_CHANGE)
    {//修改邮箱
        if (success ==1) {
            _myTextView.text = getCodeTextField.text;
            _verifyBtn.userInteractionEnabled = YES;
            [_verifyBtn setTitle:@"点击验证" forState:UIControlStateNormal];
            [_verifyBtn setTitleColor:RGBCOLOR(46, 154, 222) forState:UIControlStateNormal];
            [self didDelectSubPopViewAction:nil];
        }
         [MyToast showWithText:maessage :200];
    }else if (tag == GET_PHONE_TAG_VERIFY)
    {//验证手机号
        if (success != 1) {
            [_timer invalidate];
            getCodeBtn.userInteractionEnabled = YES;
            [getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        }
        [MyToast showWithText:maessage :200];
    }else if (tag == GET_PHONE_TAG_CHANGE)
    {//修改手机号
        if (success ==1) {
            _hphoneNumberLab.text = getCodeTextField.text;
            [self didDelectSubPopViewAction:nil];
        }
         [MyToast showWithText:maessage :200];
    }
    else if([requestDic[@"errorcode"] integerValue] == 1005)
    {
        [[[[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
    }else if ([requestDic[@"errorcode"] intValue] ==9000)
    {
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
    }else{
        [MyToast showWithText:maessage :200];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
     confirmBtn.userInteractionEnabled = YES;
    [self networkPromptMessage:@"网络连接异常"];
}
- (IBAction)didAuthorizationCode:(UIButton *)sender
{//获取授权码
    NSURL *url = [[RequestParams sharedInstance] gainUserGenerateauthcode];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setDelegate:self];
    [request setTimeOutSeconds:10];
    [request startAsynchronous];
    request.failedBlock = ^{
        [self networkPromptMessage:@"网络连接异常"];
                           };
    request.completionBlock = ^(void){
        NSData *responseData = [request responseData];
        NSDictionary *dic = [responseData objectFromJSONData];
        if ([dic[@"success"] integerValue] ==1){
            _makerText.text = [NSString stringWithFormat:@"%@",dic[@"data"][@"tempAuthCode"]];
            [_authCode setTitle:@"重新获取" forState:UIControlStateNormal];
            _authCode.frame = CGRectMake(230-72, _authCode.frame.origin.y, _authCode.frame.size.width, _authCode.frame.size.height);
            [self getTwoDimCode];
            [self showTowCodeView:YES];
            
        }else if([dic[@"errorcode"] integerValue] == 1005)
        {
            [[[[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else if ([dic[@"errorcode"] intValue] == 9000)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else{
            [self networkPromptMessage:@"服务器出错"];
        }
    };
}
-(void)getTwoDimCode{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:_memoryText.text forKey:@"n"];
    [dict setObject:_makerText.text forKey:@"a"];
    NSString *jsonStr = [dict JSONString];
    [dict release];
    CGSize size = CGSizeMake(260.f, 260.f);

    twoDimCodeImage=[QRCodeGenerator qrImageForString:jsonStr imageSize:size.width];
    UIGraphicsBeginImageContext(size);
    [twoDimCodeImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    twoDimCodeImage = UIGraphicsGetImageFromCurrentImageContext();
    [twoDimCodeImage retain];
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/erweimaAuth.png",docDir];
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(twoDimCodeImage)];
    [data writeToFile:pngFilePath atomically:YES];

}
- (IBAction)didSelectSexAction:(UIButton *)sender
{
    [self didEditData];
}

- (IBAction)didSelectBirthAction:(UIButton *)sender
{
    [self didEditData];
}


-(void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setNameBgImage:nil];
    [self setAddressBgImage:nil];
    [self setHphoneBgImage:nil];
    [self setIntroduceBgImage:nil];
    [self setCardBgImage:nil];
    [self setNameArrImage:nil];
    [self setAddressArrImage:nil];
    [self setCardArrImage:nil];
    [self setHphoneArrImage:nil];
    [self setMemoryCodeText:nil];
    [self setMemoryText:nil];
    [self setMakerText:nil];
    [self setAuthCode:nil];
    [super viewDidUnload];
}



@end
