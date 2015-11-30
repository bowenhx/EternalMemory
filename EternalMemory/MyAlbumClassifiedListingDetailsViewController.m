//
//  MyAlbumClassifiedListingDetailsViewController.m
//  EternalMemory
//
//  Created by sun on 13-6-6.
//  Copyright (c) 2013年 sun. All rights reserved.
//


#import "MyAlbumClassifiedListingDetailsViewController.h"
#import "UIImage+UIImageExt.h"
#import "PhotoViewController.h"
#import "EditPhotoAlbumsViewController.h"
#import "MyPhotoDetailsViewController.h"
#import "DiaryPictureClassificationSQL.h"
#import "MessageSQL.h"
#import "MessageModel.h"
#import "EternalMemoryAppDelegate.h"
#import "MyToast.h"
#import "UpdatePhotoViewController.h"
#import "UIImage+UIImageExt.h"
#import "MyLifeMainViewController.h"
#import "MAImagePickerFinalViewController.h"
#import "ASINetworkQueue.h"
#import "PhotoUploadEngine.h"
#import "MD5.h"
#import "MyLifeMainViewController.h"
#import "AGImagePickerController.h"
#import "MultiPicUoloaderViewController.h"


#define PHOTO_WIDTH 90
#define PHOTO_HEIGHT 90
#define kCameraToolBarHeight 54
#define PHOTOTEXT @"1"
#define REQUEST_FOR_GETBLOGLIST 100
#define REQUEST_FOR_CHANGEBLOGGROUP 200
#define REQUEST_FOR_DELETBLOG 300
#define REQUEST_FOR_ADDPHOTO 400
@interface MyAlbumClassifiedListingDetailsViewController ()
{
    MBProgressHUD *_mb;
    UILabel *label;
    
    ASINetworkQueue  *_downloadQueue;
    UIActivityIndicatorView *_activityIndicatorView;
    
    
}

@property (nonatomic, retain) IBOutlet UIImageView  *noBlogImg;
@property (nonatomic, retain) IBOutlet UILabel      *noBlogLb;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) UIToolbar         *toolBar;
@property (nonatomic, retain) NSMutableArray    *blogArray;
@property (nonatomic, retain) NSMutableArray    *blogEditArray;

@property (nonatomic, copy)   NSString      *albumTitle;
@property (nonatomic, copy)   NSString      *albumContent;

@property (nonatomic, assign) BOOL  EditingStatus;
@property (nonatomic, assign) BOOL  isEditStyle;


@end

@implementation MyAlbumClassifiedListingDetailsViewController

@synthesize scrollView      = _scrollView;
@synthesize isEditStyle     = _isEditStyle;
@synthesize toolBar         = _toolBar;
@synthesize selectGroupInt  = _selectGroupInt;
@synthesize blogArray       = _blogArray;
@synthesize EditingStatus   = _EditingStatus;
@synthesize blogEditArray   = _blogEditArray;
@synthesize noBlogImg       = _noBlogImg;
@synthesize noBlogLb        = _noBlogLb;
@synthesize selectGroupId   =_selectGroupId;



#pragma mark - object lifecycle
- (void)dealloc
{
    
    if (_downloadQueue)
    {
        [_downloadQueue cancelAllOperations];
        [_downloadQueue release];
    }
    
    RELEASE_SAFELY(_blogArray);
    RELEASE_SAFELY(_scrollView);
    RELEASE_SAFELY(_blogEditArray);
    RELEASE_SAFELY(_noBlogImg);
    RELEASE_SAFELY(_noBlogLb);
    RELEASE_SAFELY(label);
    RELEASE_SAFELY(_model);
    RELEASE_SAFELY(_groupId);
    RELEASE_SAFELY(_activityIndicatorView);
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPhotoGroupChangedNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangePhotoGroupNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"myAlbumClassDetail" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewPhotoAddedNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"myAlbum" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        _isEditStyle = NO;
        _blogEditArray = [[NSMutableArray alloc] init];
        _blogArray=[[NSMutableArray alloc] initWithCapacity:0];
        
    }
    return self;
}

-(void)reloadViewData
{
    [self getPhotosRequest];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    fromPhotoList = YES;
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.bounds = CGRectMake(0, 0, 30, 30);
    _activityIndicatorView.center = self.view.center;
    _activityIndicatorView.hidesWhenStopped = YES;

    [self setViewData];
    
    [self.view addSubview:_activityIndicatorView];
    [_activityIndicatorView startAnimating];
    
    NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];
    NSInteger indexInt  = [self.selectGroupInt integerValue];
    self.model = [groupArray objectAtIndex:indexInt];
    [_blogArray addObjectsFromArray:[MessageSQL getGroupIDMessages:_model.groupId AndUserId:USERID]];

    [self setPhotoes];
    if (![Utilities checkNetwork])
    {
    }
    else
    {
//        __block typeof(self) bself = self;
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getPhotosRequest];
//        });
    }
    
    [Utilities adjustUIForiOS7WithViews:@[_toolBar]];
    
    //TODO by ZGL
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTitleAndContent:) name:@"myAlbum" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPhotoList:) name:kChangePhotoGroupNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupChanged:) name:kPhotoGroupChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadViewData) name:@"myAlbumClassDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPhotoAdded:) name:kNewPhotoAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPhotoAdded:) name:PhotosHaveSuccessfullyUploadedNotification object:nil];
    
}

- (void)newPhotoAdded:(NSNotification *)notification
{
    if (![Utilities checkNetwork]) {
        [self setPhotoes];
        return;
    }
    [self getPhotosRequest];
    
}

/**
 *	根据相册列表显示个图片数量布局照片图标, 待用
 */
//- (void)preloadImageIcon
//{
//    int  viewWide = PHOTO_WIDTH;
//    int  viewHeight = PHOTO_HEIGHT;
//    int row=(_scrollView.frame.size.width-viewWide*3)/4;//行间距
//    int col=(_scrollView.frame.size.width-viewWide*3)/4;//列间距

//    for (int i = 0 ; i < self.blogCount; i ++) {
//        ThumbImageButton *thumbBtn = [[ThumbImageButton alloc] initWithFrame:CGRectMake(row + (row+viewWide)*(i%3), col+(col+viewHeight)*(i/3) + 20 + addPhotoBtn.frame.origin.y + 20, viewWide, viewHeight)];
//        [_scrollView addSubview:thumbBtn];
//        [self.tempThumbButtons addObject:thumbBtn];
//        
//    }
//}

