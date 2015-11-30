//
//  PhotoAlbumsViewController.m
//  EternalMemory
//
//  Created by sun on 13-5-21.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "PhotoAlbumsViewController.h"
#import "AlbumsClassificationCell.h"
#import "CreatePhotosCategoryViewController.h"
#import "MyAlbumClassifiedListingDetailsViewController.h"
#import "DiaryPictureClassificationSQL.h"
#import "MyToast.h"
#import "EternalMemoryAppDelegate.h"
#import "MyLifeMainViewController.h"
#import "MAImagePickerFinalViewController.h"
#import "MultiPicUoloaderViewController.h"
#import "AGImagePickerController.h"
#import "MyLifeMainViewController.h"
#import "EditListCell.h"
#import "MyHomeViewController.h"
#import "UIImage+UIImageExt.h"
#import "GuideView.h"
#import "StaticTools.h"

#define PHOTOTEXT @"1"
#define CELLHEIGHT  120
#define PHOTOALBUM  @"photoAlbum"
#define REQUEST_FOR_GETGROUPS 100

@interface PhotoAlbumsViewController ()

@property (nonatomic, retain)   NSArray     *categoriesArray;
@property (nonatomic, copy)     NSString    *errorcodeStr;

@end


@implementation PhotoAlbumsViewController

@synthesize tableView = _tableView;
@synthesize categoriesArray = _categoriesArray;
@synthesize isSeletedStyle = _isSeletedStyle;
@synthesize selectListCategoriesDelegate = _selectListCategoriesDelegate;
@synthesize errorcodeStr = _errorcodeStr;
@synthesize formReq = _formReq;

- (void)dealloc
{
    if (_formReq) {
        [_formReq cancel];
        [_formReq clearDelegatesAndCancel];
    }

    [_categoriesArray release];
    [_fromView release];
    
    if (_errorcodeStr) {
        RELEASE_SAFELY(_errorcodeStr);
    }
    RELEASE_SAFELY(_tableView);
    [super dealloc];
    
}

#pragma mark - private methods

- (void)backBtnPressed
{
    if ([self.fromView isEqualToString:@"updatePhonto"]) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[MyLifeMainViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (void)rightBtnPressed
{
    
    if (![Utilities checkNetwork]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络连接异常，无法创建新相册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    CreatePhotosCategoryViewController *createCateVC = [[CreatePhotosCategoryViewController alloc] init];
    [self.navigationController pushViewController:createCateVC animated:YES];
    [createCateVC release];
    
    return;
    
}

- (void)setViewData
{

    // nevBar
    self.middleBtn.hidden = YES;
    self.titleLabel.text = @"我的相册";
    if (_isSeletedStyle) {
        self.rightBtn.hidden = YES;
    }else{
        self.rightBtn.hidden = NO;
        [self.rightBtn setTitle:@"创建" forState:UIControlStateNormal];
    }
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    [Utilities adjustUIForiOS7WithViews:@[_tableView]];
   
}

- (void)getGroupsRequest
{
    
    NSURL *registerUrl = [[RequestParams sharedInstance] manageGroup] ;
    _formReq = [[ASIFormDataRequest requestWithURL:registerUrl]retain];
    
    _formReq.shouldAttemptPersistentConnection = NO;
    //_request.delegate = self;
    _formReq.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_GETGROUPS],@"tag", nil] ;
    [_formReq setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    
    [_formReq setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_formReq setPostValue:@"list" forKey:@"operation"];
    [_formReq setPostValue:@"1" forKey:@"type"];
    [_formReq setRequestMethod:@"POST"];
    [_formReq setDelegate:self];
    [_formReq setTimeOutSeconds:30.0];
    __block typeof(self) bself = self;
    [_formReq setCompletionBlock:^{
        [bself requestSuccess:_formReq];
    }];
    [_formReq setFailedBlock:^{
        [bself requestFail:_formReq];
    }];
    [_formReq startAsynchronous];
    
//    [request release];
}
#pragma mark - object lifecycle



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _isSeletedStyle = NO;
    }
    return self;
}
-(void)changeView:(NSNotification *)notify{
    
    NSDictionary *dic=[notify object];
    MyAlbumClassifiedListingDetailsViewController *myAlbumClassifiedListingDetailsViewController = [[MyAlbumClassifiedListingDetailsViewController alloc] init];
    myAlbumClassifiedListingDetailsViewController.selectGroupInt = dic[@"selectGroupInt"];
    myAlbumClassifiedListingDetailsViewController.selectGroupId=dic[@"selectGroupId"];
    [self.navigationController pushViewController:myAlbumClassifiedListingDetailsViewController animated:YES];
    [myAlbumClassifiedListingDetailsViewController release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeView:) name:@"changeView" object:nil];
    
    BOOL netStatusFlag = [Utilities checkNetwork];
    if (netStatusFlag) {
        
        self.categoriesArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];

    }
    else
    {
        self.categoriesArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];
    }
    
    
    [self setViewData];

