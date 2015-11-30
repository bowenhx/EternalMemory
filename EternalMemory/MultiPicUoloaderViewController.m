 //
//  MultiPicUoloaderViewController.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-8-20.
//  Copyright (c) 2013年 sun. All rights reserved.
//


#import "RequestParams.h"
#import "MyAlbumClassifiedListingDetailsViewController.h"
#import "AGImagePickerController.h"
#import "PhotoAlbumsViewController.h"
#import "MultiPicUoloaderViewController.h"
#import "DiaryPictureClassificationModel.h"
#import "UIImage+UIImageExt.h"
#import "DiaryPictureClassificationSQL.h"
#import "MessageModel.h"
#import "MyToast.h"
#import "MessageSQL.h"
#import "DiaryPictureClassificationModel.h"

#import <AssetsLibrary/AssetsLibrary.h>

#define MaxNumOfPhoto           6

@interface MultiPicUoloaderViewController ()

@end

@implementation MultiPicUoloaderViewController

- (void)dealloc
{
    
    [_assets removeAllObjects];
    [_thumbnails removeAllObjects];
    [_assets release];
    [_thumbnails release];
    [_chosenPhotoGroupID release];
    [_blogCountForGroup release];
    [_selectGroupInt release];
    [_photoDesStr release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangePhotoGroupNotification object:nil];
    Block_release(_uploadDidBeginBlock);
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

- (id)initWithImageFromAssets:(NSArray *)assets
{
    if (self = [super init]) {
        _assets = [[NSMutableArray alloc] initWithArray:assets];
        _thumbnails = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.rightBtn setTitle:@"上传" forState:UIControlStateNormal];
    self.titleLabel.text = @"上传照片";
    self.view.backgroundColor = RGBCOLOR(234, 239, 243);
    if (self.assets.count > 0) {
        [self convertAssetsToThumbnail:self.assets];
    }
    
    if (self.chosenPhotoGroupID.length == 0) {
        self.chosenPhotoGroupID = @"0";
    }
    
    __block MultiPicUoloaderViewController *this = self;
    _mutiPicEditView = [[MultiPicEditView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, 160)];
    [self.view addSubview:_mutiPicEditView];
    [_mutiPicEditView setShowActionSheetBlock:^{
        
//        [this showActionSheet];
        if (this.thumbnails.count >= 6) {
            [MyToast showWithText:@"一次最多只能上传六张图片" :130];
            return ;
        }
        
        [this actionSheet:nil clickedButtonAtIndex:1];
    }];
    [_mutiPicEditView setChoseGroupBlock:^{
        [this choseGroup:nil];
    }];
    [_mutiPicEditView release];
    
    
    _containerView = [[ThumImageContainerView alloc] initWithFrame:CGRectMake(0, 44+160+10, SCREEN_WIDTH, SCREEN_HEIGHT - 160 - 44)];
    [_containerView setThumbnailImages:_thumbnails];
    __block typeof(self) bself = self;
    [_containerView setDidDeleteImageAtIndexBlock:^(NSUInteger idx){
        [bself.assets removeObjectAtIndex:idx];
        [bself.thumbnails removeObjectAtIndex:idx];
        

    }];
    [self.view addSubview:_containerView];
    [_containerView release];
    
    if (iOS7) {
        [Utilities adjustUIForiOS7WithViews:@[_containerView,_mutiPicEditView]];
    }
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGroup:) name:kChangePhotoGroupNotification object:nil];
}

- (void)setChoseButtonHidden:(BOOL)hide
{
    _choseGroupButtonHidden = hide;
}

- (void)showActionSheet
{
    if (_assets.count >= 6) {
        [MyToast showWithText:@"每次最多只能上传6张照片" :130 ];
        return;
    }
    
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    [as showInView:self.view];
    [as release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
            [picker release];
            break;
        }
        
        case 1: {
            
            __block MultiPicUoloaderViewController *this = self;
            
            AGImagePickerController *pickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
                [this dismissViewControllerAnimated:YES completion:nil];
            } andSuccessBlock:^(NSArray *info) {
                
                NSUInteger addPhotoCount = MaxNumOfPhoto - _assets.count;
                if (addPhotoCount > 0) {
                    for (int i = 0; i < info.count; i ++) {
                        [this->_assets addObject:info[i]];
                        if (this->_assets.count >= MaxNumOfPhoto) {
                            break;
                        }
                    }
                }
                
                [this->_thumbnails removeAllObjects];
                [this convertAssetsToThumbnail:info];

                [this dismissViewControllerAnimated:YES completion:^{
                    [_containerView setThumbnailImages:_thumbnails];
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
                }];
            }];
            
            [pickerController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top.png"] forBarMetrics:UIBarMetricsDefault];
            
            pickerController.maximumNumberOfPhotosToBeSelected = MaxNumOfPhoto;
//            pickerController.selection = self.assets;
            [self presentViewController:pickerController animated:YES completion:nil];
            [pickerController setToolbarHidden:YES animated:YES];
            
            [pickerController release];
            
            break;
        }
        
        default:
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self.thumbnails addObject:image];
    [self.assets addObject:image];
    [_containerView setThumbnailImages:[NSMutableArray arrayWithArray:self.thumbnails]];
    [picker dismissViewControllerAnimated:YES completion:nil];
    image = nil;
    editingInfo = nil;
}


