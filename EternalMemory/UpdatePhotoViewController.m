//
//  UpdatePhotoViewController.m
//  EternalMemory
//
//  Created by sun on 13-6-5.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "UpdatePhotoViewController.h"
#import "RMWTextView.h"
#import "PhotoAlbumsViewController.h"
#import "FMDatabase.h"
#import "DiaryPictureClassificationSQL.h"
#import "MessageSQL.h"
#import "MD5.h"
#import "EternalMemoryAppDelegate.h"
#import "MyToast.h"
#import "MyAlbumClassifiedListingDetailsViewController.h"
#import "ASINetworkQueue.h"
#import "UIImage+UIImageExt.h"
#import "MyLifeMainViewController.h"

#define PHOTOTEXT @"1"
#define REQUEST_FOR_ADDPHOTO 100
#define REQUEST_FOR_UPDATAPHOTO 200

NSString * const PhotoGroupChangedNotification = @"PhotoGroupChangedNotification";

@interface UpdatePhotoViewController ()
{
    MBProgressHUD *_mbHud;
    sqlite_int64  lastId;
    NSInteger photoNumber;
    UIView *_vie;
}
@property (nonatomic, retain) IBOutlet UIImageView *sphotoImageView;
@property (nonatomic, retain) IBOutlet RMWTextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *groupNameLable;
@property (nonatomic, retain) IBOutlet UIImageView *groupNameImageView;
@property (nonatomic, retain) NSArray  *JournalCategoryArray;
@property (nonatomic, retain) NSMutableArray *blogArray;
@property (nonatomic, retain) UIView *vie;
@property (nonatomic, copy)   NSString *imgPath;
@property (nonatomic, copy)   NSString *simgPath;
@property (nonatomic, copy)   NSString *imgName;
@property (nonatomic, copy)   NSString *errorcodeStr ;


- (IBAction)onSelectedGroupBtnClicked;

@end

@implementation UpdatePhotoViewController

@synthesize sphotoImage = _sphotoImage;
@synthesize groupNameLable = _groupNameLable;
@synthesize sphotoImageView = _sphotoImageView;
@synthesize JournalCategoryArray = _JournalCategoryArray;
@synthesize selectedIndex = _selectedIndex;
@synthesize sphotoImg = _sphotoImg;
@synthesize imgPath = _imgPath;
@synthesize simgPath = _simgPath;
@synthesize blogmodel = _blogmodel;
@synthesize errorcodeStr = _errorcodeStr ;
@synthesize blogArray = _blogArray;
@synthesize imgName= _imgName;
@synthesize vie = _vie;
- (void)dealloc
{
    RELEASE_SAFELY(_sphotoImage);
    RELEASE_SAFELY(_sphotoImageView);
    RELEASE_SAFELY(_textView);
    RELEASE_SAFELY(_groupNameLable);
    RELEASE_SAFELY(_groupNameImageView);
    RELEASE_SAFELY(_JournalCategoryArray);
    RELEASE_SAFELY(_blogArray);
    RELEASE_SAFELY(_vie);
    RELEASE_SAFELY(_imgPath);
    RELEASE_SAFELY(_simgPath);
    RELEASE_SAFELY(_imgPath);
    RELEASE_SAFELY(_errorcodeStr);
    RELEASE_SAFELY(_blogmodel);
    [_mbHud removeFromSuperview];
    [_mbHud release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangePhotoGroupNotification object:nil];
    [super dealloc];
}



