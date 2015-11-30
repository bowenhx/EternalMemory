//
//  AddingAssoicationViewController.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-21.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "AddingAssoicationViewController.h"
#import "GenealogyMetaData.h"
#import "GenealogyFormDataRequest.h"
#import "Utilities.h"
#import "AssociatedInfoInputView.h"
#import "RNBlurModalView.h"
#import "MyToast.h"
#import "MyFamilySQL.h"
#import "AssoiatedFailureView.h"
#import "SweepNotourViewController.h"
#import "NSString+Base64.h"


#define NotCode                 100
#define tEternalCodeAlert       301
#define tAssociationCodeAlert   302
#define tMemoryCodeActionTag    303
#define tAuthoriseActionTag     304


@interface AddingAssoicationViewController ()
{
    UITableView   *_tableView;
}

@end

@implementation AddingAssoicationViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_tableView release];
    [_memberInfoDic release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.middleBtn.hidden = YES; 
    self.rightBtn.hidden = YES;
    self.titleLabel.text = @"添加关联";
    
    UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    
    UILabel *tableHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 60)];
    tableHeaderLabel.textAlignment = NSTextAlignmentCenter;
    tableHeaderLabel.backgroundColor = [UIColor clearColor];
    tableHeaderLabel.numberOfLines = 1;
    tableHeaderLabel.textColor = RGBCOLOR(100, 111, 127);
    tableHeaderLabel.font = [UIFont systemFontOfSize:14];
    tableHeaderLabel.text = @"与注册用户关联后，即可看到对方的家园及家谱";
    [tableHeaderView addSubview:tableHeaderLabel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundView = nil;
    _tableView.tableHeaderView = tableHeaderView;
    
    [Utilities adjustUIForiOS7WithViews:@[_tableView]];
    
    [self.view addSubview:_tableView];
    
    [tableHeaderLabel release];
    [tableHeaderView  release];
    
	// Do any additional setup after loading the view.
}

- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = RGBCOLOR(100, 110, 123);
    }
    
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        cell.textLabel.text = @"授权码关联";
    }
    
    if (section == 1) {
        cell.textLabel.text = @"二维码关联";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSString *message = nil;
//    NSInteger tag = 0;
    
    AssociatedInfoInputView *view = nil;
    
    if (indexPath.section == 0) {
        
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择关联方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"扫描二维码",@"输入记忆码", nil];
//        actionSheet.tag = tMemoryCodeActionTag;
//        [actionSheet showInView:self.view];
//        [actionSheet release];
        
//        message = @"请输入授权码";
//        tag = tAssociationCodeAlert;
        
        _assciotedType = @"write";
        view = [[AssociatedInfoInputView alloc] initWithAssociationType:AssociationTypeAuthcode];
        RNBlurModalView *model = [[RNBlurModalView alloc] initWithViewController:self view:view viewCenter:CGPointMake(160, SCREEN_HEIGHT/2-100)];
        
        [model show];
        
        [model release];
        
        __block RNBlurModalView *b_model = model;
        __block typeof(self) bSelf = self;
        [view setBtnPressedBlock:^(NSDictionary *dic, AssociationType type) {
            [b_model hide];
            
            [bSelf setupRequestWithDate:dic forAssociationType:type];
        }];
    }
    
    if (indexPath.section == 1) {
        
        _assciotedType = @"scanCode";
        [self twoDimCodeAssociated];
//        message = @"请输入授权码";
//        tag = tAssociationCodeAlert;
//        view = [[AssociatedInfoInputView alloc] initWithAssociationType:AssociationTypeAuthcode];;
    }
}

