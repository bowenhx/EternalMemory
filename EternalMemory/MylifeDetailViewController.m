//
//  MylifeDetailViewController.m
//  EternalMemory
//
//  Created by xiaoxiao on 3/10/14.
//  Copyright (c) 2014 sun. All rights reserved.
//
#import "EMEditLifeHighlightViewController.h"
#import "DiaryPictureClassificationSQL.h"
#import "MyPhotoDetailsViewController.h"
#import "MylifeDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AddRecordWarningView.h"
#import "UIImage+UIImageExt.h"
#import "ImageScrollView.h"
#include "amrFileCodec.h"
#import "MBProgressHUD.h"
#import "MessageModel.h"
#import "StaticTools.h"
#import "MessageSQL.h"
#import "MyToast.h"
#import "MD5.h"

@interface MylifeDetailViewController ()
{
    BOOL             _rotating;
    BOOL             _hiddenBar;
    BOOL             _hiddenRighBtn;
    __block BOOL     _audioExist;//判断录音有没有
    NSInteger        count;
    NSInteger        _index;
    NSInteger        comeInTime;
    NSInteger        comeInStyle;// 1 表示通过web进入 2 表示通过app进入
    CGFloat          navbarHeight;
    CGFloat          orientationWidth;
    CGFloat          scrollDistance;
    
    
    //app进入时导航栏显示的控件
    UILabel         *_titleLabel;
    UIButton        *_backBtn;
    UIButton        *_rightBtn;
    
    //web进入时导航栏显示的控件
    UIButton        *_memoryButton;
    UIButton        *_allButton;
    UIButton        *_closeButton;
    
    
    NSTimer         *_timer;
    UIImageView     *_navBarView;
    UIView          *_rotationBgView;
    UITextView      *_textView;//描述信息
    MBProgressHUD   *_hud;
    
    __block CGRect                   _originRect;
    __block UIImageView             *_submitImageView;
    __block AVAudioPlayer           *_audioPlayer;
    __block ASIHTTPRequest          *_downAudioRequest;
    __block AddRecordWarningView    *_recordWarningView;
    
    NSMutableArray                  *_albumArray;
    
    int					_firstVisiblePageIndexBeforeRotation;
    CGFloat				_percentScrolledIntoFirstVisiblePage;

}

@property(nonatomic,retain)DiaryPictureClassificationModel *diaryModel;
-(void)createContentView;
-(void)createNavgationBarFromWeb;
-(void)createNavgationBarFromApp;
-(void)createReplaceImageView;
-(void)createRecordWarningView;
-(void)setTextView;
-(void)setNavBarState;
-(void)setAudioAutoPlay;
-(void)setSubmitImageViewAfterScrollAnimation;
-(void)setNavBarOriention:(UIInterfaceOrientation)orientation;
-(void)setOrientationNoAnimation:(NSInteger)pageIndex;
-(void)clearDataWhenOrientation;
-(void)createDataWhenOrientation;
-(void)bringSubViewToFront;
- (void)tilePages;
- (ImageScrollView *)dequeueRecycledPage;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index;

//audio
- (void)downloadAndPlayAudio:(EMAudio *)audio;
- (void)downloadAudoWithUrl:(NSString *)urlStr;
@end

#define TEXTVIEW_HEIGHT 57

@implementation MylifeDetailViewController
@synthesize audio = _audio;
@synthesize imageData	= _imageData;
@synthesize currentPage	= _currentPage;
@synthesize diaryModel = _diaryModel;

