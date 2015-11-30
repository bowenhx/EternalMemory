//
//  StyleSelectListViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 13-8-20.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "StyleSelectListViewCtrl.h"
#import "UIImageView+WebCache.h"
#import "StyleSendOperation.h"
#import "CommonData.h"
#import "FileModel.h"
#import "StyleListSQL.h"
#import "DownloadModel.h"
#import "Utilities.h"
#import "DownLoadButton.h"
#import "UIImageView+Addition.h"
#import "SavaData.h"
#import "MyToast.h"
#define FileModel    [FileModel sharedInstance]
#define SELF_FRAME  self.view.frame.size.height/3
#define PHOTO_WIDTH 97          
#define PHOTO_HEIGHT 130

@implementation HomeStyleBgView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}
@end


@implementation HomeStyleBgViewSubView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadView];
    }
    return self;
}
- (void)loadView
{
       
    _downloadBut = [DownLoadButton buttonWithType:UIButtonTypeCustom];
    _downloadBut.frame =CGRectMake((self.bounds.size.width-90)/2, 5, 90, 35);
    [_downloadBut setImage:[UIImage imageNamed:@"downStyle"] forState:UIControlStateNormal];
    [self addSubview:_downloadBut];
   
    CGRect progressFrame = _downloadBut.frame;
    progressFrame.origin.x = 0;
    progressFrame.size.height = 10;
    progressFrame.size.width  = self.frame.size.width-25;
    _progress =  [[UIProgressView alloc] initWithFrame:CGRectOffset(progressFrame, 0, 14)];
    _progress.progress = 0.0f;
    _progress.progressTintColor = RGBCOLOR(38, 135, 212);
    _progress.hidden = YES;
    [self addSubview:_progress];
    
    _textLab = [[UILabel alloc] initWithFrame:CGRectOffset(_downloadBut.frame, 0, 4)];
    _textLab.text = @"等待下载";
    _textLab.font = [UIFont systemFontOfSize:12];
    _textLab.textAlignment = NSTextAlignmentCenter;
    _textLab.backgroundColor = [UIColor clearColor];
    _textLab.hidden = YES;
    [self addSubview:_textLab];
    
    CGRect delectFrame = _progress.frame;
    delectFrame.size.height = 40;
    delectFrame.size.width = 40;
    _delectBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _delectBut.frame = CGRectOffset(delectFrame, _progress.frame.size.width, -15);
    [_delectBut setImage:[UIImage imageNamed:@"delect_down"] forState:UIControlStateNormal];
    _delectBut.hidden = YES;
    [self addSubview:_delectBut];
    
}
- (void)dealloc
{
    [_progress release];
    [_textLab release];
    [super dealloc];
}
@end
@interface StyleSelectListViewCtrl ()
{
    ASIFormDataRequest      *_request;
    ASIFormDataRequest      *_request2;
    HomeStyleBgView         *_styleBgView;       //显示大背景View
    HomeStyleBgViewSubView  *_styleSubView;
    UIImageView             *_styleImage;   //显示风格图片View
    UIImageView             *_lineImage;
    
    
    NSMutableArray          *_styleAllDataArr;
    
    NSInteger           pageBag;
    NSString            *_selectStyle;      //设置风格模板
    
    BOOL            isShowUI;   //判断是否刷新UI
   
}

@end