- (void)setupRequestWithDate:(NSDictionary *)data forAssociationType:(AssociationType)type
{
    if (type == AssociationTypeAuthcode) {
        GenealogyFormDataRequest *request = [GenealogyFormDataRequest requestWithURL:[[RequestParams sharedInstance] associateMember]];
        [request associatedMemberByAssociatedKey:GenealogyAssociteKeyAuth withTheCode:data memberId:_memberInfoDic[kMemberId]];
        [request startAsynchronous];
        request.delegate = self;
    }
    
//    if (type == AssociationTypeEternalcode) {
//        GenealogyFormDataRequest *request = [GenealogyFormDataRequest requestWithURL:[[RequestParams sharedInstance] associateMember]];
//        [request associatedMemberByAssociatedKey:GenealogyAssociteKeyEternal withTheCode:data memberId:_memberInfoDic[kMemberId]];
//        [request startAsynchronous];
//        request.delegate = self;
//    }
}
-(void)twoDimCodeAssociated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectShowOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    _VerticalScreen = YES;
    num = 0;
    upOrdown = NO;
    //判断设备类型
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    _reader = [ZBarReaderViewController new];
    _reader.readerDelegate = self;
    _reader.sourceType = UIImagePickerControllerSourceTypeCamera;
    _reader.supportedOrientationsMask = UIInterfaceOrientationPortrait;
    UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height-29)];
    if (SCREEN_HEIGHT == 568 && version >= 7.0) {
        aView.frame = CGRectMake(0, 0, 320, self.view.bounds.size.height + 30);
    }
    
    aView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_sweep_backg"]];
    aView.alpha=0.7;
    UIImageView *aImageView=[[UIImageView alloc] initWithFrame:CGRectMake(44, self.view.bounds.size.height-49-75, 232, 45)];
    [aImageView setImage:[UIImage imageNamed:@"ic_sweep_lay"]];
    [aView addSubview:aImageView];
    
    _line=[[UIImageView alloc] initWithFrame:CGRectMake(49, 100, 221, 10)];
    [_line setImage:[UIImage imageNamed:@"ic_sweep_line"]];
    [aView addSubview:_line];
    
    if (version >= 7.0) {
        _line.frame = CGRectMake(49,100,221,10);
    }
    
    _reader.cameraOverlayView=aView;
    [aImageView release];
    [_line release];
    [aView release];
    
    [self handletheToolBar:_reader];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    ZBarImageScanner *scanner = _reader.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [self presentViewController:_reader animated:YES completion:nil];
    [_reader release];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 50)];
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textAlignment = NSTextAlignmentLeft;
    footerLabel.textColor = RGBCOLOR(129, 138, 146);
    footerLabel.font = [UIFont systemFontOfSize:14];
    footerLabel.numberOfLines = 0;
    [footerView addSubview:footerLabel];
    [footerLabel release];
    
    if (section == 0) {
        footerLabel.text = @"它是每个用户独一无二的号码，向对方索取授权码，即可关联。";
    }
    if (section == 1) {
        footerLabel.text = @"它是由授权码生成的二维码";
    }
    
    return [footerView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    if ([_assciotedType isEqualToString:@"scanCode"]) {
        [HUD removeFromSuperview];
        [_reader dismissViewControllerAnimated:YES completion:nil];
    }
    
    NSData *data = [request responseData];
    NSDictionary *responseDic = [data objectFromJSONData];
    NSInteger successs = [responseDic[@"success"] integerValue];
    NSString *message = responseDic[@"message"];
     
    if (successs == 1) {
        [MyToast showWithText:message :130];
        NSDictionary *dic = responseDic[@"data"];
        [MyFamilySQL updateMemberByMemberId:dic];
        [[NSNotificationCenter defaultCenter] postNotificationName:GenealogyAssociatedSuccessNotification object:responseDic[@"data"] userInfo:@{@"isOther": @(YES)}];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        
        if ([message isEqualToString:@"性别不一致"]) {
            
            NSString *name = responseDic[@"data"][@"realName"];
            NSString *gender = ([responseDic[@"data"][@"sex"] integerValue] == 1) ? (@"男") : (@"女");
            NSString *birghtDate = [Utilities convertTimestempToDateWithString:responseDic[@"data"][@"birthdate"] andDateFormat:@"yyyy-MM-dd"];
            
            UILabel *infoLabel = ({
                UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){
                    .origin.x = 0,
                    .origin.y = 0,
                    .size.width  = 215,
                    .size.height = 17
                }];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
                label.textColor = RGB(40, 121, 191);
                label.textAlignment = NSTextAlignmentCenter;
                label.text = [NSString stringWithFormat:@"%@ %@ %@",name,gender,birghtDate];
                label;
            });
            
            AssoiatedFailureView *promptView = [[AssoiatedFailureView alloc] initWithTitle:@"关联失败" promptMessage:@"您所关联的人的性别与您当前家谱的性别不同，请检查核对。" canelButton:nil containerView:infoLabel];
            
            RNBlurModalView *bluiView = [[RNBlurModalView alloc] initWithViewController:self view:promptView viewCenter:self.view.center];
            [bluiView show];
            
            [promptView setConfirmBlock:^{
                [bluiView hide];
            }];
            [bluiView release];
            [promptView release];
            
        }else if ([responseDic[@"errorcode"] intValue] == 1005)
        {
            [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        }
        else  {
            [MyToast showWithText:message :130];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == NotCode) {
        if (buttonIndex == 1) {
            [self scanPhotoImage];
        }
        return;
    }
    BOOL isLogin = NO;
    [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
    [[EternalMemoryAppDelegate getAppDelegate] showLoginVC];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if ([_assciotedType isEqualToString:@"scanCode"]) {
        [HUD removeFromSuperview];
        [_reader dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self networkPromptMessage:@"网络连接异常"];
}
-(void)handletheToolBar:(ZBarReaderViewController *)reader{
    
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    if (version>=6.0) {
        int i = 0;
        for (UIView *temp in [reader.view subviews]) {
            for (UIView *v in [temp subviews]) {
                if ([v isKindOfClass:[UIToolbar class]]) {
                    UIToolbar *toolBar = (UIToolbar *)v;
                    _selectPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [_selectPhotoBtn setBackgroundImage:[UIImage imageNamed:@"ic_sweep_selectPhotoBtn35"] forState:UIControlStateNormal];
                    [_selectPhotoBtn setTitle:@"选择图片" forState:UIControlStateNormal];
                    _selectPhotoBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
                    _selectPhotoBtn.frame = CGRectMake(250, 10, 60, 31);
                    [_selectPhotoBtn addTarget:self action:@selector(scanPhotoImage) forControlEvents:UIControlEventTouchUpInside];
                    [toolBar addSubview:_selectPhotoBtn];
                    for (UIView *ev in [v subviews]) {
                        if (i== 3) {
                            [ev removeFromSuperview];
                        }
                        i++;
                    }
                }
            }
        }
    }else{
        int i = 0;
        for (UIView *temp in [reader.view subviews]) {
            for (UIView *v in [temp subviews]) {
                if ([v isKindOfClass:[UIToolbar class]]) {
                    for (UIView *ev in [v subviews]) {
                        if (i== 2) {
                            [ev removeFromSuperview];
                        }
                        i++;
                    }
                }
            }
        }
    }
}
-(void)detectShowOrientation{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||[UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)     {
        
        _selectPhotoBtn.frame = CGRectMake(self.view.frame.size.height - 70, 7, 60, 25);
        _selectPhotoBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_selectPhotoBtn setBackgroundImage:[UIImage imageNamed:@"ic_sweep_selectPhotoBtn25"] forState:UIControlStateNormal];
        _VerticalScreen = NO;
        UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 320-30)];
        if (SCREEN_HEIGHT == 568) {
            aView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_sweep_horizontal1136"]];
        }else if (SCREEN_HEIGHT == 480){
            aView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_sweep_horizontal960"]];
        }
        aView.alpha=0.7;
        _line = [[UIImageView alloc] init];
        _line.frame = CGRectMake((self.view.frame.size.height - 221)/2, 20, 221, 10);
        [_line setImage:[UIImage imageNamed:@"ic_sweep_line"]];
        [aView addSubview:_line];
        [_line release];
        _reader.cameraOverlayView = aView;
        [aView release];
        _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
        
    }else{//
        _selectPhotoBtn.frame = CGRectMake(250, 10, 60, 31);
        _selectPhotoBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_selectPhotoBtn setBackgroundImage:[UIImage imageNamed:@"ic_sweep_selectPhotoBtn35"] forState:UIControlStateNormal];
        _VerticalScreen = YES;
        UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height-49)];
        if (SCREEN_HEIGHT == 568 && version >= 7.0) {
            aView.frame = CGRectMake(0, 0, 320, self.view.bounds.size.height + 30);
        }
        
        aView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_sweep_backg"]];
        aView.alpha=0.7;
        _line=[[UIImageView alloc] initWithFrame:CGRectMake(49, 100, 221, 10)];
        [_line setImage:[UIImage imageNamed:@"ic_sweep_line"]];
        [aView addSubview:_line];
        [_line release];
        UIImageView *aImageView=[[UIImageView alloc] initWithFrame:CGRectMake(44, self.view.bounds.size.height-49-75, 232, 45)];
        [aImageView setImage:[UIImage imageNamed:@"ic_sweep_lay"]];
        [aView addSubview:aImageView];
        [aImageView release];
        _reader.cameraOverlayView = aView;
        [aView release];
        num = 0;
        upOrdown = NO;
        _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    }
}

