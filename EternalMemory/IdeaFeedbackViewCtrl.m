//
//  IdeaFeedbackViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 13-8-16.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "IdeaFeedbackViewCtrl.h"
#import "MyToast.h"
#import "StaticTools.h"
#import "CommonData.h"
@interface IdeaFeedbackViewCtrl ()<ASIHTTPRequestDelegate,UIAlertViewDelegate,UITextViewDelegate>

@end

@implementation IdeaFeedbackViewCtrl

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
    self.titleLabel.text = @"意见反馈";
    self.middleBtn.hidden = YES;
    [self.rightBtn setTitle:@"发送" forState:UIControlStateNormal];
    
    UIImageView *imageViewBg = [[UIImageView alloc] init];
    imageViewBg.userInteractionEnabled = YES;
    imageViewBg.backgroundColor = [UIColor whiteColor];
    imageViewBg.layer.borderWidth = 1;
    imageViewBg.layer.cornerRadius = 3;
    imageViewBg.layer.borderColor = RGBCOLOR(214, 214, 214).CGColor;
    if (iPhone5)
    {
        imageViewBg.frame = CGRectMake(8, iOS7 ?75:55, self.view.bounds.size.width-16, 200);
    }
    else
    {
        imageViewBg.frame = CGRectMake(8, iOS7 ?75:55, self.view.bounds.size.width-16, 150);
    }
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(4, 4, imageViewBg.frame.size.width-8, imageViewBg.frame.size.height-8)];
    _textView.delegate = self;
    _textView.scrollEnabled = YES;
    [_textView becomeFirstResponder];
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.backgroundColor = [UIColor clearColor];
    [imageViewBg addSubview:_textView];
    [self.view addSubview:imageViewBg];
    [imageViewBg release];

    
    // Do any additional setup after loading the view from its nib.
}
-(void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnPressed
{
    if ([CommonData isTitleBlank:_textView.text]) {
        [self networkPromptMessage:@"请输入提交内容"];
        return;
    }
//    else if ()
    {
        
    }
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];

    NSDictionary *dic = [SavaData parseDicFromFile:User_File];
    
    NSURL *url = [[RequestParams sharedInstance] getIdeaFeedbackUrl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"ios" forKey:@"platform"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:@"iOS意见反馈" forKey:@"title"];
    [request setPostValue:_textView.text forKey:@"content"];
    [request setPostValue:[[UIDevice currentDevice] systemVersion] forKey:@"osversion"];  //系统版本
    [request setPostValue:version forKey:@"appversion"];                       //app版本
    [request setPostValue:dic[@"userName"] forKey:@"nickname"];                //称呢
    [request setPostValue:dic[@"lastLoginTime"] forKey:@"linktel"];            //联系电话
    [request setPostValue:dic[@"addressdetail"] forKey:@"linkaddress"];        //联系地址
    [request setPostValue:@"" forKey:@"extra"];                                //其他信息
    [request startAsynchronous];
    
    self.rightBtn.userInteractionEnabled = NO;
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    NSDictionary *dic = [data objectFromJSONData];
    if ([dic[@"success"] integerValue] == 1) {
        [self networkPromptMessage:@"提交信息成功"];
        [self backBtnPressed];
    }else if([dic[@"errorcode"] integerValue] == 1005)
    {
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE  message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
    }else if ([dic[@"errorcode"] intValue] == 9000)
    {
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
    }else{
        //[self networkPromptMessage:@"服务器出错"];
        [MyToast showWithText:dic[@"message"] :80];
    }
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSRange length = [textView.text rangeOfString:textView.text];
    if (length.length > 500)
    {
        [MyToast showWithText:@"意见最多不能超过500字":140];
        _textView.text = [_textView.text substringWithRange:NSMakeRange(0, 500)];
        return NO;
    }
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL isLogin = NO;
    [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
    [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    //[self networkPromptMessage:@"网络连接异常"];
    [MyToast showWithText:@"网络连接异常" :80];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