@implementation StyleSelectListViewCtrl


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)dealloc
{
   
    if (_request) {
        [_request cancel];
        [_request clearDelegatesAndCancel];
        _request = nil;
    }
    if (_request2) {
        [_request2 cancel];
        [_request2 clearDelegatesAndCancel];
        _request2 = nil;
    }
    [_myScrollView release];
    [_lineImage release];
    [_titleScrollView release];
    [_styleAllDataArr release],_styleAllDataArr = nil;
    [_selectStyle release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = @"选房子";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    
    //初始化View
    [self initView];

    //初始化基本数据
    [self initLoadDatas];

    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //请求风格列表
    [self loadDataRequest:@"0"];
    
    [self cleanSubviewsScrollView];
   
}
- (void)initLoadDatas
{
    pageBag = 0;
    
    //通知如果已下载家园中的风格模板，就刷新UI显示该模板为选中状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didWillLoadView) name:@"refreshSelectHomeStyle" object:nil];
    
    _styleAllDataArr = [[NSMutableArray alloc] initWithArray:[StyleListSQL getAllStyleListData]];
    
    //选中的风格模板styleID
    _selectStyle = [NSString stringWithFormat:@"%@",[SavaData parseDicFromFile:User_File][@"favoriteStyle"]];
    [_selectStyle retain];
    
    //如果有缓存，在这里处理
    if (_styleAllDataArr.count>0) {
        //默认前1套模板已经下载
        [StyleListSQL addDownLoadList:[_styleAllDataArr[0][@"styles"][0][@"styleId"] integerValue]];
        [StyleListSQL updateDownLoadState:[_styleAllDataArr[0][@"styles"][0][@"styleId"] integerValue]];
        
        [self drawStyleListButton:_styleAllDataArr];
        isShowUI = NO;
    }else{
        //请求风格列表
        [self loadDataRequest:@"0"];
        isShowUI = YES;
    }
}

- (void)initView
{
    //显示风格类型
    _titleScrollView.frame = CGRectMake(0, 44, self.view.bounds.size.width, 38);
    _titleScrollView.layer.borderWidth = 1;
    _titleScrollView.layer.borderColor = RGBCOLOR(215, 217, 217).CGColor;
    [Utilities adjustUIForiOS7WithViews:@[_titleScrollView]];
    
    CGFloat titleFrameY = CGRectGetMaxY(_titleScrollView.frame);
    if (iPhone5) {
        _myScrollView.frame = CGRectMake(0, titleFrameY, self.view.bounds.size.width, self.view.bounds.size.height-titleFrameY);
    }else{
        _myScrollView.frame = CGRectMake(0, titleFrameY, self.view.bounds.size.width, self.view.bounds.size.height-titleFrameY);
    }
    
   [_myScrollView setContentOffset:CGPointMake( 0 , titleFrameY )];
    
}

//风格类型的title显示but
- (void)drawStyleListButton:(NSMutableArray *)arr
{    
    int butWidth;
    int selfWidth = self.view.frame.size.width;
    if (arr.count>1 && arr.count<5)
    {
        butWidth = selfWidth/arr.count;
    }else if (arr.count>4)
    {
        butWidth = selfWidth/4;
    }
    
    for (int i =0; i<arr.count; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*butWidth, 0, butWidth, 36);
        button.tag = i;
        [button setTitle:arr[i][@"typename"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didSelectTitleViewButton:) forControlEvents:UIControlEventTouchUpInside];
        [_titleScrollView addSubview:button];
        
        
        HomeStyleBgView *styleView = [[HomeStyleBgView alloc] initWithFrame:CGRectMake(i*selfWidth, 0, selfWidth, _myScrollView.frame.size.height)];
        styleView.contentSize = CGSizeMake(0, 0);
        styleView.contentOffset = CGPointMake(0, -20);
        //styleView.layer.borderWidth = 3;
        //styleView.layer.borderColor = [UIColor blueColor].CGColor;
        styleView.scrollEnabled = YES;
        styleView.tag = i;
        [self.myScrollView addSubview:styleView];
        
        
        //显示每一个view上的模板类型
        [self initloadViewBut:arr[i][@"styles"] styleBackgroundView:styleView];
    }
    
    //title下划线
    _lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 35, butWidth, 3)];
    _lineImage.backgroundColor = RGBCOLOR(38, 135, 212);
    [_titleScrollView addSubview:_lineImage];
 
    
    //设置左右滑动滑动范围
    _titleScrollView.contentSize = CGSizeMake(butWidth*arr.count, 38);
    _myScrollView.contentSize = CGSizeMake(320*arr.count, _myScrollView.frame.size.height-100);
}
- (void)didSelectTitleViewButton:(UIButton *)but
{
    [self didShowSelectViewIndexPath:but.tag];
}