- (void)groupChanged:(NSNotification *)notification
{
    [self setPhotoes];
    [self getPhotosRequest];
    
}

- (void)reloadPhotoList:(NSNotification *)notification
{
    
    _toolBar.hidden = YES;
    _EditingStatus = NO;
    
    [self isViewLoaded];
    NSMutableArray *gropIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (MessageModel *model in self.blogEditArray) {
        NSString *blogId = model.blogId;
        if (blogId.length == 0)
        {
            continue;
        }
        [gropIds addObject:blogId];
    }
    
    
    NSString *ids = [gropIds componentsJoinedByString:@","];

    DiaryPictureClassificationModel *model = notification.object;
    NSString *groupId = model.groupId;
    BOOL flag = [Utilities checkNetwork];
    if (flag) {
        [self changeBlogGroupRequest:ids toGroup:groupId];
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    for (MessageModel *model in self.blogEditArray) {
        
        if (model.blogId.length > 0)
        {
            model.deletestatus = NO;
            model.status = @"4";
            model.groupId = groupId;
            
        }
        else
        {
            model.deletestatus = NO;
            model.groupId = groupId;
        }
        [arr addObject:model];
    }
    
    NSString *desGroupId = [groupId copy];
    NSString *srcGroupId = [_selectGroupId copy];
    
    [MessageSQL  refershMessagesByMessageModelArray:arr];
    
    [self updateDBDataWhenMovingBlogFromSrcGroup:srcGroupId toDesGroupId:desGroupId ];
    
    [self.blogEditArray removeAllObjects];
    [self setPhotoes];
    
    [desGroupId release];
    [srcGroupId release];
    [gropIds    release];
    [arr        release];
    
}

- (void)updateDBDataWhenMovingBlogFromSrcGroup:(NSString *)srcGroupId toDesGroupId:(NSString *)desGroupId
{
    DiaryPictureClassificationModel *srcModel = [DiaryPictureClassificationSQL getDiaryModelByGroupId:srcGroupId WithUserID:USERID];
    NSInteger srcBlogCount = [srcModel.blogcount integerValue] - self.blogEditArray.count;
    NSString  *srcLastestPhotoUrl = nil;
    MessageModel *messageModel = nil;

    self.blogArray = [MessageSQL getGroupIDMessages:_selectGroupId AndUserId:USERID];
    (self.blogArray.count > 0) ? (messageModel = self.blogArray[0]) : (messageModel = nil);
    srcLastestPhotoUrl = messageModel.attachURL;
    srcModel.latestPhotoURL = srcLastestPhotoUrl;
    srcModel.latestPhotoPath = messageModel.spaths;
    srcModel.blogcount = [NSString stringWithFormat:@"%d",srcBlogCount];
    [DiaryPictureClassificationSQL updateDiaryWithArr:@[srcModel]WithUserID:USERID];
    
    MessageModel *desMessageModel = nil;
    self.blogEditArray.count > 0 ? (desMessageModel = self.blogEditArray[0]):(desMessageModel = nil);
    DiaryPictureClassificationModel *desModel = [DiaryPictureClassificationSQL getDiaryModelByGroupId:desGroupId WithUserID:USERID];
    NSInteger desBlogCount = [desModel.blogcount integerValue] + self.blogEditArray.count;
    desModel.latestPhotoURL = desMessageModel.attachURL;
    desModel.latestPhotoPath = desMessageModel.spaths;
//    MessageModel *desMessageModel = self.blogEditArray[0];
//    desModel.latestPhotoPath = desMessageModel.spaths;
    desModel.blogcount = [NSString stringWithFormat:@"%d",desBlogCount];
    [DiaryPictureClassificationSQL updateDiaryWithArr:@[desModel]WithUserID:USERID];
}

-(void)reloadTitleAndContent:(NSNotification *)obj
{
    NSDictionary *dic=[obj object];
    NSString *content = [[dic objectForKey:@"albumContent"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    CGSize size = [content sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width, 300)];
    self.titleLabel.text = [dic objectForKey:@"albumName"] ;
    label.frame = (CGRect){
        .origin.x = label.frame.origin.x,
        .origin.y = label.frame.origin.y,
        .size.width     = size.width,
        .size.height    = size.height + 20
    };
    label.text = [dic objectForKey:@"albumContent"];
    
}
- (void)didReceiveMemoryWarning
{
    [_blogArray removeAllObjects];
    [_blogEditArray removeAllObjects];
    _scrollView = nil;
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
    }
    
    [super didReceiveMemoryWarning];
    
    
//    [_blogArray removeAllObjects];
//    [_blogArray release];
//    _blogArray = nil;
    
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
- (void)backBtnPressed
{
//    [_downloadQueue cancelAllOperations];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightBtnPressed
{
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//#warning 测试提示条
//    NTPrompView *promptView = [[NTPrompView alloc] initWithMessage:@"正在上传..."];
//    [promptView show];
//    [promptView release];
//    return;
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    
    if ([self.rightBtn.titleLabel.text isEqualToString:@"完成"]) {
        _isEditStyle = NO;
        _toolBar.hidden = YES;
        [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [self.blogEditArray removeAllObjects];
        [self setPhotoes];
    }
    else
    {
        NSString *slectGroupID =  [NSString stringWithFormat:@"%@",self.model.groupId];
        if ([slectGroupID isEqualToString:@"0"]) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle: nil otherButtonTitles:@"批量编辑照片" , nil];
            actionSheet.tag = 100;
            [actionSheet showInView:self.view];
            [actionSheet release];
        }
        else
        {
            if (self.blogArray.count == 0)
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle: nil
                                                               otherButtonTitles:@"编辑相册", nil];
                actionSheet.tag = 101;
                [actionSheet showInView:self.view];
                [actionSheet release];
            }
            else
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle: nil
                                                               otherButtonTitles:@"编辑相册",@"批量编辑照片" , nil];
                actionSheet.tag = 101;
                [actionSheet showInView:self.view];
                [actionSheet release];
            }
        }
    }
}
- (void)setViewData
{
    // nevBar
    NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];

    NSInteger indexInt  = [_selectGroupInt integerValue];

    DiaryPictureClassificationModel *model = [groupArray objectAtIndex:indexInt];
    self.rightBtn.hidden                   = NO;
    self.middleBtn.hidden                  = YES;
    self.titleLabel.text                   = model.title;
    [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [self setupToolbar];
    _toolBar.hidden                        = YES;

    //addWordLable
    label               = [[UILabel alloc] initWithFrame:CGRectMake(13, 15, 295, 20)];
    label.font          = [UIFont boldSystemFontOfSize:14.0f];
    label.numberOfLines = 0;
    label.textColor     = RGBCOLOR(118.0, 131.0, 141.0);;
    label.textAlignment = NSTextAlignmentLeft;
    [label setBackgroundColor:[UIColor clearColor]];
    
}
- (void)onAddBtnClicked
{
    
    if (_isEditStyle) {
        [MyToast showWithText:@"编辑状态下不可以上传照片。如果想要上传照片，请先点击“完成”取消编辑状态。" :130];
        return;
    }
    
    fromPhotoList = YES;

    NSInteger a=[[SavaData shareInstance] printData:HOME_STATUS];

    if (a == 2) {
        [[SavaData shareInstance] savaData:4 KeyString:HOME_STATUS];
    }else{
        [[SavaData shareInstance] savaData:1 KeyString:HOME_STATUS];
    }
    
    [self initWithImagePickerController:1];
    return;
//    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                  initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
//    actionSheet.tag = 1000;
//    [actionSheet showInView:self.view];
//    [actionSheet release];
    
}
- (void)setPhotoes
{
    
    __block typeof(self) this = self;
    
    if (_activityIndicatorView.isAnimating) {
        [_activityIndicatorView stopAnimating];
    }
    
    while (this.scrollView.subviews.count) {
        UIView* child = this.scrollView.subviews.lastObject;
        [child removeFromSuperview];
    }
    if (_blogArray.count!=0) {
        [_blogArray removeAllObjects];
    }
    [_blogArray addObjectsFromArray:[MessageSQL getMessages:@"1" AndUserId:USERID]];
    
    NSString *str = _model.remark;
    CGSize size = [str sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    [label setFrame:CGRectMake(13, 15, 295, size.height)];
    label.text = str;
//    [_scrollView addSubview:label];
//添加上传图片button
//    UIButton *addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    addPhotoBtn.frame = CGRectMake(10, - 50, 300, 42);
//    [addPhotoBtn setTitle:@"上传照片" forState:UIControlStateNormal];
//    [addPhotoBtn setBackgroundImage:[UIImage imageNamed:@"bt_lv"] forState:UIControlStateNormal];
//    [addPhotoBtn addTarget:this action:@selector(onAddBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    if (size.height > 0 ) {
//        [addPhotoBtn setFrame:CGRectMake(10, size.height + 30, 300, 42)];
//        
//    }else{
//        [addPhotoBtn setFrame:CGRectMake(10, 20 , 300, 42)];
//    }
   
//    [self.view insertSubview:_noBlogImg aboveSubview:_scrollView];
    [_scrollView addSubview:_noBlogImg];
    [_scrollView addSubview:_noBlogLb];
//    [_scrollView addSubview:addPhotoBtn];
//    [_scrollView bringSubviewToFront:addPhotoBtn];
//    [addPhotoBtn release];
    //add photoImage
    int  viewWide   = PHOTO_WIDTH;
    int  viewHeight = PHOTO_HEIGHT;
    int row=(_scrollView.frame.size.width-viewWide*3)/4;//行间距
    int col=(_scrollView.frame.size.width-viewWide*3)/4;//列间距
    
    int photoCount = [this.blogArray count];
    if (photoCount == 0) {
        _noBlogImg.hidden = NO;
        _noBlogLb.hidden = NO;
        
    }else{
        _noBlogImg.hidden = YES;
        _noBlogLb.hidden = YES;
    }
    
    
    _downloadQueue = [[ASINetworkQueue alloc] init];
    [_downloadQueue setRequestDidFinishSelector:@selector(imageFatchComplete:)];
    [_downloadQueue setDelegate:this];
    
    for (int i=0; i<photoCount; i++) {
        
        ThumbImageButton *thumbBtn = [[ThumbImageButton alloc] initWithFrame:CGRectMake(row + (row+viewWide)*(i%3), col+(col+viewHeight)*(i/3) + 10, viewWide, viewHeight)];
        thumbBtn.tag = i + 100;
        [thumbBtn addTarget:self action:@selector(getPhotoView:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:thumbBtn];
        
        MessageModel *blogModel = [self.blogArray objectAtIndex:i];
        NSString *imageName = [NSString stringWithFormat:@"simg_%@.png",blogModel.thumbnail];
        NSString *localImageName = [MD5 md5:imageName];
        NSString *path = [Utilities dataPath:localImageName FileType:@"Photos" UserID:USERID];
        UIImage *sImg = nil;
        
        if(blogModel.spaths.length != 0)
        {
            sImg = [ UIImage imageWithContentsOfFile: blogModel.spaths];
            [thumbBtn.placeholderImageView setImage: sImg];
            if (!sImg)
            {
                sImg = [ UIImage imageWithContentsOfFile: path];
                [thumbBtn.placeholderImageView setImage: sImg];
            }
        }
        

        
        if (!sImg) 
        {
            NSURL *url               = [NSURL URLWithString:blogModel.thumbnail];
            NSString *imageName      = [NSString stringWithFormat:@"simg_%@.png",blogModel.thumbnail];
            NSString *localImageName = [MD5 md5:imageName];
            NSString *path           = [Utilities dataPath:localImageName FileType:@"Photos" UserID:USERID];
            
            ASIHTTPRequest *downloadImageRequest = [[ASIHTTPRequest alloc] initWithURL:url];
            int tagValue                         = i+100;
            [downloadImageRequest setDownloadDestinationPath:path];
            [downloadImageRequest setUserInfo:@{@"tag":[NSNumber numberWithInt:tagValue], @"object":thumbBtn,@"path":path,@"blogModel":blogModel}];
            [_downloadQueue addOperation:downloadImageRequest];
            [downloadImageRequest release];
        }
        
        [thumbBtn release];
    }
    
    if (_downloadQueue.operations.count > 0) {
        [_downloadQueue go];
    }
    
    [_scrollView setContentSize:CGSizeMake(320.0,col+(col+viewHeight)*(photoCount/3) + 20 +size.height + 200)];
}

- (void)imageFatchComplete:(ASIHTTPRequest *)request
{
    
    
    NSData *data = [NSData dataWithContentsOfFile:[request downloadDestinationPath]];

    __block ThumbImageButton *pVc = request.userInfo[@"object"];
    MessageModel *model = request.userInfo[@"blogModel"];
    NSString *imgPath = request.userInfo[@"path"];

    UIImage *image = [UIImage imageWithData:data];
//    image = [image croppedImage:CGRectMake(0, 0, 180, 180)];
    //image = [image fixOrientation];
    if (image) {
        [pVc.placeholderImageView setImage:image];
    }
    pVc.placeholderImageView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        pVc.placeholderImageView.alpha = 1;
    }];
    
    model.spaths = imgPath;
    
    [MessageSQL updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
        NSString *u_sql = [NSString stringWithFormat:@"update %@ set spaths = ? where blogId = ?", tableName];
        [db executeUpdate:u_sql, model.spaths, model.blogId];
    } WithUserID:USERID];
}

