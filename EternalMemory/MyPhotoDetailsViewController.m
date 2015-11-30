                           //
//  MyPhotoDetailsViewController.m
//  EternalMemory
//
//  Created by sun on 13-6-7.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MyPhotoDetailsViewController.h"
#import "CycleScrollView.h"
#import "UpdatePhotoViewController.h"
#import "DiaryPictureClassificationSQL.h"
#import "DiaryPictureClassificationModel.h"
#import "MessageSQL.h"
#import "UIImage+UIImageExt.h"
#import "EternalMemoryAppDelegate.h"
#import "EditPhotoDescriptionViewController.h"
#import "ReviewImageNaviBar.h"
#import "EMRecordEngine.h"
#import "EMAudio.h"
#include "amrFileCodec.h"
#import "EMRecordViewController.h"
#import "EMPhotoSyncEngine.h"
#import "MyAlbumClassifiedListingDetailsViewController.h"
#import "AddRecordWarningView.h"
#import "RecordPromptView.h"
#import "EMRecordEngine.h"

#define TEXTVIEW_HEIGHT 57
#define PHOTOTEXT @"1"
#define REQUEST_FOR_DELETEPHOTO 100


@interface MyPhotoDetailsViewController () <AVAudioPlayerDelegate>{
    UpdatePhotoViewController *_updatePhotoViewController;
//    RecordPromptView          *recordPromptView;
    BOOL _isRecording;
    
    //web进入时导航栏显示的控件
    UIButton        *_memoryButton;
    UIButton        *_allButton;
    UIButton        *_closeButton;
    
}

@property (nonatomic, retain) NSMutableArray    *picArray ,*stringArray;
@property (nonatomic, retain) CycleScrollView   *cycle;
@property (nonatomic, retain) UITextView        *imageWordTextView;
@property (nonatomic, retain) NSMutableArray    *blogArray;
@property (nonatomic, retain) MessageModel      *model;
@property (nonatomic, retain) UpdatePhotoViewController *updatePhotoViewController;
@property (nonatomic, retain) NSString *errorcodeStr ;
@property (nonatomic, retain) IBOutlet UIImageView  *noBlogImg;
@property (nonatomic, retain) IBOutlet UILabel      *noBlogLb;
@property (nonatomic, assign) BOOL  isNaviBarHidden;
@property (nonatomic, assign) BOOL  shouldHiddenStatusBar;
@property (nonatomic, retain) UIButton *recoredButton;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

@property (nonatomic, retain) UIButton *closeBtnInPanoramic;

@property (nonatomic, retain) UIView            *recordView;

@property (nonatomic, retain) ReviewImageNaviBar *canHiddenNaviBar;

@property (nonatomic, retain) ASIHTTPRequest     *downAudioRequest;

@property(nonatomic, retain) __block AddRecordWarningView *recordWarningView;

-(void)stopAudioPlayWhenClick;
-(void)createNavgationBarFromWeb;
@end

@implementation MyPhotoDetailsViewController
@synthesize picArray = _picArray;
@synthesize cycle = _cycle;
@synthesize imageWordTextView = _imageWordTextView;
@synthesize stringArray = _stringArray;
@synthesize selectGroupInt =_selectGroupInt;
@synthesize blogArray = _blogArray;
@synthesize model = _model;
@synthesize updatePhotoViewController = _updatePhotoViewController;
@synthesize errorcodeStr = _errorcodeStr ;
@synthesize noBlogImg = _noBlogImg;
@synthesize noBlogLb = _noBlogLb;
@synthesize myPhotoDetailsDelegate = _myPhotoDetailsDelegate;
@synthesize recordWarningView = _recordWarningView;
#pragma mark - object lifecycle
- (void)dealloc
{
    RELEASE_SAFELY(_cycle);
    RELEASE_SAFELY(_imageWordTextView);
    RELEASE_SAFELY(_stringArray);
    RELEASE_SAFELY(_currentMessageModel);
    RELEASE_SAFELY(_picArray);
    RELEASE_SAFELY(_updatePhotoViewController);
    RELEASE_SAFELY(_groupId);
    RELEASE_SAFELY(_canHiddenNaviBar);
    RELEASE_SAFELY(_recoredButton);
    RELEASE_SAFELY(_audioPlayer);
    RELEASE_SAFELY(_downAudioRequest);
    RELEASE_SAFELY(_recordView);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
    
    [super dealloc];
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        _shouldRightButtonHidden = NO;
        _stringArray = [[NSMutableArray alloc] init];
        _picArray = [[NSMutableArray alloc] init];
        _blogArray = [[NSMutableArray alloc] initWithCapacity:0];
        _updatePhotoViewController = [[UpdatePhotoViewController alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navBarView.hidden = NO;
    self.titleLabel.hidden = NO;
    self.rightBtn.hidden = NO;
    self.backBtn.hidden = NO;
    _isRecording = NO;
    [self setValue:@(UIInterfaceOrientationPortrait) forKey:@"interfaceOrientation"];
    [self setViewData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self stopAudioPlayWhenClick];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor blackColor];
    
    _shouldHiddenStatusBar = NO;
    _isNaviBarHidden = NO;
    fromPhotoList = NO;
    self.blogArray = self.blogs;
    self.currentMessageModel = self.blogArray[_selectPhotoIndex];
    
    self.middleBtn.hidden = YES;
    //    self.rightBtn.enabled = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPhotoAdded) name:@"setPhotoes" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePhotoDescription:) name:kPhotoDescriptionChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoDesChanged:) name:PhotoDesChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAudioSuccess:) name:EMAudioDeleteSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAudioFailure:) name:EMAudioDeleteFailureNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAudioSuccess:) name:EMAudioUploadSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAudioFailure:) name:EMAudioUploadFailureNotification object:nil];

}
-(void)createNavgationBarFromWeb
{
    _memoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _memoryButton.frame = CGRectMake(10, 10, 75, 30);
    _memoryButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_memoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_memoryButton setTitle:@"时光记忆" forState:UIControlStateNormal];
    [_memoryButton setTitleColor:[UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1] forState:UIControlStateNormal];
    [_memoryButton setBackgroundImage:[UIImage imageNamed:@"life_memory_photo"] forState:UIControlStateNormal];
    
    [_memoryButton addTarget:self action:@selector(showMemoryPhoto) forControlEvents:UIControlEventTouchUpInside];
    _memoryButton.userInteractionEnabled = YES;
    [_memoryButton setHighlighted:NO];
    [self.view addSubview:_memoryButton];
    
    _allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allButton.frame = CGRectMake(85, 10, 75, 30);
    _allButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_allButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_allButton setTitle:@"其他图片" forState:UIControlStateNormal];
    [_allButton setTitleColor:[UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1] forState:UIControlStateNormal];
    [_allButton setBackgroundImage:[UIImage imageNamed:@"all_photo_selected"] forState:UIControlStateNormal];
    [_allButton setBackgroundImage:[UIImage imageNamed:@"all_photo_selected"] forState:UIControlStateHighlighted];
    [self.view addSubview:_allButton];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = CGRectMake(280, 10, 30, 30);
    [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(backToHomeWeb) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    
}

