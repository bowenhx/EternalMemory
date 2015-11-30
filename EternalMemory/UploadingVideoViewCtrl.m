//
//  UploadingVideoViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 13-6-6.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadingVideoViewCtrl.h"
#import "CommonData.h"
#import "FileModel.h"
#import "EternalMemoryAppDelegate.h"
#import "MyVideoPageViewCtrl.h"
#import "MyToast.h"
#import "StaticTools.h"
#import "VedioSendOperation.h"
#import "UploadingDebugging.h"
#import "ResumeVedioSendOperation.h"

#define UPDATE_READY_TAG  1001
#define UPDATE_RSUME_TAG  1002
#define UPDATE_FIRST_TAG  1003
#define UPDATE_GOGO_TAG   1004

#define FileModel     [FileModel sharedInstance]
#define ResumeUploading [ResumeVedioSendOperation shareInstance]
#define IOS7_OR_LATER  ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
//#import "TCPSocket.h"
@interface UploadingVideoViewCtrl ()
{
    __block UIView      *_myBgView;
    UITextField *_myTextField;
    UISwitch       *_switch;
    ASIHTTPRequest *uploadRequest;
    NSString       *sourceId;
    NSString       *vedioSize;
    NSFileHandle   *fileHandle;
    long            beginLocation;
    long            uploadSize;
    NSData         *uploadData;
}

// 开始视频上传
//-(void)beginUpdateVedioWithBlogId:(NSString *)blogId fileSize:(NSString *)fileSize;
//// 视频断点续传
//-(void)resumeUpdateVedioWithBlogId:(NSString *)blogId fileGoOnSize:(long)fileBeGoOnSize;

@end

@implementation UploadingVideoViewCtrl

@synthesize allSize;
- (void)dealloc
{
    //    [fileHandle release];
    //    RELEASE_SAFELY(fileHandle);
    //    RELEASE_SAFELY(uploadRequest);
    RELEASE_SAFELY(_imageVideo);
    RELEASE_SAFELY(_strVideoPath);
    RELEASE_SAFELY(sourceId);
    RELEASE_SAFELY(vedioSize);
    [_myTextField release];
    [_switch release];
    [_myBgView release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [super viewDidLoad];
    self.titleLabel.text = @"视频取名";
    self.middleBtn.hidden = YES;
    
    [self.rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    
    _myBgView = [[UIView alloc] initWithFrame:CGRectMake(0, iOS7 ? 65 :45, self.view.bounds.size.width, self.view.bounds.size.height-44)];
    _myBgView.backgroundColor = [UIColor clearColor];
    
    
    
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 200)];
    viewBg.backgroundColor =[UIColor whiteColor];
    viewBg.layer.borderWidth = 1;
    viewBg.layer.cornerRadius = 3;
    viewBg.layer.borderColor = RGBCOLOR(208, 211, 209).CGColor;
    
    UIImageView *pictureVideo = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 290, 190)];
    pictureVideo.contentMode = UIViewContentModeScaleAspectFill;
    pictureVideo.clipsToBounds = YES;
    pictureVideo.autoresizesSubviews = YES;
    pictureVideo.image = self.imageVideo;
    pictureVideo.backgroundColor = [UIColor clearColor];
    [viewBg addSubview:pictureVideo];
    [pictureVideo release];
    [_myBgView addSubview:viewBg];
    [viewBg release];
    
    
    CGRect videoTitleFrame = viewBg.frame;
    videoTitleFrame.size.height = 30;
    UILabel *videoTitle = [[UILabel alloc] initWithFrame:CGRectOffset(videoTitleFrame, 5, viewBg.frame.size.height+5)];
    videoTitle.text = @"给这个视频取个名字";
    videoTitle.textColor = RGB(102, 102, 102);
    videoTitle.font = [UIFont systemFontOfSize:14];
    videoTitle.backgroundColor = [UIColor clearColor];
    [_myBgView addSubview:videoTitle];
    
    
    UIImageView *imageTextBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@""] stretchableImageWithLeftCapWidth:5 topCapHeight:5]];
    imageTextBg.layer.borderWidth = 1;
    imageTextBg.layer.borderColor =  RGBCOLOR(208, 211, 209).CGColor;
    imageTextBg.layer.cornerRadius = 3;
    CGRect imageTextBgF = videoTitle.frame;
    imageTextBgF.size.height = 49;
    imageTextBg.frame = CGRectOffset(imageTextBgF, -5, videoTitle.frame.size.height);
    imageTextBg.backgroundColor = [UIColor whiteColor];
    imageTextBg.userInteractionEnabled = YES;
    
    
    _myTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, self.view.bounds.size.width-50, 39)];
    _myTextField.backgroundColor = [UIColor clearColor];
    _myTextField.delegate = self;
    _myTextField.placeholder = @"描述信息最多输入10个字";
    _myTextField.returnKeyType = UIReturnKeyDone;
    _myTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _myTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [imageTextBg addSubview:_myTextField];
    
    
    [_myBgView addSubview:imageTextBg];
    
    [self.view addSubview:_myBgView];
    
    [imageTextBg release];
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //这里判断视频文件是否存在，当不存在时要放回到上传页面
    if ([_strVideoPath isEqualToString:@""] || _strVideoPath.length <10) {
        [self backBtnPressed];
    }
    
}
- (void)touchClickSwich:(UISwitch *)s
{
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_myTextField resignFirstResponder];
    [self shouldDidFieldTextF];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.view sendSubviewToBack:_myBgView];
    [_myBgView bringSubviewToFront:self.navBarView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect frame = _myBgView.frame;
                         frame.origin.y = iPhone5 ? -10 : -120;
                         _myBgView.frame = frame;
                     }];
    return YES;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_myTextField resignFirstResponder];
    [self shouldDidFieldTextF];
}
- (void)shouldDidFieldTextF
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect frame = _myBgView.frame;
                         frame.origin.y = iOS7 ? 65 :45;
                         _myBgView.frame = frame;
                     }];
}
- (long)videoFileSize
{
    NSData *data = [NSData dataWithContentsOfFile:self.strVideoPath];
    return data.length;
}
- (void)continueUploadingVideo
{
    FileModel.upload_videoNum = 0;
    FileModel.isUpVideo = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeVideoList" object:[NSNumber numberWithBool:NO]];
    
    
}
- (BOOL)isNOUploadingVideo
{
    NSString *str = [NSString stringWithFormat:@"%@",_myTextField.text];
    if ([str isEqualToString:@"(null)" ] || [str isEqualToString:@""]) {
        [self networkPromptMessage:@"视频描述信息不能为空"];
        return NO;
    }else if ([SavaData parseArrFromFile:Video_File].count >=2)
    {
        [self networkPromptMessage:@"视频上传最多两个"];
        return NO;
    }else
    {
        return YES;
    }
}

