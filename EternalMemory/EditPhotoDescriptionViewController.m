//
//  EditPhotoDescriptionViewController.m
//  EternalMemory
//
//  Created by FFF on 13-12-11.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "EditPhotoDescriptionViewController.h"
#import "MessageModel.h"
#import "LimitePasteTextView.h"
#import "RequestParams.h"
#import "MessageSQL.h"
#import "MyToast.h"
#import "PhotoListFormedRequest.h"
#import "NTLimitationInputView.h"
#import "Utilities.h"
#import "EMPhotoSyncEngine.h"

@import AVFoundation;
@import CoreAudio;
//
#define tLengthOverflowAlert        100

@interface EditPhotoDescriptionViewController () <ASIHTTPRequestDelegate>

@property (retain, nonatomic) IBOutlet UIView *containerView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet NTLimitationInputView *inputView;
@property (retain, nonatomic) PhotoListFormedRequest *request;

@end

NSString * const PhotoDesChangedNotification = @"PhotoDesChangedNotification";

@implementation EditPhotoDescriptionViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.titleLabel.text = @"编辑相片描述";
    [self.rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    self.middleBtn.hidden = YES;
    
    CGPoint containerPos = CGPointMake(_containerView.frame.origin.x
                                       , self.navBarView.frame.size.height + 10);
    CGSize containerSize = CGSizeMake(_containerView.frame.size.width, 96);
    _containerView.frame = (CGRect){
        .origin = containerPos,
        .size   = containerSize
    };
    
    _containerView.layer.cornerRadius = 3;
    _containerView.layer.borderColor  = RGBCOLOR(220, 220, 220).CGColor;
    _containerView.layer.borderWidth  = 0.5;
    
    _imageView.frame = CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, 83, 83);
  
    _inputView.maxLength = 100;
    _inputView.string = self.model.content;
    
    [_imageView setImage:_model.thumbnailImage];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    [_model               release];
    [_containerView       release];
    [_request             release];
    [_imageView           release];
    
    [super dealloc];
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    PhotoListFormedRequest *aRequest = (PhotoListFormedRequest *)request;
    NSDictionary *dic = [aRequest requestForUpdatingPhotoDesSuccess];
    if (dic)
    {
        [MessageSQL synchronizeBlog:@[dic] WithUserID:USERID];
        [MyToast showWithText:@"修改成功" :130];
        [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDesChangedNotification object:_model];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag  == tLengthOverflowAlert) {

    }

}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    _model.content = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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


#pragma mark - private : button click

- (void)backBtnPressed
{
    [_request clearDelegatesAndCancel];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)rightBtnPressed
{
    //TODO: sending change des request
    self.model.content = _inputView.string;
    NSInteger strLength = self.model.content.length;
    if (strLength > 100) {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"内容过长" message:@"您输入的描述信息过长，最多只能输入100个字" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alerView.tag = tLengthOverflowAlert;
        [alerView show];
        [alerView release];
        return;
    }
    
    if ([Utilities checkNetwork]) {
        [self sendRequest];
    } else {
        if ([[EMPhotoSyncEngine sharedEngine] updateOperationNeesdsSyncWithModel:self.model]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDesChangedNotification object:_model];
        } else {
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

- (void)sendRequest
{
    NSString *serverVersion = [[SavaData shareInstance] directPrintObject:kSavedPhotoListServerVersion];
    NSString *clientVersion = nil;
    if (!serverVersion) {
        clientVersion = @"1";
    } else {
        clientVersion = serverVersion;
    }
    NSURL *url = [[RequestParams sharedInstance] updatePhotoDetail];
    PhotoListFormedRequest *request = [[PhotoListFormedRequest alloc] initWithURL:url];
    [request setupRequestForUpdatePhotoDes:_model];
    [request setPostValue:clientVersion forKey:@"clientversion"];
    request.delegate = self;
    [request startAsynchronous];
    self.request = request;
    [request release];
}

- (void)setModel:(MessageModel *)model
{
    if (_model != model) {
        [_model release];
        _model = [model retain];
    }
    
}
@end
