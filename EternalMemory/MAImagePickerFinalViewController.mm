//
//  MAImagePickerFinalViewController.m
//  instaoverlay
//
//  Created by Maximilian Mackh on 11/10/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import "MAImagePickerFinalViewController.h"
#import "UpdatePhotoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "PhotoUploadRequest.h"
#import "UIImage+UIImageExt.h"
#import "EMPhotoSyncEngine.h"
#import "PhotoUploadEngine.h"
#import "RecordPromptView.h"
#import "RecordOperation.h"
#import "RecordPlayView.h"
#import "RequestParams.h"
#import "Utilities.h"
#import "MessageSQL.h"
#import "MyToast.h"
#import "EMAudio.h"

#import "EMRecordViewController.h"

//#import "MAOpenCV.h"

@interface MAImagePickerFinalViewController ()<UIActionSheetDelegate>
{
    NSTimer          *_timer;
    NSInteger         listenTime;//录音播放的时长
    UIToolbar        *finishToolBar;
    UIBarButtonItem  *_rotateButton;
    UIBarButtonItem  *undoButton;
    UIBarButtonItem  *confirmButton;
    UIButton         *recordButton;
    UIButton         *_rotationButton;
    RecordPromptView *recordPromptView;
    __block RecordPlayView   *recordPlayView;
    __block BOOL  beginRecord;
}

@property (nonatomic, retain ) EMAudio *audio;
@property (nonatomic, retain)  AVAudioPlayer *player ;

//停止试听录音
-(void)stopListenRecord;
-(void)resetListenView;
//选择完图片后重置tabbar
-(void)resetTabBar;
//录音操作
-(void)recordOperation:(UIButton *)sender;
    
    
@end

@implementation MAImagePickerFinalViewController