#pragma mark - private methods
- (void)backBtnPressed
{

    [self dismissViewControllerAnimated:YES completion: nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)rightBtnPressed
{
    
    [self.textView resignFirstResponder];
    //by jxl
    _mbHud.labelText = @"正在处理...";
    _mbHud.mode = MBProgressHUDModeText;
    [_mbHud show:YES];
    _vie.hidden = NO;
    self.rightBtn.enabled = NO;
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
    NSString *dateStr = [NSString stringWithFormat:@"%f",timestamp];
    NSString *content = _textView.text;
    [content isEqualToString:@"请添加照片描述"] ? content = @"" : content;
    self.blogmodel.content = content;
    self.blogmodel.deletestatus = NO;
    self.blogmodel.lastModifyTime = dateStr;
    
    
    BOOL networkStr = [Utilities checkNetwork];
    if (!networkStr) {
        [_mbHud hide:YES];
        _vie.hidden = YES;
        [MyToast showWithText:@"无网络连接" :380];
        //修改图片
        if ( [self.titleLabel.text isEqualToString: @"修改图片信息" ])
        {
            //                无网 有blogid 标记登录要同步
            if (self.blogmodel.blogId && self.blogmodel.blogId.length > 0) {
                self.blogmodel.needDownL = YES;
                self.blogmodel.needSyn = YES;
                self.blogmodel.needUpdate = YES;
                self.blogmodel.status = @"4";
            }
            //   无网 无blogid 存数据库
            else{
                //修改对应blog的content、groupid字段
            }
            NSArray *blogArray = [NSArray arrayWithObject:self.blogmodel];
            [MessageSQL refershMessagesByMessageModelArray:blogArray];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoDescriptionChangedNotification object:@{@"groupId":self.blogmodel.groupId, @"blogModel":self.blogmodel, @"des":self.textView.text}];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            
            NSData *bimgdata = UIImagePNGRepresentation(self.sphotoImage);
            NSData *simgdata = UIImagePNGRepresentation(self.sphotoImg);
            
            NSString *sImgName = [NSString stringWithFormat:@"simg_%@.png",dateStr];
            NSString *bImgName = [NSString stringWithFormat:@"img_%@.png",dateStr];
            
            NSString *sImgLocalPath = [Utilities dataPath:sImgName FileType:@"Photos" UserID:USERID];
            NSString *bImgLocalPath = [Utilities dataPath:bImgName FileType:@"Photos" UserID:USERID];
            
            [bimgdata writeToFile:bImgLocalPath atomically:YES];
            [simgdata writeToFile:sImgLocalPath atomically:YES];
            
            
            [self addPhotoToMessageTable];
            
        }
    }
    else
    {
        self.blogArray = [MessageSQL getMessages:PHOTOTEXT AndUserId:USERID];
        
        if ( [self.titleLabel.text isEqualToString: @"修改图片信息" ]) {
            
            if (self.blogmodel.blogId.length > 0) {
                [self upDatePhotoRequest:self.blogmodel];
            }
            //#warning                有网 无blogid 上传图片
            else
            {
                [self compressionImg];
                [self addPhotoRequest];
            }
            
        }
    }
}
- (void)compressionImg
{
//    NSData *imgData = UIImageJPEGRepresentation(self.sphotoImage, 1.0);
    // 图片大于2M要先进行压缩
//by jxl
//    self.sphotoImage = [self.sphotoImage scalingImageByRatio];//调整图片像素
//    data = [self.sphotoImage compressedData:0.1];
   NSData *imgData  =  UIImageJPEGRepresentation(self.sphotoImage, 0.02);
    self.sphotoImage = [UIImage imageWithData:imgData];
    imgData = nil;
}
- (void)popToDetailView
{
    //进入相册详情
    MyAlbumClassifiedListingDetailsViewController *myAlbumClassifiedListingDetailsViewController = [[MyAlbumClassifiedListingDetailsViewController alloc] init];
    myAlbumClassifiedListingDetailsViewController.selectGroupId = self.blogmodel.blogId;
    NSString *selectedIndex = [NSString stringWithFormat:@"%d",_selectedIndex];
    myAlbumClassifiedListingDetailsViewController.selectGroupInt = selectedIndex;
    PhotoAlbumsViewController *photoAlbumsViewController = [[[PhotoAlbumsViewController alloc] init] autorelease];
    photoAlbumsViewController.fromView = [NSString stringWithFormat:@"updatePhonto"];
    NSMutableArray *array = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];
    [array addObject:photoAlbumsViewController];
    self.navigationController.viewControllers = array;
    [self.navigationController pushViewController:myAlbumClassifiedListingDetailsViewController animated:YES];
    [myAlbumClassifiedListingDetailsViewController release];
}
- (void)addPhotoToMessageTable
{
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    self.imgName = [NSString stringWithFormat:@"img_%f.png",timestamp];
    NSString *dateStr = [NSString stringWithFormat:@"img_%f.png",timestamp];
    
    self.sphotoImage = [self.sphotoImage fixOrientation];
    NSData *bimgdata = UIImagePNGRepresentation(self.sphotoImage);
    NSData *simgdata = UIImagePNGRepresentation(self.sphotoImg);
    
    NSString *sImgName = [NSString stringWithFormat:@"simg_%@.png",dateStr];
    NSString *bImgName = [NSString stringWithFormat:@"img_%@.png",dateStr];
    
    
    NSString *sImgLocalPath = [Utilities dataPath:sImgName FileType:@"Photos" UserID:USERID];
    NSString *bImgLocalPath = [Utilities dataPath:bImgName FileType:@"Photos" UserID:USERID];
    
    [bimgdata writeToFile:bImgLocalPath atomically:YES];
    [simgdata writeToFile:sImgLocalPath atomically:YES];
    

    NSString * doc = PATH_OF_DOCUMENT;
    NSString * path = [doc stringByAppendingPathComponent:@"memory.db"];
    FMDatabase * db = [FMDatabase databaseWithPath:path];
    self.JournalCategoryArray  = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID] ;
    DiaryPictureClassificationModel *model = [self.JournalCategoryArray   objectAtIndex:_selectedIndex];
    
    [DiaryPictureClassificationSQL updateDiaryForGroupId:model.groupId photoPath:sImgLocalPath WithUserID:USERID];
    
    db.logsErrors = YES;
    if ([db open]) {
        NSString  *tableName = [NSString stringWithFormat:@"Message_%@",USERID];
        NSDate *date = [NSDate date];
        NSTimeInterval timestamp = [date timeIntervalSince1970] * 1000;
        NSString  *deleteStatusStr = [NSString stringWithFormat:@"0"];
        NSString  *status = @"2";//noExchange 是1 ，add是2 、delete是3 、update是4
        NSString  *accessLevel = @"1";
        bool needSyn = 1;//是否需要同步
        bool needUpdate = 1;//是否更新
        bool needDownL = 0;//是否下载
        
        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (blogType,content,groupid,groupname,title,accessLevel,status,needSyn,needUpdate,needDownL,createTime,deleteStatus,paths,spaths,userId) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
        if ([db executeUpdate:sqlStr, PHOTOTEXT, self.textView.text, model.groupId, model.title, sImgName,accessLevel,status,[NSNumber numberWithBool:needSyn],[NSNumber numberWithBool:needUpdate], [NSNumber numberWithBool:needDownL],[NSString stringWithFormat:@"%f",timestamp],deleteStatusStr,bImgLocalPath,sImgLocalPath,USERID])
        {
            lastId=[db lastInsertRowId];
            self.rightBtn.enabled = YES;
            //进入相册详情
            self.JournalCategoryArray  = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID] ;
            DiaryPictureClassificationModel *model = [self.JournalCategoryArray   objectAtIndex:_selectedIndex];
            MyAlbumClassifiedListingDetailsViewController *myAlbumClassifiedListingDetailsViewController = [[MyAlbumClassifiedListingDetailsViewController alloc] init];
            myAlbumClassifiedListingDetailsViewController.selectGroupId = model.groupId;
            myAlbumClassifiedListingDetailsViewController.selectGroupInt=[NSString stringWithFormat:@"%d",_selectedIndex];
            PhotoAlbumsViewController *photoAlbumsViewController = [[[PhotoAlbumsViewController alloc] init] autorelease];
            photoAlbumsViewController.fromView = [NSString stringWithFormat:@"updatePhonto"];
            NSMutableArray *array = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];
            [array addObject:photoAlbumsViewController];
            self.navigationController.viewControllers = array;
            [self.navigationController pushViewController:myAlbumClassifiedListingDetailsViewController animated:YES];
            [myAlbumClassifiedListingDetailsViewController release];
        }
        else
        {
        }
    }
    [db close];
}
- (void)addPhotoRequest
{
    

    self.JournalCategoryArray  = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID] ;
