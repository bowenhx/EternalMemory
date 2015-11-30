//
//  EMEditLifeHighlightViewController.m
//  EternalMemory
//
//  Created by FFF on 14-3-10.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "EMEditLifeHighlightViewController.h"
#import "EMPhotoAlbumCollectionCell.h"
#import "PhotoOrderViewController.h"
#import "PhotoListCollectionViewCell.h"
#import "DiaryPictureClassificationModel.h"
#import "PhotoListViewController.h"
#import "MessageSQL.h"
#import "Utilities.h"
#import "EMEditLifeMemoCollectionHeaderView.h"
#import "PhotoCategoryFlowLayout.h"
#import "MessageModel.h"
#import "EMAllMemoTemplateEngine.h"
#import "ASIFormDataRequest.h"
#import "MyToast.h"
#import "RequestParams.h"
#import "PhotoListFormedRequest.h"
#import "DiaryPictureClassificationSQL.h"
#import "EMAllLifeMemoDAO.h"

NSInteger const DeleteAlert = 100;
NSInteger const PopAlert    = 101;

@interface EMEditLifeHighlightViewController ()<UIScrollViewDelegate> {
    NSInteger _itemIndexToDel;
}

@property (nonatomic, retain) NSDictionary *albumDic;
@property (nonatomic, retain) NSArray      *photoList;
@property (nonatomic, assign) id           albumDataSource;
@property (nonatomic, retain) NSString     *currentAlbumTitle;

@property (nonatomic, retain) NSMutableDictionary *imageDownloaderInprogress;
@property (nonatomic, retain) EMPhotoAlbumViewItem *currentItem;
@property (nonatomic, retain) UIView       *animationView;

@property (nonatomic, retain) ASIFormDataRequest *photoListRequest;

@end

@implementation EMEditLifeHighlightViewController