@synthesize finalImageView = _finalImageView;
@synthesize adjustedImage = _adjustedImage;
@synthesize sourceImage = _sourceImage;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
    [_rotateButton release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EMRecordDidStopNotification" object:nil];

    [_audio release];
    [_player release];
    [super dealloc];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    beginRecord = YES;
    listenTime = 1;
//    [self setupToolbar];
//    [self setupEditor];
    [self resetTabBar];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _adjustedImage = _sourceImage;
    _sourceImage = nil;
    _finalImageView = [[[UIImageView alloc] init]autorelease];
    [_finalImageView setFrame:CGRectMake(0, 15, self.view.bounds.size.width, self.view.bounds.size.height - (kCameraToolBarHeight + 70))];
    [_finalImageView setContentMode:UIViewContentModeScaleAspectFit];
    [_finalImageView setUserInteractionEnabled:YES];
    [_finalImageView setImage:_adjustedImage];
    
    UIScrollView * imgScrollView = [[UIScrollView alloc] initWithFrame:_finalImageView.frame];
    [imgScrollView setScrollEnabled:YES];
    [imgScrollView setUserInteractionEnabled:YES];
    [imgScrollView addSubview:_finalImageView];
    [imgScrollView setMinimumZoomScale:1.0f];
    [imgScrollView setMaximumZoomScale:3.0f];
    [imgScrollView setDelegate:self];
    [self.view addSubview:imgScrollView];
    [imgScrollView release];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopRecord:) name:@"getRecordInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EMRecordDidStopNotification:) name:@"EMRecordDidStopNotification" object:nil];
    
    //设置旋转按钮
    
    _rotationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rotationButton.frame = CGRectMake(280, 50, 30, 30);
    [_rotationButton setImage:[UIImage imageNamed:@"bj_fz"] forState:UIControlStateNormal];
    [_rotationButton addTarget:self action:@selector(rotateImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rotationButton];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _finalImageView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)popCurrentViewController
{
    if (_timer || self.audio.duration > 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:@"确定放弃本次录音?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 1000;
        [alertView show];
        [alertView release];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000)
    {
        if (buttonIndex == 1)
        {
            if (_timer && _timer.isValid) {
                [_timer invalidate];
                _timer = nil;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else
    {
        if (buttonIndex == 1) {
            BOOL isLogin = NO;
            
            [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
            return;
        }
    }
}

- (void)comfirmFinishedImage:(UIBarButtonItem *)barBut
{
    if (![barBut.image isEqual:[UIImage imageNamed:@"bj_d.png"]]) {
//        [undoButton setTintColor:[UIColor whiteColor]];
//        [barBut setImage:[UIImage imageNamed:@""]];
////        [barBut setTitle:@"完成"];
//        barBut.image = [UIImage imageNamed:@"bj_d.png"];
////        [barBut setTintColor:[UIColor whiteColor]];
//        [_rotateButton setImage:[UIImage imageNamed:@""]];
//        [_rotateButton setTitle:@"点击录音"];
//        [_rotateButton setTintColor:[UIColor whiteColor]];
        [self resetTabBar];
        return;
    }
    if ([barBut.image isEqual:[UIImage imageNamed:@"bj_d.png"]]) {

        [self storeImageToCache];
    }
    //    [self storeImageToCache];
}

-(void)resetTabBar
{
    UIImageView *backView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - kCameraToolBarHeight, self.view.bounds.size.width, kCameraToolBarHeight)];
    backView.image = [UIImage imageNamed:@"camera-bottom-bar"];
    backView.userInteractionEnabled = YES;
    //返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 60, 50);
    [backButton setImage:[UIImage imageNamed:@"bj_fh"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(popCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:backButton];
    
    //操作录音按钮
    
    UIImageView *recorderBgImage = [[UIImageView alloc] initWithFrame:CGRectMake(85, 5, 150, 40)];
    recorderBgImage.backgroundColor = [UIColor whiteColor];
    recorderBgImage.layer.cornerRadius = 8;
    [backView addSubview:recorderBgImage];
    [recorderBgImage release];
//    
//    recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    recordButton.frame = CGRectMake(60, 0, 200, 50);
//    [recordButton setTitle:@"点击录音" forState:UIControlStateNormal];
//    [recordButton addTarget:self action:@selector(recordOperation:) forControlEvents:UIControlEventTouchUpInside];
//    [backView addSubview:recordButton];
    recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordButton.frame = CGRectMake(85, 5, 150, 40);
    [recordButton setTitle:@"按下录音" forState:UIControlStateNormal];
    recordButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 8, 125);
    [recordButton setImage:[UIImage imageNamed:@"reorder_recorderBtnNormal"] forState:UIControlStateNormal];
    recordButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(recordOperation:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:recordButton];
    
    //上传按钮
    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadButton.frame = CGRectMake(260, 0, 60, 50);
    [uploadButton setImage:[UIImage imageNamed:@"bj_d"] forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(storeImageToCache) forControlEvents:UIControlEventTouchUpInside];
    uploadButton.imageEdgeInsets = UIEdgeInsetsMake(15, 16, 15, 17);
    [backView addSubview:uploadButton];
    
    [finishToolBar removeFromSuperview];
    [self.view addSubview:backView];
    [backView release];
    
}
//录音操作
-(void)recordOperation:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"按下录音"])
    {
//        [_rotateButton setTitle:@"停止录音"];
        [sender setTitle:@"停止录音" forState:UIControlStateNormal];
        recordPromptView = [[RecordPromptView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 50) WithSelectPhoto:YES];
        [self.view addSubview:recordPromptView];
        [RecordOperation startRecord:300];
        return;
    }
    else if ([sender.titleLabel.text isEqualToString:@"停止录音"])
    {
        
        [RecordOperation stopRecord];
        [recordPromptView removeFromSuperview];
        recordPromptView = nil;
    }
    else if ([sender.titleLabel.text hasPrefix:@"已录音0"])
    {
        [self recordFinishOrActionSheet];
    }
}
    
- (void) updateImageView
{
    [_finalImageView setNeedsDisplay];
    [_finalImageView setImage:_adjustedImage];
    [self.view setUserInteractionEnabled:YES];
}