- (void)imageFatchfailure:(ASIHTTPRequest *)request
{
}

//- (void)addImg{
//    int photoCount = [self.blogArray count];
//    for (int i=0; i<photoCount; i++) {
//        MessageModel *blogModel = [self.blogArray objectAtIndex:i];
//        _selectGroupId = blogModel.groupId;
//        if (blogModel.spaths.length!=0&&(NSNull *)blogModel.spaths!=[NSNull null]) {
//            UIImage *sImg = [ UIImage imageWithContentsOfFile: blogModel.spaths];
//            [_photoViewController.photoImage setImage: sImg];
//            
//        }else{
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSString *imgUrlStr = [NSString stringWithFormat:@"%@",blogModel.thumbnail];
//                NSURL * url = [NSURL URLWithString:imgUrlStr];
//                NSData * data = [[NSData alloc]initWithContentsOfURL:url];
//                UIImage *image = [[UIImage alloc]initWithData:data];
//                if (data != nil) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [_photoViewController.photoImage setImage: image];
//                    });
//                }
//            });
//            
//        }
//    }
////    [_mb hide:YES];
//    
//}
- (void)setupToolbar
{
    int viewHeight = 460;
    if (iPhone5) {
        viewHeight = 548;
    }
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewHeight - kCameraToolBarHeight, self.view.bounds.size.width, kCameraToolBarHeight)];
    [_toolBar setBackgroundImage:[UIImage imageNamed:@"camera-bottom-bar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
//    UIBarButtonItem *moveButton = nil;
    UIBarButtonItem *deleteButton = nil;
    if (iOS7)
    {
//        UIButton *moveButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
//        moveButton1.frame = CGRectMake(0, 0, 46, 46);
//        [moveButton1 setImage:[UIImage imageNamed:@"bj_yd"] forState:UIControlStateNormal];
//        moveButton1.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 20, 0);
//        [moveButton1 setTitle:@"移动" forState:UIControlStateNormal];
//        [moveButton1 addTarget:self action:@selector(moveImages) forControlEvents:UIControlEventTouchUpInside];
//        [moveButton1 setTitleEdgeInsets:UIEdgeInsetsMake(20, -20, 0, 0)];
//        [moveButton1.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
//        moveButton = [[UIBarButtonItem alloc] initWithCustomView:moveButton1];
//        
        UIButton *deleteButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton1.frame = CGRectMake(0, 0, 46, 46);
        [deleteButton1 setImage:[UIImage imageNamed:@"bj_del"] forState:UIControlStateNormal];
        deleteButton1.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 20, 0);
        [deleteButton1 setTitle:@"删除" forState:UIControlStateNormal];
        [deleteButton1 addTarget:self action:@selector(deleteImages) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton1 setTitleEdgeInsets:UIEdgeInsetsMake(20, -20, 0, 0)];
        [deleteButton1.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
        deleteButton = [[UIBarButtonItem alloc] initWithCustomView:deleteButton1];
    }
    else
    {
//        moveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bj_yd"] style:UIBarButtonItemStylePlain target:self action:@selector(moveImages)];
//        moveButton.title = @"移动" ;
//        moveButton.accessibilityLabel = @"Return to Frame Adjustment View";
//        
        deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bj_del"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteImages)];
        deleteButton.title = @"删除";
        deleteButton.accessibilityLabel = @"Confirm adjusted Image";
    }

//    UIBarButtonItem *moveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bj_yd"] style:UIBarButtonItemStylePlain target:self action:@selector(moveImages)];
//    moveButton.title = @"移动" ;
//    moveButton.accessibilityLabel = @"Return to Frame Adjustment View";
//        
//    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bj_del"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteImages)];
//    deleteButton.title = @"删除";
//    deleteButton.accessibilityLabel = @"Confirm adjusted Image";
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixedSpace setWidth:77.0f] ;

    [_toolBar setItems:[NSArray arrayWithObjects:flexibleSpace,deleteButton,flexibleSpace, nil]];
    
    [self.view addSubview:_toolBar];
    [flexibleSpace release];
    [fixedSpace release];
}
#pragma mark - http
- (void)getPhotosRequest
{
//    NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT];
//    NSInteger indexInt  = [self.selectGroupInt integerValue];
//    DiaryPictureClassificationModel *model = [groupArray objectAtIndex:indexInt];
    NSURL *registerUrl = [[RequestParams sharedInstance] photolist];
    _formRequest = [[ASIFormDataRequest alloc] initWithURL:registerUrl] ;
    _formRequest.delegate = self;
    _formRequest.shouldAttemptPersistentConnection = NO;
    _formRequest.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_GETBLOGLIST],@"tag", nil] ;
    [_formRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_formRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_formRequest setPostValue:self.selectGroupId forKey:@"groupid"];
    [_formRequest setRequestMethod:@"POST"];
    [_formRequest setTimeOutSeconds:30.0];
    __block typeof(self) bself = self;
    [_formRequest setCompletionBlock:^{
        [bself requestSuccess:_formRequest];
    }];
    [_formRequest setFailedBlock:^{
        [bself requestFail:_formRequest];
    }];
    [_formRequest startAsynchronous];
    [_formRequest release];
   
}
- (void)changeBlogGroupRequest:(NSString *)blogid toGroup:(NSString *)groupid
{
    NSURL *registerUrl = [[[RequestParams sharedInstance] changeBlogGroup] retain];
    _formRequest = [[ASIFormDataRequest alloc] initWithURL:registerUrl] ;
    [registerUrl release];
    _formRequest.delegate = self;
    _formRequest.shouldAttemptPersistentConnection = NO;
    _formRequest.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_CHANGEBLOGGROUP],@"tag", nil]  ;
    [_formRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_formRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_formRequest setPostValue:groupid forKey:@"groupid"];
    [_formRequest setPostValue:blogid forKey:@"blogid"];
    [_formRequest setRequestMethod:@"POST"];
    [_formRequest setTimeOutSeconds:30.0];
    __block typeof(self) bself = self;
    [_formRequest setCompletionBlock:^{
        [bself requestSuccess:_formRequest];
    }];
    [_formRequest setFailedBlock:^{
        [bself requestFail:_formRequest];
    }];
    [_formRequest startAsynchronous];
    [_formRequest release];
   
}
- (void)deleteBlogsReauest:(NSString *)blogArrayStr
{
    NSURL *registerUrl = [[[RequestParams sharedInstance] deletePhoto] retain];
    _formRequest = [[ASIFormDataRequest alloc] initWithURL:registerUrl];

    _formRequest.shouldAttemptPersistentConnection = NO;
    _formRequest.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_DELETBLOG],@"tag", nil];
    [_formRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_formRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_formRequest setPostValue:blogArrayStr forKey:@"blogid"];
    [_formRequest setRequestMethod:@"POST"];
    [_formRequest setTimeOutSeconds:30.0];
    __block typeof(self) bself = self;
    [_formRequest setCompletionBlock:^{
        [bself requestSuccess:_formRequest];
    }];
    [_formRequest setFailedBlock:^{
        [bself requestFail:_formRequest];
    }];
    [_formRequest startAsynchronous];
    [_formRequest release];
    [registerUrl release];
   
}
- (void)addPhotoRequest:(MessageModel *)blog
{
    NSURL *registerUrl = [[[RequestParams sharedInstance] uploadPhoto] retain];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:registerUrl];
    [registerUrl release];
    request.shouldAttemptPersistentConnection = NO;
    request.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_ADDPHOTO],@"tag", nil];
    [request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [request setPostValue:PHOTOTEXT forKey:@"blogtype"];
    [request setPostValue:blog.groupId forKey:@"groupid"];
    [request setPostValue:blog.content forKey:@"content"];
    [request setPostValue:[NSString stringWithFormat:@"%d",blog.ID] forKey:@"clientid"];
    [request setFile:blog.paths forKey:@"upfile"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:15.0];
    __block typeof(self) bself = self;
    [request setCompletionBlock:^{
        [bself requestSuccess:request];
    }];
    [request setFailedBlock:^{
        [bself requestFail:request];
    }];
    [request startAsynchronous];
    [request release];
    
}