- (void)dealloc
{
    if (_downAudioRequest)
    {
        NSLog(@"_downloadAudio is not finished");
        [[NSFileManager defaultManager] removeItemAtPath:_downAudioRequest.downloadDestinationPath error:nil];
        [_downAudioRequest clearDelegatesAndCancel];
        _downAudioRequest = nil;
    }
    if (_visiblePages)
    {
        RELEASE_SAFELY(_visiblePages);
    }
    if (_recycledPages)
    {
        RELEASE_SAFELY(_recycledPages);
    }
    RELEASE_SAFELY(_imageData);
    RELEASE_SAFELY(_audio);
    RELEASE_SAFELY(_albumArray);
    
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

-(id)initWithDataArray:(NSMutableArray *)dataArray withPage:(NSInteger)pageIndex withModel:(DiaryPictureClassificationModel *)model comeInStyle:(NSInteger)style albumArray:(NSArray *)photoArray
{
    self = [super init];
    if (self)
    {
        _index = pageIndex;
        _currentPage = 0;
        comeInTime = 1;
        comeInStyle = style;
        self.imageData = dataArray;
        count = self.imageData.count - 2;
        orientationWidth = 320;
        scrollDistance = 320;
        self.diaryModel = model;
        self.audio = model.audio;
        [self createView];
        if (comeInStyle == 1)
        {
            [self createNavgationBarFromWeb];
            _hiddenBar = YES;
            [self startTimer];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToHomeWeb) name:@"backToHomeWeb" object:nil];
        }
        else
        {
            _hiddenBar = NO;
            [self createNavgationBarFromApp];
            [self setNavBarState];
        }
        [self setAudioAutoPlay];
        [self createReplaceImageView];
        [[[UIApplication sharedApplication] keyWindow]setBackgroundColor:[UIColor blackColor]];
        [self createContentView];
        [self setTextView];
        [self setCurrentPage:pageIndex];
        self.view.backgroundColor = [UIColor blackColor];
        if (photoArray != nil)
        {
            _albumArray = [[NSMutableArray alloc] initWithArray:photoArray];
        }
    }
    return self;
}


- (BOOL)shouldHideRightBtn {
    __block NSInteger memoCount = 0;
    [self.imageData enumerateObjectsUsingBlock:^(MessageModel *model, NSUInteger idx, BOOL *stop) {
        if (model.blogId.length == 0) {
            memoCount ++;
        }
    }];
    
    BOOL isMemoAllTemplate = (memoCount == 5);
    BOOL hasNoPhotos = ([MessageSQL getMessageCount] == 0);
    
    _hiddenRighBtn = (isMemoAllTemplate && hasNoPhotos);
    
    return _hiddenRighBtn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteLifeAudio:) name:Delete_Life_Audio object:nil];
	// Do any additional setup after loading the view.
}

- (void)createView
{
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:[self frameForPagingScrollView]];
    _pagingScrollView.delegate = self;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor blackColor];
    [_pagingScrollView setContentSize:[self contentSizeForPagingScrollView]];
    [self.view addSubview:_pagingScrollView];
    [_pagingScrollView release];
    _recycledPages = [[NSMutableSet alloc] init];
    _visiblePages  = [[NSMutableSet alloc] init];
}