#pragma mark - Notification & Observer Method

- (void)newPhotoAdded {
    if ([EMRecordEngine sharedEngine].isRecording) {
        return;
    }
    
    [self setViewData];
}
- (void)deleteAudioSuccess:(NSNotification *)notification {
    EMAudio *audio = (EMAudio *)notification.object;
    if ([audio.blogId isEqualToString:self.currentMessageModel.blogId]) {
        self.currentMessageModel.audio = audio;
        [self audioButtonForAudio:audio];
    }
}

- (void)deleteAudioFailure:(NSNotification *)notification {
    EMAudio *audio = (EMAudio *)notification.object;
    if ([audio.blogId isEqualToString:self.currentMessageModel.blogId]) {
        [self audioButtonForAudio:audio];
    }
    self.currentMessageModel.audio = audio;
    
}

- (void)uploadAudioSuccess:(NSNotification *)notification {
    EMAudio *audio = (EMAudio *)notification.object;
    if ([audio.blogId isEqualToString:self.currentMessageModel.blogId]) {
        self.currentMessageModel.audio = audio;
        [self audioButtonForAudio:self.currentMessageModel.audio];
    } 
}

- (void)uploadAudioFailure:(NSNotification *)notification {
    EMAudio *audio = (EMAudio *)notification.object;
    audio.isUploading = NO;
    if ([audio.blogId isEqualToString:self.currentMessageModel.blogId]) {
        [self audioButtonForAudio:audio];
    }
    [self showHubWithMessage:@"语音上传失败"];
}

- (void)photoDesChanged:(NSNotification *)notification
{
    MessageModel *model = notification.object;
    
    NSString *des = model.content;
    
    [self.stringArray replaceObjectAtIndex:_selectPhotoIndex withObject:des];
    
    _imageWordTextView.text = des;
    
}

- (void)imageLoaded:(NSNotification *)notification
{
    self.rightBtn.enabled = YES;
}

#pragma mark -

- (void)updateDBDataWhenMovingBlogFromSrcGroup:(NSString *)srcGroupId toDesGroupId:(NSString *)desGroupId DesModel:(MessageModel *)desMessageModel
{
    DiaryPictureClassificationModel *srcModel = [DiaryPictureClassificationSQL getDiaryModelByGroupId:srcGroupId WithUserID:USERID];
    NSInteger srcBlogCount = [srcModel.blogcount integerValue] - 1;
    NSString  *srcLastestPhotoUrl = nil;
    MessageModel *messageModel = nil;
    
//    _selectPhotoIndex --;
//    _selectPhotoIndex <= 0 ? (_selectPhotoIndex = 0) : (_selectPhotoIndex);

    NSArray *array = [MessageSQL getGroupIDMessages:self.selectGroupInt AndUserId:USERID];
    (array.count > 0) ? (messageModel = array[0]) : (messageModel = nil);
    srcLastestPhotoUrl = messageModel.attachURL;
    srcModel.latestPhotoURL = srcLastestPhotoUrl;
    srcModel.latestPhotoPath = messageModel.spaths;
    srcModel.blogcount = [NSString stringWithFormat:@"%d",srcBlogCount];
    [DiaryPictureClassificationSQL updateDiaryWithArr:@[srcModel] WithUserID:USERID];
    
    DiaryPictureClassificationModel *desModel = [DiaryPictureClassificationSQL getDiaryModelByGroupId:desGroupId WithUserID:USERID];
    NSInteger desBlogCount = [desModel.blogcount integerValue] + 1;
    desModel.latestPhotoURL = _currentMessageModel.attachURL;
    desModel.latestPhotoPath = _currentMessageModel.spaths;
    desModel.blogcount = [NSString stringWithFormat:@"%d",desBlogCount];
    [DiaryPictureClassificationSQL updateDiaryWithArr:@[desModel] WithUserID:USERID];
}