- (void)rightBtnPressed//开始上传
{
    if ([CommonData isTitleBlank:_myTextField.text]) {
        [self networkPromptMessage:@"视频描述信息不能为空"];
        return;
    }else if([StaticTools lenghtWithString:_myTextField.text] >20)
    {
        [self networkPromptMessage:@"最多输入10个字"];
        return;
    }
    self.rightBtn.userInteractionEnabled = NO;
    FileModel.videoNumber++;
    FileModel.isUploading = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"upLoadVedioNumber" object:nil];
    
    NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:FileModel.vedioName,@"name",self.strVideoPath,@"path",[NSNumber numberWithLongLong:self.allSize],@"size",_myTextField.text,@"content",[NSNumber numberWithBool:YES],@"first",[NSNumber numberWithInt:0],@"state",[NSNumber numberWithFloat:0],@"progress",@"等待上传...",@"stateDescription",@"vedio",@"type", [NSNumber numberWithLongLong:0],@"receiveSize",nil];
    
    [FileModel.uploadingArr addObject:infoDic];
    BOOL uploading = NO;
    for (NSDictionary *dic in FileModel.uploadingArr)
    {
        if ([dic[@"state"] intValue] == 1)
        {
            uploading = YES;
            break;
        }
    }
    if (uploading == YES)
    {
        
    }
    else
    {
        [ResumeUploading startOrResumeUploadingWithFileIndex:(FileModel.uploadingArr.count - 1)];
    }
    ResumeUploading.uploadSuccess = ^(int index){
        [[EternalMemoryAppDelegate getAppDelegate] uploadingSuccess:index];
    };
    ResumeUploading.uploadFialed = ^(NSString *identifier, int index)
    {
        [[EternalMemoryAppDelegate getAppDelegate] uploadingFailed:index];
    };
    ResumeUploading.spaceNotEnough = ^()
    {
        [[EternalMemoryAppDelegate getAppDelegate] spaceIsNotEnough];
    };
    ResumeUploading.unexceptedSituation = ^(NSDictionary *dic){
    };

    [UploadingDebugging savaUplaodFiles:FileModel.uploadingArr];

    [self backBtnPressed];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSRange textrange = [textField.text rangeOfString:textField.text];
    if (textrange.length > 12)
    {
        [MyToast showWithText:@"内容最多为10个汉字":140];
        _myTextField.text = [_myTextField.text substringWithRange:NSMakeRange(0, 10)];
        return NO;
    }
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    BOOL isLogin = NO;
    [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
    [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
}
- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:NO];
    if (self.isHome) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showMyVideoPageViewCtrl" object:nil];
        self.isHome = NO;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
