//
//  EditIntroViewCtrl.m
//  EternalMemory
//
//  Created by Guibing Li on 13-5-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "EditIntroViewCtrl.h"
#import "RequestParams.h"
#import "CommonData.h"
#import "MyToast.h"

@interface EditIntroViewCtrl ()
{
    UITextView  *_textView;
}

@end

@implementation EditIntroViewCtrl
-(void)dealloc
{
    [_textView release];
    [super dealloc];
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
    self.titleLabel.text = @"编辑简介";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = NO;
    [self.rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    
    UIImageView *imageViewBg = [[UIImageView alloc] init];
    imageViewBg.userInteractionEnabled = YES;
    imageViewBg.backgroundColor = [UIColor whiteColor];
    imageViewBg.layer.borderWidth = 1;
    imageViewBg.layer.cornerRadius = 3;
    imageViewBg.layer.borderColor = RGBCOLOR(214, 214, 214).CGColor;
    if (iPhone5)
    {
        imageViewBg.frame = CGRectMake(8, iOS7 ? 75:55, self.view.bounds.size.width-16, 200);
    }
    else
    {
        imageViewBg.frame = CGRectMake(8, iOS7 ? 75:55, self.view.bounds.size.width-16, 150);
    }
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(4, 4, imageViewBg.frame.size.width-8, imageViewBg.frame.size.height-8)];
    _textView.delegate = self;
    _textView.scrollEnabled = YES;
    _textView.text = self.strIntro;
    [_textView becomeFirstResponder];
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.backgroundColor = [UIColor clearColor];
    [imageViewBg addSubview:_textView];
    [self.view addSubview:imageViewBg];
    [imageViewBg release];
	// Do any additional setup after loading the view.
}

-(void)rightBtnPressed
{
    //保存数据
//    NSString *token = [[SavaData shareInstance]printToken:TOKEN];
    NSString *address = @"modify";
    
    NSURL *url = [[RequestParams sharedInstance] userDatasInquire];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:address forKey:@"operation"];
    [request setPostValue:_textView.text forKey:@"intro"];
    [request setPostValue:@"2" forKey:@"flag"];

    [request setTimeOutSeconds:10];
    [request startAsynchronous];

    [request setFailedBlock:^(void)
    {
        [self networkPromptMessage:@"网络连接异常"];
    }];
    request.completionBlock = [^(void){
       NSData *data = [request responseData];
        NSDictionary *dic = [data objectFromJSONData];
        NSInteger success = [[dic objectForKey:@"success"] integerValue];
        NSString *message = [NSString stringWithFormat:@"%@",[dic objectForKey:@"message"]];
       
        
        if (success ==1) {
            
            NSMutableDictionary *fileDic = [NSMutableDictionary dictionaryWithDictionary:[SavaData parseDicFromFile:User_File]];
            [fileDic setObject:_textView.text forKey:@"intro"];
            [SavaData writeDicToFile:fileDic FileName:User_File];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDatasFile" object:nil];
            
            [self networkPromptMessage:message];
            [self backBtnPressed];
        }else if([dic[@"errorcode"] integerValue] == 1005)
        {
             [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else if ([dic[@"errorcode"] intValue] == 9000)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else
        {
            [self networkPromptMessage:message];
        }

        } copy];


}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSRange length = [textView.text rangeOfString:textView.text];
    if (length.length > 5000)
    {
        [MyToast showWithText:@"意见最多不能超过5000字":140];
        _textView.text = [_textView.text substringWithRange:NSMakeRange(0, 5000)];
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
-(void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