- (void) updateImageViewAnimated
{
    [UIView transitionWithView:_finalImageView
                      duration:0.4f
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        _finalImageView.image = _adjustedImage;
                    } completion:NULL];
    
    [self.view setUserInteractionEnabled:YES];
}

- (void)storeImageToCache
{
    if (recordPromptView != nil)
    {
        [RecordOperation stopRecord];
        [recordPromptView removeFromSuperview];
        recordPromptView = nil;
    }
    
    
    if (_finishBackImagePickerBlock) {
        _finishBackImagePickerBlock (self.adjustedImage,self.audio);
    }
    
//    if ([Utilities checkNetwork]) {
//        PhotoUploadRequest *request = [[PhotoUploadRequest alloc] initWithURL:[[RequestParams sharedInstance] uploadPhoto]];
//        [request setupRequestForUplodingImage:self.adjustedImage];
//        MessageModel *model = [[MessageModel alloc] init];
//        model.rawImage = self.adjustedImage;
//        model.status = @"2";
//        request.userInfo = @{kModel: model};
    
//        [model release];
    
        [self dismissViewControllerAnimated:YES completion:nil];
        
//        [PhotoUploadEngine sharedEngine].uploadRequests = @[request];
//        [PhotoUploadEngine sharedEngine].audio = self.audio;
//        [[PhotoUploadEngine sharedEngine] startUpload];
//        [request release];
        
//    } else {
//        __block typeof(self) bself = self;
//        EMPhotoSyncEngine *engine = [EMPhotoSyncEngine sharedEngine];
//        engine.writeFileSuccessBlock = ^(NSString *path) {
//            [MessageSQL updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
//                NSString *sql = [NSString stringWithFormat:@"select id from %@ where paths = ?",tableName];
//                FMResultSet *rs = [db executeQuery:sql,path];
//                int ID = 0;
//                while ([rs next]) {
//                    ID = [rs intForColumn:@"id"];
//                }
//                bself.audio.ID = ID;
//                [[EMAudioUploader sharedUploader] startUploadAudio:self.audio];
//                
//            } WithUserID:USERID];
//        };
//        [engine uploadOperationNeedsSyncWithImages:@[self.adjustedImage]];
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }

}

- (void)setupToolbar
{
    finishToolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kCameraToolBarHeight, self.view.bounds.size.width, kCameraToolBarHeight)] autorelease];
    [finishToolBar setBackgroundImage:[UIImage imageNamed:@"camera-bottom-bar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    undoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bj_fh"] style:UIBarButtonItemStylePlain target:self action:@selector(popCurrentViewController)];
    undoButton.accessibilityLabel = @"Return to Frame Adjustment View";
    
    _rotateButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bj_fz"] style:UIBarButtonItemStylePlain target:self action:@selector(rotateImage:)];
    _rotateButton.accessibilityLabel = @"Rotate Image by 90 Degrees";
    _rotateButton.title =@"旋转";
    
    confirmButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bj_d"] style:UIBarButtonItemStylePlain target:self action:@selector(comfirmFinishedImage:)];
    confirmButton.accessibilityLabel = @"Confirm adjusted Image";
    
    UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    [fixedSpace setWidth:10.0f];
    
    [finishToolBar setItems:[NSArray arrayWithObjects:fixedSpace,undoButton,flexibleSpace,_rotateButton,flexibleSpace,confirmButton,fixedSpace, nil]];
    
    [self.view addSubview:finishToolBar];
    [undoButton release];
    [confirmButton release];
}

- (void)rotateImage:(UIBarButtonItem *)barBtn
{

//    else{
        switch (_adjustedImage.imageOrientation)
        {
            case UIImageOrientationRight:
                _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                            scale: 1.0
                                                      orientation: UIImageOrientationDown];
                break;
            case UIImageOrientationDown:
                _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                             scale: 1.0
                                                      orientation: UIImageOrientationLeft];
                break;
            case UIImageOrientationLeft:
                _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                            scale: 1.0
                                                      orientation: UIImageOrientationUp];
                break;
            case UIImageOrientationUp:
                _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                            scale: 1.0
                                                      orientation: UIImageOrientationRight];
                break;
            default:
                break;
        }
    
        [self updateImageViewAnimated];