- (void)changeGroup:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    DiaryPictureClassificationModel *model = notification.object;
    self.chosenPhotoGroupID = model.groupId;

    self.blogCountForGroup  = model.blogcount;
    self.selectGroupInt = dic[@"selectInt"];
    [_mutiPicEditView setGroupButtonTitle:model.title];
    dic = nil;
}

- (void)choseGroup:(id)sender
{
    PhotoAlbumsViewController *photoAlbumsViewController = [[PhotoAlbumsViewController alloc] init ];
    photoAlbumsViewController.isSeletedStyle = YES;

    [self presentViewController:photoAlbumsViewController animated:YES completion:nil];
    [photoAlbumsViewController release];

}

- (void)convertAssetsToThumbnail:(NSArray *)assets
{
    if (!_thumbnails) {
        _thumbnails = [[NSMutableArray alloc] init];
    }
    
    for (int i = 0 ; i < self.assets.count; i++)
    {    
        ALAsset *aAsset = _assets[i];
        
        if ([aAsset isKindOfClass:[ALAsset class]]) {
            CGImageRef imageRef = [aAsset thumbnail];
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            [self.thumbnails addObject:image];
        }
        else
        {
            [self.thumbnails addObject:aAsset];
        }
    }
}

- (void)backBtnPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBtnPressed
{
    if (self.assets.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您还没有选择照片" message:@"要现在选择照片么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        [alertView release];
        
        return;
    }
    
    [MyToast showWithText:@"开始上传" :130];
    self.photoDesStr = _mutiPicEditView.photoDesTextView.text;
    if ([self.photoDesStr isEqualToString:@"请输入照片描述"]) {
        self.photoDesStr = @"";
    }
//    [MyToast showWithText:@"开始上传" :100];
    BOOL connected = [Utilities checkNetwork];
    if (!connected) {
        NSMutableArray *cacheImages = [[NSMutableArray alloc] init];
        int idx = 0;
        for (ALAsset *aAsset in _assets) {
            UIImage *image = nil;
            if ([_assets[idx] isKindOfClass:[ALAsset class]]) {
                
                image = [self getFullScreenImageFromAsset:_assets[idx]];
            }
            if ([_assets[idx] isKindOfClass:[UIImage class]]) {
                image = _assets[idx];
            }
            [cacheImages addObject:image];
            idx ++;
        }
        
        [self cacheDataAndSavePicToLocalWhenOffline:cacheImages];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewPhotoAddedNotification object:nil];
        [cacheImages release];
    }
    else
    {
        
        __block MultiPicUoloaderViewController *this = self;
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_async(queue, ^{
            dispatch_apply([_assets count], queue, ^(size_t idx) {
                
                UIImage *image = nil;
                if ([_assets[idx] isKindOfClass:[ALAsset class]]) {
                    image = [this getFullScreenImageFromAsset:_assets[idx]];
                }
                if ([_assets[idx] isKindOfClass:[UIImage class]]) {
                    image = _assets[idx];
                    image = [image fixOrientation];
                }
                [this uploadImage:image withImageName:[NSString stringWithFormat:@"image%zd.png",idx]];
            });
            
        });
    }
    
    
    DiaryPictureClassificationModel *diaryModel = [DiaryPictureClassificationSQL getDiaryModelByGroupId:self.chosenPhotoGroupID WithUserID:USERID];
    NSUInteger blogCount = [diaryModel.blogcount integerValue];
    blogCount += self.assets.count;
    diaryModel.blogcount = [NSString stringWithFormat:@"%d",blogCount];
    NSArray *blogs = @[diaryModel];
    [DiaryPictureClassificationSQL updateDiaryWithArr:blogs WithUserID:USERID];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (_uploadDidBeginBlock) {
            _uploadDidBeginBlock(_chosenPhotoGroupID,_selectGroupInt);
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self actionSheet:nil clickedButtonAtIndex:1];
    }
}