//    DiaryPictureClassificationModel *model = [self.JournalCategoryArray   objectAtIndex:_selectedIndex];
//    NSString *groupIdStr = [NSString stringWithFormat:@"%@",self.blogmodel.groupId];
    NSString *contentStr = [NSString stringWithFormat:@"%@",_textView.text];
    NSURL *registerUrl = [[RequestParams sharedInstance] uploadPhoto];


    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:registerUrl];
    request.delegate = self;
    request.shouldAttemptPersistentConnection = NO;
    request.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_ADDPHOTO],@"tag", nil];
    [request addRequestHeader: @"clienttoken"value:USER_TOKEN_GETOUT];
    [request addRequestHeader: @"serverauth"value:USER_AUTH_GETOUT];
    [request buildRequestHeaders];
    [request setPostValue:PHOTOTEXT  forKey:@"blogtype"];
    [request setPostValue:self.blogmodel.groupId forKey:@"groupid"];
    [request setPostValue:contentStr forKey:@"content"];

//压缩图片质量
    
    UIImage *imageToUpload = [UIImage imageWithContentsOfFile:self.blogmodel.paths];
    
    imageToUpload = [imageToUpload scalingImageByRatio];
    imageToUpload = [imageToUpload fixOrientation];
    NSData *_imgData = [imageToUpload compressedData:0.5];

    [request addData:_imgData withFileName:@"imges.jpg" andContentType:@"image/jpg" forKey:@"upfile"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:30.0];
    __block typeof(self) bself = self;
    
    [request setCompletionBlock:^{
        [bself requestSuccess:request];
        [_mbHud setHidden:YES];
        _vie.hidden = YES;
    }];
    [request setFailedBlock:^{

        [bself requestFail:request];
        [_mbHud setHidden:YES];
        _vie.hidden = YES;
    }];

    [request startAsynchronous];
    [request release];

   