//    [self getGroupsRequest];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:@"isAlbumChanged" object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:@"isAlbumChanged" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:kPhotoGroupChangedNotification object:nil];

    // Do any additional setup after loading the view from its nib.

    
//    BOOL notFirst = [[SavaData shareInstance] printisAppFirst:@"photoFirst"];
//    if (!notFirst) {
//        [GuideView guideViewAddToWindow:@"photo"];
//        [[SavaData shareInstance] saveisAppFirstBool:YES forKey:@"photoFirst"];
//    }
}



- (void)viewDidAppear:(BOOL)animated
{
    self.categoriesArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];
    [self.tableView reloadData];
}

-(void)reloadTableData
{
    self.categoriesArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.categoriesArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self getGroupsRequest];
    self.categoriesArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];
    
    //self.categoriesArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT];
    //[self.tableView reloadData];
    //TODO by ZGL
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:@"photoAlbum" object:nil];
//    [self.tableView reloadData];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // 耗时的操作
//        [self getGroupsRequest];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // 更新界面
//            [self.tableView reloadData];
//        });
//    });

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isSeletedStyle == YES) {
        return [self.categoriesArray count];
    }
    return [self.categoriesArray count] + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!_isSeletedStyle && indexPath.row == 0) {
        return 85;
    }
    return CELLHEIGHT;
}
#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row=[indexPath row];
    static NSString *PhotoAlbumsViewControllerIdentifier = @"PhotoAlbumsViewControllerIdentifier";
    AlbumsClassificationCell *cell = (AlbumsClassificationCell *)[tableView dequeueReusableCellWithIdentifier:PhotoAlbumsViewControllerIdentifier];
    EditListCell *operationCell = nil;
    operationCell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(!operationCell && !_isSeletedStyle) {
        __block typeof(self) this = self;
        operationCell = [[EditListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        operationCell.containerPosition = CGPointMake(CGRectGetMidX(self.view.frame)-20, iOS7 ? 35 : 45);
        operationCell.additionButtonBackgroud = [UIImage imageNamed:@"zp_sc.png"];
        operationCell.reviewButtonBackground  = [UIImage imageNamed:@"zp_yl.png"];
        operationCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [operationCell setAddtionOperationBlock:^{
            
            [[SavaData shareInstance] savaData:3 KeyString:HOME_STATUS];
            fromPhotoList = NO;
            
            [this initWithImagePickerController:1];
        }];
        
        [operationCell setReviewOperationBlock:^{
            
            if (![Utilities checkNetwork]) {
                [MyToast showWithText:@"网络不给力，无法浏览" :130];
                return ;
            }
            MyHomeViewController *myHome = [[MyHomeViewController alloc] init];
            [this.navigationController pushViewController:myHome animated:YES];
            [myHome release];
        }];
    }
    
    if(!cell) {
        cell = [[[AlbumsClassificationCell viewForNib] retain] autorelease];
    }
    
    if (row == 0&&!_isSeletedStyle) {

        operationCell.selectionStyle = UITableViewCellSelectionStyleNone;
        operationCell.backgroundColor = [UIColor clearColor];
        
    }else if(row!=0&&!_isSeletedStyle) {
        cell.accessoryImg.hidden = NO;

        [cell setData:[self.categoriesArray objectAtIndex:[indexPath row] - 1]];
    }
    
    if (_isSeletedStyle) {
        
        cell.accessoryImg.hidden = YES;
        [cell setData:[self.categoriesArray objectAtIndex:[indexPath row]]];
        operationCell.enable = NO;

    }
    
    if (indexPath.row == 0 && !_isSeletedStyle) {
        return operationCell;
    }
    else
    {
        return cell;
    }
    
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger row =[indexPath row];
    if (row == 0 && !_isSeletedStyle) {
        return;
    }
    if (row != 0 && _isSeletedStyle ==NO) {
        //进入相册详情
        
        MyAlbumClassifiedListingDetailsViewController *myAlbumClassifiedListingDetailsViewController = [[MyAlbumClassifiedListingDetailsViewController alloc] init];
        DiaryPictureClassificationModel *model = self.categoriesArray[row - 1];
        
        myAlbumClassifiedListingDetailsViewController.model = model;
        myAlbumClassifiedListingDetailsViewController.selectGroupInt = [NSString stringWithFormat:@"%d",row - 1];
        myAlbumClassifiedListingDetailsViewController.blogCount = [model.blogcount integerValue];
        myAlbumClassifiedListingDetailsViewController.selectGroupId = model.groupId;
        [self.navigationController pushViewController:myAlbumClassifiedListingDetailsViewController animated:YES];
        
        [myAlbumClassifiedListingDetailsViewController release];
    }
    
    if (_isSeletedStyle == YES ){
        //返回分组
        
        DiaryPictureClassificationModel *model = self.categoriesArray[row];
        NSString *selectGroupInd = [NSString stringWithFormat:@"%d",row];
    
        groupIdToSendTO = model.groupId;
        [[NSNotificationCenter defaultCenter] postNotificationName:kChangePhotoGroupNotification object:model userInfo:@{@"selectInt": selectGroupInd}];

        [_selectListCategoriesDelegate selectedIndex:row];
        [self dismissViewControllerAnimated:YES completion:nil];

//        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - request
-(void)requestSuccess:(ASIFormDataRequest *)request
{
    __block typeof(self) bself = self;

    NSData *responseData = [request responseData];
    NSDictionary *resultDictionary = [responseData objectFromJSONData];
    NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    NSInteger tag=[[request.userInfo objectForKey:@"tag"] integerValue];
    bself.errorcodeStr = [NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"errorcode"]];
    if (tag == REQUEST_FOR_GETGROUPS) {
        if ([resultStr isEqualToString:@"0"]) {
            NSString *errorStr;//=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
            if ([bself.errorcodeStr isEqualToString:@"1005"]) {
                errorStr = AUTO_RELOGIN;
                UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:errorStr delegate:bself cancelButtonTitle:nil otherButtonTitles:ALERT_OK, nil];
                alter.tag = 1000;
                [alter show];
                [alter release];
            }
            if ([bself.errorcodeStr isEqualToString:@"9000"]) {
                
                UIAlertView *alter =[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:bself cancelButtonTitle:nil otherButtonTitles:ALERT_OK, nil];
                alter.tag = 2000;
                [alter show];
                [alter release];
                
            }
            
        }
        else
        {
            NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:10];
            [dataArray setArray:[resultDictionary objectForKey:@"data"]];
//            [DiaryPictureClassificationSQL  refershDiaryPictureClassificationes:dataArray WithUserID:USERID];
            [StaticTools updateDiaryAndPhotoGroup:dataArray WithUserID:USERID];

             bself.categoriesArray = [DiaryPictureClassificationSQL getDiaryPictureClassificationes:PHOTOTEXT AndUserId:USERID];

            [bself.tableView reloadData];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1000 && [self.errorcodeStr isEqualToString:@"1005"]) {
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
    }
    if (alertView.tag == 2000 && [self.errorcodeStr isEqualToString:@"9000"]) {
        
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
    }
    
}
-(void)requestFail:(ASIFormDataRequest *)request
{
//    [MyToast showWithText:@"网络连接异常" :380];
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=2) {
        [self initWithImagePickerController:buttonIndex];
    }
}
- (void)initWithImagePickerController:(NSInteger)index
{
    BOOL isAnimated = YES;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    [imagePickerController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top"] forBarMetrics:0];
    imagePickerController.delegate = self;
    if (index==1){
        [self showAGImagePicker];
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

- (void)showAGImagePicker
{
    AGImagePickerController *multiImagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
        
        if (!error) {
            [self dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
            }];
        } else {
            
        }
        
    } andSuccessBlock:^(NSArray *info) {
        
       [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            MultiPicUoloaderViewController *multiUploadVC = [[MultiPicUoloaderViewController alloc] initWithImageFromAssets:info];
            multiUploadVC.uploadDidBeginBlock = ^(NSString *gourpId, NSString *selectGroupInt){
                MyAlbumClassifiedListingDetailsViewController *controller = [[MyAlbumClassifiedListingDetailsViewController alloc] init];
                controller.selectGroupId = gourpId;
                controller.selectGroupInt = selectGroupInt;
                [self.navigationController pushViewController:controller animated:YES];
                [controller release];
            };
            [self presentViewController:multiUploadVC animated:YES completion:nil];
            [multiUploadVC release];
        }];
        
    }];
    
    [multiImagePickerController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top.png"] forBarMetrics:UIBarMetricsDefault];
    multiImagePickerController.maximumNumberOfPhotosToBeSelected = 6;
    multiImagePickerController.toolbarHidden = YES;
    multiImagePickerController.shouldShowSavedPhotosOnTop = YES;
    
    [self presentViewController:multiImagePickerController animated:YES completion:nil];
    [multiImagePickerController release];

}

#pragma mark  UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *deviceModel = info[@"UIImagePickerControllerMediaMetadata"][@"{TIFF}"];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //图片压缩，因为原图都是很大的，不必要传原图
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
    
    MultiPicUoloaderViewController *controller = [[MultiPicUoloaderViewController alloc] init];
    NSMutableArray *imageArr = [[NSMutableArray alloc] initWithObjects:image, nil];
    controller.assets = imageArr;
    [imageArr release];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self presentViewController:controller animated:YES completion:nil];
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

@end
