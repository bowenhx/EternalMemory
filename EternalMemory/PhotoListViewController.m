//
//  PhotoListViewController.m
//  EternalMemory
//
//  Created by FFF on 13-12-9.
//  Copyright (c) 2013年 sun. All rights reserved.
//


#import "PhotoListViewController.h"
#import "PhotoListCollectionViewCell.h"
#import "Utilities.h"
#import "SaveData.h"
#import "MessageSQL.h"
#import "MessageModel.h"
#import "RequestParams.h"
#import "IconDownloader.h"
#import "SDWebImageDownloader.h"
#import "EMPhotoSyncEngine.h"
#import "PhotoUploadEngine.h"
#import "PhotoListFormedRequest.h"
#import "MyPhotoDetailsViewController.h"
#import "StatusIndicatorView.h"
#import "EMRecordEngine.h"
#import "PhotoCategoryFlowLayout.h"
#import "DiaryPictureClassificationSQL.h"
#import "DiaryPictureClassificationModel.h"

#define PHOTO_CELL_IDENTIFER        @"defaultCell"

#define tDeleteConfirmationAlertTag     101
#define tMultiLoginAlertTag             102

#define tGetPhotoListRequest            201
#define tDeletingPhotoRequest           202

NSString * const PhotoListHasChangedNotification = @"PhotoListHasChangeNotification";

@interface PhotoListViewController ()<UIScrollViewDelegate, ASIHTTPRequestDelegate, MyPhotoDetailsDelegate,IconDewnloaderDelegate, SDWebImageDownloaderDelegate>
{
    BOOL        _editing;
    DiaryPictureClassificationModel *_diaryModel;
    MyPhotoDetailsViewController *_myPhotoDetailsViewController;

}

@property (nonatomic, retain) UIImageView            *collectionBackgroundView;
@property (nonatomic, retain) NSIndexPath            *deleteIndexPath;
@property (nonatomic, retain) PhotoListFormedRequest *activeRequest;
@property (nonatomic, retain) NSMutableArray         *photos;
@property (nonatomic, retain) NSMutableArray         *photosToDelete;
@property (nonatomic, retain) NSMutableDictionary    *imageDownlodInProgress;

@property (nonatomic, retain) UICollectionView       *collectionView;

@property (nonatomic, copy)   NSString               *albumId;

@end

@implementation PhotoListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}
- (instancetype)initWithDiaryModel:(DiaryPictureClassificationModel *)diaryModel {
    _diaryModel = [diaryModel retain];
    return [self initWithAlbumID:diaryModel.groupId];
}

- (instancetype)initWithAlbumID:(NSString *)groupID {
    
    if (self = [super init]) {
        _albumId = [groupID copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_activeRequest clearDelegatesAndCancel];
    [_albumId release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"self.photos"];
    [_activeRequest release];
    [_myPhotoDetailsViewController release];
    [_photosToDelete release];
    [_imageDownlodInProgress release];
    [_deleteIndexPath release];
    [_photos release];
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (SDWebImageDownloader *downloader in self.imageDownlodInProgress) {
        downloader.completionBlock = nil;
        downloader.delegate = nil;
        [downloader cancel];
    }
    
    [self.imageDownlodInProgress removeAllObjects];;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCollectionView];
    [self registerNotifications];
    
    self.middleBtn.hidden = YES;
    [self.rightBtn setTitle:@"删除照片" forState:UIControlStateNormal];
    self.rightBtn.frame=CGRectMake(SCREEN_WIDTH - 72, 6, 60, 31);
    if (iOS7) {
        self.rightBtn.frame=CGRectMake(SCREEN_WIDTH - 72, 26, 60, 31);
    }

    self.titleLabel.text = _diaryModel.title;
    _editing             = NO;
    self.photos = [MessageSQL getMessages:_albumId AndUserId:USERID];
    
    if ([Utilities checkNetwork] /*&& ![PhotoUploadEngine sharedEngine].isUploading*/) {
        [self requestForPhotoList];
    }
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPhotoAdded:) name:PhotosHaveSuccessfullyUploadedNotification object:nil];
    [self addObserver:self forKeyPath:@"self.photos" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"self.photos"]) {
        NSArray *photos = change[@"new"];
        if (photos.count > 0) {
            _collectionBackgroundView.hidden = YES;
        } else if (photos.count == 0) {
            _collectionBackgroundView.hidden = NO;
        }
        [_collectionView reloadData];
    }
}