//添加吐死
    
    
}

- (void)upDatePhotoRequest:(MessageModel *)blog
{
    __block typeof(self) bself = self;

    NSURL *registerUrl = [[RequestParams sharedInstance] updatePhotoDetail];
   ASIFormDataRequest *_request = [ASIFormDataRequest requestWithURL:registerUrl];
    //request.delegate = self;
    _request.shouldAttemptPersistentConnection = NO;
    _request.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_UPDATAPHOTO],@"tag", nil] ;
    [_request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_request setPostValue:@"0" forKey:@"blogtype"];
    [_request setPostValue:self.blogmodel.groupId forKey:@"groupid"];
    [_request setPostValue:self.blogmodel.content forKey:@"content"];
    [_request setPostValue:self.blogmodel.blogId forKey:@"blogid"];
    [_request setRequestMethod:@"POST"];
    [_request setTimeOutSeconds:30.0];
    [_request setCompletionBlock:^{
        [bself requestSuccess:_request];
    }];
    [_request setFailedBlock:^{
        [bself requestFail:_request];
    }];
    [_request startAsynchronous];
    
}

- (void)setGroup:(NSDictionary *)groupDic
{
    //    self.blogmodel.groupId = [groupDic objectForKey:@"groupId"];
    [self.groupNameLable setText:[groupDic objectForKey:@"title"]];
    NSString *selectGroupIntStr = [groupDic objectForKey:@"selectGroupIntStr"];
    NSInteger selectedGroupInt = [selectGroupIntStr integerValue];
    _selectedIndex  = selectedGroupInt;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DetailViewUpBtnClicked"];
}
- (void)setViewData
{
    //
    [self.groupNameLable setNumberOfLines:0];
    NSString *s = @"默认相册";
    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    [self.groupNameLable setFrame:CGRectMake(_groupNameLable.frame.origin.x,_groupNameLable.frame.origin.y
                                             , labelsize.width, labelsize.height)];
    // nevBar
    self.rightBtn.hidden = NO;
    self.middleBtn.hidden = YES;
    [self.textView becomeFirstResponder];
    self.JournalCategoryArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];
    //    NSInteger blogIndex = [self.JournalCategoryArray  indexOfObject:self.blogmodel];
    //    _selectedIndex = blogIndex;
    if (self.blogmodel) {
        self.titleLabel.text = @"修改图片信息";
        if (!self.rightBtn)
        {
            [self.rightBtn retain];
        }
        [self.rightBtn setTitle:@"保存" forState:UIControlStateNormal];
        self.uploadLabel.text=[NSString stringWithFormat:@"%@",_uploadLabelText];;
        if ( self.blogmodel.content.length > 0 ) {
            self.textView.text =  self.blogmodel.content;
        }else{
            self.textView.placeholder =  @"请添加照片描述";
        }
        NSArray *groupArray = [DiaryPictureClassificationSQL  getDiaryPictureClassificationesByGroupId:self.blogmodel.groupId];
        DiaryPictureClassificationModel *groupModel = [groupArray objectAtIndex:0];
        [self.groupNameLable  setText:groupModel.title];
        UIImage *sImg;
        if (self.blogmodel.spaths) {
            sImg = [[ UIImage alloc] initWithContentsOfFile: _blogmodel.spaths];
            [self.sphotoImageView setImage: sImg];
            RELEASE_SAFELY(sImg);
        }else{
            NSString *imgUrlStr = [NSString stringWithFormat:@"%@",_blogmodel.thumbnail];
            NSURL *imgURL = [NSURL URLWithString:imgUrlStr];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            sImg = [UIImage imageWithData:imgData];
            self.imgPath = imgUrlStr;
            [self.sphotoImageView setImage: sImg];
            
            [sImg release];
        }
        
    }else{

        self.titleLabel.text = @"上传图片";
        if(self.rightBtn == nil)
        {
            [self.rightBtn retain];
        }

        [self.rightBtn setTitle:@"上传" forState:UIControlStateNormal];
        self.sphotoImg = [self thumbnailWithImageWithoutScale:self.sphotoImage size:CGSizeMake(180, 180)];
        [self.sphotoImageView setImage:self.sphotoImg];
        CALayer *layer = [self.sphotoImageView layer];   //获取ImageView的层
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:6.0];
        self.textView.placeholder =  @"请添加照片描述";
        
    }
    
    //img
    //    NSDate *date = [NSDate date];
    //    NSTimeInterval timestamp = [date timeIntervalSince1970];
    //    self.imgName = [NSString stringWithFormat:@"img_%f.png",timestamp];
    //    NSString *sImgName = [NSString stringWithFormat:@"simg_%f.png",timestamp];
    //    NSString *localImgName = [MD5 md5:self.imgName];
    //    NSString *localSImgName = [MD5 md5:sImgName];
    //
    //    [self saveImage:self.sphotoImage withName:localImgName];
    //    [self saveImage:self.sphotoImg withName:localSImgName];
    //    self.imgPath = [self dataPath:localImgName];
    //    self.simgPath = [self dataPath:localSImgName];
    //
    //    _imgData = [UIImageJPEGRepresentation(self.sphotoImage, 1.0f)retain];
    NSString *diaPathStr = [Utilities dataPath:@"PhotoesDic" FileType:@"Photos" UserID:USERID];

    NSDictionary *diaryDic = [NSDictionary dictionaryWithContentsOfFile:diaPathStr];
    if (diaryDic) {
        [self setGroup:diaryDic];
        [[NSFileManager defaultManager] removeItemAtPath:diaPathStr error:nil];
    }
    
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