- (void)changePhotoDescription:(NSNotification *)notification
{
    DiaryPictureClassificationModel *groupModel = (DiaryPictureClassificationModel *)notification.object[@"groupModel"];
    
    NSString *groupId = [NSString stringWithFormat:@"%@",groupModel.groupId];
    MessageModel *blogModel = (MessageModel *)notification.object[@"messageModel"];
    
    if (![groupId isEqualToString:_groupId]) {
        
        MessageModel *aModel = self.blogArray[_selectPhotoIndex];
        [MessageSQL refershMessagesByMessageModelArray:@[aModel]];
        
        NSString *desGroupId = [groupId copy];
        NSString *srcGroupId = [_groupId copy];
        
        [self updateDBDataWhenMovingBlogFromSrcGroup:srcGroupId toDesGroupId:desGroupId DesModel:blogModel];
        
        [desGroupId release];
        [srcGroupId release];
        
        if (self.blogArray.count > 1 )
        {
            [self.blogArray removeObjectAtIndex:_selectPhotoIndex];
            [self.stringArray removeObjectAtIndex:_selectPhotoIndex];
            _selectPhotoIndex --;
            _selectPhotoIndex <= 0 ? (_selectPhotoIndex = 0) : (_selectPhotoIndex);

        }
        else if(self.blogArray.count == 1)
        {
            [self.blogArray removeObjectAtIndex:0];
            [self.stringArray removeObjectAtIndex:0];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        
        [self setViewData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoGroupChangedNotification object:nil];
        
        //发通知；
        return;
    }
    
    NSString *des = blogModel.content;
    
    [self.stringArray replaceObjectAtIndex:_selectPhotoIndex withObject:des];
    
    _imageWordTextView.text = des;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
- (void)backBtnPressed
{
    _selectPhotoIndex = 0;
    if ([self.comeFrom isEqualToString:@"Home"]) {
        [self dismissViewControllerAnimated:NO completion:^{
        }];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)rightBtnPressed
{

    BOOL containAudio = [self.recordWarningView.testLabel.text rangeOfString:@"还没录音"].location == NSNotFound;
//    NSString *recordBtnTitle = _recoredButton.titleLabel.text;
    if (containAudio) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle: @"删除相片"
                                                       otherButtonTitles:@"删除语音",@"编辑相片描述", nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    } else {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle: @"删除相片"
                                                       otherButtonTitles:@"编辑相片描述", nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
}

-(void)showMemoryPhoto
{
    [self dismissViewControllerAnimated:NO completion:NULL];
}

-(void)backToHomeWeb
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backToHomeWeb" object:nil];
}

- (void)setBlogs:(NSMutableArray *)blogs
{
    if (_blogs != blogs) {
        [_blogs release];
        _blogs = [blogs retain];
    }
    
    self.blogArray = _blogs;
}

- (void)record:(UIButton *)button {
    
    //音频文件保存路径
    NSString *buttonTitle = button.titleLabel.text;
    if ([buttonTitle isEqualToString:@"录音"]) {
        
        EMRecordViewController *recordVC = [[EMRecordViewController alloc] init];
        recordVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        recordVC.model = self.currentMessageModel;
        [self presentViewController:recordVC animated:YES completion:nil];
        [recordVC release];

        
        return;
    } else if ([buttonTitle isEqualToString:@"播放"]) {
        [self downloadAndPlayAudio:self.currentMessageModel.audio];
    }
}

- (void)audioButtonForAudio:(EMAudio *)audio
{
    if (audio.isUploading)
    {
        [_recordWarningView setRecordState:RecordStateUpload WithEMAudio:nil];
    }
    else if (audio.audioURL.length <= 0 && audio.wavPath.length <= 0)
    {
        [_recordWarningView setRecordState:RecordStateMake WithEMAudio:nil];
    }
    else
    {
        [_recordWarningView setRecordState:RecordStateReadyPlay WithEMAudio:audio];
    }
    
    _recoredButton.enabled = YES;
    if (audio.audioStatus == EMAudioSyncStatusNeedsToBeDeleted || ((audio.audioURL.length <= 0) && (audio.wavPath.length <= 0))) {
        [_recoredButton setTitle:@"录音" forState:UIControlStateNormal];
    } else {
        [_recoredButton setTitle:@"播放" forState:UIControlStateNormal];
    }
}

- (void)setViewData
{
    // nevBar
    if (self.blogArray.count == 0 || self.blogArray == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    self.currentMessageModel = self.blogArray[_selectPhotoIndex];
    EMAudio *audio = self.currentMessageModel.audio;
    if (!audio) {
        audio = [[EMAudio new] autorelease];
    }
    audio.ID = self.currentMessageModel.ID;
    self.currentMessageModel.audio = audio;
    self.view.userInteractionEnabled = YES;
    _recordWarningView = [[AddRecordWarningView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, 30)];
    _recordWarningView.userInteractionEnabled = YES;
    __block typeof(self) this = self;
    _recordWarningView.makeRecord = ^(void){
        _recordWarningView.hidden = YES;
        
        EMRecordViewController *vc = [[EMRecordViewController alloc] init];
        vc.model = this.currentMessageModel;
        [vc setDismissBlock:^(EMAudio *audio){
            this.recordWarningView.hidden = NO;
            audio.isUploading = YES;
            [this audioButtonForAudio:audio];
            [vc.view removeFromSuperview];
        }];
        [vc setTimeTooShortBlock:^(EMAudio *audio) {
            this.recordWarningView.hidden = NO;
            [this showHubWithMessage:@"录音时间太短，请重新录制"];
            audio.isUploading = NO;
            [this audioButtonForAudio:audio];
            [vc.view removeFromSuperview];
        }];
        [this addChildViewController:vc];
        vc.view.backgroundColor = [UIColor clearColor];
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        
        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
        if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
            vc.view.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
        }
        [vc.recordPromptView setsubViewFrameWithState:self.interfaceOrientation];
        [this.view addSubview:vc.view];
        [vc release];
        
        this.recordView = vc.view;
        
    };
    
    _recoredButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recoredButton.frame = CGRectZero;
    [_recoredButton setTitle:@"录音" forState:UIControlStateNormal];
    _recoredButton.backgroundColor = [UIColor redColor];
    [_recoredButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    self.middleBtn.hidden = YES;
   
    [self audioButtonForAudio:audio];
    
    _recordWarningView.playRecord = ^(void){
        [this readyToPlayAudio];
    };
    _recordWarningView.stopRecord = ^(void){
        [this stopAudioPlayWhenClick];
    };
    
    if (_hideRecordButtonForNoAudio && (self.currentMessageModel.audio.audioURL.length <= 0 && self.currentMessageModel.audio.wavPath.length <= 0)) {
        _recordWarningView.hidden = YES;
    } else {
        _recordWarningView.hidden = NO;
    }
    
    if (_hideRecordButtonForNoAudio) {
        [self.navBarView setImage:nil];
        self.rightBtn.hidden = YES;
        self.backBtn.hidden = YES;
        self.titleLabel.hidden = YES;
        self.navBarView.hidden = YES;
        [self createNavgationBarFromWeb];
    }
    

    [self.rightBtn setTitle:@"更多" forState:UIControlStateNormal];
    NSString *titileStr = [NSString stringWithFormat:@"%d/%d",_selectPhotoIndex+1,[self.blogArray count]];
    [self.titleLabel setText:titileStr];
    [self reloadScrollView];
}
- (void)reloadScrollView
{
    [self.picArray removeAllObjects];
    [self.stringArray removeAllObjects];
    //img
    if (_cycle) {
        [_cycle removeFromSuperview];
    }
    if (_canHiddenNaviBar) {
        [_canHiddenNaviBar removeFromSuperview];
    }
    if (_imageWordTextView) {
        [_imageWordTextView removeFromSuperview];
    }
    
    for (MessageModel *blogModel in self.blogArray) {
        NSString *summayStr = @" ";//[NSString stringWithFormat:@" "]; ;
        //        if (blogModel.content.length > 0 )
        //        {
        summayStr = [NSString stringWithFormat:@"%@",blogModel.content];
        if ([summayStr isEqualToString:@"(null)"]) {
            summayStr = @" ";
        }
        //        }
        [self.stringArray addObject:summayStr];
        if (blogModel.paths.length > 0) {
            
            [self.picArray addObject:blogModel.paths];
        }
        else if (blogModel.attachURL.length > 0)
        {
            NSString *imgUrlStr = [NSString stringWithFormat:@"%@",blogModel.attachURL];
            NSURL *imgURL = [NSURL URLWithString:imgUrlStr];
            [self.picArray addObject:imgURL];
        }
    }
    
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    int _viewHeight = 416;
    if (iPhone5) {
        _viewHeight = 504;
    }
    if ([self.picArray count] > 0)
    {
        if (orientation == UIInterfaceOrientationPortrait) {
            self.cycle = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, _viewHeight)
                                                 cycleDirection:CycleDirectionLandscape
                                                       pictures:self.picArray
                                                       andIndex:_selectPhotoIndex];
            self.cycle.interfaceOrientation = UIInterfaceOrientationPortrait;
        } else {
            self.cycle = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, iPhone5 ? 568 : 480, 320)
                                                 cycleDirection:CycleDirectionLandscape
                                                       pictures:self.picArray
                                                       andIndex:_selectPhotoIndex];
            
            NSArray *views = [self.cycle.rootScrollView subviews];
            for (int i = 0; i < views.count; i ++) {
                int x = i * (iPhone5 ? 568 : 480);
                UIView *view = views[i];
                if ([view isKindOfClass:NSClassFromString(@"ReviewImageScrollView")]) {
                    view.frame = (CGRect){
                        .origin.x = x,
                        .origin.y = 0,
                        .size.width  = (iPhone5 ? 568 : 480),
                        .size.height = 320
                    };
                }
            }
            
            _cycle.interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            
            CGFloat x = iPhone5 ? 568 : 480;
            self.cycle.rootScrollView.contentSize = CGSizeMake(_blogs.count * x, 0);
            self.cycle.rootScrollView.contentOffset = CGPointMake(_selectPhotoIndex * x, 0);
        }
        
        [Utilities adjustUIForiOS7WithViews:@[_cycle]];
        self.cycle.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToShowNavBar:)];
        [self.cycle addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        self.canHiddenNaviBar = [[ReviewImageNaviBar alloc] init];
        [self.canHiddenNaviBar.backButton addTarget:self action:@selector(backBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.canHiddenNaviBar.rightButton addTarget:self action:@selector(rightBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        self.canHiddenNaviBar.titleLabel.text = self.titleLabel.text;
        self.canHiddenNaviBar.titleLabel.textColor = [UIColor whiteColor];
        self.canHiddenNaviBar.rightButton.hidden = _shouldRightButtonHidden;
        [_cycle addSubview:self.canHiddenNaviBar];
        
        [_cycle bringSubviewToFront:self.canHiddenNaviBar];
        if (orientation == UIInterfaceOrientationPortrait) {
            self.canHiddenNaviBar.hidden = YES;
        } else {
            self.canHiddenNaviBar.hidden = NO;
        }
        self.navBarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

        self.cycle.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
       
        [self.cycle addSubview:_recoredButton];
        [self.cycle addSubview:_recordWarningView];
        
    }
    else if (self.picArray.count == 0)
    {
        [self backBtnPressed];
        return;
    }
    
    _cycle.delegate = self;
    [self.view addSubview:_cycle];
    
    _imageWordTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, _viewHeight - TEXTVIEW_HEIGHT, 320, TEXTVIEW_HEIGHT)];
    _imageWordTextView.font = [UIFont boldSystemFontOfSize:14.0f];
    _imageWordTextView.textColor = [UIColor whiteColor];
    _imageWordTextView.textAlignment = NSTextAlignmentCenter;
    _imageWordTextView.editable = NO;
    [_imageWordTextView setBackgroundColor:[UIColor blackColor]];
    
    _imageWordTextView.alpha = 0.6;
    
    if (orientation == UIInterfaceOrientationPortrait) {
        [_imageWordTextView setFrame:CGRectMake(0, iOS7 ? (SCREEN_HEIGHT - TEXTVIEW_HEIGHT) : (SCREEN_HEIGHT - TEXTVIEW_HEIGHT - 20) , 320, TEXTVIEW_HEIGHT)];
        [self.recordView setFrame:self.view.bounds];
        [_recordWarningView setFrame:CGRectMake(0,0, SCREEN_WIDTH, 30)];
        [_recordWarningView setsubViewFrame];
    } else {
        [_imageWordTextView setFrame:CGRectMake(0, iOS7 ? (320 - TEXTVIEW_HEIGHT) : (320 - TEXTVIEW_HEIGHT - 20) , (iPhone5 ? 568 : 480), TEXTVIEW_HEIGHT)];
        [self.recordView setFrame:self.view.bounds];
        [_recordWarningView setFrame:CGRectMake(0, 40, (iPhone5 ? 568 : 480), 30)];
        [_recordWarningView setsubViewFrame];
    }
    
    _imageWordTextView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    
    if ([self.stringArray count]> 0)
    {
        if (self.stringArray.count == 0)
        {
            _imageWordTextView.text = [NSString stringWithFormat:@"%@",[self.stringArray objectAtIndex:0]];
        }
        else
        {
            _imageWordTextView.text = [NSString stringWithFormat:@"%@", [self.stringArray objectAtIndex:_selectPhotoIndex]];
        }
        _noBlogImg.hidden = NO;
        _noBlogLb.hidden  = NO;
    }
    else
    {
        _imageWordTextView.text = @"";
        _noBlogImg.hidden = YES;
        _noBlogLb.hidden  = YES;
    }
    
    [self.view addSubview:_imageWordTextView];
}

