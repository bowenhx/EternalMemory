//
//  VerifyCodeViewController.m
//  EternalMemory
//
//  Created by zhaogl on 13-11-29.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "VerifyCodeViewController.h"
#import "MyToast.h"
#import "LoginViewController.h"

#define RESEND   200
@interface VerifyCodeViewController ()

@end

@implementation VerifyCodeViewController
@synthesize userInfo = _userInfo;
@synthesize comeInStyle;
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
    
    self.titleLabel.text = @"填写验证码";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    
    UIScrollView *_scrollView = [[UIScrollView alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        _scrollView.frame = CGRectMake(0, 64, 320, SCREEN_HEIGHT - 64);
    }else{
        _scrollView.frame = CGRectMake(0, 44, 320, SCREEN_HEIGHT - 64);
    }
    _scrollView.backgroundColor = [UIColor colorWithRed:238/255. green:242/255. blue:245/255. alpha:1.0];
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelKeyboard)];
    [_scrollView addGestureRecognizer:recognizer];
    [recognizer release];
    
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 180, 20)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = @"包含验证码的短信已发送至";
    nameLabel.textColor = [UIColor colorWithRed:118/255. green:131/255. blue:141/255. alpha:1.0];
    nameLabel.font = [UIFont systemFontOfSize:15.0f];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    [_scrollView addSubview:nameLabel];
    [nameLabel release];
    
    
    UILabel *_mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 25, 110, 20)];
    _mobileLabel.backgroundColor = [UIColor clearColor];
    _mobileLabel.text = self.userInfo[@"mobile"];
    _mobileLabel.font = [UIFont systemFontOfSize:15.0f];
    _mobileLabel.textAlignment = NSTextAlignmentLeft;
    [_scrollView addSubview:_mobileLabel];
    [_mobileLabel release];
    
    
    UIImageView *codeImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 45, 155, 45)];
    codeImg.image = [UIImage imageNamed:@"code_kuang"];
    [_scrollView addSubview:codeImg];
    [codeImg release];
    
    _codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 45, 150, 45)];
    _codeTextField.borderStyle = UITextBorderStyleNone;
    _codeTextField.placeholder = @" 验证码";
    _codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _codeTextField.textAlignment = NSTextAlignmentLeft;
    _codeTextField.textColor = [UIColor blackColor];
    _codeTextField.font = [UIFont systemFontOfSize:14.0f];
    _codeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _codeTextField.returnKeyType = UIReturnKeyNext;
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _codeTextField.delegate = self;
    _codeTextField.tag = 3;
    [_scrollView addSubview:_codeTextField];
    [_codeTextField release];
    
    
    _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendBtn.frame = CGRectMake(185, 45, 115, 45);
    [_sendBtn setTitle:@"59s" forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_sendBtn setBackgroundImage:[UIImage imageNamed:@"sendBtn_normal"] forState:UIControlStateNormal];
    [_sendBtn setBackgroundImage:[UIImage imageNamed:@"sendBtn_pressed"] forState:UIControlStateSelected];
    [_sendBtn addTarget:self action:@selector(resend) forControlEvents:UIControlEventTouchUpInside];
    _sendBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [_scrollView addSubview:_sendBtn];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(10, 115, 300, 45);
    [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
    confirmBtn.backgroundColor = [UIColor colorWithRed:32/255. green:156/255. blue:215/255. alpha:1.0];
    confirmBtn.tintColor = [UIColor whiteColor];
    [confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:confirmBtn];
    
    [_codeTextField becomeFirstResponder];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshSendBtn) userInfo:nil repeats:YES];
    [timer fire];
    
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)refreshSendBtn{
    
    NSInteger str =[[_sendBtn.titleLabel.text substringToIndex:_sendBtn.titleLabel.text.length - 1] integerValue] - 1;
    [_sendBtn setTitle:[NSString stringWithFormat:@"%ds",str] forState:UIControlStateNormal];
    if ([_sendBtn.titleLabel.text isEqualToString:@"0s"]) {
        [timer invalidate];
        [_sendBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        _sendBtn.userInteractionEnabled = YES;
    }else if ([[_sendBtn.titleLabel.text substringToIndex:_sendBtn.titleLabel.text.length - 1] integerValue] >= 1) {
        _sendBtn.userInteractionEnabled = NO;
    }
}
-(void)cancelKeyboard{
    
    [_codeTextField resignFirstResponder];

}


-(void)resend{
    
    _sendBtn.userInteractionEnabled = YES;
    NSURL *url = [[RequestParams sharedInstance] userCheckMobile];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    request.userInfo = @{@"tag": [NSNumber numberWithInt:RESEND]};
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:@"get" forKey:@"flag"];
    [request setPostValue:self.userInfo[@"mobile"] forKey:@"mobile"];
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setTimeOutSeconds:10];
    [request startAsynchronous];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshSendBtn) userInfo:nil repeats:YES];
    [_sendBtn setTitle:@"59s" forState:UIControlStateNormal];
    [timer fire];
    
}
-(void)confirm{
    NSURL *url = [[RequestParams sharedInstance] userDatasInquire];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setPostValue:@"modify" forKey:@"operation"];
    [request setPostValue:@"perfect" forKey:@"perfect"];
    [request setPostValue:self.userInfo[@"realname"] forKey:@"realname"];
    if ([self.userInfo[@"sid"] isEqualToString:@"null"]) {
        [request setPostValue:@"" forKey:@"sid"];
    }else{
        [request setPostValue:self.userInfo[@"sid"] forKey:@"sid"];
    }
    [request setPostValue:self.userInfo[@"email"] forKey:@"email"];
    [request setPostValue:self.userInfo[@"sex"] forKey:@"sex"];
    [request setPostValue:@"1" forKey:@"checkmobile"];
    [request setPostValue:self.userInfo[@"mobile"] forKey:@"mobile"];
    [request setPostValue:self.userInfo[@"birthdate"] forKey:@"birthdate"];
    [request setPostValue:@"1" forKey:@"flag"];
    [request setPostValue:@"" forKey:@"addressdetail"];
    [request setPostValue:_codeTextField.text forKey:@"mobilecode"];
    [request setTimeOutSeconds:10];
    [request startAsynchronous];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    if ([request.userInfo[@"tag"] integerValue] == RESEND) {
        
        if ([resultDictionary[@"success"] intValue] == 1){
        }else{
            [MyToast showWithText:@"重新发送失败" :150];
        }
        
    }else {
        if ([resultDictionary[@"success"] intValue] == 1)
        {
            //数据写入plist
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:resultDictionary[@"data"]];
            [SavaData writeDicToFile:dic FileName:User_File];
            [MyToast showWithText:@"完善资料成功" :150];
            if (self.comeInStyle == 0) {
                for (UIViewController *viewCtrl in self.navigationController.viewControllers)
                {
                    if ([viewCtrl isKindOfClass:[LoginViewController class]])
                    {
                        [self.navigationController popToViewController:viewCtrl animated:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ToSecondWay" object:nil];
                    }
                }
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeNoteView" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateInfoSuccess" object:nil];
            }
        }else{
            [MyToast showWithText:resultDictionary[@"message"] :150];
        }
    }
    
}

-(void)backBtnPressed{
    if (comeInStyle == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(comeInStyle == 1)
    {
        [self dismissViewControllerAnimated:YES completion:NULL];

    }
}
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