- (void)newPhotoAdded:(NSNotification *)notification
{
    [self requestForPhotoList];
}

- (void)setupCollectionView;
{
    if (!_collectionView) {
        
        PhotoCategoryFlowLayout *flowLayout = [[PhotoCategoryFlowLayout alloc] init];
//        flowLayout.scrollDirection         = UICollectionViewScrollDirectionVertical;
//        flowLayout.minimumLineSpacing      = 5;
//        flowLayout.minimumInteritemSpacing = 5;
//        flowLayout.itemSize = CGSizeMake(100, 100);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:(CGRect){
            .origin.x       = 5,
            .origin.y       = self.navBarView.frame.size.height,
            .size.width     = SCREEN_WIDTH - 10,
            .size.height    = SCREEN_HEIGHT - (iOS7 ? 64 : 44)
        } collectionViewLayout:flowLayout];
        
        _collectionView.dataSource      = self;
        _collectionView.delegate        = self;
        _collectionView.bounces         = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[PhotoListCollectionViewCell class] forCellWithReuseIdentifier:PHOTO_CELL_IDENTIFER];
        [self.view addSubview:_collectionView];
        
        [_collectionView release];
        [flowLayout release];
        
        _collectionBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo"]];
        _collectionBackgroundView.contentMode = UIViewContentModeCenter;
        _collectionBackgroundView.frame = _collectionView.frame;
        
        [self.view addSubview:_collectionBackgroundView];
        [self.view bringSubviewToFront:_collectionBackgroundView];
        [_collectionBackgroundView release];
        
    } 
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PHOTO_CELL_IDENTIFER forIndexPath:indexPath];
    
    NSInteger itemCount = self.photos.count;
    if (itemCount > 0) {
        
        MessageModel *model = self.photos[indexPath.item];
        cell.checked = model.selected;
        cell.editing = _editing;
        
        [cell configCellWithModel:model];
        
        if (!collectionView.dragging && !collectionView.decelerating && !model.thumbnailImage) {
            [self startDownload:model forIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.item;
    if (_editing) {
        MessageModel *model = self.photos[indexPath.item];
        model.selected = !model.selected;
        PhotoListCollectionViewCell *cell = (PhotoListCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.checked = model.selected;
        NSDictionary *deleteDic = @{@"model": model, @"indexPath": indexPath};
        cell.checked ? [_photosToDelete addObject:deleteDic] : [_photosToDelete removeObject:deleteDic];

    } else {
        //进入照片预览界面
        if (!_myPhotoDetailsViewController) {
            _myPhotoDetailsViewController = [[MyPhotoDetailsViewController alloc] init ];
        }
        _myPhotoDetailsViewController.selectPhotoIndex=index;
        _myPhotoDetailsViewController.myPhotoDetailsDelegate = self;
        _myPhotoDetailsViewController.blogs = self.photos;
        [self presentViewController:_myPhotoDetailsViewController animated:YES completion:nil];
        
        NSArray *windows = [UIApplication sharedApplication].windows;
        for (UIWindow *window in windows) {
            if ([window isKindOfClass:[StatusIndicatorView class]]) {
                StatusIndicatorView *view = (StatusIndicatorView *)window;
                [view dismiss];
                break;
            }
        }
    }
}


#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    PhotoListFormedRequest *pRequest = (PhotoListFormedRequest *)request;
    NSInteger tag = [request.userInfo[@"tag"] integerValue];
    NSDictionary *dic = [[pRequest responseData] objectFromJSONData];

    NSInteger errorcode = [dic[@"errorcode"] integerValue];
#if TARGET_VERSION_LITE == 1
    [self multiLoginHandle:dic];
#endif
    switch (tag) {
        case tGetPhotoListRequest:
        {
            NSArray *arr = [pRequest handleRequestResultForGroupId:_albumId];
            if (arr) {
                self.photos = [arr mutableCopy];
                [_collectionView reloadData];
                if (_myPhotoDetailsViewController && ![EMRecordEngine sharedEngine].isRecording) {
                    _myPhotoDetailsViewController.blogs = self.photos;
                    [_myPhotoDetailsViewController reloadScrollView];
                }
            }
            arr = nil;
            break;
        }
        case tDeletingPhotoRequest:
        {
            if ([pRequest handleDeletingRequest])
            {
                NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
                NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
                
                for (NSDictionary *dic  in self.photosToDelete) {
                    
                    MessageModel *model = dic[@"model"];
                    NSIndexPath *indexPath = dic[@"indexPath"];
                    
                    [indexPaths addObject:indexPath];
                    [models addObject:model];
                    
                    [self.photos removeObject:model];
                    
                    [[NSFileManager defaultManager] removeItemAtPath:model.spaths error:nil];
                    [[NSFileManager defaultManager] removeItemAtPath:model.paths error:nil];
                }
                
                _editing = NO;
                [MessageSQL deletePhoto:models];
        
                [models removeAllObjects];
                [indexPaths removeAllObjects];
                models = nil;
                indexPaths = nil;
                
                if (self.photos.count == 0) {
                    self.photos = [NSMutableArray array];
                }
                
                [_photosToDelete removeAllObjects];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PhotosHaveSuccessfullyUploadedNotification object:nil];
                
                __block UICollectionView *collection = _collectionView;
                double delayInSeconds = 0.25;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    if (collection) {
                        [self rightBtnPressed];
                        for (MessageModel *model in self.photos) {
                            model.editStatus = YES;
                        }
                        [collection reloadData];

                    }
                });
            } else {
                //服务器不存在该blogId对应的数据，直接从本地删除。
                if (errorcode == 2007) {
                   NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
                    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *dic  in self.photosToDelete) {
                        
                        MessageModel *model = dic[@"model"];
                        NSIndexPath *indexPath = dic[@"indexPath"];
                        
                        [indexPaths addObject:indexPath];
                        [models addObject:model];
                        
                        [self.photos removeObject:model];
                        
                        [[NSFileManager defaultManager] removeItemAtPath:model.spaths error:nil];
                        [[NSFileManager defaultManager] removeItemAtPath:model.paths error:nil];
                    }
                    _editing = NO;
                    [MessageSQL deletePhoto:models];
                    [_collectionView deleteItemsAtIndexPaths:indexPaths];
                    
                    [models removeAllObjects];
                    [indexPaths removeAllObjects];
                    models = nil;
                    indexPaths = nil;
                    
                    __block UICollectionView *collection = _collectionView;
                    double delayInSeconds = 0.25;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        if (collection) {
                            [collection reloadData];
                        }
                    });
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSInteger tag = [request.userInfo[@"tag"] integerValue];
    if (tag == tDeletingPhotoRequest) {
//        [self rightBtnPressed];
    }
}