- (void)tapToShowNavBar:(UITapGestureRecognizer *)gesture
{
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        _isNaviBarHidden = !_isNaviBarHidden;
        if (!_hideRecordButtonForNoAudio) {
            _recordWarningView.hidden = _isNaviBarHidden;
        }
        __block ReviewImageNaviBar *bar = _canHiddenNaviBar;
        [UIView animateWithDuration:0.3 animations:^{
             [[UIApplication sharedApplication] setStatusBarHidden:_isNaviBarHidden withAnimation:UIStatusBarAnimationFade];
            _isNaviBarHidden ? (bar.alpha = 0) : (bar.alpha = 1);

        }];
    }
}

- (void)contentSizeToFit
{
    if([_imageWordTextView.text length]>0) {
        CGSize contentSize = _imageWordTextView.contentSize;
        UIEdgeInsets offset;
        CGSize newSize = contentSize;
        if(contentSize.height <= _imageWordTextView.frame.size.height) {
            CGFloat offsetY = (_imageWordTextView.frame.size.height - contentSize.height)/2;
            offset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
        }
        else {
            offset = UIEdgeInsetsZero;
            CGFloat fontSize = 18;
            while (contentSize.height > _imageWordTextView.frame.size.height) {
                [_imageWordTextView setFont:[UIFont fontWithName:@"Helvetica Neue" size:fontSize--]];
                contentSize = _imageWordTextView.contentSize;
            }
            newSize = contentSize;
        }
        [_imageWordTextView setContentSize:newSize];
        [_imageWordTextView setContentInset:offset];
    }
}
#pragma mark - http
- (void)deletePhotoRequest:(NSString *)blogId
{
    NSURL *registerUrl = [[RequestParams sharedInstance] deletePhoto];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:registerUrl];
    request.delegate = self;
    request.shouldAttemptPersistentConnection = NO;
    request.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_DELETEPHOTO],@"tag", nil];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:blogId forKey:@"blogid"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:30.0];
    __block typeof(self) bself = self;
    [request setCompletionBlock:^{
        [bself requestSuccess:request];
    }];
    [request setFailedBlock:^{
        [bself requestFail:request];
    }];
    [request startAsynchronous];
}

