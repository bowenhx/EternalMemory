//
//  PhotoCategoryViewController.m
//  EternalMemory
//
//  Created by FFF on 13-12-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MyAlbumClassifiedListingDetailsViewController.h"
#import "MAImagePickerFinalViewController.h"
#import "PhotoCategoryViewController.h"
#import "MylifeDetailViewController.h"
#import "AGImagePickerController.h"
#import "PhotoListViewController.h"
#import "UploadingPhotoViewCtrl.h"
#import "EMPhotoAlbumTopView.h"
#import "PhotoListFormedRequest.h"
#import "PhotoUploadRequest.h"
#import "EMAllMemoTemplateEngine.h"
#import "UIImage+UIImageExt.h"
#import "PhotoCategoryCell.h"
#import "PhotoUploadEngine.h"
#import "EMPhotoSyncEngine.h"
#import "ASINetworkQueue.h"
#import "RequestParams.h"
#import "MBProgressHUD.h"
#import "MessageModel.h"
#import "MessageSQL.h"
#import "DiaryPictureClassificationSQL.h"
#import "Utilities.h"
#import "MyToast.h"
#import "PhotoAlbumNavigationViewController.h"
#import "EMAlbumImage.h"
#import "ErrorCodeHandle.h"
#import "EMAllLifeMemoDAO.h"

#import "EMPhotoAlbumRequestEngine.h"
#import "EMMemorizeMessageModel.h"

#import "EMPhotoAlbumCollectionCell.h"
#import "EMEditLifeHighlightViewController.h"

#import "PhotoOrderViewController.h"
#import "MyToast.h"
#import "PhotoUploadEngine.h"



#define DBLog(format,...) NSLog((@"[%s][%s][%d]" format), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);

static NSString * const PhotoCellIdentifer = @"PhotoCellIdentifer";

@import ImageIO;

#define TABLE_CELL_IDENTIFER        @"DEFAULT_CELL"

@interface PhotoCategoryViewController ()<AGImagePickerControllerDelegate>
{
    __block NSInteger _photoCount ;
    BOOL     _hasMemos;
    BOOL     _hasAlbums;
}

@property (nonatomic, retain) NSMutableArray *photoCategories;
@property (nonatomic, retain) EMPhotoAlbumTopView *topView;
@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) UIImageView *coverView;

@property (nonatomic, assign) NSNumber *showCoverImage;
@property (nonatomic, retain) NSArray *memoPhotos;
@property (nonatomic, retain) NSArray *albums;

@end

@implementation PhotoCategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        _hasMemos = YES;
        _hasAlbums = YES;
    }
    
    return self;
}

- (void)dealloc
{
    [_albums release];
    [_memoPhotos release];
    [_photoCategories release];
    [_topView release];
    [_collectionView release];
    //移除所有通知。
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _photoCount = 0 ;
    self.middleBtn.hidden = YES;
    self.titleLabel.text  = @"相册";
    self.photoCategories  = [@[@"默认相册"] mutableCopy];
    self.rightBtn.frame=CGRectMake(SCREEN_WIDTH - 72, 6, 60, 31);
    if (iOS7) {
        self.rightBtn.frame=CGRectMake(SCREEN_WIDTH - 72, 26, 60, 31);
    }
    [self.rightBtn setTitle:@"选择照片" forState:UIControlStateNormal];
    
    [self layoutSubView];
    [self registerNotifications];
    [self getDataFromLocal];
    [self getData];
    
    if ((self.memoPhotos.count == 0 && self.albums.count == 0) && ![Utilities checkNetwork]) {
        [self shouldShowCoverImage];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMemo:) name:Refresh_Sort_Photo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAudio:) name:Delete_Life_Audio object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAudio:) name:Refresh_Life_Audio object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:PhotosHaveSuccessfullyUploadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:kPhotoGroupChangedNotification object:nil];

}

- (void)shouldShowCoverImage {
    [MyToast showWithText:@"请检查网络连接" :130];
    self.coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, iOS7? 64 : 44, SCREEN_WIDTH, SCREEN_HEIGHT - (iOS7 ? 64 : 44))];
    self.coverView.backgroundColor = RGB(238, 242, 245);
    self.coverView.userInteractionEnabled = YES;
    self.coverView.contentMode = UIViewContentModeCenter;
    [self.coverView setImage:[UIImage imageNamed:@"without_photo_img"]];
    [self.view addSubview:self.coverView];

}