//开始布局每种风格类型的View
- (void)initloadViewBut:(NSMutableArray *)arr styleBackgroundView:(HomeStyleBgView *)styleBgView
{
    int row=10;     //首个image的x
    int col=15;     //首个image的y
    int rowH = 45;  //行间距
    int rowW = 5;   //列间距
    
    float sizeH = 0.0;
    NSInteger styleId = 0;
    for (int i=0; i<arr.count; i++) {
        _styleImage = [[UIImageView alloc] initWithFrame:CGRectMake(row + (rowW+PHOTO_WIDTH)*(i%3), col+(rowH+PHOTO_HEIGHT)*(i/3), PHOTO_WIDTH, PHOTO_HEIGHT)];
        _styleImage.tag = [arr[i][@"styleId"] integerValue];
        NSString *imageStr = arr[i][@"thumbnail"];
        [_styleImage setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"photo_mr"]];
        _styleImage.contentMode = UIViewContentModeScaleToFill;
        [_styleImage addDetailShow:imageStr];
        CGRect subView = _styleImage.frame;
        subView.origin.y = CGRectGetMaxY(_styleImage.frame);
        subView.size.width = PHOTO_WIDTH;
        subView.size.height = rowH;
        _styleSubView = [[HomeStyleBgViewSubView alloc] initWithFrame:CGRectOffset(subView, 0, 0)];
        sizeH = CGRectGetMaxY(_styleSubView.frame);
        
        
        styleId = [arr[i][@"styleId"] integerValue];
        _styleSubView.tag = styleId;
        _styleSubView.downloadBut.tag = styleId;
        _styleSubView.delectBut.tag = styleId;
        _styleSubView.downloadBut.ID = i;
       
        [styleBgView addSubview:_styleImage];
        [styleBgView addSubview:_styleSubView];
        [FileModel.downStyleArr addObject:_styleSubView];
        
        //判断是否是已下载过的风格
        NSInteger isDown = [self isDownloadStyle:styleId];
        if (isDown == 1) {//已下载
            [_styleSubView.downloadBut setImage:[UIImage imageNamed:@"select_no_set_style"] forState:UIControlStateNormal];
            [_styleSubView.downloadBut setImage:[UIImage imageNamed:@"select_set_style"] forState:UIControlStateSelected];
            if ([_selectStyle integerValue] == styleId) {
                _styleSubView.downloadBut.selected = YES;
                FileModel.downStyleBut = _styleSubView.downloadBut;
            }
        }else if(isDown == 0){//未下载
            [_styleSubView.downloadBut setImage:[UIImage imageNamed:@"downStyle"] forState:UIControlStateNormal];
            //首次进来默认的和原来选中的模板不一样则继续下载
            if ([_selectStyle integerValue] == styleId) {
                [_styleSubView.downloadBut setImage:[UIImage imageNamed:@"select_set_style"] forState:UIControlStateSelected];
            }
        }else if (isDown == 2){//正在下载
            
            
            //判断是否是正在下载
            for (NSNumber *downTag in FileModel.downStyleIDArr)
            {
                if ([downTag integerValue] == _styleSubView.tag) {
                    _styleSubView.downloadBut.hidden = YES;
                    _styleSubView.progress.hidden = YES;
                    _styleSubView.delectBut.hidden = NO;
                    _styleSubView.textLab.hidden = NO;
                }
                
                if (FileModel.isHomeDown) {
                    [self showDownloadSchedule:FileModel.styleOperation[0] isHomeDown:YES];
                }
            }
        }
        else if (isDown == 3){//重新下载
            [_styleSubView.downloadBut setImage:[UIImage imageNamed:@"reDownStyle"] forState:UIControlStateNormal];
        }
        
        
        [_styleSubView.downloadBut addTarget:self action:@selector(didSelectTypeViewIndex:) forControlEvents:UIControlEventTouchUpInside];
        [_styleSubView.delectBut addTarget:self action:@selector(didDelectDownLoadData:) forControlEvents:UIControlEventTouchUpInside];
        
        
       
        [_styleImage release];
        [_styleSubView release];
        
       
        //[self showStyleBigimage:styleBgView size:_styleImage.frame styleID:[arr[i][@"styleId"] integerValue]];
    }
    [styleBgView release];
    //设置每一个View上下滑动范围
    styleBgView.contentSize = CGSizeMake(320, sizeH+20);
}
//刷新风格UI显示以选中模板
- (void)didWillLoadView
{
    for (HomeStyleBgViewSubView *subView in FileModel.downStyleArr) {
        if (subView.tag == FileModel.styleID) {
            [subView.downloadBut setImage:[UIImage imageNamed:@"select_set_style"] forState:UIControlStateNormal];
        }
    }
    if (_styleAllDataArr) {
        [_styleAllDataArr release],_styleAllDataArr = nil;
    }
    _styleAllDataArr = [[NSMutableArray alloc] initWithArray:[StyleListSQL getAllStyleListData]];
}