-(void)createNavgationBarFromWeb
{
    _memoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _memoryButton.frame = CGRectMake(10, 10, 75, 30);
    _memoryButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_memoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_memoryButton setTitle:@"时光记忆" forState:UIControlStateNormal];
    [_memoryButton setTitleColor:[UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1] forState:UIControlStateNormal];
    [_memoryButton setBackgroundImage:[UIImage imageNamed:@"life_memory_photo_selected"] forState:UIControlStateNormal];
    [_memoryButton setBackgroundImage:[UIImage imageNamed:@"life_memory_photo_selected"] forState:UIControlStateHighlighted];

    [_memoryButton addTarget:self action:@selector(showMemoryPhoto) forControlEvents:UIControlEventTouchUpInside];
    _memoryButton.userInteractionEnabled = YES;
    [self.view addSubview:_memoryButton];
    
    _allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allButton.frame = CGRectMake(85, 10, 75, 30);
    _allButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_allButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_allButton setTitle:@"其他图片" forState:UIControlStateNormal];
    [_allButton setTitleColor:[UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1] forState:UIControlStateNormal];

    [_allButton setBackgroundImage:[UIImage imageNamed:@"all_photo"] forState:UIControlStateNormal];
    [_allButton addTarget:self action:@selector(showAllPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_allButton];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = CGRectMake(280, 10, 30, 30);
    [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(rightBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    navbarHeight = _allButton.frame.origin.y + _allButton.frame.size.height;
    
    [self setAudioAutoPlay];
    [self createReplaceImageView];
}

-(void)createNavgationBarFromApp
{
    _navBarView=[[UIImageView alloc] init];
    _navBarView.frame=CGRectMake(0, 0, SCREEN_WIDTH, 44);
    if (iOS7) {
        _navBarView.frame=CGRectMake(0, 0, SCREEN_WIDTH, 64);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    [_navBarView setImage:[UIImage imageNamed:@"top"]];
    _navBarView.userInteractionEnabled = YES;
    _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-160)/2, 2, 160, 40)];
    if (iOS7) {
        _titleLabel.frame=CGRectMake((SCREEN_WIDTH-160)/2, 22, 160, 40);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    _titleLabel.backgroundColor=[UIColor clearColor];
    _titleLabel.font=[UIFont systemFontOfSize:20.0f];
    _titleLabel.textAlignment=NSTextAlignmentCenter;
    _titleLabel.textColor=[UIColor whiteColor];
    _titleLabel.text = @"时光记忆";
    [_navBarView addSubview:_titleLabel];
    [_titleLabel release];
    
    UIFont *btnTxtFont = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.titleLabel.font = btnTxtFont;
    _backBtn.frame = CGRectMake(10, 7, 52, 31);
    if (iOS7) {
        _backBtn.frame=CGRectMake(10, 27, 52, 31);
    }

    _backBtn.showsTouchWhenHighlighted=YES;
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"but_left_nav_normal"] forState:UIControlStateNormal];
    [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backBtnPressed) forControlEvents:UIControlEventTouchUpInside];

    
    _rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.titleLabel.font = btnTxtFont;
    _rightBtn.frame=CGRectMake(SCREEN_WIDTH - 52, 6, 42, 31);
    if (iOS7) {
        _rightBtn.frame=CGRectMake(SCREEN_WIDTH - 52, 26, 42, 31);
    }
    _rightBtn.showsTouchWhenHighlighted=YES;
    [_rightBtn setBackgroundImage:[UIImage imageNamed:@"but_right_nav_normal"] forState:UIControlStateNormal];  //btn_rbg 图片在子类定义
    _rightBtn.titleLabel.font=[UIFont systemFontOfSize:14.0f];
    [_rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(rightBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _rightBtn.hidden = [self shouldHideRightBtn];
    navbarHeight = _navBarView.frame.size.height + _navBarView.frame.origin.y;
  
    [_navBarView addSubview:_backBtn];
    [_navBarView addSubview:_rightBtn];
    [self.view addSubview:_navBarView];
    [_navBarView release];
}

-(void)createRecordWarningView
{
    __block typeof(self) this = self;
    _recordWarningView = [[AddRecordWarningView alloc] initWithFrame:CGRectMake(0,navbarHeight, SCREEN_WIDTH, 30)];
    _recordWarningView.userInteractionEnabled = YES;
    _recordWarningView.playRecord = ^(void){
        [this readyToPlayAudio];
    };
    _recordWarningView.stopRecord = ^(void){
        [this stopAudioPlayWhenClick];
    };
    [self.view addSubview:_recordWarningView];
    [_recordWarningView release];
}
-(void)setAudioAutoPlay
{
    if (_audio.duration > 0)
    {
        if (_recordWarningView == nil)
        {
            [self createRecordWarningView];
        }
        if (_audio.wavPath.length > 0)
        {
            _audioExist = YES;
            [_recordWarningView setRecordState:RecordStateStop WithEMAudio:_audio];
            [self downloadAndPlayAudio:_audio];
        }
        else
        {
            _audioExist = NO;
            [_recordWarningView setRecordState:RecordStateReadyPlay WithEMAudio:_audio];
            [self downloadAudoWithUrl:_audio.audioURL];
        }
    }
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.mode = MBProgressHUDModeText;
    [self.view addSubview:_hud];
    [_hud release];
}
-(void)createReplaceImageView
{
    _rotationBgView = [[UIView alloc] initWithFrame:self.view.bounds];
    _rotationBgView.backgroundColor = [UIColor blackColor];
    
    _submitImageView = [[UIImageView alloc] initWithFrame:_rotationBgView.bounds];
    _submitImageView.backgroundColor = [UIColor clearColor];
    _submitImageView.clipsToBounds = YES;
    [_rotationBgView addSubview:_submitImageView];
    [_submitImageView release];
    [self.view addSubview:_rotationBgView];
    [_rotationBgView release];
    [self.view sendSubviewToBack:_rotationBgView];
}

-(void)createContentView
{
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(0, (SCREEN_HEIGHT - 57), 320, 57)];
    _textView.alpha = 0.5f;
    _textView.editable = NO;
    _textView.userInteractionEnabled = YES;
    _textView.textColor = [UIColor whiteColor];
    _textView.textAlignment = NSTextAlignmentLeft;
    _textView.backgroundColor = [UIColor blackColor];
    _textView.font = [UIFont boldSystemFontOfSize:14.0f];
    [self.view addSubview:_textView];
    [_textView release];
}
-(void)setTextView
{
    MessageModel *model = (MessageModel *)_imageData[_index];
    NSString *content = model.content;
    if (content.length == 0)
    {
        _textView.text = @"";
        _textView.scrollEnabled = NO;
    }
    else
    {
        CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(320, 10000) lineBreakMode:NSLineBreakByWordWrapping];
        _textView.text = content;
        if (size.height > 57)
        {
            _textView.scrollEnabled = YES;
            _textView.contentSize = CGSizeMake(320, size.height);
        }
        else
        {
            _textView.scrollEnabled = NO;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (comeInTime == 1)
    {
        [self.view bringSubviewToFront:_hud];
        _hud.labelText = @"点击图片暂停自动播放图片";
        [_hud showAnimated:YES whileExecutingBlock:^{
            sleep(1);
        } completionBlock:^{
        }];
        comeInTime = 2;
    }
    else
    {
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (comeInStyle == 1)
    {
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
    if (comeInTime == 2)
    {
        [self willAnimateRotationToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0];
        [self didRotateFromInterfaceOrientation:[[UIApplication sharedApplication]statusBarOrientation]];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopTimer];
    [self stopAudioPlayWhenClick];
}

-(void)setCurrentPage:(NSInteger)pageIndex
{
    if ((pageIndex < 0) || (pageIndex > ([self.imageData count] - 1)))
    {
        return;
    }
    [self scrollToPage:pageIndex];
    [self tilePages];
}
-(void)setOrientationNoAnimation:(NSInteger)pageIndex
{
    CGPoint pOffset = CGPointMake(pageIndex * scrollDistance, 0.0f);
    [_pagingScrollView setContentOffset:pOffset animated:NO];
    [self tilePages];
}

- (void)scrollToPage:(NSInteger)pageIndex
{
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGPoint pOffset = CGPointMake(pageIndex * pageWidth, 0.0f);
    [_pagingScrollView setContentOffset:pOffset animated:YES];
}

- (void)tilePages
{
    CGRect visibleBounds = _pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex = MIN(lastNeededPageIndex, [self.imageData count] - 1);
    for (ImageScrollView *page in _visiblePages)
    {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex)
        {
            [page setZoomScale:page.minimumZoomScale animated:NO];
            [_recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [_visiblePages minusSet:_recycledPages];
    
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++)
    {
        if (![self isDisplayingPageForIndex:index])
        {
            ImageScrollView *page = [self dequeueRecycledPage];
            if (page == nil)
            {
                page = [[[ImageScrollView alloc] init] autorelease];
                page.imageScrollViewDelegate = self;
            }
            [self configurePage:page forIndex:index];
            [_pagingScrollView addSubview:page];
            [_visiblePages addObject:page];
        }
    }
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (ImageScrollView *page in _visiblePages)
    {
        if (page.index == index)
        {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

-(ImageScrollView *)dequeueRecycledPage
{
    ImageScrollView *page = [_recycledPages anyObject];
    if (page)
    {
        [[page retain] autorelease];
        [_recycledPages removeObject:page];
    }
    return page;
}

-(void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index
{
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
    MessageModel *model = (MessageModel *)self.imageData[index];
    [page loadImageDate:model];
}

#pragma mark - NSNotificationCenter--

-(void)deleteLifeAudio:(NSNotification *)sender
{
    self.audio = nil;
    if (_recordWarningView)
    {
        [_recordWarningView removeFromSuperview];
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGPoint offset = _pagingScrollView.contentOffset;
    if (offset.x < 0)
    {
        [_pagingScrollView setContentOffset:CGPointMake(count * scrollDistance, 0) animated:NO];
    }
    else if (offset.x > ((count + 1) * scrollDistance))
    {
        [_pagingScrollView setContentOffset:CGPointMake(1 * scrollDistance, 0) animated:NO];
    }
    [self tilePages];
    offset = _pagingScrollView.contentOffset;
	_index = floorf((offset.x - pageWidth / 2.0) / pageWidth) + 1;
    [self setTextView];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self setSubmitImageViewAfterScrollAnimation];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setSubmitImageViewAfterScrollAnimation];
}

#pragma mark - Frame Calculations
#define PADDING 0
- (CGRect)frameForPagingScrollView
{
    CGRect frame = [self.view bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index
{
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 *PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView
{
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self.imageData count], bounds.size.height);
}

#pragma mark -NSTimer Event

-(void)startTimer
{
    [self stopTimer];
    if (_imageData.count > 1)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(setScrollViewOffSet) userInfo:nil repeats:YES];
    }
}

-(void)stopTimer
{
    if (_timer && _timer.isValid)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)setScrollViewOffSet
{
    if (_rotating == NO)
    {
        if (_visiblePages.count == 0 || _pagingScrollView == nil)
        {
            return;
        }
        CGPoint offset = _pagingScrollView.contentOffset;
        NSInteger index = (int)offset.x / scrollDistance;
        if (index == (count + 1))
        {
            [_pagingScrollView setContentOffset:CGPointMake(1 * scrollDistance, 0) animated:NO];
            index = 1;
        }
        [_pagingScrollView setContentOffset:CGPointMake((index + 1) * scrollDistance, 0) animated:YES];
    }
}

-(void)setNavBarState
{
    if (_hiddenBar == NO)
    {
        _navBarView.hidden = YES;
        _textView.hidden = NO;
        if (comeInStyle == 2)
        _recordWarningView.frame = CGRectMake(0,20, orientationWidth, 30);
        _hiddenBar = YES;
        [self.view bringSubviewToFront:_hud];
        _hud.labelText = @"点击图片暂停自动播放图片";
        [_hud showAnimated:YES whileExecutingBlock:^{
            sleep(1);
        } completionBlock:^{
        }];
        
        [self startTimer];
    }
    else
    {
        _navBarView.hidden = NO;
        _textView.hidden = YES;
        if (comeInStyle == 2)
        _recordWarningView.frame = CGRectMake(0,navbarHeight, orientationWidth, 30);

        _hiddenBar = NO;
        _hud.labelText = @"再次点击图片继续播放图片";
        [self.view bringSubviewToFront:_hud];
        [_hud showAnimated:YES whileExecutingBlock:^{
            sleep(1);
        } completionBlock:^{
        }];
        
        [self stopTimer];
    }
}

#pragma mark - ImageScrollViewDelegate
- (void) singleTap:(ImageScrollView *)imageScrollView
{
    [self setNavBarState];
}

#pragma mark - AudioPlay
- (void)downloadAndPlayAudio:(EMAudio *)audio {
    
    if (!audio) {
        return;
    }
    
    if (_audioPlayer.isPlaying) {
        [_audioPlayer stop];
    }
    NSError *error = nil;
    
    if (_audio.audioData.length > 0 ) {
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:audio.audioData error:nil];
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
        return;
    }
    
    if (_audio.wavPath.length > 0) {
        
        NSString *fileType = [[audio.wavPath componentsSeparatedByString:@"."] lastObject];
        if ([fileType isEqualToString:@"amr"]) {
            
            
            NSString *wavPath = [audio.wavPath stringByReplacingCharactersInRange:NSMakeRange(audio.wavPath.length - 3, 3) withString:@"wav"];
            if (! DecodeAMRFileToWAVEFile([audio.wavPath cStringUsingEncoding:NSASCIIStringEncoding], [wavPath cStringUsingEncoding:NSASCIIStringEncoding])) {
                return;
            }
            _audio.wavPath = wavPath;
            [MessageSQL updateAudio:audio forBlogid:[(MessageModel *)self.imageData[2] blogId]];
            
            NSData *audioData = [NSData dataWithContentsOfFile:wavPath];
            _audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
            _audioPlayer.delegate = self;
            [_audioPlayer prepareToPlay];
            [_audioPlayer play];
            
            return;
        }
        NSData *data = [NSData dataWithContentsOfFile:audio.wavPath];
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
        if (error) {
            return;
        }
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
        
        _audio.audioData = data;
        return;
    }
    if (_audio.audioURL.length > 0) {
        [self downloadAudoWithUrl:audio.audioURL];
        return;
    }
}

- (void)downloadAudoWithUrl:(NSString *)urlStr {
    NSString *basePath = [Utilities FileFolder:@"Audioes" UserID:USERID];
    NSString *fileName = [self audioFileName:urlStr];
    NSString *desPath = [basePath stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL URLWithString:urlStr];
    _downAudioRequest = [ASIHTTPRequest requestWithURL:url];
    [_downAudioRequest setDownloadDestinationPath:desPath];
    [_downAudioRequest startAsynchronous];
    
    __block typeof(self) this = self;
    [_downAudioRequest setCompletionBlock:^{
        NSLog(@"_download audio is OK");
        NSString *wavFilename = [fileName stringByReplacingCharactersInRange:NSMakeRange(fileName.length - 4, 4) withString:@".wav"];
        NSString *wavFilePath = [basePath stringByAppendingPathComponent: wavFilename];
        
        if (! DecodeAMRFileToWAVEFile([desPath cStringUsingEncoding:NSASCIIStringEncoding], [wavFilePath cStringUsingEncoding:NSASCIIStringEncoding])) {
            return ;
        }
        
        NSData *audioData = [NSData dataWithContentsOfFile:wavFilePath];
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
        _audioPlayer.delegate = this;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
        [[NSFileManager defaultManager] removeItemAtPath:desPath error:nil];
        [DiaryPictureClassificationSQL updateDiaryAudioInfo:_diaryModel ForGrouID:_diaryModel.groupId];
        if ([MessageSQL updateAudioPath:wavFilePath forModel:(MessageModel *)this.imageData[2]]) {
            this.audio.wavPath = wavFilePath;
            this.audio.audioData = audioData;
            _audioExist = YES;
            [_recordWarningView setRecordState:RecordStateStop WithEMAudio:_audio];
        }
        _downAudioRequest = nil;
    }];
}
- (NSString * )audioFileName:(NSString *)urlStr {
    
    return [[urlStr componentsSeparatedByString:@"/"] lastObject];
}

-(void)readyToPlayAudio
{
    if (_audioExist == NO)
    {
        if ([Utilities checkNetwork])
        {
            _hud.labelText = @"录音正在下载，请等待";
        }
        else
        {
            _hud.labelText = @"请先联网下载录音";
        }
        [_hud showAnimated:YES whileExecutingBlock:^{
            sleep(1);
        } completionBlock:^{
        }];
        return;
    }
    [_recordWarningView setRecordState:RecordStateStop WithEMAudio:_audio];
    [self downloadAndPlayAudio:_audio];
}
-(void)stopAudioPlayWhenClick
{
    [_recordWarningView setRecordState:RecordStateReadyPlay WithEMAudio:_audio];
    [self stopAudioPlay];
}
- (void)stopAudioPlay {
    if (_audioPlayer) {
        if (_audioPlayer.isPlaying)
        {
            [_audioPlayer stop];
        }
        [_audioPlayer release];
        _audioPlayer = nil;
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_audioPlayer release];
    _audioPlayer = nil;
    [_recordWarningView setRecordState:RecordStateReadyPlay WithEMAudio:_audio];
}

#pragma mark - navbar Button Event
- (void)backBtnPressed
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(void)rightBtnPressed
{
    
    if (comeInStyle == 1)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeContinueMusic" object:nil];
        }];
    }
    else
    {
        if ([Utilities checkNetwork])
        {
            EMEditLifeHighlightViewController *vc = [[EMEditLifeHighlightViewController alloc] init];
            vc.audio = self.audio;
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
        else
        {
            [MyToast showWithText:@"网络连接失败，请检查网络" :200];
        }
    }
}
-(void)backToHomeWeb
{
    [self dismissViewControllerAnimated:NO completion:NULL];
}
-(void)showMemoryPhoto
{
//    NSLog(@"showMemoryPhoto");
}
-(void)showAllPhoto
{
    if ([Utilities checkNetwork])
    {
        [StaticTools getPhotoFromServer:self];
    }
    else
    {
        [StaticTools getPhotoFromLocal:self];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - View controller rotation methods

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (BOOL)prefersStatusBarHidden
{
    if (comeInStyle == 1)
    {
        return YES;
    }
    return NO;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _rotating = YES;
    if (_hiddenBar == YES)
    {
        [self stopTimer];
    }
    [self.view bringSubviewToFront:_submitImageView];
    [self clearDataWhenOrientation];

    [self bringSubViewToFront];

    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||  toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        _rotationBgView.frame = self.view.bounds;
        [StaticTools setViewRect:_submitImageView image:_submitImageView.image];
        CGRect rect = _submitImageView.bounds;
        if (iPhone5)
        {
            if ([UIApplication sharedApplication].statusBarHidden == NO)
            {
                rect.origin.y += 10;
            }
            else
            {
//                rect.origin.y -= 10;
            }
        }
        else
        {
            if ([UIApplication sharedApplication].statusBarHidden == NO)
            {
                if (iOS7)
                {
                    rect.origin.y += 10;
                }
            }
        }
        _submitImageView.frame = rect;
        CGFloat originY = 0;
        if (comeInStyle == 2)
        {
            originY = _hiddenBar == YES ? 0 : 64;
        }
        else
        {
            originY = 64;
        }
        CGFloat width = (iPhone5)?  568 : 480;
        [_textView setFrame:CGRectMake(0, iOS7 ? (320 - TEXTVIEW_HEIGHT ) : (320 - TEXTVIEW_HEIGHT ) , (iPhone5 ? 568 : 480), TEXTVIEW_HEIGHT)];
        scrollDistance = width;
    }
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        _rotationBgView.frame = self.view.bounds;
        [StaticTools setViewRect:_submitImageView image:_submitImageView.image];
        CGRect rect = _submitImageView.bounds;
        if (iPhone5)
        {
            if ([UIApplication sharedApplication].statusBarHidden == NO)
            {
                if (iOS7)
                {
                    rect.origin.y += 10;
                }
            }
            else
            {
//                rect.origin.y -= 10;
            }
        }
        _submitImageView.frame = rect;
        CGFloat originY = 0;
        if (comeInStyle == 2)
        {
            originY = _hiddenBar == YES ? 0 : 64;
        }
        else
        {
            originY = 64;
        }
        [_textView setFrame:CGRectMake(0, iOS7 ? (SCREEN_HEIGHT - TEXTVIEW_HEIGHT) : (SCREEN_HEIGHT - TEXTVIEW_HEIGHT ) , 320, TEXTVIEW_HEIGHT)];

        scrollDistance = 320;
    }

    [self setNavBarOriention:toInterfaceOrientation];
    
    navbarHeight = _navBarView.frame.size.height + _navBarView.frame.origin.y;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _rotating = NO;
    [self createDataWhenOrientation];
    [self bringSubViewToFront];
    for (ImageScrollView *page in _visiblePages)
	{
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index];
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
    }
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = (_index  * pageWidth);
    _pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
    if (_hiddenBar == YES)
    {
        [self startTimer];
    }
    [self setOrientationNoAnimation:_index];
}

-(void)bringSubViewToFront
{
    if (comeInStyle == 1)
    {
        [self.view bringSubviewToFront:_memoryButton];
        [self.view bringSubviewToFront:_allButton];
        [self.view bringSubviewToFront:_closeButton];
    }
    else
    {
        [self.view bringSubviewToFront:_backBtn];
        [self.view bringSubviewToFront:_rightBtn];
        [self.view bringSubviewToFront:_navBarView];
    }
    [self.view bringSubviewToFront:_recordWarningView];
    [self.view bringSubviewToFront:_textView];
}

-(void)clearDataWhenOrientation
{
    [_pagingScrollView removeFromSuperview];
    _pagingScrollView = nil;
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
}
-(void)createDataWhenOrientation
{
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:[self frameForPagingScrollView]];
    _pagingScrollView.delegate = self;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor blackColor];
    [_pagingScrollView setContentSize:[self contentSizeForPagingScrollView]];
    [self.view addSubview:_pagingScrollView];
    [_pagingScrollView release];
}
-(void)setSubmitImageViewAfterScrollAnimation
{
    NSString *filePath = [StaticTools getMemoPhoto:(MessageModel *)_imageData[_index]];
    if (filePath != nil)
    {
        _submitImageView.image = [UIImage imageWithContentsOfFile:filePath];
        [StaticTools setViewOldRect:_submitImageView image:_submitImageView.image];
    }
    else
    {
        [_submitImageView setImageWithURL:[NSURL URLWithString:[(MessageModel *)_imageData[_index] attachURL]] placeholderImage:[UIImage imageNamed:@"photo"] success: ^(UIImage *image){
            [StaticTools setViewOldRect:_submitImageView image:_submitImageView.image];
        }failure:nil];
    }
}