#pragma mark - Notification Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"showCoverImage"]) {
    }
}

- (void)deleteAudio:(NSNotification *)notification {
    self.topView.diaryModel.audio = nil;
}

- (void)addAudio:(NSNotification *)notification {
    self.topView.diaryModel = (DiaryPictureClassificationModel *)notification.object;
}

- (void)refreshMemo:(NSNotification *)notification {
     
    NSArray *arr = (NSArray *)notification.object;
    
    __block typeof(self) bself = self;
    [arr enumerateObjectsUsingBlock:^(MessageModel *model, NSUInteger idx, BOOL *stop) {
        NSString *fileName = [Utilities fileNameOfURL:model.attachURL];
        NSData *data = UIImagePNGRepresentation(model.thumbnailImage);
        if (model.blogId.length > 0) {
            
            NSString *fullPath = [[Utilities lifeMemoPathOfUserUploaded] stringByAppendingPathComponent:fileName];
            [data writeToFile:fullPath atomically:YES];
            model.paths = [Utilities relativePathOfFullPath:fullPath];
            model.thumbnailType = MessageModelThumbnailTypeUserUpload;
            [bself.topView setImage:model.thumbnailImage ForPosition:idx];
            
        } else {
            NSString *fullPath = [[Utilities lifeMemoPathOfTemplate] stringByAppendingPathComponent:fileName];
            [data writeToFile:fullPath atomically:YES];
            model.templateImagePath = [Utilities relativePathOfFullPath:fullPath];
            model.paths = [Utilities relativePathOfFullPath:fullPath];
            model.templateImageURL = model.attachURL;
            model.thumbnailType = MessageModelThumbnailTypeTemplate;
            [bself.topView setTemplateImage:model.thumbnailImage forPosition:idx];
            
        }
//        [EMAllLifeMemoDAO updateMemoPath:model.paths forPhotoWall:model.photoWall];
        
    }];
    
    [self downloadMemoPhotos:arr];
    self.topView.photos = arr;
}

- (void)getDataFromLocal {
    self.memoPhotos = [EMAllLifeMemoDAO allMemoModels];
    self.topView.photos = _memoPhotos;
    __block typeof(self) bself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_apply(self.memoPhotos.count, dispatch_get_global_queue(0, 0), ^(size_t i) {
            MessageModel *model = bself.memoPhotos[i];
            model.thumbnailImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:model.paths]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model.blogId.length > 0) {
                    [bself.topView setImage:model.thumbnailImage ForPosition:i];
                } else {
                    [bself.topView setTemplateImage:model.thumbnailImage forPosition:i];
                }
            });
        });
    });
    self.topView.diaryModel = [DiaryPictureClassificationSQL getAllLifeAudio];
    self.albums = [DiaryPictureClassificationSQL albumsExceptForLifeMemoForAUser:USERID];
    [self.collectionView reloadData];
    
    self.showCoverImage = [NSNumber numberWithBool:(self.albums.count > 0 && self.memoPhotos.count > 0)];
}

- (void)getData {
    
    //TODO: 添加加载中的小视图
    if ([Utilities checkNetwork]) {
        __block typeof(self) bself = self;
        EMPhotoAlbumRequestEngine *engine = [[EMPhotoAlbumRequestEngine sharedEngine] retain];
        [engine startRequest];
        [engine setSuccessBlock:^(NSDictionary *albums) {
            bself.memoPhotos = albums[kEMAlubmRequestEngineResultMemoPhotoArray];
            bself.albums = albums[kEMAlbumRequestEngineResultAlbumArray];
            bself.topView.diaryModel = albums[kEMAlbumRequestEngineResultLifeTimeAlbum];
            bself.topView.photos = _memoPhotos;
            [bself downloadMemoPhotos:_memoPhotos];
            [bself.collectionView reloadData];
            //download image
            [EMAllLifeMemoDAO insertMemoModels:albums[kEMAlubmRequestEngineResultMemoPhotoArray]];
            
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.albums];
            [arr addObject:self.topView.diaryModel];
            [bself cacheAlbumData:arr];
           
        }];
        
        [engine setFailureBlock:^(NSString *errorCode, NSString *msg) {
            [ErrorCodeHandle handleErrorCode:errorCode AndMsg:msg];
        }];
        
        //检查本地有没有保存模板图片，如果没有， 从服务器下载存本地
        NSString *path = [Utilities lifeMemoPathOfTemplate];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        if (files.count == 0 || !files) {
            EMAllMemoTemplateEngine *engine = [[EMAllMemoTemplateEngine alloc] initWithURL:[RequestParams urlForAllLifeMemoTemplate]];
            [engine start];
            [engine setSuccessBlock:^(NSArray *allTemplates) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    NSMutableArray *arr = [NSMutableArray array];
                    dispatch_apply(allTemplates.count, dispatch_get_global_queue(0, 0), ^(size_t idx) {
                        MessageModel *templateModel = allTemplates[idx];
                        NSURL *url = [NSURL URLWithString:templateModel.attachURL];
                        NSData *imageData = [NSData dataWithContentsOfURL:url];
                        NSString *imageName = [Utilities fileNameOfURL:templateModel.attachURL];
                        NSString *fullPath = [path stringByAppendingPathComponent:imageName];
                        [imageData writeToFile:fullPath atomically:YES];
//                        [arr addObject:templateModel.attachURL];
                        [EMAllLifeMemoDAO updateTemplatePath:fullPath forPhotoWall:templateModel.photoWall];
                    });
                });
            }];
        }
        
        if (self.memoPhotos.count > 0 && self.albums.count > 0) {
                [self.coverView removeFromSuperview];
        }
        
    } else {
        
    }
}