- (NSInteger)isDownloadStyle:(NSInteger)index
{
    NSInteger isDownLoad = [StyleListSQL getDownLoadState:index];
    return isDownLoad;
}
- (void)didSelectGlideDirection:(int)index
{
    [self didShowSelectViewIndexPath:index];
}

- (void)didShowSelectViewIndexPath:(int)page
{
    pageBag = page;
    [UIView animateWithDuration:0.3 animations:^{
        _lineImage.frame = CGRectMake(_lineImage.frame.size.width*page, 35, _lineImage.frame.size.width, 3);
    }];

    [_myScrollView setContentOffset:CGPointMake(page*320, 0) animated:YES];
    if (page>3) {
        [_titleScrollView setContentOffset:CGPointMake(_lineImage.frame.size.width, 0) animated:YES];
    }else if (page ==3)
    {
        [_titleScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
}

#pragma mark ScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView ==_myScrollView) {
        CGFloat pageViewWidth = _myScrollView.frame.size.width;
        int page = floor((_myScrollView.contentOffset.x - pageViewWidth / 2) / pageViewWidth) + 1;
        [self didSelectGlideDirection:page];
    }
}
- (void)didSelectStyleBoad
{//这里默认是第二套
    for (HomeStyleBgViewSubView *subView in FileModel.downStyleArr) {
        if (subView.tag == 2) {
            FileModel.downStyleBut = subView.downloadBut;
            subView.downloadBut.selected = YES;
            //修改默认styleID
            _selectStyle = [NSString stringWithFormat:@"%d",subView.tag];
            [self succeedSelectStyleBoad];
        }
    }
}

- (void)didSelectTypeViewIndex:(DownLoadButton *)but
{
    //判断是否是已下载，如果已下载就选为设定风格
    NSInteger isDown = [self isDownloadStyle:but.tag];
    if (isDown ==1) {
        if (but == FileModel.downStyleBut) {
            but.selected = !but.selected;
            if (!but.selected) {
                [self didSelectStyleBoad];
            }
        }else{
            FileModel.downStyleBut.selected = NO;
            but.selected = YES;
            if (but.selected) {
                _selectStyle = [NSString stringWithFormat:@"%d",but.tag];
                if ([Utilities checkNetwork]) {
                    [self loadDataRequest:_selectStyle];
                }else{
                    [self succeedSelectStyleBoad];
                    [[SavaData shareInstance] savadataStr:[_selectStyle copy] KeyString:offLineStyle];
                    [[SavaData shareInstance] savaDictionary:@{@"offStyleHome":_selectStyle,@"pageBag":@(pageBag)} keyString:@"OFFLINESTYLE"];
                }
            }
            FileModel.downStyleBut = but;
        }
        return;
    }
    
    [self isNetWork:but];
}
    
