//
//  LeaveMessageViewController.m
//  EternalMemory
//
//  Created by zhaogl on 13-12-19.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "LeaveMessageViewController.h"
#import "MyToast.h"
#import "RequestParams.h"
#import "MyToast.h"
#import "UIImage+ImageEffects.h"

@interface LeaveMessageViewController ()

@end

@implementation LeaveMessageViewController


-(void)dealloc{
    
    [_nickNameTextField release];
    [_contentImg release];
    [_contentTextView release];
    [_scrollView release];
    [_request clearDelegatesAndCancel];
    [_request release];
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
    
    self.navBarView.hidden = YES;
    self.rightBtn.hidden = YES;
    self.middleBtn.hidden = YES;
    self.backBtn.hidden = YES;
//    self.view.backgroundColor = [UIColor blackColor];
    
    _scrollView.scrollEnabled = YES;
    _scrollView.contentSize = CGSizeMake(320, 600);
    
    _contentImg.layer.cornerRadius = 5;
    _contentImg.layer.borderWidth = 1;
    _contentImg.userInteractionEnabled = YES;
    UIColor *_color = [UIColor blackColor];
    _nickNameTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"昵  称" attributes:@{NSForegroundColorAttributeName: _color}] autorelease];
    
    _contentTextView.attributedText = [[[NSAttributedString alloc] initWithString:@"留言内容"] autorelease];
    
    [_bgImageView setImage:[[UIImage imageNamed:@"Default.png"] applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.8 maskImage:nil]];
    
    // Do any additional setup after loading the view from its nib.
}
-(IBAction)leaveMessage:(id)sender{
    
    NSURL *url = [[RequestParams sharedInstance] leaveMessage];
    _request = [[ASIFormDataRequest alloc] initWithURL:url];
    [_request setRequestMethod:@"POST"];
    [_request setPostValue:[[SavaData shareInstance] printDataStr:USER_ID_ORIGINAL] forKey:@"userid"];
    [_request setPostValue:@"ios" forKey:@"platform"];
    [_request setPostValue:_nickNameTextField.text forKey:@"nickname"];
    [_request setPostValue:_contentTextView.text forKey:@"content"];
    [_request setTimeOutSeconds:20];
    [_request setDelegate:self];
    [_request setShouldAttemptPersistentConnection:NO];
    [_request startAsynchronous];
    
}
-(IBAction)close:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)requestFinished:(ASIHTTPRequest *)request{
    
    NSData *data = [request responseData];
    NSDictionary *dic = [data objectFromJSONData];
    NSString *message = dic[@"message"];
    NSInteger success = [dic[@"success"] integerValue];
    if (success == 1) {
        [MyToast showWithText:@"留言成功" :150];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [MyToast showWithText:message :150];
    }
}
-(void)requestFailed:(ASIHTTPRequest *)request{
    
    [MyToast showWithText:@"请检查网络" :150];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    _scrollView.contentOffset = CGPointMake(0, 0);
    [_nickNameTextField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate
{
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortraitUpsideDown;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationPortraitUpsideDown;
}

@end