#pragma mark - CycleScrollViewDelegate
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didSelectImageView:(int)index {
    //
    //    [[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"点击了第%d张", index]
    //                                 message:nil
    //                                delegate:nil
    //                       cancelButtonTitle:@"确定"
    //                       otherButtonTitles: nil] autorelease] show];
}
//照片预览滑动操作
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didScrollImageView:(int)index
{
    _selectPhotoIndex = index - 1;
    [self.downAudioRequest clearDelegatesAndCancel];
    [self stopAudioPlay];
    if ([self.picArray count] == 0 )
    {
        self.titleLabel.text = @"0/0";
        self.canHiddenNaviBar.titleLabel.text = self.titleLabel.text;
        _noBlogImg.hidden = NO;
        _noBlogLb.hidden  = NO;
        _imageWordTextView.text =@"";
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        _noBlogImg.hidden = YES;
        _noBlogLb.hidden  = YES;
        self.titleLabel.text = [NSString stringWithFormat:@"%d/%d", index,[self.picArray count]];
        self.canHiddenNaviBar.titleLabel.text = self.titleLabel.text;
        _imageWordTextView.text = [NSString stringWithFormat:@"%@", [self.stringArray objectAtIndex:_selectPhotoIndex]];
        
        if (_currentMessageModel != nil)
        {
            [_currentMessageModel release];
            
        }
        
        //TODO: 检查这张照片是否是音频描述，如果有，直接播放该音频文件，将添加录音按钮改为“播放”。Actionsheet中有删除音频的操作。
        _currentMessageModel = [self.blogArray[_selectPhotoIndex] retain];
        EMAudio *audio = _currentMessageModel.audio;
        if (!audio) {
            audio = [[EMAudio new] autorelease];
        }
        audio.ID = _currentMessageModel.ID;
        self.currentMessageModel.audio = audio;
        [self audioButtonForAudio:audio];
        
        //可自动播放----会有问题
//        [_recordWarningView setRecordState:RecordStateStop WithEMAudio:self.currentMessageModel.audio];
//        [self downloadAndPlayAudio:self.currentMessageModel.audio];
        if (_hideRecordButtonForNoAudio && (self.currentMessageModel.audio.audioURL.length <= 0 && self.currentMessageModel.audio.wavPath.length <= 0)) {
            _recordWarningView.hidden = YES;
        } else {
            _recordWarningView.hidden = NO;
        }
    }
    
    if (index == self.blogArray.count)
    {
        [self showHubWithMessage:@"这是最后一张"];
    }
    else if (index == 1)
    {
        [self showHubWithMessage:@"这是第一张"];
    }
}