#pragma mark - MyPhotoDetailDelegate

- (void)reloadPhotoes:(BOOL)isReloadPhotoes
{
    if (isReloadPhotoes) {
        [_collectionView reloadData];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = alertView.tag;
    
    if (tag == tDeleteConfirmationAlertTag) {
        if (buttonIndex == 1) {
            //TODO: 删除接口
            
            NSMutableArray *blogids = [NSMutableArray arrayWithCapacity:0];

            for (int i = 0 ; i < _photosToDelete.count; i++) {
                NSDictionary *dic = _photosToDelete[i];
                MessageModel *model = dic[@"model"];
                NSString *blogid = model.blogId;
                if (blogid.length > 0) {
                    [blogids addObject:model.blogId];
                }
                
            }
            NSString *blogid = [blogids componentsJoinedByString:@","];
            
            if ([Utilities checkNetwork]) {
                [self requestForDeletingPhotosWithBlogid:blogid];
            } else {
                EMPhotoSyncEngine *engine = [EMPhotoSyncEngine sharedEngine];
                for (NSDictionary *dic in self.photosToDelete) {
                    MessageModel *modelToDelete = dic[@"model"];
                    if ([engine deleteOperationNeedsSyncWithModel:modelToDelete])
                    {
                        [self.photos removeObject:modelToDelete];

                        if (self.photos.count == 0) {
                            self.photos = [NSMutableArray array];
                        }
                        
                        _editing = NO;
                        __block UICollectionView *bcv = _collectionView;
                        double delayInSeconds = 0.75;
                        [[NSNotificationCenter defaultCenter] postNotificationName:PhotoListHasChangedNotification object:nil];
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [bcv reloadData];
                        });
                    }
                }
            }
        } else if(buttonIndex == 0) {

            for (NSDictionary *dic in _photosToDelete) {
                NSIndexPath *indexPath = dic[@"indexPath"];
                MessageModel *model = dic[@"model"];
                model.selected = NO;
                PhotoListCollectionViewCell *cell = (PhotoListCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
                [cell setChecked:NO];
            }
            [self rightBtnPressed];
        }
    } else if (tag == tMultiLoginAlertTag) {
        EternalMemoryAppDelegate *app = (EternalMemoryAppDelegate *)[UIApplication sharedApplication].delegate;
        [app showLoginVC];
    }
}