#pragma mark - object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
     
        // Custom initialization
        //_selectedIndex = 0;
        
        photoNumber = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _vie = [[UIView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44)];
    _vie.backgroundColor = [UIColor clearColor];
    _vie.hidden = YES;
    [self.view addSubview:_vie];

    if (fromPhotoList == YES) {
        _uploadBtn.enabled = NO;

    }
    
    _sphotoImageView.contentMode = UIViewContentModeScaleAspectFill;
    _sphotoImageView.clipsToBounds = YES;
    _mbHud = [[MBProgressHUD alloc]initWithView:_vie];
    [_vie addSubview:_mbHud];
    [self setViewData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGroup:) name:kChangePhotoGroupNotification object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)changeGroup:(NSNotification *)notification
{
    DiaryPictureClassificationModel *model = [notification.object retain];
    _groupNameLable.text = model.title;
    self.blogmodel.groupId = model.groupId;
    [model release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction methods,public methods
- (IBAction)textViewResignFirstResponder
{
    [self.view endEditing:YES];
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (IBAction)onSelectedGroupBtnClicked
{
    if (fromPhotoList == YES) {
        
        return;
    }
    PhotoAlbumsViewController *photoAlbumsViewController = [[PhotoAlbumsViewController alloc] init ];
    photoAlbumsViewController.isSeletedStyle = YES;
    photoAlbumsViewController.selectListCategoriesDelegate = self;
//    [self.navigationController pushViewController:photoAlbumsViewController animated:YES];
    [self presentViewController:photoAlbumsViewController animated:YES completion:nil];
    [photoAlbumsViewController release];
    //RELEASE_SAFELY(photoAlbumsViewController);
}
#pragma mark - PhotoAlbumsViewDelegate SelectListCategoriesDelegate
- (void)selectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = selectedIndex;
//    self.JournalCategoryArray  = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT] ;
//    DiaryPictureClassificationModel *model = [self.JournalCategoryArray   objectAtIndex:_selectedIndex - 1];
//    self.blogmodel.groupId = model.groupId;
//    [self.groupNameLable setNumberOfLines:0];
//    UIFont *font = [UIFont systemFontOfSize:16];
//    CGSize size = CGSizeMake(320,2000);
//    CGSize labelsize = [model.title sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
//    [self.groupNameLable setFrame:CGRectMake(320 - labelsize.width - 31 ,163, labelsize.width, labelsize.height)];
//    [self.groupNameLable setText:model.title];
//    [_groupNameImageView setFrame:CGRectMake(320 - labelsize.width - 31 - 20 ,167, 13, 13)];
    
}
#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    int wid = currentImage.size.width;
    int hight = currentImage.size.height;
    CGSize size = CGSizeMake(wid, hight);
    UIGraphicsBeginImageContext(size);
    [currentImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    currentImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imgData = [UIImageJPEGRepresentation(currentImage, 1.0f)retain];
    
    NSString *fullPath = [Utilities dataPath:imageName FileType:@"Photos" UserID:USERID];
    [imgData writeToFile:fullPath atomically:NO];
    
    [imgData release];
}

#pragma mark - ASIHTTPRequest
-(void)requestSuccess:(ASIFormDataRequest *)request
{
    [_mbHud hide:YES];
    _vie.hidden = YES;
    self.rightBtn.enabled = YES;
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    if (resultDictionary) {
        NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
        NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
//        NSString *str = [resultDictionary objectForKey:@"message"];
        self.errorcodeStr = [NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"errorcode"]];
        if (tag == REQUEST_FOR_ADDPHOTO) {
            
            if ([resultStr isEqualToString:@"0"])
            {
                if ([self.errorcodeStr isEqualToString:@"3013"]) {
                    self.errorcodeStr  =  [NSString stringWithFormat:@"%@",@"上传失败"];
                    [MyToast showWithText:self.errorcodeStr:[UIScreen mainScreen].bounds.size.height/2-40];
                }
                if ([self.errorcodeStr isEqualToString:@"3045"]) {
                    
                    self.errorcodeStr  =  [NSString stringWithFormat:@"%@",@"您的20张照片已上传完毕"];
                    [MyToast showWithText:self.errorcodeStr:[UIScreen mainScreen].bounds.size.height/2-40];
                }
                if ([self.errorcodeStr isEqualToString:@"1005"]||[self.errorcodeStr isEqualToString:@"2007"]) {
                    UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alter show];
                    [alter release];
                }
                if ([self.errorcodeStr isEqualToString:@"9000"]) {
                    
                    UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alter.tag = 2000;
                    [alter show];
                    [alter release];
                }
            }
            else
            {
                [MessageSQL deletePhoto:@[self.blogmodel]];
                NSDictionary *dataDic =[resultDictionary objectForKey:@"data"];
//                NSDictionary *metaDic =[resultDictionary objectForKey:@"meta"];
//                NSString *spaceusedStr = [metaDic objectForKey:@"spaceused"];
                NSArray *blogArray = [NSArray arrayWithObject:dataDic];
                [MessageSQL synchronizeBlog:blogArray WithUserID:USERID];
                
                NSString *groupId = dataDic[@"groupId"];
                NSString *thumbnail = dataDic[@"thumbnail"];

                //更新使用空间
                NSNumber *spaceUsed = [NSNumber numberWithLongLong:[resultDictionary[@"meta"][@"spaceused"] longLongValue]];
                [SavaData fileSpaceUseAmount:spaceUsed];

                NSString *imageName = [NSString stringWithFormat:@"simg_%@.png",thumbnail];
                NSString *localImageName = [MD5 md5:imageName];
                NSString *path = [Utilities dataPath:localImageName FileType:@"Photos" UserID:USERID];
                
                [DiaryPictureClassificationSQL updateDiaryForGroupId:groupId photoPath:path WithUserID:USERID];
                
                //更新使用空间

                //进入相册详情
                self.JournalCategoryArray  = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID] ;
                
                DiaryPictureClassificationModel *model = [self.JournalCategoryArray   objectAtIndex:_selectedIndex];
                
                //TODO: 添加改变相册分组的通知。
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoDescriptionChangedNotification object:@{@"groupModel": model, @"messageModel": self.blogmodel}];
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
                
//  ---------------------------------------------------------------------------------
                NSInteger a=[[SavaData shareInstance] printData:HOME_STATUS];
                if (a == 3) {
                    for(id obj in self.navigationController.viewControllers){
                        if ([obj isKindOfClass:[PhotoAlbumsViewController class]]) {
                            [self.navigationController popToViewController:obj animated:NO];
                        }
                    }
//                    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:NO];
                    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_selectedIndex],@"selectGroupInt", model.groupId,@"selectGroupId",nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeView" object:dic];
                }
                if (a == 4) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"myAlbumClassDetail" object:nil];
                    for(id obj in self.navigationController.viewControllers){
                        if ([obj isKindOfClass:[MyAlbumClassifiedListingDetailsViewController class]]) {
                            [self.navigationController popToViewController:obj animated:NO];
                        }
                    }
                }
                if (a == 1) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"myAlbumClassDetail" object:nil];
                    for(UIViewController *controller in self.navigationController.viewControllers){
                        if ([controller isKindOfClass:[MyAlbumClassifiedListingDetailsViewController class]]) {
                            [self.navigationController popToViewController:controller animated:NO];
                        }
                    }   
                }
                if (a == 2) {
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    return;
                    MyAlbumClassifiedListingDetailsViewController *myAlbumClassifiedListingDetailsViewController = [[MyAlbumClassifiedListingDetailsViewController alloc] init];
                    myAlbumClassifiedListingDetailsViewController.selectGroupId = model.groupId;
                    myAlbumClassifiedListingDetailsViewController.selectGroupInt=[NSString stringWithFormat:@"%d",_selectedIndex];
                    
                    PhotoAlbumsViewController *photoAlbumsViewController = [[[PhotoAlbumsViewController alloc] init] autorelease];
                    photoAlbumsViewController.fromView = [NSString stringWithFormat:@"updatePhonto"];
                    NSMutableArray *array = [NSMutableArray arrayWithArray: self.navigationController.viewControllers]; 
                    [array addObject:photoAlbumsViewController];
                    self.navigationController.viewControllers = array;
                    [self.navigationController pushViewController:myAlbumClassifiedListingDetailsViewController animated:YES];
                    [myAlbumClassifiedListingDetailsViewController release];

                }
                /*__block typeof (self) bself=self;

                dispatch_async(dispatch_get_main_queue(),^{
                    
                    MyAlbumClassifiedListingDetailsViewController *myAlbumClassifiedListingDetailsViewController = [[MyAlbumClassifiedListingDetailsViewController alloc] init];
                    myAlbumClassifiedListingDetailsViewController.selectGroupId = model.groupId;
                    myAlbumClassifiedListingDetailsViewController.selectGroupInt=[NSString stringWithFormat:@"%d",_selectedIndex];
                    
                    PhotoAlbumsViewController *photoAlbumsViewController = [[[PhotoAlbumsViewController alloc] init] autorelease];
                    photoAlbumsViewController.fromView = [NSString stringWithFormat:@"updatePhonto"];
                    NSMutableArray *array = [NSMutableArray arrayWithArray: bself.navigationController.viewControllers];
                    [array addObject:photoAlbumsViewController];
                    bself.navigationController.viewControllers = array;
                    [bself.navigationController pushViewController:myAlbumClassifiedListingDetailsViewController animated:YES];
                    [myAlbumClassifiedListingDetailsViewController release];
                });*/
                
                [[SavaData shareInstance] savaData:a KeyString:HOME_STATUS];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        if (tag == REQUEST_FOR_UPDATAPHOTO) {
            
            if ([resultStr isEqualToString:@"0"]) {
                NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
                if ([self.errorcodeStr isEqualToString:@"1005"]) {
                    errorStr = AUTO_RELOGIN;
                }
                UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alter show];
                [alter release];
            }else{
                NSDictionary *dataDic =[resultDictionary objectForKey:@"data"];
                NSArray *blogArray = [NSArray arrayWithObject:dataDic];
                [MessageSQL synchronizeBlog:blogArray WithUserID:USERID];
                //进入相册详情
//                NSString *groupId = [dataDic objectForKey:@"groupId"];
                

//                    MyAlbumClassifiedListingDetailsViewController *myAlbumClassifiedListingDetailsViewController = [[MyAlbumClassifiedListingDetailsViewController alloc] init];
//                    myAlbumClassifiedListingDetailsViewController.selectGroupId = groupId;
//                    NSString *selectedIndex = [NSString stringWithFormat:@"%d",_selectedIndex];
//                    myAlbumClassifiedListingDetailsViewController.selectGroupInt = selectedIndex;
//                    PhotoAlbumsViewController *photoAlbumsViewController = [[[PhotoAlbumsViewController alloc] init] autorelease];
//                    photoAlbumsViewController.fromView = [NSString stringWithFormat:@"updatePhonto"];
//                    NSMutableArray *array = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];
//                    [array addObject:photoAlbumsViewController];
//                    self.navigationController.viewControllers = array;
//                    [self.navigationController pushViewController:myAlbumClassifiedListingDetailsViewController animated:YES];
//                    [myAlbumClassifiedListingDetailsViewController release];
                    
                    
                    DiaryPictureClassificationModel *model = [self.JournalCategoryArray   objectAtIndex:_selectedIndex];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoDescriptionChangedNotification object:@{@"groupModel": model, @"messageModel": self.blogmodel}];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    return ;
                    
                
                
            }
        }
    }else{
        //         [MyToast showWithText:@"" :[UIScreen mainScreen].bounds.size.height/2-40];
    }
}
-(void)requestFail:(ASIFormDataRequest *)request
{
    [_mbHud setHidden:YES];
    self.rightBtn.enabled = YES;
    if ([Utilities checkNetwork]) {
        NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
        NSString  *text=nil;
        if (tag == REQUEST_FOR_ADDPHOTO) {
            text=@"添加照片失败";
        }
        if (tag == REQUEST_FOR_UPDATAPHOTO) {
            text=@"上传照片失败";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MyToast showWithText:text :[UIScreen mainScreen].bounds.size.height/2-40];
        });
    }
    
    [MyToast showWithText:@"网络连接异常，操作失败" :140];
}