- (void)layoutSubView {
    if (!_topView) {
        self.topView = [[EMPhotoAlbumTopView alloc] initWithFrame:CGRectMake(0, iOS7 ? 64 : 44, SCREEN_WIDTH, 180)];
        [self.topView setItemCount:5];
        _topView.backgroundColor = RGB(237, 241, 244);
        [self.view addSubview:_topView];
        
        [self.topView setSelectBlock:^(NSArray *items, DiaryPictureClassificationModel *model, NSInteger idx) {
            //items 中存放EMMemoryMessageModel 用来显示一生记忆中的照片, model: voiceSize, voiceUrl, duration三个字段表示录音。
            //TODO: 跳浏览大图界面。
            if (items.count == 0 || items == nil) {
                return ;
            }
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:items];
            if (items.count > 1)
            {
                [array insertObject:[array lastObject] atIndex:0];
                [array addObject:[array objectAtIndex:1]];
            }
            MylifeDetailViewController *mylifeDetailViewController = [[MylifeDetailViewController alloc]initWithDataArray:array withPage:(idx+ 1) withModel:model comeInStyle:2 albumArray:nil];
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mylifeDetailViewController];
            PhotoAlbumNavigationViewController *navi = [[PhotoAlbumNavigationViewController alloc] initWithRootViewController:mylifeDetailViewController];
            [self presentViewController:navi animated:YES completion:NULL];
            [mylifeDetailViewController release];
            [navi release];
        }];
    }
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 12;
        flowLayout.minimumInteritemSpacing = 12;
        flowLayout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
        flowLayout.itemSize = CGSizeMake(95, 125);

        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.topView.frame.size.height + (iOS7 ? 64 : 44), SCREEN_WIDTH, SCREEN_HEIGHT - self.topView.frame.size.height - self.navBarView.frame.size.height) collectionViewLayout:flowLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.backgroundColor = RGB(237, 241, 244);
        [self.collectionView registerClass:[EMPhotoAlbumCollectionCell class] forCellWithReuseIdentifier:PhotoCellIdentifer];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        [self.view addSubview:_collectionView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getDataFromLocal];
    
}
- (void)uploadListCtrl:(NSNotification *)info
{
    DiaryPictureClassificationModel *model = [info object];
    [self pushPhotoListViewController:model];
}
#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _photoCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCategoryCell *cell = (PhotoCategoryCell *)[tableView dequeueReusableCellWithIdentifier:TABLE_CELL_IDENTIFER];
    
    __block typeof(self) bself = self;
    cell.photoCount             = _photoCount;
    cell.catagoryNameLabel.text = _photoCategories[indexPath.row];
    cell.folderBtnPressedBlock  = ^{
        PhotoListViewController *plvc = [[PhotoListViewController alloc] init];
        [bself.navigationController pushViewController:plvc animated:YES];
        [plvc release];
    };
    
    return cell;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _albums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EMPhotoAlbumCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifer forIndexPath:indexPath];
    DiaryPictureClassificationModel *model = self.albums[indexPath.item];

    [cell configCellWithDiaryModel:model];
    
    if (!model.thumbnail) {
        
        model.thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:model.latestPhotoPath]]];
        
        if (model.thumbnail) {
            cell.image = model.thumbnail;
            return cell;
        }
        
        [self downloadImageForIndexPath:indexPath];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DiaryPictureClassificationModel *ablumModel = self.albums[indexPath.item];
    [self pushPhotoListViewController:ablumModel];
}