#pragma mark - ImageDownload

- (void)startDownload:(MessageModel *)model forIndexPath:(NSIndexPath *)indexPath
{
    SDWebImageDownloader *imageDownloader = self.imageDownlodInProgress[indexPath];
    if (!imageDownloader) {
        @autoreleasepool {
            __block UICollectionView *w_collectionView = _collectionView;
            NSDictionary *downloaderUserInfo = @{@"model": model, @"indexPath": indexPath};
            NSURL *url = [NSURL URLWithString:model.thumbnail];
            imageDownloader = [[SDWebImageDownloader alloc] init];
            imageDownloader.url = url;
            imageDownloader.userInfo = downloaderUserInfo;
            imageDownloader.completionBlock = ^(SDWebImageDownloader *downloader) {
                NSDictionary *userInfo = downloader.userInfo;
                UIImage *image = [UIImage imageWithData:downloader.imageData];
                MessageModel *model = userInfo[@"model"];
                NSIndexPath  *indexPath = userInfo[@"indexPath"];
                if (w_collectionView) {
                    PhotoListCollectionViewCell *cell = (PhotoListCollectionViewCell *)[w_collectionView cellForItemAtIndexPath:indexPath];
                    model.thumbnailImage = image;
                    [cell configCellWithModel:model];
                }
                
                NSString *path = [Utilities fullPathForSavingPhotos];
                NSString *imageName = [Utilities fileNameOfURL:url.absoluteString];
                NSString *fullPath = [path stringByAppendingPathComponent:imageName];
                [downloader.imageData writeToFile:fullPath atomically:YES];
                [MessageSQL updataSPathForImageURL:model.thumbnail withPath:fullPath];

                [self.imageDownlodInProgress removeObjectForKey:indexPath];
            };
            
            [imageDownloader start];
            
            self.imageDownlodInProgress[indexPath] = imageDownloader;
            [imageDownloader release];
        }
    } else {
        [imageDownloader start];
    }

//    IconDownloader *downloader = self.imageDownlodInProgress[indexPath];
//    if (!downloader) {
//        downloader = [[IconDownloader alloc] init];
//        downloader.messageModel = self.photos[indexPath.item];
//        __block typeof(self) bself = self;
//        __block UICollectionView *w_cv = _collectionView;
//        __block MessageModel *w_model = model;
//        __block NSIndexPath *w_indexPath = indexPath;
//        downloader.completionHandler = ^{
//            PhotoListCollectionViewCell *cell = (PhotoListCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
//            cell.image = model.thumbnailImage;
//            NSString *path = [model pathForSavedThumbnailImageToLocalPath];
//            [MessageSQL updataSPathForImageURL:model.thumbnail withPath:path];
//            [bself.imageDownlodInProgress removeObjectForKey:indexPath];
//
//        };
//        self.imageDownlodInProgress[indexPath] = downloader;
//        [downloader startDownload];
//        [downloader release];
//    }
}