#pragma mark -- alterview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ([ self.errorcodeStr isEqualToString:@"1005"]||[self.errorcodeStr isEqualToString:@"2007"]) {
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate]  showLoginVC];
    }
    if (alertView.tag == 2000) {
        
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [[EternalMemoryAppDelegate getAppDelegate]  showLoginVC];

    }
    //    if (alertView.tag == 1000 && buttonIndex == 1) {
    //        //跳转到VIP申请
    //    }
}
#pragma mark -- img
//- (void)dowork: (NSURL*) url imgName:(NSString *)imgName{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    NSError *error;
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    NSHTTPURLResponse *response;
//    
//    NSData* retData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    if (response.statusCode == 200) {
//        UIImage* img = [UIImage imageWithData:retData];
//        NSString *imgKeyStr =[NSString stringWithFormat:@"img"];
//        NSString *imgNameKeyStr = [NSString stringWithFormat:@"imgName"];
//        NSDictionary *dataDic = [NSDictionary dictionaryWithObjectsAndKeys:img,imgKeyStr,imgName,imgNameKeyStr,nil];
//        [self   performSelectorOnMainThread:@selector(saveImg:) withObject:dataDic waitUntilDone:YES];
//    }
//    [pool drain]; 
//}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)saveImg:(NSDictionary *)imgDic
{
    NSString *imgKeyStr =[NSString stringWithFormat:@"img"];
    NSString *imgNameKeyStr = [NSString stringWithFormat:@"imgName"];
    UIImage *img = [imgDic objectForKey:imgKeyStr];
    NSString *imgNameStr = [imgDic objectForKey:imgNameKeyStr];
    [self saveImage:img withName:imgNameStr];
}
- (void)imageFatchComplete:(ASIHTTPRequest *)request
{
}

- (void)imageFatchfailure:(ASIHTTPRequest *)request
{
//    NSError *error = [request error];
}

@end