- (void)pushPhotoListViewController:(DiaryPictureClassificationModel *)ablumModel
{
    PhotoListViewController *listViewController = [[PhotoListViewController alloc] initWithDiaryModel:ablumModel];
    [self.navigationController pushViewController:listViewController animated:YES];
    [listViewController release];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 0);
}

#pragma mark - private
- (void)downloadMemoPhotos:(NSArray *)photos {
    
    __block typeof(self) bself = self;
    dispatch_queue_t downloadQueue = dispatch_queue_create("com.iyhjy.download", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(downloadQueue, ^{
        dispatch_apply(photos.count, downloadQueue, ^(size_t i) {
            MessageModel *model = photos[i];
            NSURL *imageURL = [NSURL URLWithString:model.attachURL];
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:imageURL];
            
            [NSURLConnection sendAsynchronousRequest:imageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (data) {
                    NSString *urlStr = response.URL.absoluteString;
                    model.thumbnailImage = [UIImage imageWithData:data];
                    model.rawImage = [UIImage imageWithData:data];
                    NSString *fileName = [Utilities fileNameOfURL:urlStr];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (model.blogId.length > 0) {
                            NSString *fullPath = [[Utilities lifeMemoPathOfUserUploaded] stringByAppendingPathComponent:fileName];
                            [data writeToFile:fullPath atomically:YES];
                            model.paths = [Utilities relativePathOfFullPath:fullPath];
                            model.thumbnailType = MessageModelThumbnailTypeUserUpload;
                            [bself.topView setImage:model.thumbnailImage ForPosition:i];
                        } else {
                            NSString *fullPath = [[Utilities lifeMemoPathOfTemplate] stringByAppendingPathComponent:fileName];
                            [data writeToFile:fullPath atomically:YES];
                            model.templateImagePath = [Utilities relativePathOfFullPath:fullPath];
                            model.paths = [Utilities relativePathOfFullPath:fullPath];
                            model.templateImageURL = model.attachURL;
                            model.thumbnailType = MessageModelThumbnailTypeTemplate;
                            [bself.topView setTemplateImage:model.thumbnailImage forPosition:i];
                        }
                        
                        //                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [EMAllLifeMemoDAO updateMemoPath:model.paths forPhotoWall:model.photoWall];
                        
//                        });
                    });
                }
                //TODO: 图片缓存本地
            }];
        });
        
        
    });
    
    dispatch_release(downloadQueue);
}

- (void)downloadImageForIndexPath:(NSIndexPath *)indexPath {
    
    __block typeof(self) bself = self;
    DiaryPictureClassificationModel *model = self.albums[indexPath.item];
    NSURL *imageUrl = [NSURL URLWithString:model.latestPhotoURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data) {
            EMPhotoAlbumCollectionCell *cell = (EMPhotoAlbumCollectionCell *)[bself.collectionView cellForItemAtIndexPath:indexPath];
            model.thumbnail = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell configCellWithDiaryModel:model];
            });
            
            //缓存数据
            
            NSString *path = [[Utilities fullPathForSavingPhotos] stringByAppendingPathComponent:[Utilities fileNameOfURL:model.latestPhotoURL]];
            [data writeToFile:path atomically:YES];
            NSString *relativePath = [Utilities relativePathOfFullPath:path];
            [DiaryPictureClassificationSQL updateDiaryForGroupId:model.groupId photoPath:relativePath WithUserID:USERID];
            
        }
        //TODO: 图片存本地
        //相册封面存本地
        //更新数据库路径
        
    }];
}

- (void)getPhotoCountFromServer
{
    if ([Utilities checkNetwork]) {
        __block UITableView *tableView = _tableView;
        PhotoListFormedRequest *request = [[PhotoListFormedRequest alloc] initWithURL:[[RequestParams sharedInstance] photolist]];
        [request setupRequestForGettingPhotoList];
        [request startAsynchronous];
        [request setCompletionBlock:^{
            NSData *data = [request responseData];
            NSDictionary *dic = [data objectFromJSONData];
            NSInteger success = [dic[@"success"] integerValue];
            if (success == 1) {
                NSArray *arr = dic[@"data"];
                _photoCount = arr.count;
                arr = nil;
                [tableView reloadData];
            }
            data = nil;
            dic = nil;
        }];
    } else {
        _photoCount = [MessageSQL getMessageCount];
        [_tableView reloadData];
    }
}