#pragma  mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"删除相片"]) {
        [self stopAudioPlay];

        NSDate *date = [NSDate date];
        NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
        NSString *timeStr = [NSString stringWithFormat:@"%f",timestamp];
        MessageModel *blogModel = [self.blogArray objectAtIndex:_selectPhotoIndex];
        blogModel.lastModifyTime = timeStr;
        blogModel.syncTime = timeStr;
        NSArray *blogArray = [NSArray arrayWithObject:blogModel];
        
        //删除单张
        NSString *networkStr = [Utilities GetCurrntNet];
        //无网
        if ([networkStr isEqualToString:@"没有网络链接"])
        {
            if (blogModel.blogId.length > 0)
            {
                blogModel.status = @"3";
                blogModel.deletestatus = YES;
                blogModel.needSyn = YES;
                blogModel.needUpdate = YES;
                [MessageSQL refershMessagesByMessageModelArray:blogArray];
                
                //                NSFileManager *fileManager = [NSFileManager defaultManager];
                //                NSData *data = [NSData dataWithContentsOfFile:blogModel.paths];
                //                if (data.length > 0) {
                //                    [fileManager removeItemAtPath:blogModel.paths error:nil];
                //                }
                //
                //                NSData *sdata = [NSData dataWithContentsOfFile:blogModel.spaths];
                //                if (sdata.length > 0)
                //                {
                //                    [fileManager removeItemAtPath:blogModel.spaths error:nil];
                //                }
                
                [self removePhotoWithModel:blogModel index:_selectPhotoIndex];
                
            }
            else
            {
                [MessageSQL deletePhoto:blogArray];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSData *data = [NSData dataWithContentsOfFile:blogModel.paths];
                if (data.length > 0) {
                    [fileManager removeItemAtPath:blogModel.paths error:nil];
                }
                
                NSData *sdata = [NSData dataWithContentsOfFile:blogModel.spaths];
                if (sdata.length > 0)
                {
                    [fileManager removeItemAtPath:blogModel.spaths error:nil];
                }
                
                [self removePhotoWithModel:blogModel index:_selectPhotoIndex];
                
            }
            
            
            [self showHubWithMessage:@"删除成功"];
            
            
            
            [self setViewData];
            if(_myPhotoDetailsDelegate && [_myPhotoDetailsDelegate respondsToSelector:@selector(reloadPhotoes:)]){
                [_myPhotoDetailsDelegate reloadPhotoes:YES];
            }
            
        }
        else
        {
            
            if (blogModel.blogId.length > 0 )
            {
                [self deletePhotoRequest:blogModel.blogId];
            }
            
            else
            {
                [MessageSQL deletePhoto:blogArray];

                [self showHubWithMessage:@"删除成功"];

                
                _selectPhotoIndex --;
                _selectPhotoIndex <= 0 ? (_selectPhotoIndex = 0) : (_selectPhotoIndex);
                [self setViewData];
                if(_myPhotoDetailsDelegate && [_myPhotoDetailsDelegate respondsToSelector:@selector(reloadPhotoes:)]){
                    [_myPhotoDetailsDelegate reloadPhotoes:YES];
                }
            }
        }
    }
    if ([title isEqualToString:@"编辑相片描述"]) {

        if (!_isNaviBarHidden) {
            _canHiddenNaviBar.hidden = YES;
        }
        MessageModel *model = self.blogArray[_selectPhotoIndex];
        EditPhotoDescriptionViewController *vc = [[EditPhotoDescriptionViewController alloc] init];
        vc.model = model;
        [self presentViewController:vc animated:YES completion:nil];
        [vc release];
    }
    
    if ([title isEqualToString:@"删除语音"]) {
        [self stopAudioPlayWhenClick];
        self.currentMessageModel.audio.blogId = self.currentMessageModel.blogId;
        [self deleteAudio:self.currentMessageModel.audio];
//        [[EMAudioUploader sharedUploader] deleteAudio:self.currentMessageModel.audio];
    }
}
#pragma mark - ASIHTTPRequest
-(void)requestSuccess:(ASIFormDataRequest *)request
{
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    self.errorcodeStr = [NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"errorcode"]];
    if (tag == REQUEST_FOR_DELETEPHOTO) {
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([self.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }
        else
        {
            NSDictionary *metaDic = [resultDictionary objectForKey:@"meta"];
            NSString *versionsStr = [metaDic objectForKey:@"versions"];
            NSDate *date = [NSDate date];
            NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
            
            NSString *timeStr = [NSString stringWithFormat:@"%f",timestamp];
            MessageModel *blogModel = [self.blogArray objectAtIndex:_selectPhotoIndex];
            blogModel.status = @"1";
            blogModel.needSyn = NO;
            blogModel.needUpdate = NO;
            blogModel.lastModifyTime = timeStr;
            blogModel.syncTime = timeStr;
            blogModel.localVer = versionsStr;
            blogModel.serverVer = versionsStr;
            NSArray *blogArray = [NSArray arrayWithObject:blogModel];
            [MessageSQL refershMessagesByMessageModelArray:blogArray];
            [MessageSQL deletePhoto:blogArray];
            NSInteger count = [MessageSQL getMessageCount];
            
            [self removePhotoWithModel:blogModel index:_selectPhotoIndex];
            
            if(_myPhotoDetailsDelegate && [_myPhotoDetailsDelegate respondsToSelector:@selector(reloadPhotoes:)]){
                [_myPhotoDetailsDelegate reloadPhotoes:YES];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoGroupChangedNotification object:nil userInfo:nil];
            
            [self showHubWithMessage:@"删除成功"];
            
            //更新使用空间
            NSNumber *spaceUsed = [NSNumber numberWithLongLong:[metaDic[@"spaceused"] longLongValue]];
            [SavaData fileSpaceUseAmount:spaceUsed];
            if (count == 0) {
//                [self.navigationController popViewControllerAnimated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            } else {
                [self setViewData];
            }
            /*NSString *spaceusedStr = [metaDic objectForKey:@"spaceused"];
             if (spaceusedStr) {
             NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
             NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:User_File];
             NSMutableDictionary *userDataDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
             [userDataDic setObject:spaceusedStr forKey:@"spaceUsed"];
             [userDataDic writeToFile:plistPath atomically:YES];
             }*/   
        }
    }
    
}

-(void)requestFail:(ASIFormDataRequest *)request
{
    [self showHubWithMessage:@"网络连接异常,删除图片失败"];
}

- (void)removePhotoWithModel:(MessageModel *)model index:(NSInteger)idx
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = [NSData dataWithContentsOfFile:model.paths];
    if (data.length > 0)
    {
        [fileManager removeItemAtPath:model.paths error:nil];
    }
    
    NSData *sdata = [NSData dataWithContentsOfFile:model.spaths];
    if (sdata.length > 0)
    {
        [fileManager removeItemAtPath:model.spaths error:nil];
    }
    
    self.blogArray.count == 1 ? ([self.blogArray removeObjectAtIndex:0]) : ([self.blogArray removeObjectAtIndex:idx]);
    
    MessageModel *aModel=nil;// = [[MessageModel alloc] init];
    DiaryPictureClassificationModel *diaryModel = [DiaryPictureClassificationSQL getDiaryModelByGroupId:model.groupId WithUserID:USERID];
    
    if (self.blogArray.count > 0)
    {
        aModel = self.blogArray[0];
        diaryModel.blogcount = [NSString stringWithFormat:@"%d",self.blogArray.count];
        diaryModel.latestPhotoURL = aModel.attachURL;
        diaryModel.latestPhotoPath = aModel.spaths;
        
        [DiaryPictureClassificationSQL updateDiaryWithArr:@[diaryModel] WithUserID:USERID];
        
    }
    else
    {
        diaryModel.blogcount = [NSString stringWithFormat:@"%d",self.blogArray.count];
        diaryModel.latestPhotoURL = nil;
        diaryModel.latestPhotoPath = nil;
        //        diaryModel.groupId = model.groupId;
        [DiaryPictureClassificationSQL updateDiaryWithArr:@[diaryModel] WithUserID:USERID];
        
    }
    
    _selectPhotoIndex --;
    
    if (_selectPhotoIndex>0) {
        
    } else {
        _selectPhotoIndex = 0 ;
    }
}