-(void)setNavBarOriention:(UIInterfaceOrientation)orientation
{
    CGFloat distanceY = (comeInStyle == 1 ? 0 : 20);
    if (comeInStyle == 1)
    {
        if (orientation == UIInterfaceOrientationPortrait)
        {
            _memoryButton.frame = CGRectMake(10, 10, 75, 30);
            _allButton.frame = CGRectMake(85, 10, 75, 30);
            _closeButton.frame = CGRectMake(280, 10, 30, 30);
            [_recordWarningView setFrame:CGRectMake(0,(_memoryButton.frame.origin.y + _memoryButton.frame.size.height), SCREEN_WIDTH, 30)];
            [_recordWarningView setsubViewFrame];
        }
        else
        {
            CGFloat width = (iPhone5)? 568 : 480;
            _memoryButton.frame = CGRectMake(20, 10, 75, 30);
            _allButton.frame = CGRectMake(95, 10, 75, 30);
            _closeButton.frame = CGRectMake(width - 40, 10, 30, 30);
            [_recordWarningView setFrame:CGRectMake(0, (_memoryButton.frame.origin.y + _memoryButton.frame.size.height), (iPhone5 ? 568 : 480), 30)];
            [_recordWarningView setsubViewFrame];
        }
    }
    else
    {
        if (orientation == UIInterfaceOrientationPortrait)
        {
            CGFloat height = (iOS7)? 64 :44;
            _navBarView.frame=CGRectMake(0, 0, SCREEN_WIDTH, height);
            _rightBtn.frame=CGRectMake(268, 6 + (height - 44), 42, 31);
            _backBtn.frame = CGRectMake(10, 6 + (height - 44), 52, 31);
            _titleLabel.frame=CGRectMake((SCREEN_WIDTH-160)/2, height - 40, 160, 40);
            if (_navBarView.hidden == NO)
            {
                [_recordWarningView setFrame:CGRectMake(0,(_navBarView.frame.size.height + _navBarView.frame.origin.y), SCREEN_WIDTH, 30)];
            }
            else
            {
                [_recordWarningView setFrame:CGRectMake(0,distanceY, SCREEN_WIDTH, 30)];
            }
            [_recordWarningView setsubViewFrame];
        }
        else
        {
            NSString *device = [[UIDevice currentDevice] localizedModel];
            CGFloat width = (iPhone5)? 568 : 480;
            orientationWidth = width;
            CGFloat height = (iOS7)? 64 :44;
            _navBarView.frame=CGRectMake(0, 0, width, height);
            if ([device hasPrefix:@"iPad"])
            {
                _rightBtn.frame = CGRectMake(width - 62, (height - 31) / 2 + 10, 42, 31);
                _backBtn.frame = CGRectMake(20, (height - 31) / 2 + 10, 52, 31);
                _titleLabel.frame = CGRectMake((width - 160)/ 2, (height - 40) / 2, 160, 40);
            }
            else
            {
                _rightBtn.frame = CGRectMake(width - 62, (height - 31) / 2, 42, 31);
                _backBtn.frame = CGRectMake(20, (height - 31) / 2, 52, 31);
                _titleLabel.frame = CGRectMake((width - 160)/ 2, (height - 40) / 2, 160, 40);
            }
            if (_navBarView.hidden == NO)
            {
                [_recordWarningView setFrame:CGRectMake(0, (_navBarView.frame.origin.y + _navBarView.frame.size.height), (iPhone5 ? 568 : 480), 30)];
            }
            else
            {
                [_recordWarningView setFrame:CGRectMake(0,distanceY, SCREEN_WIDTH, 30)];
            }
            [_recordWarningView setsubViewFrame];

        }
    }
}

@end