- (void)isNetWork:(DownLoadButton *)but
{
    //判断网络是否是2G/3G 给提示
    NSString *message = @"当前使用的网络链接类型是WWAN（2G/3G）";
    NSString *strNetwork = [Utilities GetCurrntNet];
    if ([strNetwork isEqualToString:@"没有网络链接"]) {
        [self networkPromptMessage:@"没有网络链接"];
        return;
        
    }
    else if ([strNetwork isEqualToString:message]) {
        FileModel.downStyleBut = but;
        NSString *strMeg = @"当前使用的网络链接类型是WWAN（2G/3G），是否确定下载模板";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:strMeg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alert.tag = 100;
        [alert show];
        [alert release];
    }else if ([strNetwork isEqualToString:@"1"])
    {
        //判断该模板是否是正在下载，主要区别与家园中的下载
        if (FileModel.styleOperation.count >0 ) {
            StyleSendOperation *operation = [FileModel.styleOperation objectAtIndex:0];
            if ( operation.indexHome==1 && but.tag == [_selectStyle integerValue]) {
                [self networkPromptMessage:@"该模板正在处理，请稍等"];
            }else{//下载风格模板
                [self beginDownloadTypeBoad:but];
            }
        }else{
            [self beginDownloadTypeBoad:but];
        }
        
    }

}
- (void)showProgressView:(NSInteger)temp
{
    for (HomeStyleBgViewSubView *subView in FileModel.downStyleArr)
    {
        if (subView.tag == temp) {
            subView.delectBut.hidden = NO;
             subView.progress.hidden = NO;
            [FileModel.downStyleIDArr addObject:@(temp)];
            
            if (FileModel.downStyleIDArr.count >1) {
                subView.progress.hidden = YES;
                subView.textLab.hidden = NO;
            }
        }
    }
}
//开始下载模板  
- (void)beginDownloadTypeBoad:(DownLoadButton *)but
{
    [StyleListSQL addDownLoadList:[_styleAllDataArr[pageBag][@"styles"][but.ID][@"styleId"] integerValue]];
    but.hidden = YES;
    //显示相对应的进度条
    [self showProgressView:but.tag];
    
    StyleSendOperation *operation = [[StyleSendOperation alloc] initWithStyleSendOperation:_styleAllDataArr[pageBag][@"styles"][but.ID]];
    operation.indexHome = 0;
    if (FileModel.styleOperation.count ==0)
    {
        [operation main];
        [FileModel.styleOperation addObject:operation];
    }else{
        //如果还在点击下载，把下载添加到数组，形成下载队列
        [FileModel.styleOperation addObject:operation];
    }
    
    [self showDownloadSchedule:operation isHomeDown:NO];
    [operation release];
}

- (void)showDownloadSchedule:(StyleSendOperation *)operation isHomeDown:(BOOL)isDown
{
    operation.didDownStyleProgressBlock = ^(long long pro,long long gre)
    {
        float flo = [CommonData getProgress:gre currentSize:pro];
        //应该是记住正在下载的进度条
        for (HomeStyleBgViewSubView *downStyle in FileModel.downStyleArr) {
            if (downStyle.tag == FileModel.styleID) {
                downStyle.textLab.hidden = YES;
                downStyle.progress.hidden = NO;
                downStyle.progress.progress = flo;
                
                if (downStyle.progress.progress ==1) {
                    [downStyle.downloadBut setImage:[UIImage imageNamed:@"select_no_set_style"]  forState:UIControlStateNormal];
                    [downStyle.downloadBut setImage:[UIImage imageNamed:@"select_set_style"] forState:UIControlStateSelected];
                    downStyle.downloadBut.hidden = NO;
                    //downButton = subView.downloadBut;
                    downStyle.progress.hidden = YES;
                    downStyle.delectBut.hidden = YES;
                    
                    if (isDown) {
                        [downStyle.downloadBut setSelected:YES];
                    }
                }
            }
        }
        
    };

}
- (void)shwoDownloadViewButton:(NSInteger)index
{
    //由对应styleID来找到要删除的view
    for (HomeStyleBgViewSubView *downStyle in FileModel.downStyleArr)
    {
        if (downStyle.tag == index)
        {
            downStyle.downloadBut.hidden = NO;
            downStyle.textLab.hidden = YES;
            downStyle.progress.hidden = YES;
            downStyle.delectBut.hidden = YES;
            downStyle.progress.progress =0;
        }
    }
}
//取消下载文件操作
- (void)didDelectDownLoadData:(UIButton *)but
{
    [self shwoDownloadViewButton:but.tag];
    
    //取出对应的请求，并cancel掉
    for ( int i =0;i<FileModel.downStyleIDArr.count;i++ ) {
        NSInteger downIndex = [FileModel.downStyleIDArr[i] integerValue];
        if (but.tag == downIndex) {
            StyleSendOperation *operation = FileModel.styleOperation[i];
            [operation.styleRequest cancel];
            [operation.styleRequest clearDelegatesAndCancel];
            [operation isCancelled];
            [FileModel.styleOperation removeObject:operation];
            
            if (FileModel.styleID == but.tag)
            {//判断是否是正在下载的文件名字，这里只是删除正在下载的临时文件
                [self delectDocumentTempDirectoryFile];
            }
            
            //如果删除正在下载的再继续下载下一个，否则不处理
            if (FileModel.styleID == but.tag &&FileModel.styleOperation.count >0 && [FileModel.styleOperation[0] isKindOfClass:[StyleSendOperation class]]){
                operation = FileModel.styleOperation[0];
                [operation main];
            }
            
            [FileModel.downStyleIDArr removeObject:@(but.tag)];

        }
    }

}