- (void)cacheAlbumData:(NSArray *)models {
    [models enumerateObjectsUsingBlock:^(DiaryPictureClassificationModel *model, NSUInteger idx, BOOL *stop) {
        if (model.latestPhotoURL.length <= 0) {
            return ;
        }
        model.latestPhotoPath = [self relativePathForSaveModel:model];
    }];
    
    [DiaryPictureClassificationSQL addDiaryPictureClassificationes:models];
    
}

- (NSString *)relativePathForSaveModel:(DiaryPictureClassificationModel *)model {
    return [[Utilities relativePathForSavingPhotos] stringByAppendingPathComponent:[model.latestPhotoURL lastPathComponent]];
}

-(void)middleBtnPressed{
    
    PhotoOrderViewController *photoOrderVC = [[PhotoOrderViewController alloc] init];
    [self.navigationController pushViewController:photoOrderVC animated:YES];
    [photoOrderVC release];
}

- (void)backBtnPressed
{   
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBtnPressed
{

//---------------------------上传照片---------------------------------------
    if (self.albums.count < 4 && ![Utilities checkNetwork]) {
        [MyToast showWithText:@"请链接网络获取分组信息" :130];
        return;

    }else{
        UploadingPhotoViewCtrl *uploadingPhotoVC = [[UploadingPhotoViewCtrl alloc] initWithNibName:iOS7 ? @"UploadingPhotoViewCtrl-5": @"UploadingPhotoViewCtrl" bundle:nil];
        [self.navigationController pushViewController:uploadingPhotoVC animated:YES];
        [uploadingPhotoVC release];
        return;
    }
//------------------------------------------------------------------
    NSURL *url = [[RequestParams sharedInstance] uploadPhoto];
    BOOL isUploading = [[PhotoUploadEngine sharedEngine] isUploading];
    if (isUploading) {
        [MyToast showWithText:@"还有照片正在上传，稍等一会儿哟" :130];
        return;
    }
    ASINetworkQueue *uploadQueue = [ASINetworkQueue queue];
    __block typeof(self) bself = self;
    AGIPCDidFail failBlock = ^(NSError *error) {
    };
    
    AGIPCDidFinish finashBlock = ^(NSArray *info) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (info.count == 1) {
                MAImagePickerFinalViewController *vc = [[MAImagePickerFinalViewController alloc] init];
                UIImage *image = [self imageFromAsset:info[0]];
                vc.sourceImage = image;
                vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                double delayInSeconds = 0.75;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [bself presentViewController:vc animated:YES completion:nil];
                });
                
                return;
            }
            
            for (ALAsset *aAsset in info) {
                @autoreleasepool {
                    PhotoUploadRequest *request = [[PhotoUploadRequest alloc] initWithURL:url];
                    UIImage *aImage = [[self fullSizeImageForAssetRepresentation:aAsset.defaultRepresentation] fixOrientation];
                    MessageModel *model = [[self modelWithImage:aImage] retain];
                    NSDictionary *userInfo = @{kModel: model};
                    [request setupRequestForUplodingImage:aImage groupid:@""];
                    request.userInfo = userInfo;
                    [uploadQueue addOperation:request];
                    [request release];
                    aImage = nil;
                    [model release];
                }
            }
            
            if ([Utilities checkNetwork]) {
                PhotoUploadEngine *uploadEngine = [PhotoUploadEngine sharedEngine];
                uploadEngine.uploadQueue = uploadQueue;
                [uploadEngine startUpload];
            }
            else
            {
                EMPhotoSyncEngine *syncEngine = [EMPhotoSyncEngine sharedEngine];
                
                NSMutableArray *imagesToUpload = [[NSMutableArray alloc] init];
                for (int i = 0 ; i < info.count; i++) {
                    @autoreleasepool {
                        ALAsset *asset = info[i];
                        UIImage *aImage = [self fullSizeImageForAssetRepresentation:asset.defaultRepresentation];
                        [imagesToUpload addObject:aImage];
                    }
                }
                
                [syncEngine uploadOperationNeedsSyncWithImages:imagesToUpload upGroupId:@""];
                [imagesToUpload release];
            }
        });
    };
    
    AGImagePickerController *pickerController = [[AGImagePickerController alloc] initWithDelegate:nil failureBlock:failBlock successBlock:finashBlock maximumNumberOfPhotosToBeSelected:9 shouldChangeStatusBarStyle:YES toolbarItemsForManagingTheSelection:nil andShouldShowSavedPhotosOnTop:YES];
    
    [self presentViewController:pickerController animated:YES completion:nil];
    [pickerController release];
    
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recountPhotos:) name:PhotoListHasChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPhotoCountFromServer) name:PhotosHaveSuccessfullyUploadedNotification object:nil];
}