- (void)showHubWithMessage:(NSString *)message
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [[EternalMemoryAppDelegate getAppDelegate].window addSubview:HUD];
    HUD.labelText = message;
    HUD.mode = MBProgressHUDModeText;
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        [HUD release];
    }];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskPortrait;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    CGRect cycleFrame = _cycle.frame;
    UIScrollView *_scrollView = _cycle.rootScrollView;
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||  toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {

        _shouldHiddenStatusBar = YES;
        self.canHiddenNaviBar.frame = (CGRect){
            .origin.x = 0,
            .origin.y = 0,
            .size.width  = _cycle.frame.size.width,
            .size.height = 40
        };
        
        [_imageWordTextView setFrame:CGRectMake(0, iOS7 ? (320 - TEXTVIEW_HEIGHT) : (320 - TEXTVIEW_HEIGHT - 20) , (iPhone5 ? 568 : 480), TEXTVIEW_HEIGHT)];
        [self.recordView setFrame:self.view.bounds];
        [_recordWarningView setFrame:CGRectMake(0, 40, (iPhone5 ? 568 : 480), 30)];
        [_recordWarningView setsubViewFrame];

        self.canHiddenNaviBar.hidden = NO;
        if (_hideRecordButtonForNoAudio) {
            self.canHiddenNaviBar.hidden = YES;
            [self setNavBarOriention:UIInterfaceOrientationLandscapeLeft];
            self.canHiddenNaviBar.backgroundColor = [UIColor clearColor];
            self.canHiddenNaviBar.rightButton.hidden = YES;
            self.canHiddenNaviBar.backButton.hidden = YES;
            self.canHiddenNaviBar.titleLabel.hidden = YES;
            CGFloat screenWidth = iPhone5 ? 568 : 480;
            [self.canHiddenNaviBar.backgroundImageView setImage:nil];
            _memoryButton.frame = CGRectMake(20, 10, 75, 30);
            _allButton.frame = CGRectMake(95, 10, 75, 30);
            _closeButton.frame = CGRectMake(screenWidth - 40, 10, 30, 30);
            [self.view bringSubviewToFront:_memoryButton];
            [self.view bringSubviewToFront:_allButton];
            [self.view bringSubviewToFront:_closeButton];
//            [self.canHiddenNaviBar addSubview:_memoryButton];
//            [self.canHiddenNaviBar addSubview:_allButton];
//            [self.canHiddenNaviBar addSubview:_closeButton];
        }
//        [self.canHiddenNaviBar addSubview:_closeButton];
        cycleFrame.origin.y = 0 ;
        cycleFrame.size.height = 320;
        _cycle.frame = cycleFrame;
        _cycle.backgroundColor = [UIColor blueColor];
        self.navBarView.hidden = YES;
        self.titleLabel.hidden = YES;
        self.rightBtn.hidden = _shouldRightButtonHidden;
        self.backBtn.hidden = YES;
        NSArray *views = [_scrollView subviews];
        for (int i = 0; i < views.count; i ++) {
            int x = i * (iPhone5 ? 568 : 480);
            UIView *view = views[i];
            if ([view isKindOfClass:NSClassFromString(@"ReviewImageScrollView")]) {
                view.frame = (CGRect){
                    .origin.x = x,
                    .origin.y = 0,
                    .size.width  = (iPhone5 ? 568 : 480),
                    .size.height = 320
                };
            }
        }
        
        _cycle.interfaceOrientation = UIInterfaceOrientationLandscapeLeft;

        CGFloat x = iPhone5 ? 568 : 480;
        _scrollView.contentSize = CGSizeMake(_blogs.count * x, 0);
        _scrollView.contentOffset = CGPointMake(_selectPhotoIndex * x, 0);
    }
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {

        
        if (([UIApplication sharedApplication].statusBarHidden) && !iOS7) {
            CGRect viewFrame = self.view.frame;
            viewFrame.origin.y = 20;
            self.view.frame = viewFrame;
        }
        [_imageWordTextView setFrame:CGRectMake(0, iOS7 ? (SCREEN_HEIGHT - TEXTVIEW_HEIGHT) : (SCREEN_HEIGHT - TEXTVIEW_HEIGHT - 20) , 320, TEXTVIEW_HEIGHT)];
        [_recordWarningView setFrame:CGRectMake(0,0, SCREEN_WIDTH, 30)];
        [_recordWarningView setsubViewFrame];
        [self.recordView setFrame:self.view.bounds];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        _shouldHiddenStatusBar = NO;
        NSArray *views = [_scrollView subviews];
        self.canHiddenNaviBar.hidden = YES;
        cycleFrame.origin.y = iOS7 ? 64 : 44;
        _cycle.frame = cycleFrame;
        self.navBarView.image = [UIImage imageNamed:@"top.png"];
        if (_hideRecordButtonForNoAudio) {
            [self setNavBarOriention:UIInterfaceOrientationPortrait];
//            self.navBarView.image = nil;
//            _closeButton.frame = CGRectMake(320 - 55, 5, 40, 40);
//            [self.navBarView addSubview:_closeButton];
        }
        self.navBarView.hidden = NO;
        self.titleLabel.hidden = NO;
        self.rightBtn.hidden = _shouldRightButtonHidden;
        self.backBtn.hidden = NO;
        for (int i = 0; i < views.count; i ++) {
            int x = i * 320;
            UIView *view = views[i];
            if ([view isKindOfClass:NSClassFromString(@"ReviewImageScrollView")]) {
                view.frame = (CGRect){
                    .origin.x = x,
                    .origin.y = 0,
                    .size.width  = 320,
                    .size.height = (iPhone5 ? 568 : 480)
                };
            }
        }
        _cycle.interfaceOrientation = UIInterfaceOrientationPortrait;
        _scrollView.contentSize = CGSizeMake(_blogs.count * 320, 0);
        _scrollView.contentOffset = CGPointMake(_selectPhotoIndex * 320, 0);
        _scrollView.backgroundColor = [UIColor blueColor];
        
        
    }
    
    if (iOS7) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    if (_hideRecordButtonForNoAudio) {
//        self.navBarView.hidden = YES;
        self.navBarView.hidden = YES;
        self.rightBtn.hidden = YES;
        self.backBtn.hidden = YES;
        self.titleLabel.hidden = YES;
//        self.canHiddenNaviBar.hidden = YES;
    }
}

- (BOOL)prefersStatusBarHidden
{
   return _hideRecordButtonForNoAudio;
}

- (UIStatusBarAnimation) preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

#pragma mark -- alterview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0&&[self.errorcodeStr isEqualToString:@"1005"])
    {
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate]  showLoginVC];
    }
}

#pragma mark - play audio

-(void)readyToPlayAudio
{
    [_recordWarningView setRecordState:RecordStateStop WithEMAudio:self.currentMessageModel.audio];
    [self downloadAndPlayAudio:self.currentMessageModel.audio];
}

- (void)playAudioAtPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    NSData *audioData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    self.audioPlayer.numberOfLoops = 0;
    self.audioPlayer.volume = 1;
    if (self.audioPlayer) {
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    } else {
    }
}
-(void)stopAudioPlayWhenClick
{
    [_recordWarningView setRecordState:RecordStateReadyPlay WithEMAudio:self.currentMessageModel.audio];
    [self stopAudioPlay];
}
- (void)stopAudioPlay {
    if (self.audioPlayer) {
        if (self.audioPlayer.isPlaying) {
            [self.audioPlayer stop];
        }
    }
}
#pragma mark -- img