-(void)animationLine{
    
    if (_VerticalScreen) {//竖屏
        float begin = 7*self.view.bounds.size.height/48 + 30;
        
        if (upOrdown == NO) {
            num ++;
            _line.frame = CGRectMake(49, begin+2*num, 220,10);
            if (2*num == 184) {
                upOrdown = YES;
            }
        }
        else {
            num --;
            _line.frame = CGRectMake(49, begin+2*num, 220,10);
            if (num == 0) {
                upOrdown = NO;
            }
        }
    }else{//横屏
        float begin = 20;
        float beginX = (self.view.frame.size.height - 221)/2;
        if (upOrdown == NO) {
            num ++;
            _line.frame = CGRectMake(beginX, begin+2*num, 220,10);
            if (2*num == 184) {
                upOrdown = YES;
            }
        }
        else {
            num --;
            _line.frame = CGRectMake(beginX, begin+2*num, 220,10);
            if (num == 0) {
                upOrdown = NO;
            }
        }
    }
}
- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader withRetry: (BOOL) retry
{    
    if(retry){
        _fromPhotoLibrary = NO;
        //retry == 1 选择图片为非二维码。
        [reader dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您选择的图片非授权码生成的二维码，需要重新选择吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            alert.tag = NotCode;
            [alert show];
            [alert release];
        }];
    }
}
-(void)scanPhotoImage{
    
    _fromPhotoLibrary = YES;
    ZBarReaderController *reader = [[ZBarReaderController alloc] init];
    reader.readerDelegate = self;
    reader.showsHelpOnFail = NO;
    reader.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [reader.scanner setSymbology: ZBAR_I25
                          config: ZBAR_CFG_ENABLE
                              to: 0];
    [_reader presentViewController:reader animated:YES completion:nil];
    [reader release];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (_fromPhotoLibrary) {
        _fromPhotoLibrary = NO;
        [picker dismissViewControllerAnimated:YES completion:^{
            [picker removeFromParentViewController];
        }];
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [_timer invalidate];
    _timer = nil;
    _line.frame = CGRectMake(49, 7*self.view.bounds.size.height/48 + 35, 220, 10);
    num = 0;
    upOrdown = NO;
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
    }];
}
- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    if (!_timer) {
        return;
    }
    [_timer invalidate];
    _timer = nil;
    _line.frame = CGRectMake(49, 7*self.view.bounds.size.height/48 + 35, 220, 10);
    num = 0;
    upOrdown = NO;
    
    if (reader.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        _fromPhotoLibrary = NO;
        id<NSFastEnumeration> results =
        [info objectForKey: ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        NSDictionary *dict=[symbol.data objectFromJSONString];
        [reader dismissViewControllerAnimated:NO completion:^{
            [self networkPromptMessage:@"正在处理"];
            NSString *www = dict[@"ieternal"];
            NSString *authEnCode = dict[@"authcode"];
            if ([www isEqualToString:@"www.ieternal.com"] && authEnCode) {
                _authDecode = [NSString base64Decode:authEnCode];
                [_authDecode retain];
                [self setupRequestWithDate:[NSDictionary dictionaryWithObjectsAndKeys:_authDecode,kAssociateAuthCode,nil] forAssociationType:AssociationTypeAuthcode];
            }else{
                [_reader dismissViewControllerAnimated:NO completion:^{
                    SweepNotourViewController *sweepVC=[[SweepNotourViewController alloc] init];
                    sweepVC.sweepResults=[NSString stringWithFormat:@"%@",symbol.data];
                    [self.navigationController pushViewController:sweepVC animated:YES];
                    [sweepVC release];
                    [HUD removeFromSuperview];
                }];
                
            }
        }];
        
    }else if (reader.sourceType == UIImagePickerControllerSourceTypeCamera){
        
        id<NSFastEnumeration> results =
        [info objectForKey: ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        NSDictionary *dict=[symbol.data objectFromJSONString];
        NSString *www = dict[@"ieternal"];
        NSString *authEnCode = dict[@"authcode"];
        [self networkPromptMessage:@"正在处理"];
        if ([www isEqualToString:@"www.ieternal.com"] && authEnCode) {
            _authDecode = [NSString base64Decode:authEnCode];
            [_authDecode retain];
            [self setupRequestWithDate:[NSDictionary dictionaryWithObjectsAndKeys:_authDecode,kAssociateAuthCode,nil] forAssociationType:AssociationTypeAuthcode];
        }else{
            
            [HUD removeFromSuperview];
            [_reader dismissViewControllerAnimated:NO completion:^{
                SweepNotourViewController *sweepVC=[[SweepNotourViewController alloc] init];
                sweepVC.sweepResults=[NSString stringWithFormat:@"%@",symbol.data];
                [self.navigationController pushViewController:sweepVC animated:YES];
                [sweepVC release];
            }];
        }
    }
}
- (void)networkPromptMessage:(NSString *)message
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = message;
    HUD.mode = MBProgressHUDModeText;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation UINavigationController (navCtrl)

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