-(UIImage *)fullSizeImageForAssetRepresentation:(ALAssetRepresentation *)assetRepresentation
{
    UIImage *result = nil;
    NSData *data = nil;
    
    uint8_t *buffer = (uint8_t *)malloc(sizeof(uint8_t)*[assetRepresentation size]);
    if (buffer != NULL) {
        NSError *error = nil;
        NSUInteger bytesRead = [assetRepresentation getBytes:buffer fromOffset:0 length:[assetRepresentation size] error:&error];
        data = [NSData dataWithBytes:buffer length:bytesRead];
        
        free(buffer);
    }
    
    if ([data length])
    {
        CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        
        [options setObject:(id)kCFBooleanTrue forKey:(id)kCGImageSourceShouldAllowFloat];
        [options setObject:(id)kCFBooleanTrue forKey:(id)kCGImageSourceCreateThumbnailFromImageAlways];
        [options setObject:(id)[NSNumber numberWithFloat:640.0f] forKey:(id)kCGImageSourceThumbnailMaxPixelSize];
        //[options setObject:(id)kCFBooleanTrue forKey:(id)kCGImageSourceCreateThumbnailWithTransform];
        
        CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
        
        if (imageRef) {
            result = [UIImage imageWithCGImage:imageRef scale:[assetRepresentation scale] orientation:(UIImageOrientation)[assetRepresentation orientation]];
            CGImageRelease(imageRef);
        }
        
        if (sourceRef)
            CFRelease(sourceRef);
    }
    
    return result;
}

- (MessageModel *)modelWithImage:(UIImage *)image
{
    MessageModel *model = [[MessageModel alloc] init];
    model.rawImage = image;
    model.status   = @"2";
    return [model autorelease];
}

- (UIImage *)dataOfImageFromAsset:(ALAsset *)asset
{
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    Byte *buffer = (Byte*)malloc(rep.size);
    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    UIImage *image = [UIImage imageWithData:data scale:rep.scale];
    image = image.fixOrientation;
    return image;
}

- (UIImage *)imageFromAsset:(ALAsset *)asset
{
    CGImageRef imgRef = asset.defaultRepresentation.fullScreenImage;
    ALAssetOrientation oriention = asset.defaultRepresentation.orientation;
    UIImageOrientation imageOrientation = (UIImageOrientation)oriention;
    UIImage *image = [UIImage imageWithCGImage:imgRef scale:asset.defaultRepresentation.scale orientation:imageOrientation];
    imgRef = nil;
    return image;
}

- (NSArray *)photosFromAssets:(NSArray *)assets
{
    NSArray *photos = [assets retain];
    NSMutableArray *imagesToUpload = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < assets.count; i++) {
        @autoreleasepool {
            ALAsset *asset = [assets[i] retain];
            UIImage *image = [self imageFromAsset:asset];
            [imagesToUpload addObject:image];
            [asset release];
        }
    }

    [photos release];
    
    return [imagesToUpload autorelease];
}

- (void)setupTableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:(CGRect){
            .origin.x    = 0,
            .origin.y    = self.navBarView.frame.origin.y + self.navBarView.frame.size.height,
            .size.width  = SCREEN_WIDTH,
            .size.height = SCREEN_HEIGHT - (iOS7 ? 64 : 44)
        } style:UITableViewStylePlain];
        
        _tableView.dataSource      = self;
        _tableView.delegate        = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight       = 300;
        
        [_tableView registerNib:[UINib nibWithNibName:@"PhotoCategoryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:TABLE_CELL_IDENTIFER];
        [self.view addSubview:_tableView];
        [_tableView release];
    }
}

- (void)recountPhotos:(NSNotification *)notification
{
    _photoCount = [MessageSQL getMessageCount];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