//    }
    
}

#pragma mark - NSNotificationCenter---RecordInfo
    
-(void)EMRecordDidStopNotification:(NSNotification *)sender
{
    [RecordOperation stopRecord];
    [recordPromptView removeFromSuperview];
    recordPromptView = nil;
}
-(void)stopRecord:(NSNotification *)sender
{
    if ([(EMAudio *)sender.object duration] < 1)
    {
        [MyToast showWithText:@"录音时间太短,请重新录音" :200];
        [recordButton setTitle:@"按下录音" forState:UIControlStateNormal];
        recordButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 8, 125);
        [recordButton setImage:[UIImage imageNamed:@"reorder_recorderBtnNormal"] forState:UIControlStateNormal];
        recordButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else
    {
        self.audio = (EMAudio *)sender.object;
        [recordButton setTitle:[NSString stringWithFormat:@"已录音0%d:%02d''",(self.audio.duration / 60),(self.audio.duration % 60)] forState:UIControlStateNormal];
        [recordButton setImage:[UIImage imageNamed:@"record_ready_play"] forState:UIControlStateNormal];
    }
}

- (void)recordFinishOrActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除录音" otherButtonTitles:@"试听录音", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self deleteAudio:self.audio];
            break;
        case 1:
            [self listenningAudio:self.audio];
        default:
            break;
    }
}

- (void)deleteAudio:(EMAudio *)audio {
    
    [recordButton setTitle:@"按下录音" forState:UIControlStateNormal];
    recordButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 8, 125);
    [recordButton setImage:[UIImage imageNamed:@"reorder_recorderBtnNormal"] forState:UIControlStateNormal];
    recordButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([[NSFileManager defaultManager] removeItemAtPath:audio.wavPath error:nil]) {
        [MyToast showWithText:@"删除成功" :140];
//        [_rotateButton setTitle:@"按下录音"];
        self.audio = nil;
    }
}
- (void)listenningAudio:(EMAudio *)audio {
    
    recordPlayView = [[RecordPlayView alloc]initWithFrame:self.view.bounds];
    __block typeof(self) bself = self;
    [self.view addSubview:recordPlayView];
    [recordPlayView release];
    recordPlayView.stopListenRecord = ^(void){
        [bself stopListenRecord];
    };
    if (audio.wavPath.length > 0 ) {
        NSData *audioData = [NSData dataWithContentsOfFile:audio.wavPath];
        recordPlayView.showTimeLabel .text = [NSString stringWithFormat:@"0%d:%02d / 0%d:%02d",(listenTime / 60),(listenTime % 60),(self.audio.duration / 60),(self.audio.duration % 60)];
        [self playAudioWithData:audioData];
        if (self.audio.duration <= 1)
        {
            recordPlayView.showTimeLabel.text = @"00:00 / 00:01";
        }
        else
        {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        }
        return;
    }
}
//停止试听录音
-(void)stopListenRecord
{
    [_player stop];
    [self resetListenView];
}

#pragma mark - NSTimer

-(void)updateProgress
{
//    [recordPlayView.progressView setProgress:listenTime /(float) self.audio.duration];
    recordPlayView.showTimeLabel .text = [NSString stringWithFormat:@"0%d:%02d / 0%d:%02d",(listenTime / 60),(listenTime % 60),(self.audio.duration / 60),(self.audio.duration % 60)];
    listenTime ++;
}

- (void)playAudioWithData:(NSData *)audioData {
    self.player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
    self.player.delegate = self;
    [self.player prepareToPlay];
    [self.player play];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.audio.duration <= 1)
    {
        recordPlayView.showTimeLabel.text = @"00:01 / 00:01";
    }
    [self resetListenView];
}
-(void)resetListenView
{
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
    [_player release];
    _player = nil;
    listenTime = 1;
    [recordPlayView removeFromSuperview];
    recordPlayView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