#pragma mark - toolBarBtn
- (void)moveImages
{
    if ([self.blogEditArray count] == 0) {
        [MyToast showWithText:@"请选择要移动的照片" :[UIScreen mainScreen].bounds.size.height/2-40];
        
    }else{
        
        
        PhotoAlbumsViewController *photoAlbumsViewController = [[PhotoAlbumsViewController alloc] init ];
        photoAlbumsViewController.isSeletedStyle = YES;
//        photoAlbumsViewController.selectListCategoriesDelegate = self;
//        photoAlbumsViewController.clissifyVC = self;
//        [self.navigationController pushViewController:photoAlbumsViewController animated:YES];
        [self presentViewController:photoAlbumsViewController animated:YES completion:nil];
        RELEASE_SAFELY(photoAlbumsViewController);
        
    }
}
- (void)deleteImages
{
    if ([self.blogEditArray count] == 0)
    {
        [MyToast showWithText:@"请选择要删除的照片" :[UIScreen mainScreen].bounds.size.height/2-40];
        return;
    }
    else
    {
        NSMutableArray *refershMessagesArray = [[NSMutableArray alloc] init];
        NSMutableArray *localPhtoAry=[[NSMutableArray alloc] initWithCapacity:0];
        NSMutableString *blogArrayStr = [NSMutableString stringWithFormat:@""];
        for (MessageModel *blogModel in self.blogEditArray) {
            NSDate *date = [NSDate date];
            NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
            NSString *timeStr = [NSString stringWithFormat:@"%f",timestamp];
            blogModel.status = @"3";
            blogModel.deletestatus = YES;
            blogModel.needSyn = YES;
            blogModel.needUpdate = YES;
            blogModel.lastModifyTime = timeStr;
            blogModel.syncTime = timeStr;
            if (blogModel.blogId.length == 0)
            {
                [localPhtoAry addObject:blogModel];//本地有，服务器上没有的，直接从本地删除；
            }
            else
            {
                [refershMessagesArray addObject:blogModel];
                [blogArrayStr appendString:blogModel.blogId];
                [blogArrayStr appendString:@","];
            }
        }
        
        if (localPhtoAry.count!=0)
        {
            [MessageSQL deletePhoto:localPhtoAry];
            _isEditStyle = NO;
            _toolBar.hidden = YES;
            [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
            [self.blogEditArray removeAllObjects];

            
            [MessageSQL  refershMessagesByMessageModelArray:localPhtoAry];
            _isEditStyle = NO;
            _toolBar.hidden = YES;
            for (MessageModel *model in localPhtoAry) {
                NSFileManager *fileMngr = [NSFileManager defaultManager];
                NSData *data = [NSData dataWithContentsOfFile:model.paths];
                if (data.length > 0)
                {
                    [fileMngr removeItemAtPath:model.paths error:nil];
                }
                NSData *sdata = [NSData dataWithContentsOfFile:model.spaths];
                if (sdata.length > 0)
                {
                    [fileMngr removeItemAtPath:model.spaths error:nil];
                }
            }
            [self updateDiaryDBData:self.selectGroupId];
            
        }
        
        [self setPhotoes];
        //需要同步删除
        if (blogArrayStr.length!=0)
        {
            [blogArrayStr deleteCharactersInRange:NSMakeRange(blogArrayStr.length - 1, 1)];
            NSString *networkStr = [Utilities GetCurrntNet];
            //无网
            if ([networkStr isEqualToString:@"没有网络链接"]) {
                // 添加图片
                [MessageSQL  refershMessagesByMessageModelArray:refershMessagesArray];
                _isEditStyle = NO;
                _toolBar.hidden = YES;
                [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
//                [MessageSQL deletePhoto:self.blogEditArray];
                [self.blogEditArray removeAllObjects];
                [self setPhotoes];
                
                [self updateDiaryDBData:self.selectGroupId];
            }
            else
            {
                [self deleteBlogsReauest:blogArrayStr];
            }
        }
        RELEASE_SAFELY(refershMessagesArray);
        RELEASE_SAFELY(localPhtoAry);
    }
}

- (void)updateDiaryDBData:(NSString *)groupId
{
    MessageModel *aModel = nil;
    DiaryPictureClassificationModel *diaryModel = [[DiaryPictureClassificationSQL getDiaryModelByGroupId:groupId WithUserID:USERID] retain];
    
    [_blogArray removeAllObjects];
    [_blogArray addObjectsFromArray:[MessageSQL getGroupIDMessages:groupId AndUserId:USERID]];
    
    if (_blogArray.count > 0)
    {
        aModel = _blogArray[0];
        diaryModel.blogcount = [NSString stringWithFormat:@"%d",_blogArray.count];
        diaryModel.latestPhotoURL = aModel.attachURL;
        diaryModel.latestPhotoPath = aModel.spaths;
        
        [DiaryPictureClassificationSQL updateDiaryWithArr:@[diaryModel]WithUserID:USERID];

    }
    else
    {
        diaryModel.blogcount = [NSString stringWithFormat:@"%d",_blogArray.count];
        diaryModel.latestPhotoURL = nil;
        diaryModel.latestPhotoPath = aModel.spaths;
        [DiaryPictureClassificationSQL updateDiaryWithArr:@[diaryModel]WithUserID:USERID];
        
    }
    
    [diaryModel release];
//    [aModel release];
}


#pragma mark - PhotoAlbumsViewDelegate SelectListCategoriesDelegate
- (void)selectedIndex:(NSInteger)selectedIndex
{
    _toolBar.hidden = YES;
    NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];
    DiaryPictureClassificationModel *groupModel = [groupArray objectAtIndex:selectedIndex];
    NSMutableArray *refershMessagesArray = [[NSMutableArray alloc] init];
    NSMutableArray *localPhtoAry=[[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *blogArrayStr = [NSMutableString stringWithFormat:@""];
    for (MessageModel *blogModel in self.blogEditArray) {
        NSDate *date = [NSDate date];
        NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
        NSString *timeStr = [NSString stringWithFormat:@"%f",timestamp];
        blogModel.groupId = groupModel.groupId;
        blogModel.groupname = groupModel.title;
        blogModel.status = @"4";
        blogModel.deletestatus = NO;
        blogModel.needSyn = YES;
        blogModel.needUpdate = YES;
        blogModel.lastModifyTime = timeStr;
        blogModel.syncTime = timeStr;
        //无blogid
        if (blogModel.blogId.length == 0 ) {
            [localPhtoAry addObject:blogModel];
            
        }else{

            [refershMessagesArray addObject:blogModel];
            [blogArrayStr appendString:blogModel.blogId];
            [blogArrayStr appendString:@","];
        }
        
    }
    //有blogid 情况
    if (blogArrayStr.length!=0) {
        [blogArrayStr deleteCharactersInRange:NSMakeRange(blogArrayStr.length - 1, 1)];
        NSString *networkStr = [Utilities GetCurrntNet];
        if ([networkStr isEqualToString:@"没有网络链接"]) {
            //修改状态用于同步
            [MyToast showWithText:@"无网络连接" :380];
            [MessageSQL  refershMessagesByMessageModelArray:refershMessagesArray];
            _isEditStyle = NO;
            _toolBar.hidden = YES;
            [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
            [self.blogEditArray removeAllObjects];
            [self setPhotoes];
        }else{
            //有网络请求网络修改信息 成功后刷新
            [self changeBlogGroupRequest:blogArrayStr toGroup:groupModel.groupId];
        }
    }
    if ([localPhtoAry count] != 0) {
        NSString *networkStr = [Utilities GetCurrntNet];
        if ([networkStr isEqualToString:@"没有网络链接"]) {
            //修改状态用于同步
            [MyToast showWithText:@"无网络连接" :380];
            [MessageSQL  refershMessagesByMessageModelArray:localPhtoAry];
            _isEditStyle = NO;
            _toolBar.hidden = YES;
            [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
            [self.blogEditArray removeAllObjects];
            [self setPhotoes];
        }else{
            //有网络请求网络修改信息
            for (MessageModel *blog in localPhtoAry) {
                [self addPhotoRequest:blog];
            }
        }
    }
    RELEASE_SAFELY(refershMessagesArray);
    RELEASE_SAFELY(localPhtoAry);
    
}


#pragma mark - PhotoViewDelegate
- (void)getPhotoView:(ThumbImageButton *)btn
{
    NSInteger index = btn.tag - 100;
    MessageModel *blogModel = [self.blogArray objectAtIndex:index];
    if (_isEditStyle) {
        
        btn.isChecked = !btn.isChecked;
        
        btn.isChecked ?
            ([self.blogEditArray addObject:blogModel]) :
            ([self.blogEditArray removeObject:blogModel]);
        
    }else{
        
        //MyPhotoDetailsViewController
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setPhotoes" object:nil];
        MyPhotoDetailsViewController *myPhotoDetailsViewController = [[MyPhotoDetailsViewController alloc] init ];
        myPhotoDetailsViewController.selectPhotoIndex=index;
        myPhotoDetailsViewController.selectGroupInt =  self.selectGroupId;
        myPhotoDetailsViewController.groupId = self.selectGroupId;
        myPhotoDetailsViewController.myPhotoDetailsDelegate = self;
        myPhotoDetailsViewController.blogs = self.blogArray;
//        [self.navigationController pushViewController:myPhotoDetailsViewController animated:YES];
        [self presentViewController:myPhotoDetailsViewController animated:YES completion:nil];
        [myPhotoDetailsViewController release];
    }
    
}
#pragma  mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //TODO by ZGL
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            if ([_blogArray count] > 0 ) {
                _isEditStyle = YES;
                _toolBar.hidden = NO;
                [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
            }
        }
    }else if (actionSheet.tag == 101) {
        if (buttonIndex == 0) {
            EditPhotoAlbumsViewController *editPhotoAlbumsViewController = [[EditPhotoAlbumsViewController alloc] init];
            editPhotoAlbumsViewController.selectGroupInt = self.selectGroupInt;
            editPhotoAlbumsViewController.editDelegate=self;
            [self.navigationController pushViewController:editPhotoAlbumsViewController animated:YES];
            [editPhotoAlbumsViewController release];
        }else if (buttonIndex == 1){
            if ([_blogArray count] > 0 ) {
                _isEditStyle = YES;
                _toolBar.hidden = NO;
                [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
            }else{
//                [MyToast showWithText:@"没有可操作的照片" :[UIScreen mainScreen].bounds.size.height/2-40];
            }
        }
    }else{
        if (buttonIndex!=2) {
            [self initWithImagePickerController:buttonIndex];
        }
    }    
}

#pragma mark - UIActionSheetDelegate

- (void)initWithImagePickerController:(NSInteger)index
{
    BOOL isAnimated = YES;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    [imagePickerController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top"] forBarMetrics:0];
    imagePickerController.delegate = self;
    if (index==1){
        
        __block typeof(self) this = self;
        AGImagePickerController *multiImagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
            
            if (!error) {
                [this dismissViewControllerAnimated:YES completion:^{
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
                }];
            } else {
                
            }
            
        } andSuccessBlock:^(NSArray *info) {
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
            [this dismissViewControllerAnimated:YES completion:^{
                MultiPicUoloaderViewController *multiUploadVC = [[MultiPicUoloaderViewController alloc] initWithImageFromAssets:info];
                
                multiUploadVC.chosenPhotoGroupID = this.selectGroupId;
                [multiUploadVC setChoseButtonHidden:YES];
                [this presentViewController:multiUploadVC animated:YES completion:^{
                    [multiUploadVC.mutiPicEditView setGroupButtonTitle:this.titleLabel.text];
                    multiUploadVC.mutiPicEditView.choseGroupButton.enabled = NO;
                    multiUploadVC.chosenPhotoGroupID = this.selectGroupId;
                }];
                [multiUploadVC release];
            }];
            
        }];
        
        [multiImagePickerController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top.png"] forBarMetrics:UIBarMetricsDefault];
        multiImagePickerController.maximumNumberOfPhotosToBeSelected= 6;
        multiImagePickerController.toolbarHidden = YES;
        multiImagePickerController.shouldShowSavedPhotosOnTop = YES;
        
        
        [self presentViewController:multiImagePickerController animated:YES completion:nil];
        [multiImagePickerController release];
        
        return;
        
    } else if (index==0) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            isAnimated = NO;
        }
    }
    [self presentViewController:imagePickerController animated:isAnimated completion:nil];
    [imagePickerController release];
}

#pragma mark  UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *deviceModel = info[@"UIImagePickerControllerMediaMetadata"][@"{TIFF}"];
    NSArray *groupArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];
    NSInteger indexInt  = [self.selectGroupInt integerValue];
    DiaryPictureClassificationModel *model = [groupArray objectAtIndex:indexInt];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:nil name:@"DetailViewUpBtnClicked" object:nil];
    NSString *selectGroupIntStr = [NSString stringWithFormat:@"%@",self.selectGroupInt];
    NSString *groupNameStr = [NSString stringWithFormat:@"%@",model.title];
    NSString *titleKey = [NSString stringWithFormat:@"title"];
    NSString *groupIdKey = [NSString stringWithFormat:@"selectGroupIntStr"];
    NSDictionary *selecetGroupDic = [NSDictionary dictionaryWithObjectsAndKeys:selectGroupIntStr,groupIdKey,groupNameStr,titleKey, nil];
    [self savePhotoesGroup:selecetGroupDic withName:@"PhotoesDic"];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image scalingImageByRatio];//调整图片像素
    image = [image fixOrientation];
    NSData *data = [image compressedData:0.8];
    image = [UIImage imageWithData:data];

    if ([@"iPhone 5" isEqualToString:deviceModel]) {
        if (image.size.width > image.size.height) {
            image = [image imageByScalingAndCroppingForSize:CGSizeMake(1024, 768)];
        }
        else if (image.size.width < image.size.height) {
            image = [image imageByScalingAndCroppingForSize:CGSizeMake(768, 1024)];
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    data = nil;
    info = nil;
    
    __block MultiPicUoloaderViewController *controller = [[MultiPicUoloaderViewController alloc] init];
    NSMutableArray *imageArr = [[NSMutableArray alloc] initWithObjects:image, nil];
    controller.assets = imageArr;
    controller.chosenPhotoGroupID = self.selectGroupId;
    [controller setChoseButtonHidden:YES];
    [imageArr release];
    
    __block typeof(self) this = self;
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [this presentViewController:controller animated:YES completion:nil];
    });
    

    [controller release];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    }
}