- (void)dealloc {
    [_currentItem release];
    [_animationView release];
    [_currentAlbumTitle release];
    [_photoList release];
    [_albumDic release];
    
    [self.topView removeObserver:self forKeyPath:@"photos"];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.albumDic = @{@"童年": @1,
                      @"青年": @2,
                      @"少年": @3, 
                      @"中年": @4,
                      @"老年": @5,
                      @"其他": @6
                      };
    self.albumDataSource = _albumDic;

    self.photoList = @[@1,@2,@3,@4,@4,@4,@1];
    self.topView.editMode = YES;
    [self.collectionView registerClass:[PhotoListCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoListIdentifer"];
    [self.rightBtn setTitle:@"下一步" forState:UIControlStateNormal];
    self.rightBtn.enabled = self.topView.photos.count > 0 ;
    [self.collectionView reloadData];
    __block typeof(self) bself = self;
    EMAllMemoTemplateEngine *engine = [[EMAllMemoTemplateEngine alloc] initWithURL:[RequestParams  urlForAllLifeMemoTemplate]];
    [engine start];
    [engine setSuccessBlock:^(NSArray *allTemplates) {
        bself.topView.templateModels = allTemplates;
    }];
    [engine setFailureBlock:^(id obj) {
        
    }];
    
    UISwipeGestureRecognizer *swipGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipSwitch:)];
    swipGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.collectionView addGestureRecognizer:swipGesture];
    [swipGesture release];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    
    [self.topView addObserver:self forKeyPath:@"photos" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    

    [self.topView setDeleteBlock:^(NSInteger idx) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要删除这张照片么？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        _itemIndexToDel = idx;
        alert.tag = DeleteAlert;
        [alert show];
        [alert release];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger tag = alertView.tag;
    if (buttonIndex == 1) {
        switch (tag) {
            case DeleteAlert:
                [self.topView removeItemAtPosition:_itemIndexToDel];
                break;
            case PopAlert:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
        }
    }
}

- (void)getData {
    return;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"photos"]) {
        NSArray *arrNew = change[@"new"];

        if (arrNew.count > 0) {
            self.rightBtn.enabled = YES;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *str1 = @"set";
    NSString *str2 = @"Orientation:";
    NSString *str3 = [NSString stringWithFormat:@"%@%@",str1, str2];
    if ([[UIDevice currentDevice] respondsToSelector:NSSelectorFromString(str3)]) {
        [[UIDevice currentDevice] performSelector:NSSelectorFromString(str3)
                                       withObject:(id)UIInterfaceOrientationPortrait];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getDataFromLocal];
}
- (void)swipSwitch:(UISwipeGestureRecognizer *)gesture {
    if ([self.albumDataSource isKindOfClass:[NSArray class]]) {
        [self backBtnPressed];
    }
}

- (void)rightBtnPressed {
    if (![Utilities checkNetwork]) {
        [MyToast showWithText:@"请检查网络连接" :130];
        return;
    }
    
    if (self.audio) {
        self.topView.diaryModel.audio = [self.audio copy];
    }
    
    PhotoOrderViewController *vc = [[PhotoOrderViewController alloc] init];
    vc.dataSource = self.topView.photos;
    vc.diaryModel = self.topView.diaryModel;
    [self.navigationController pushViewController:vc animated:NO];
    [vc release];
    
    self.audio = nil;
    
    for (MessageModel *model in self.topView.photos) {
    }
}

- (void)backBtnPressed {
    if ([_albumDataSource isKindOfClass:[NSDictionary class]]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要放弃当前修改么？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alert.tag = PopAlert;
        [alert show];
        [alert release];
//        [self dismissViewControllerAnimated:YES completion:NULL];

    } else if ([_albumDataSource isKindOfClass:[NSArray class]]) {
        self.albumDataSource = _albumDic;
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    if ([self.albumDataSource isKindOfClass:[NSDictionary class]]) {
        return _albumDic.count;
    } else if ([_albumDataSource isKindOfClass:[NSArray class]]) {
        return _photoList.count;
    }
    return 0;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    //TODO: 数据源切换动画效果： 先删除所有相册的Cell， 然后再将所有照片的Cell添加到视图上。delay
    if ([_albumDataSource isKindOfClass:[NSDictionary class]]) {
        NSString *groupId = [self.albums[indexPath.item] groupId];
        self.photoList = [self photosForGroup:groupId];
        self.currentAlbumTitle = [self.albums[indexPath.item] title];
        self.albumDataSource = _photoList;
        [self.collectionView registerClass:[EMEditLifeMemoCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        
        if (self.photoList.count == 0) {
            [self ememo_getPhotosFromServerOfAlbum:groupId];
            return;
        }
        [collectionView reloadData];
        
    } else if ([_albumDataSource isKindOfClass:[NSArray class]]) {
        PhotoListCollectionViewCell *cell = (PhotoListCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (self.photoList.count>0) {
            MessageModel *model = self.photoList[indexPath.item];
            [self animateCell:cell andModel:model];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_albumDataSource isKindOfClass:[NSDictionary class]]) {
        EMPhotoAlbumCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCellIdentifer" forIndexPath:indexPath];
        
        if (self.albums.count > 0 ) {
            DiaryPictureClassificationModel *model = self.albums[indexPath.item];
            [cell configCellWithDiaryModel:model];
            if (!model.thumbnail) {
                [self performSelector:@selector(downloadImageForIndexPath:) withObject:indexPath];
            }
        }
        
        return cell;
    } else if ([_albumDataSource isKindOfClass:[NSArray class]]) {
        PhotoListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoListIdentifer" forIndexPath:indexPath];
        if (self.photoList.count > 0) {
            MessageModel *model = self.photoList[indexPath.item];
            [cell configCellWithModel: model];
            if (model.thumbnailImage) {
                return cell;
            }
            if (!collectionView.dragging && !collectionView.decelerating) {
                [self memo_downloadPhotoImage:model cell:cell];
            }
            return cell;
        }
        
    }
    
    return nil;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    
    EMEditLifeMemoCollectionHeaderView *reusabelView = (EMEditLifeMemoCollectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    
    reusabelView.title = _currentAlbumTitle;
    reusabelView.backgroundColor = [UIColor clearColor];
    
    return reusabelView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_albumDataSource isKindOfClass:[NSDictionary class]]) {
        return CGSizeMake(95, 125);
    } if ([_albumDataSource isKindOfClass:[NSArray class]]) {
        return CGSizeMake(95, 95);
    }
    
    return CGSizeZero;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if ([_albumDataSource isKindOfClass:[NSArray class]]) {
         return CGSizeMake(SCREEN_WIDTH, 30);
    }
    return CGSizeZero;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.albumDataSource isKindOfClass:[NSArray class]]) {
        [self loadImageOnScreen];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.albumDataSource isKindOfClass:[NSArray class]]) {
        [self loadImageOnScreen];
    }
}

#pragma mark - private

- (void)loadImageOnScreen {
    if (self.photoList.count > 0) {
        NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visibleIndexPaths) {
            MessageModel *model = self.photoList[indexPath.item];
            PhotoListCollectionViewCell *cell = (PhotoListCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell configCellWithModel:model];
            
            if (!model.thumbnailImage) {
                [self memo_downloadPhotoImage:model cell:cell];
            }
        }
    }
}

- (void)memo_downloadPhotoImage:(MessageModel *)model cell:(PhotoListCollectionViewCell *)cell {
    

    NSURL *url = [NSURL URLWithString:model.thumbnail];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            
            cell.image = image;
            model.thumbnailImage = image;
        }
    }];
}

