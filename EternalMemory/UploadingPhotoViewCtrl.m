//
//  UploadingPhotoViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 14-3-13.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "UploadingPhotoViewCtrl.h"
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
#import "UIImage+UIImageExt.h"
#import "PhotoCategoryCell.h"
#import "PhotoUploadEngine.h"
#import "EMPhotoSyncEngine.h"
#import "ASINetworkQueue.h"
#import "RequestParams.h"
#import "MBProgressHUD.h"
#import "MessageModel.h"
#import "MessageSQL.h"
#import "EMAudioUploader.h"
#import "DiaryPictureClassificationSQL.h"
#import "Utilities.h"
#import "MyToast.h"
#import "PhotoAlbumNavigationViewController.h"
#import "EMAlbumImage.h"
#import "ErrorCodeHandle.h"
#define PHOTOS_WIDTH    70
#define PHOTOS_HEIGHT   70
#define PHOTOS_X        4
#define PHOTOS_Y        15
#define SCROLLVIEW_MAX_H [UIScreen mainScreen].bounds.size.height - 150

@interface UploadingPhotoViewCtrl ()<UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet UIButton       *typePhotoBtn;
    IBOutlet UITableView    *myTableView;
    UIScrollView            *_myScrollView;
    NSArray                 *_typeData;
    
    
    NSInteger               changH;
    NSInteger               cellRowTag;
    UIButton                *_addImageBtn;
    UIButton                *_delBtn;
    __block NSInteger           phontoIndex;
    __block NSMutableArray  *_imagesArr;
}

@property (nonatomic, retain) CALayer *shadowLayer;

@end



@implementation UploadingPhotoViewCtrl

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
    self.titleLabel.text = @"上传照片";
    [self.rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    self.middleBtn.hidden = YES;
    
    //数据处理
    [self initUpData];
    
    //设置View
    [self initLoadView];
}

- (void)initUpData
{
    changH = 0;
    cellRowTag = 0;
    phontoIndex = 0;
    _typeData = [[DiaryPictureClassificationSQL getDiaryPictureClassificationes:@"1" AndUserId:USERID] retain];
    
    _imagesArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self addObserver:self forKeyPath:@"phontoIndex" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)initLoadView
{
    myTableView.clipsToBounds = YES;
    myTableView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    myTableView.layer.shadowRadius = 1;
    myTableView.layer.shadowOffset = CGSizeMake(0, 1);
    myTableView.layer.shadowPath = [UIBezierPath bezierPathWithRect:myTableView.bounds].CGPath;
    myTableView.backgroundColor = RGB(242, 242, 242);
    myTableView.layer.cornerRadius = 3;
    
    _shadowLayer = [CALayer layer];
    _shadowLayer.frame = myTableView.frame;
    _shadowLayer.backgroundColor = [UIColor whiteColor].CGColor;
    _shadowLayer.shadowColor = [UIColor lightGrayColor].CGColor;
    _shadowLayer.shadowOpacity = 0.5;
    _shadowLayer.shadowRadius  = 3;
    _shadowLayer.cornerRadius = 3;
    _shadowLayer.shadowOffset = CGSizeMake(0, 0);
    _shadowLayer.hidden = YES;
    _shadowLayer.shadowPath = [UIBezierPath bezierPathWithRect:_shadowLayer.bounds].CGPath;
    [self.view.layer insertSublayer:_shadowLayer below:myTableView.layer];
    
    
    _myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10,iOS7? 150: 120, 300, 100)];
    _myScrollView.showsVerticalScrollIndicator = NO;
    _myScrollView.showsHorizontalScrollIndicator = NO;
    _myScrollView.backgroundColor = [UIColor whiteColor];
    _myScrollView.layer.cornerRadius = 4;
    _myScrollView.layer.borderWidth = .5f;
    _myScrollView.layer.borderColor = RGB(181, 181, 181).CGColor;
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(PHOTOS_X, PHOTOS_Y, PHOTOS_WIDTH, PHOTOS_HEIGHT);
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_photo_image"] forState:UIControlStateNormal];
    [_myScrollView addSubview:addBtn];
    _addImageBtn = addBtn;
    [self.view addSubview:_myScrollView];
    
    [addBtn addTarget:self action:@selector(addSelectUploadingPhoto:) forControlEvents:UIControlEventTouchUpInside];

}