- (UIImage *)getFullScreenImageFromAsset:(ALAsset *)aAsset
{
    
    ALAssetRepresentation *assetRep = [aAsset defaultRepresentation];
    CGImageRef imageRef = [assetRep fullScreenImage];
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    return image;
}

- (void)cacheDataAndSavePicToLocalWhenOffline:(NSArray *)images;
{
    NSArray *cacheImages = [images retain];
    
    NSString *tempFilePath = [NSString stringWithFormat:@"%@/Library/ETMemory/Photos/%@",NSHomeDirectory(),USERID];
    NSMutableArray *savedBlogs = [[NSMutableArray alloc] init];
    for (UIImage *image in cacheImages) {
        NSDate *date = [[NSDate alloc] init];
        NSTimeInterval timestamp = [date timeIntervalSince1970];
        NSString *filePath = [tempFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"img_%f.png",timestamp]];
        
        NSData *data = UIImageJPEGRepresentation(image, 1);
        [data writeToFile:filePath atomically:YES];
        
        MessageModel *blog = [[MessageModel alloc] init];
        blog.paths      = filePath;
        blog.spaths     = filePath;
        blog.tempPath   = filePath;
        blog.tempSPath  = filePath;
        blog.needSyn    = YES;
        blog.status     = @"2";
        blog.groupId    = _chosenPhotoGroupID;
        blog.blogType   = @"1";
        blog.title      = self.mutiPicEditView.photoDesTextView.text;
        [savedBlogs addObject:blog];
                
        [blog release];
        [date release];
        data = nil;
        
    }
    [cacheImages release];
    
    for (MessageModel *blog in savedBlogs) {
        
        [MessageSQL updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
            
            NSString *str = [NSString stringWithFormat:@"insert into %@ (content, paths, spaths, temp_paths, temp_spaths,status, groupid, blogType) values (?,?,?,?,?,?,?,?)",tableName];
            if(![db executeUpdate:str, blog.title,blog.paths,blog.spaths,blog.tempPath,blog.tempSPath,blog.status,blog.groupId,blog.blogType])
            {
            }
        }WithUserID:USERID];
    }
    
    [savedBlogs release];
   
}


- (void)uploadImage:(UIImage *)image withImageName:(NSString *)name
{
    NSURL *url = [[RequestParams sharedInstance] uploadPhoto];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.shouldAttemptPersistentConnection = NO;
    
    if ([self.photoDesStr isEqualToString:@"请输入照片描述"]) {
        self.photoDesStr = @"";
    }

    [request addRequestHeader: @"clienttoken"   value:USER_TOKEN_GETOUT];
    [request addRequestHeader: @"serverauth"    value:USER_AUTH_GETOUT];
    [request buildRequestHeaders];
    [request setPostValue:@"0"                  forKey:@"blogtype"];
    [request setPostValue:_chosenPhotoGroupID   forKey:@"groupid"];
    [request setPostValue:self.photoDesStr      forKey:@"content"];
    
    //压缩图片质量
    NSData *_imgData = UIImageJPEGRepresentation(image, 0.3);
    
    [request addData:_imgData withFileName:name andContentType:@"image/jpg" forKey:@"upfile"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:30.0];
    [request startAsynchronous];
    
    [request setCompletionBlock:^{
        
        NSDictionary *dic = [request.responseData objectFromJSONData];
        
        NSUInteger success = [dic[@"success"] integerValue];
        if (success == 1) {
            
            [MyToast showWithText:@"上传成功" :130];
            
            NSNumber *spaceUsed = [NSNumber numberWithLongLong:[dic[@"meta"][@"spaceused"] longLongValue]];
            [SavaData fileSpaceUseAmount:spaceUsed];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewPhotoAddedNotification object:nil userInfo:nil];

        }else if([dic[@"errorcode"] integerValue] == 1005)
        {
            [[[[UIAlertView alloc]initWithTitle:ALERT_TITLE  message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else if ([dic[@"errorcode"] intValue] ==9000)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }else{
             [MyToast showWithText:dic[@"message"] :100];
        }
        
    }];
    
    [request setFailedBlock:^{
    }];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