- (void)ememo_getPhotosFromServerOfAlbum:(NSString *)groupId {
    self.photoListRequest = [ASIFormDataRequest requestWithURL:[[RequestParams sharedInstance] photolist]];
    self.photoListRequest.timeOutSeconds = 60;
    [self.photoListRequest setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [self.photoListRequest setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [self.photoListRequest setPostValue:groupId forKey:@"groupid"];
    [self.photoListRequest setPostValue:@"0" forKey:@"getdeleted"];

    [self.photoListRequest startAsynchronous];
    
    __block ASIFormDataRequest *brequest = _photoListRequest;
    __block typeof(self) bself = self;
    [self.photoListRequest setCompletionBlock:^{
        
        NSData *data = [brequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *message = dic[@"message"];
        NSInteger success = [dic[@"success"] integerValue];
        if (success) {
            NSArray *photosDic = dic[@"data"];
            NSMutableArray *photos = [NSMutableArray array];
            [photosDic enumerateObjectsUsingBlock:^(NSDictionary *dic , NSUInteger idx, BOOL *stop) {
                MessageModel *model = [[MessageModel alloc] initWithDict:dic];
                NSString *imageName = [Utilities fileNameOfURL:model.thumbnail];
                NSString *path = [[Utilities fullPathForSavingPhotos] stringByAppendingPathComponent:imageName];
                 model.spaths = path;
                model.status = @"1";
                [photos addObject:model];
                
               
                [model release];
            }];
            
            [MessageSQL addBlogs:photos inGroup:groupId];
            bself.photoList = [MessageSQL getGroupIDMessages:groupId AndUserId:USERID];
            bself.albumDataSource = bself.photoList;
            dispatch_async(dispatch_get_main_queue(), ^{
                [bself.collectionView reloadData];
            });
           
        } else {
        }
    }];
    
    [self.photoListRequest setFailedBlock:^{
        
    }];
}

- (UICollectionViewLayout *)photoListFlowLayout {
    PhotoCategoryFlowLayout *flowLayout = [[PhotoCategoryFlowLayout alloc] init];
    flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 44);
    
    return [flowLayout autorelease];
    
}

- (void)animateCell:(PhotoListCollectionViewCell *)cell andModel:(MessageModel *)model{
    
    self.currentItem = [self firstEmptyItem];
    //找不到没有图片的item， 则直接返回， 不做动画。
    if (!_currentItem) {
        return;
    }
    [self.topView setPhoto:model atPosition:_currentItem.itemPosition];
    CGSize startSize = cell.frame.size;
    CGPoint originPosition = cell.center;
    
    CGPoint positionInRootView = [self.view convertPoint:originPosition fromView:self.collectionView];
    
    self.animationView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, startSize}];
    self.animationView.center = positionInRootView;
    self.animationView.layer.contents = (id)[cell.image CGImage];
    self.animationView.layer.masksToBounds = YES;
    [self.view addSubview:_animationView];
    [_animationView release];
    
    CGPoint endPosition = [self.view convertPoint:_currentItem.center fromView:self.topView.scrollView];
    if (endPosition.x > 320) {
        //TODO: 终点坐标超出屏幕，处理滚动。
    }
    
    CABasicAnimation *positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnim.fromValue = [NSValue valueWithCGPoint:positionInRootView];
    positionAnim.toValue = [NSValue valueWithCGPoint:endPosition];
    
    CABasicAnimation *boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnim.fromValue = [NSValue valueWithCGRect:(CGRect){CGPointZero, startSize}];
    boundsAnim.toValue = [NSValue valueWithCGRect:(CGRect){CGPointZero, _currentItem.itemImageSize}];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.delegate = self;
    group.animations = @[positionAnim, boundsAnim];
    group.duration = 0.1;
    
    [_animationView.layer addAnimation:group forKey:@"kAViewAnimation"];
    
    _animationView.frame = (CGRect){CGPointZero, _currentItem.itemImageSize};
    _animationView.center = endPosition;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    //TODO: 动画结束，移除self.animatView, 设置item的image；
    UIImage *image = [UIImage imageWithCGImage:(CGImageRef)_animationView.layer.contents];
    _currentItem.image = image;
    [self.animationView removeFromSuperview];
}

- (EMPhotoAlbumViewItem *)firstEmptyItem
{
    EMPhotoAlbumViewItem *item = nil;
    for (EMPhotoAlbumViewItem *aItem in self.topView.photoItems) {
        if (aItem.image) {
            continue;
        } else {
            item = aItem;
            break;
        }
    }
    
    return item;
}

- (NSArray *)photosForGroup:(NSString *)groupID {
    return [MessageSQL getGroupIDMessages:groupID AndUserId:USERID];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