- (void)sendDeleteAudioRequestWithBlogid:(NSString *)blogId {
    NSURL *deleteAudioUrl = [[RequestParams sharedInstance] deleteAudio];
    ASIFormDataRequest *deleteRequest = [ASIFormDataRequest requestWithURL:deleteAudioUrl];
    [deleteRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [deleteRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [deleteRequest setPostValue:blogId forKey:@"blogid"];
    [deleteRequest setRequestMethod:@"POST"];
    [deleteRequest setTimeOutSeconds:30];
    
    [deleteRequest startAsynchronous];
    
    __block typeof(self) bself = self;
    [deleteRequest setCompletionBlock:^{
        NSData *data = [deleteRequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *msg = dic[@"message"];
        NSInteger success = [dic[@"success"] integerValue];
        if (!success) {
            return;
        }
        
        bself.currentMessageModel.audio.blogId = bself.currentMessageModel.blogId;
        [[NSFileManager defaultManager] removeItemAtPath:bself.currentMessageModel.audio.wavPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:bself.currentMessageModel.audio.amrPath error:nil];
        
        
        [MessageSQL deleteAUdioDataForBlogId:bself.currentMessageModel.blogId];
        EMAudio *audio = [EMAudio new];
        bself.currentMessageModel.audio = audio;
        [bself.recoredButton setTitle:@"录音" forState:UIControlStateNormal];
        [bself showHubWithMessage:@"语音删除成功"];
        [audio release];
        
        [bself audioButtonForAudio:bself.currentMessageModel.audio];
        
    }];
    
    [deleteRequest setFailedBlock:^{
    }];
}

- (void)deleteAudio:(EMAudio *)audio {
    
    if ([Utilities checkNetwork]) {
        [self sendDeleteAudioRequestWithBlogid:audio.blogId];
    } else {
        if ([[EMPhotoSyncEngine sharedEngine] deleteNeedsSyncWithAudio:audio]) {
            audio.audioData = nil;
            audio.audioURL = @"";
            audio.amrPath = @"";
            audio.wavPath = @"";
            audio.duration = 0;
            audio.size = 0;
            [self audioButtonForAudio:audio];
        }
    }
}

- (void)downloadAndPlayAudio:(EMAudio *)audio {
    
    if (!audio) {
        return;
    }
    
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
    }

    NSError *error = nil;
    
    if (audio.audioData.length > 0 ) {

        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audio.audioData error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play]; 
        
        _recoredButton.enabled = NO;
        [_recoredButton setTitle:@"正在播放..." forState:UIControlStateNormal];
        return;
    }
    
    if (audio.wavPath.length > 0) {
        
        
        NSString *fileType = [[audio.wavPath componentsSeparatedByString:@"."] lastObject];
        if ([fileType isEqualToString:@"amr"]) {
            
            
            NSString *wavPath = [audio.wavPath stringByReplacingCharactersInRange:NSMakeRange(audio.wavPath.length - 3, 3) withString:@"wav"];
            if (! DecodeAMRFileToWAVEFile([audio.wavPath cStringUsingEncoding:NSASCIIStringEncoding], [wavPath cStringUsingEncoding:NSASCIIStringEncoding])) {
                return;
            }
            audio.wavPath = wavPath;
            [MessageSQL updateAudio:audio forBlogid:self.currentMessageModel.blogId];
            
            NSData *audioData = [NSData dataWithContentsOfFile:wavPath];
            self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
            self.audioPlayer.delegate = self;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
            
            return;
        }
        NSData *data = [NSData dataWithContentsOfFile:audio.wavPath];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
        if (error) {
            return;
        }
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        
        audio.audioData = data;
        _recoredButton.enabled = NO;
        [_recoredButton setTitle:@"正在播放..." forState:UIControlStateNormal];
        return;
    }
    
    if (audio.audioURL.length > 0) {
        [self downloadAudoWithUrl:audio.audioURL];
        return;
    }
}

- (void)downloadAudoWithUrl:(NSString *)urlStr {
    NSString *basePath = [Utilities FileFolder:@"Audioes" UserID:USERID];
    NSString *fileName = [self audioFileName:urlStr];
    NSString *desPath = [basePath stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL URLWithString:urlStr];
    self.downAudioRequest = [ASIHTTPRequest requestWithURL:url];
    [self.downAudioRequest setDownloadDestinationPath:desPath];
    [self.downAudioRequest startAsynchronous];
    
    __block typeof(self) bself = self;
    [self.downAudioRequest setCompletionBlock:^{
        NSString *wavFilename = [fileName stringByReplacingCharactersInRange:NSMakeRange(fileName.length - 4, 4) withString:@".wav"];
        NSString *wavFilePath = [basePath stringByAppendingPathComponent: wavFilename];
        
        if (! DecodeAMRFileToWAVEFile([desPath cStringUsingEncoding:NSASCIIStringEncoding], [wavFilePath cStringUsingEncoding:NSASCIIStringEncoding])) {
            return ;
        }
        
        NSData *audioData = [NSData dataWithContentsOfFile:wavFilePath];
        bself.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
        bself.audioPlayer.delegate = bself;
        [bself.audioPlayer prepareToPlay];
        [bself.audioPlayer play];
        
        _recoredButton.enabled = NO;
        [_recoredButton setTitle:@"正在播放..." forState:UIControlStateNormal];
        
        [[NSFileManager defaultManager] removeItemAtPath:desPath error:nil];
        if ([MessageSQL updateAudioPath:wavFilePath forModel:bself.currentMessageModel]) {
            bself.currentMessageModel.audio.wavPath = wavFilePath;
            bself.currentMessageModel.audio.audioData = audioData;
        }
        
    }];
}

- (NSString * )audioFileName:(NSString *)urlStr {
    
    return [[urlStr componentsSeparatedByString:@"/"] lastObject];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self audioButtonForAudio:self.currentMessageModel.audio];
}

-(void)setNavBarOriention:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationPortrait)
    {
        _memoryButton.frame = CGRectMake(10, 10, 75, 30);
        _allButton.frame = CGRectMake(85, 10, 75, 30);
        _closeButton.frame = CGRectMake(280, 10, 30, 30);
    }
    else
    {
        CGFloat width = (iPhone5)? 568 : 480;
        _memoryButton.frame = CGRectMake(20, 10, 75, 30);
        _allButton.frame = CGRectMake(95, 10, 75, 30);
        _closeButton.frame = CGRectMake(width - 40, 10, 30, 30);
    }
}

@end