#pragma mark popToFrontView delegate

-(void)popToPhotoAlbumVC{
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma  mark - ASIFormDataRequest
-(void)requestSuccess:(ASIFormDataRequest *)temprequest
{
    __block typeof(self) bself = self;
    ASIFormDataRequest *request = [temprequest retain];
    NSData *responseData = [request responseData];
//    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [responseData objectFromJSONData];
    NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    
    NSString *errorcodeStr = [NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"errorcode"]];
    if (tag == REQUEST_FOR_GETBLOGLIST) {
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:bself cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            NSMutableArray *blogArray = [resultDictionary objectForKey:@"data"];
            [MessageSQL synchronizeBlog:blogArray WithUserID:USERID];
            _isEditStyle = NO;
            _toolBar.hidden = YES;
            if (bself.rightBtn == nil)
            {
                [bself.rightBtn retain];
                [bself.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
                
            }
                
            [bself.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
            
            [bself.blogEditArray removeAllObjects];
            [bself setPhotoes];
        }
        
    }
    if (tag == REQUEST_FOR_CHANGEBLOGGROUP) {
        if ([resultStr isEqualToString:@"0"]) {
//            [MyToast showWithText:@"移动分组失败" :130];
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            if ([@"blogid参数错误" isEqualToString:errorStr]) {
                [bself setPhotoes];
                return;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:bself cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }else{
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"isAlbumChanged" object:nil];
            
            NSDictionary *metaDic = [resultDictionary objectForKey:@"meta"];
            NSString *versionsStr = [metaDic objectForKey:@"versions"];
            NSMutableArray *refershMessagesArray = [[NSMutableArray alloc] init];
            for (MessageModel *blogModel in bself.blogEditArray) {
                NSDate *date = [NSDate date];
                NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
                NSString *timeStr = [NSString stringWithFormat:@"%f",timestamp];
                blogModel.status = @"1";
                blogModel.needSyn = NO;
                blogModel.needUpdate = NO;
                blogModel.lastModifyTime = timeStr;
                blogModel.syncTime = timeStr;
                blogModel.localVer = versionsStr;
                blogModel.serverVer = versionsStr;
                [refershMessagesArray addObject:blogModel];
            }
            [MessageSQL  refershMessagesByMessageModelArray:refershMessagesArray];
            [refershMessagesArray release];
            _isEditStyle = NO;
            _toolBar.hidden = YES;
            [MyToast showWithText:resultDictionary[@"message"] :130];
            [bself.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
            [bself.blogEditArray removeAllObjects];
            [bself setPhotoes];
        }
    }
    
    if (tag == REQUEST_FOR_DELETBLOG) {
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
            }
            UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:bself cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
        }
        else
        {
            [MyToast showWithText:@"删除成功" :130];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"isAlbumChanged" object:nil];
            NSMutableString *blogIdsStr = [resultDictionary objectForKey:@"data"];
            NSDictionary *metaDic = [resultDictionary objectForKey:@"meta"];
            NSArray *blogsAry;

            if ([blogIdsStr rangeOfString:@","].location != NSNotFound) {
                blogsAry = [blogIdsStr  componentsSeparatedByString:@","];
                __block NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
                [blogsAry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    NSString *blogId = (NSString *)obj;
                    MessageModel *model = [[MessageModel alloc] init];
                    model.blogId = blogId;
                    [arr addObject:model];
                    [model release];
                }];
                
                
                blogsAry = [arr retain];
                
                [arr release];
                
               
            }
            else
            {
                MessageModel *model = [[MessageModel alloc] init];
                model.blogId = blogIdsStr;
                blogsAry = [NSArray arrayWithObject:model];
                [model release];
            }

            [MessageSQL  deletePhoto:blogsAry];
            
            _isEditStyle = NO;
            _toolBar.hidden = YES;
            [bself.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
            [bself.blogEditArray removeAllObjects];
            [bself updateDiaryDBData:bself.selectGroupId];
            [bself setPhotoes];
            
            //更新使用空间
            NSNumber *spaceUsed = [NSNumber numberWithLongLong:[metaDic[@"spaceused"] longLongValue]];
            [SavaData fileSpaceUseAmount:spaceUsed];
        }
    }
    if (tag == REQUEST_FOR_ADDPHOTO) {
        
        if ([resultStr isEqualToString:@"0"]) {
            //            NSString *errorStr=[NSString stringWithFormat:@"%@",@"上传失败"];
            //            [MyToast showWithText:errorStr :[UIScreen mainScreen].bounds.size.height/2-40];
            
        }else{
            
            [MyToast showWithText:@"上传成功" :130];
            NSDictionary *dataDic =[resultDictionary objectForKey:@"data"];
            NSDictionary *metaDic =[resultDictionary objectForKey:@"meta"];
            NSString *spaceusedStr = [metaDic objectForKey:@"spaceused"];
            NSArray *blogArray = [NSArray arrayWithObject:dataDic];
            [MessageSQL refershMessages:blogArray clientId:[metaDic objectForKey:@"clientId"]] ;
            //更新使用空间
            NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *doucumentsDirectiory = [storeFilePath objectAtIndex:0];
            NSString *plistPath =[doucumentsDirectiory stringByAppendingPathComponent:User_File];
            NSMutableDictionary *userDataDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
            [userDataDic setObject:spaceusedStr forKey:@"spaceUsed"];
            [userDataDic writeToFile:plistPath atomically:YES];
            _isEditStyle = NO;
            _toolBar.hidden = YES;
            [bself.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
            [bself.blogEditArray removeAllObjects];
            [bself setPhotoes];
        }
    }
    
}
-(void)requestFail:(ASIFormDataRequest *)request
{

    NSDictionary *dict=[NSDictionary dictionaryWithDictionary:request.userInfo];
    NSInteger tag=[[dict objectForKey:@"tag"] integerValue];
    NSString  *text = nil;
    if (tag == REQUEST_FOR_GETBLOGLIST) {
        text=@"获取照片失败";
    }
    if (tag == REQUEST_FOR_CHANGEBLOGGROUP) {
        text=@"移动分组失败";
    }
    if (tag == REQUEST_FOR_DELETBLOG) {
        text=@"删除照片失败";
    }
    if (tag == REQUEST_FOR_ADDPHOTO) {
        text=@"添加照片失败";
    }
    [MyToast showWithText:text :[UIScreen mainScreen].bounds.size.height/2-40];
    //   [MyToast showWithText:@"请求错误，请检查网络" :140];
}
#pragma mark -- alterview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ([alertView.message isEqualToString:AUTO_RELOGIN]) {
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate]  showLoginVC];
    }
}


#pragma mark --  MyPhotoDetailsDelegate
- (void)reloadPhotoes:(BOOL)isReloadPhotoes
{
    if (isReloadPhotoes) {
        [self setPhotoes];
    }
}

#pragma mark - 保存日志至沙盒
- (void) savePhotoesGroup:( NSDictionary *)currentDiaryInfo withName:(NSString *)diaryName
{
    NSString *fullPath = [Utilities dataPath:diaryName FileType:@"Photos" UserID:USERID];
    [currentDiaryInfo writeToFile:fullPath atomically:NO];
}

@end