- (void)loadImageOnScreen
{
    if (self.photos.count > 0) {
        NSArray *visibleIndexPaths = [_collectionView indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visibleIndexPaths) {
            
            MessageModel *model = self.photos[indexPath.item];
            if (model.thumbnailImage)
                continue;
            
            PhotoListCollectionViewCell *cell = (PhotoListCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
            
            UIImage *image = [model thumbnailImageAtLocalPath];
            if (!image) {
                [self startDownload:model forIndexPath:indexPath];
            } else {
                [cell configCellWithModel:model];
            }
        }
    }
}

- (void)imageDownloaderDidFinish:(SDWebImageDownloader *)downloader
{
    NSDictionary *userInfo = downloader.userInfo;
    UIImage *image = [UIImage imageWithData:downloader.imageData];
    MessageModel *model = userInfo[@"model"];
    NSIndexPath  *indexPath = userInfo[@"indexPath"];
    PhotoListCollectionViewCell *cell = (PhotoListCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    cell.image = image;
    model.thumbnailImage = image;
    NSString *path = [model pathForSavedThumbnailImageToLocalPath];

    [MessageSQL updataSPathForImageURL:model.thumbnail withPath:path];
    [self.imageDownlodInProgress removeObjectForKey:indexPath];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImageOnScreen];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!scrollView.decelerating) {
        [self loadImageOnScreen];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.imageDownlodInProgress.count > 0) {
        [self flushActivetedDownload];
    }
}

#pragma mark - private

- (void)multiLoginHandle:(NSDictionary *)dic
{
    NSInteger errorCode = [dic[@"errorcode"] integerValue];
    if (errorCode == 1005) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录异常" message:@"您的账号在异地登录，请重新登录" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.tag = tMultiLoginAlertTag;
        [alert show];
        [alert release];
        return;
    }
}

- (void)flushActivetedDownload
{
    for (SDWebImageDownloader *downloader in self.imageDownlodInProgress) {
        [downloader cancel];
    }
    
    [self.imageDownlodInProgress removeAllObjects];
}

- (void)requestForPhotoList
{
    NSString *savedVersion = [DiaryPictureClassificationSQL serverversionForGourpId:_albumId];
    NSString *clientVersion = (savedVersion == nil ? @"0" : savedVersion);
    NSInteger count = [MessageSQL getMessageCount];
    if (count == 0) {
        clientVersion = @"0";
    }
    NSString *getDeleteAttr = clientVersion.integerValue == 0 ? @"0" : @"1";
    NSURL *aUrl = [[RequestParams sharedInstance] photolist];
    PhotoListFormedRequest *request = [PhotoListFormedRequest requestWithURL:aUrl];
    [request setupRequestForGettingPhotoList];
    [request setPostValue:getDeleteAttr forKey:@"getdeleted"];
    [request setPostValue:clientVersion forKey:@"clientversion"];
    [request setPostValue:_albumId forKey:@"groupid"];
    request.delegate = self;
    request.userInfo = @{@"tag" : @(tGetPhotoListRequest)};
    [request startAsynchronous];
    self.activeRequest = request;
}

- (void)requestForDeletingPhotosWithBlogid:(NSString *)blogid
{
    NSURL *url = [[RequestParams sharedInstance] deletePhoto];
    PhotoListFormedRequest *request = [PhotoListFormedRequest requestWithURL:url];
    [request setupRequestForDeletingPhotoWithBlogid:blogid];
    request.userInfo = @{@"tag": @(tDeletingPhotoRequest)};
    request.delegate = self;
    [request startAsynchronous];
    self.activeRequest = request;
    
}
- (void)requestForDeletingPhoto:(MessageModel *)model
{
    NSURL *url = [[RequestParams sharedInstance] deletePhoto];
    PhotoListFormedRequest *request = [PhotoListFormedRequest requestWithURL:url];
    [request setupRequestForDeletingPhoto:model];
    request.delegate = self;
    request.userInfo = @{@"tag" : @(tDeletingPhotoRequest)};
    [request startAsynchronous];
    self.activeRequest = request;
    
}

- (void)backBtnPressed
{
    [self.activeRequest clearDelegatesAndCancel];
    self.activeRequest = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBtnPressed
{
    _editing = !_editing;
    NSArray *cells = [_collectionView visibleCells];
    for (PhotoListCollectionViewCell *cell in cells) {
        cell.editing = _editing;
    }
    if (_editing) {
        if (!self.photosToDelete) {
            self.photosToDelete = [[NSMutableArray alloc] init];
        }
        [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
        
    } else {
        [self.rightBtn setTitle:@"删除照片" forState:UIControlStateNormal];
        if (_photosToDelete.count > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"选中的照片将要被删除，确定要删除么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = tDeleteConfirmationAlertTag;
            [alert show];
            [alert release];
            return;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSArray *allDownloads = [self.imageDownlodInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownlodInProgress removeAllObjects];

}

@end