-(void)backBtnPressed
{
    if (_imagesArr.count == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:@"取消上传图片？" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        alertView.tag = 100;
        [alertView show];
        [alertView release];
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==100) {
        if (buttonIndex == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        if (buttonIndex ==1) {
            if (_delBtn.tag < _imagesArr.count) {
                [self removeScrollViewSuperViewBtn];
                [_imagesArr removeObjectAtIndex:_delBtn.tag];
                
                for (NSArray *arrImage in _imagesArr) {
                    [self showImageRefSize:arrImage[0] imageFrame:_addImageBtn audioHave:arrImage.count>1 ? arrImage[1]:nil];
                    phontoIndex ++;
                    [self setValue:@(phontoIndex) forKey:@"phontoIndex"];
                }
            }
        }
    }
   
}

- (IBAction)selectTypePhotoButton:(UIButton *)sender
{
    sender.selected = !sender.selected;
    myTableView.hidden = !myTableView.hidden;
    _shadowLayer.hidden = !_shadowLayer.hidden;
    _myScrollView.hidden = !_myScrollView.hidden;
    
//    if (sender.isSelected) {
//        [self.view sendSubviewToBack:_myScrollView];
//        [_myScrollView bringSubviewToFront:myTableView];
//    }
}

- (void)addSelectUploadingPhoto:(UIButton *)sender
{
    BOOL isUploading = [[PhotoUploadEngine sharedEngine] isUploading];
    if (isUploading) {
        [MyToast showWithText:@"还有照片正在上传，稍等一会儿哟" :130];
        return;
    }
    
    __block typeof(self) bself = self;
    AGIPCDidFail failBlock = ^(NSError *error) {
    };
    
    AGIPCDidFinish finashBlock = ^(NSArray *info) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (info.count == 1) {
                MAImagePickerFinalViewController *finishImageVC = [[MAImagePickerFinalViewController alloc] init];
                UIImage  *image = [self imageFromAsset:info[0]];
                finishImageVC.sourceImage = image;
                finishImageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                double delayInSeconds = 0.75;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [bself presentViewController:finishImageVC animated:YES completion:nil];
                });
                
                finishImageVC.finishBackImagePickerBlock = ^(UIImage *showImg , EMAudio *audio){
                    [bself showImageRefSize:showImg imageFrame:sender audioHave:audio];
                    phontoIndex ++;
                    [self setValue:@(phontoIndex) forKey:@"phontoIndex"];
                    if (audio) {
                        NSArray *imageArr = @[showImg, audio];
                        [_imagesArr addObject:imageArr];
                    }else {
                        NSArray *imageArr = @[showImg];
                        [_imagesArr addObject:imageArr];
                    }
                };
                
                [finishImageVC release];
            }else{

                double delayInSeconds = 0.35;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    for (ALAsset *aAsset in info) {
                        @autoreleasepool {
                            UIImage *aImage = [[bself fullSizeImageForAssetRepresentation:aAsset.defaultRepresentation] fixOrientation];
                            [bself showImageRefSize:aImage imageFrame:sender audioHave:nil];
                            NSArray *imageArr = @[aImage];
                            [_imagesArr addObject:imageArr];
                            
                            aImage = nil;
                            phontoIndex ++;
                            [self setValue:@(phontoIndex) forKey:@"phontoIndex"];
                        }
                    }
                });
            }
        });
    };
    
    if (_imagesArr.count<9) {
        int contNum = 9 - _imagesArr.count;
        AGImagePickerController *pickerController = [[AGImagePickerController alloc] initWithDelegate:nil failureBlock:failBlock successBlock:finashBlock maximumNumberOfPhotosToBeSelected:contNum shouldChangeStatusBarStyle:YES toolbarItemsForManagingTheSelection:nil andShouldShowSavedPhotosOnTop:YES];
        
        [self presentViewController:pickerController animated:YES completion:nil];
        [pickerController release];
    }else {
        [self networkPromptMessage:@"不要贪心哦,请先上传完再来选"];
    }
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"phontoIndex"]) {
        if (phontoIndex >8) {
            _addImageBtn.hidden = YES;
        }else{
            _addImageBtn.hidden = NO;
        }
    }
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
- (MessageModel *)modelWithImage:(NSArray *)array
{
    MessageModel *model = [[MessageModel alloc] init];
    model.rawImage = array[0];
    if (array.count>1) {
        model.audio = array[1];
    }
    model.status   = @"2";
    return model;
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
- (void)showImageRefSize:(UIImage *)image imageFrame:(UIButton *)sender audioHave:(EMAudio *)audio
{
    [self addPhotosImageView:sender.frame showImage:image audioHave:audio];

    float addBtnMaxX = CGRectGetMaxX(sender.frame)+4;
    if (addBtnMaxX<250) {
         sender.frame = CGRectMake(addBtnMaxX, sender.frame.origin.y, PHOTOS_WIDTH, PHOTOS_HEIGHT);
    }else{
        sender.frame = CGRectMake(PHOTOS_X, CGRectGetMaxY(sender.frame)+10, PHOTOS_WIDTH, PHOTOS_HEIGHT);

        if (CGRectGetHeight(_myScrollView.frame) > SCROLLVIEW_MAX_H) {
            changH ++;
            _myScrollView.contentSize = CGSizeMake(_myScrollView.frame.size.width, _myScrollView.frame.size.height+(PHOTOS_HEIGHT+10)*changH);
            [_myScrollView setContentOffset:CGPointMake(_myScrollView.contentOffset.x, _myScrollView.contentOffset.y+PHOTOS_HEIGHT+10) animated:YES];
        }else{
             _myScrollView.frame = CGRectMake(_myScrollView.frame.origin.x, _myScrollView.frame.origin.y, _myScrollView.frame.size.width, _myScrollView.frame.size.height + PHOTOS_HEIGHT+10);
        }
    }
}
- (void)addPhotosImageView:(CGRect)rect showImage:(UIImage *)imgV audioHave:(EMAudio *)audio
{
    UIButton *btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnImage.frame = rect;
    [btnImage setBackgroundImage:imgV forState:UIControlStateNormal];
    btnImage.tag = phontoIndex;

    [_myScrollView addSubview:btnImage];
    if (audio) {
        [_myScrollView addSubview:[self addAudioImage:rect]];
    }
    [btnImage addTarget:self action:@selector(diddeletePhotoImage:) forControlEvents:UIControlEventTouchUpInside];

}

- (UIImageView *)addAudioImage:(CGRect)btnFrmae
{
    UIImageView *audioImage = [[UIImageView alloc] initWithFrame:CGRectMake(btnFrmae.origin.x+3, btnFrmae.origin.y+48, 15, 15)];
    audioImage.image = [UIImage imageNamed:@"audio_icon"];
    return [audioImage autorelease];
}

- (void)diddeletePhotoImage:(UIButton *)btn
{
    _delBtn = btn;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您是否要删除该照片？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alertView.tag =101;
    [alertView show];
    [alertView release];

}
- (void)removeScrollViewSuperViewBtn
{
    for (UIButton *buttonView in [_myScrollView subviews]) {
        if ([buttonView isEqual:_addImageBtn]) {
            //保留添加button
        }else{
            [buttonView removeFromSuperview];
            buttonView = nil;
        }
        
    }
    
    _myScrollView.frame = CGRectMake(10, iOS7? 150: 120, 300, 100);
    _addImageBtn.frame = CGRectMake(PHOTOS_X, PHOTOS_Y, PHOTOS_WIDTH, PHOTOS_HEIGHT);
    changH = 0;
    phontoIndex = 0;
    [self setValue:@(phontoIndex) forKey:@"phontoIndex"];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _typeData.count-1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *defineString = @"defineSting";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:defineString];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:defineString];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = [self backTitlediaryPictureClassifcationModelData:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [typePhotoBtn setTitle:[self backTitlediaryPictureClassifcationModelData:indexPath.row] forState:UIControlStateNormal];
    cellRowTag = indexPath.row;
    typePhotoBtn.selected = NO;
    myTableView.hidden = YES;
    _myScrollView.hidden = NO;
    _shadowLayer.hidden = !_shadowLayer.hidden;
}
- (NSString *)backTitlediaryPictureClassifcationModelData:(NSInteger)index
{
    if (_typeData.count<5) {
        return @"";
    }else {
        DiaryPictureClassificationModel *diaryText =  _typeData[index];
        return diaryText.title;
    }
}
-(void)rightBtnPressed
{
    if (_imagesArr.count <1) {
        [self networkPromptMessage:@"您没有照片要上传"];
        return;
    }
    
    ASINetworkQueue *uploadQueue = [ASINetworkQueue queue];
    NSURL *url = [[RequestParams sharedInstance] uploadPhoto];
    DiaryPictureClassificationModel *diaryModel = _typeData[cellRowTag];
    for (NSArray *imgArr in _imagesArr) {
        PhotoUploadRequest *request = [[PhotoUploadRequest alloc] initWithURL:url];
        MessageModel *model = [self modelWithImage:imgArr];
        NSDictionary *userInfo = @{kModel: model};
        [request setupRequestForUplodingImage:imgArr[0] groupid:diaryModel.groupId];
        request.userInfo = userInfo;
        
        [uploadQueue addOperation:request];
        [request release];
        [model release];
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
        for (int i = 0 ; i < _imagesArr.count; i++) {
            @autoreleasepool {
                NSArray *upDataArr = _imagesArr[i];
                if ([upDataArr count] >1) {
                        syncEngine.writeFileSuccessBlock = ^(NSString *path) {
                            [MessageSQL updataBlogPathUsingBlock:^(FMDatabase *db, NSString *tableName) {
                                NSString *sql = [NSString stringWithFormat:@"select id from %@ where paths = ?",tableName];
                                FMResultSet *rs = [db executeQuery:sql,path];
                                int ID = 0;
                                while ([rs next]) {
                                    ID = [rs intForColumn:@"id"];
                                }
                                EMAudio *audio = upDataArr[1];
                                audio.ID = ID;
                                [[EMAudioUploader sharedUploader] startUploadAudio:audio];
                                
                            } WithUserID:USERID];
                        };
                        [syncEngine uploadOperationNeedsSyncWithImages:@[upDataArr[0]] upGroupId:diaryModel.groupId];

                }else{
                    [imagesToUpload addObject:upDataArr[0]];
                }
               
            }
        }
        
        [syncEngine uploadOperationNeedsSyncWithImages:imagesToUpload toGroup:diaryModel];
        [imagesToUpload release],imagesToUpload = nil;
        
    }
    
    [self removeScrollViewSuperViewBtn];
    [_imagesArr removeAllObjects];
    
    
//    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(_begin:) userInfo:nil repeats:YES];

}
- (void)_begin:(NSTimer *)timer
{
    BOOL isUploading = [[PhotoUploadEngine sharedEngine] isUploading];
    if (!isUploading) {
        [self.navigationController popViewControllerAnimated:NO];
       
//        DiaryPictureClassificationModel *diaryModel = _typeData[cellRowTag];
//        [[NSNotificationCenter defaultCenter] postNotificationName:PhotosUploadingSuccessPushListNotification object:diaryModel];
        
        [timer invalidate],timer = nil;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [typePhotoBtn release];
    [myTableView release];
    [_typeData release],_typeData = nil;
    [_imagesArr release],_imagesArr = nil;
    [_myScrollView release];
    [self removeObserver:self forKeyPath:@"phontoIndex"];
    [super dealloc];
}
@end