//下载过程中的临时文件
- (void)delectDocumentTempDirectoryFile
{
    NSString *targetPath = [[CommonData getTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",FileModel.downStyleName]];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    
    if ([CommonData isExistFile:targetPath]) {
        [fileManager removeItemAtPath:targetPath error:&error];
        if (!error) {
        }
    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==100) {
        if (buttonIndex ==1) {
            [self beginDownloadTypeBoad:(DownLoadButton *)FileModel.downStyleBut];
        }
    }else if (alertView.tag ==110)
    {
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
    }
    
}
- (void)loadDataRequest:(NSString *)style
{
    NSURL *url = [[RequestParams sharedInstance] getHomeStyleList];
    if ([style integerValue] == 0) {
        _request = [[ASIFormDataRequest alloc] initWithURL:url];
        [_request setRequestMethod:@"POST"];
        [_request setDelegate:self];
        [_request setPostValue:@"ios" forKey:@"web"];
        [_request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
        [_request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
        [_request setPostValue:@"typelist" forKey:@"operation"];
        [_request setUserInfo:@{@"tag":@"0"}];
        
        [_request setTimeOutSeconds:20];
        [_request setShouldAttemptPersistentConnection:NO];
        [_request startAsynchronous];
    }else
    {
        _request2 = [[ASIFormDataRequest alloc] initWithURL:url];
        [_request2 setRequestMethod:@"POST"];
        [_request2 setDelegate:self];
        [_request2 setPostValue:@"ios" forKey:@"web"];
        [_request2 setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
        [_request2 setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
        [_request2 setPostValue:@"set" forKey:@"operation"];
        [_request2 setPostValue:style forKey:@"favoriteStyle"];
        [_request2 setUserInfo:@{@"tag":@"1"}];
        
        [_request2 setTimeOutSeconds:20];
        [_request2 setShouldAttemptPersistentConnection:NO];
        [_request2 startAsynchronous];
    }

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    NSDictionary *dic = [data objectFromJSONData];
    
    NSInteger tag = [request.userInfo[@"tag"] integerValue];
    if ([dic[@"errorcode"] intValue] == 1005)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = 110;
        [alertView show];
        [alertView release];
    } else if ([dic[@"errorcode"] intValue] == 9000)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = 110;
        [alertView show];
        [alertView release];
    }else if (tag ==0) {
        if (_styleAllDataArr.count>0) {
            [_styleAllDataArr removeAllObjects];
        }
        _styleAllDataArr = [dic[@"data"] mutableCopy];
        if (_styleAllDataArr.count>0 && [_styleAllDataArr isKindOfClass:[NSMutableArray class]]) {
            //默认前1套模板已经下载
            [StyleListSQL addDownLoadList:[_styleAllDataArr[0][@"styles"][0][@"styleId"] integerValue]];
            [StyleListSQL updateDownLoadState:[_styleAllDataArr[0][@"styles"][0][@"styleId"] integerValue]];
            //[StyleListSQL addDownLoadList:[_styleAllDataArr[1][@"styles"][0][@"styleId"] integerValue]];
            //[StyleListSQL updateDownLoadState:[_styleAllDataArr[1][@"styles"][0][@"styleId"] integerValue]];
            
            
            if (isShowUI) {
                //开始刷新UI
                [self drawStyleListButton:_styleAllDataArr];
            }
            
            //[self cleanSubviewsScrollView];
           
            //把数据存入本地
            [self saveStyleListData:_styleAllDataArr];
            //[self loadDataRequest:_styleArr[0][@"sid"]];
        }
    }else if (tag ==1)
    {
        [self networkPromptMessage:dic[@"message"]];
        [self succeedSelectStyleBoad];        
    }
    

}
//清掉缓存View
- (void)cleanSubviewsScrollView
{
    for(id obj in _titleScrollView.subviews){
        [obj removeFromSuperview];
    }
    for(id obj in _myScrollView.subviews){
        [obj removeFromSuperview];
    }
    //清除缓存数据
    [FileModel.downStyleArr removeAllObjects];
}
- (void)succeedSelectStyleBoad
{
    NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithDictionary:[SavaData parseDicFromFile:User_File]];
    [userDic setObject:_selectStyle forKey:@"favoriteStyle"];
    [SavaData writeDicToFile:[userDic retain] FileName:User_File];
    
    NSMutableArray *arrData = _styleAllDataArr[pageBag][@"styles"];
    for (NSDictionary *dic in arrData) {
        if ([dic[@"styleId"] integerValue] == [_selectStyle integerValue]) {
            NSString *styleId = [NSString stringWithFormat:@"style%@",dic[@"styleId"]];
            [[SavaData shareInstance] savadataStr:styleId KeyString:@"styleId"];
            [[SavaData shareInstance] savadataStr:dic[@"zipname"] KeyString:@"specificStyle"];
            
        }
    }
    [[SavaData shareInstance] savadataStr:_selectStyle KeyString:[NSString stringWithFormat:@"%@homeStyle",PUBLICUID]];
    //[[NSUserDefaults standardUserDefaults] setValue:_selectStyle forKey:[NSString stringWithFormat:@"%@homeStyle",PUBLICUID]];

}
- (void)saveStyleListData:(NSMutableArray *)arrData
{
    [StyleListSQL saveAllStyleListData:arrData andUid:PUBLICUID];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self networkPromptMessage:@"网络连接异常"];
}
- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return NO;
}

- (void)viewDidUnload {
    [self setMyScrollView:nil];
    [self setTitleScrollView:nil];
    [super viewDidUnload];
}
    
//无网时，风格模板同步处理
+ (void)offLineStyleSelect:(NSString *)styleID
{
    NSURL *url = [[RequestParams sharedInstance] getHomeStyleList];
    ASIFormDataRequest *request3 = [[ASIFormDataRequest alloc] initWithURL:url];
    [request3 setRequestMethod:@"POST"];
    [request3 setDelegate:self];
    [request3 setPostValue:@"ios" forKey:@"web"];
    [request3 setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request3 setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request3 setPostValue:@"set" forKey:@"operation"];
    [request3 setPostValue:styleID forKey:@"favoriteStyle"];
    [request3 setUserInfo:@{@"tag":@"1"}];
    
    [request3 setTimeOutSeconds:20];
    [request3 setShouldAttemptPersistentConnection:NO];
    [request3 setFailedBlock:^(void)
     {
         [MyToast showWithText:@"风格设置同步失败" :200];
     }];
    request3.completionBlock = ^(void){
//        NSData *data = [request3 responseData];
//        NSDictionary *dic = [data objectFromJSONData];
        [StyleSelectListViewCtrl succeedSelectStyleBoadHome];

    };
    [request3 startAsynchronous];

}
+ (void)succeedSelectStyleBoadHome
{
    NSDictionary *dicOff = [[SavaData shareInstance] printDataDic:@"OFFLINESTYLE"];
    NSString *offStyleID = dicOff[@"offStyleHome"];
    NSInteger pageID = [dicOff[@"pageBag"] integerValue];
    NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithDictionary:[SavaData parseDicFromFile:User_File]];
    [userDic setObject:offStyleID forKey:@"favoriteStyle"];
    
    [SavaData writeDicToFile:[userDic retain] FileName:User_File];
    
    NSMutableArray *arrData = [StyleListSQL getAllStyleListData][pageID][@"styles"];
    for (NSDictionary *dic in arrData) {
        if ([dic[@"styleId"] integerValue] == [offStyleID integerValue]) {
            NSString *styleId = [NSString stringWithFormat:@"style%@",dic[@"styleId"]];
            [[SavaData shareInstance] savadataStr:styleId KeyString:@"styleId"];
            [[SavaData shareInstance] savadataStr:dic[@"zipname"] KeyString:@"specificStyle"];
            
        }
    }
    [[SavaData shareInstance] savadataStr:offStyleID KeyString:[NSString stringWithFormat:@"%@homeStyle",PUBLICUID]];
    
}
@end
