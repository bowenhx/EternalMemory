//
//  MomeryCodeViewController.m
//  EternalMemory
//
//  Created by jiangxl on 13-9-13.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MomeryCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "RequestParams.h"
#import "Config.h"
#import "EternalMemoryAppDelegate.h"
#import "FileModel.h"
#import "CommonData.h"
#import "MyToast.h"
#import "MyHomeVideoListViewController.h"
#import "StyleSendOperation.h"
#import "MyLifeMainViewController.h"


@interface MomeryCodeViewController ()

@end

@implementation MomeryCodeViewController
@synthesize dictData = _dictData;
@synthesize eterCode = _eterCode;
@synthesize visitStyle = _visitStyle;
@synthesize ieternalNum = _ieternalNum;


@synthesize associatekey = _associatekey;
@synthesize associatevalue = _associatevalue;
@synthesize associateauthcode = _associateauthcode;
@synthesize whichStyle = _whichStyle;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _addView = [[UIView alloc]init];
        // Custom initialization
    }
    return self;
}

//检测手机设备类型
-(NSString*)checkIphone{
    
    NSString*
    machineName();
    {
        struct utsname systemInfo;
        uname(&systemInfo);
        
        return [NSString stringWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addJStoWebview) name:@"addJStoWebviewsss" object:nil];
    _homeWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    _addView.frame = CGRectMake(0, 44, _homeWebView.frame.size.width, _homeWebView.frame.size.height);
    [self.view addSubview:_addView];
    _homeWebView.hidden = YES;
    _homeWebView.delegate = self;
    [_homeWebView setUserInteractionEnabled: YES ];
    _homeWebView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_homeWebView];
    [self loadWebview];
      NSURL *url = nil;
    if ([_visitStyle isEqualToString:@"eternalcode"]) {
       url =[[RequestParams sharedInstance]memoryVisitHomeUrl:_eterCode];
    }else{
       url = [[RequestParams sharedInstance]accreditVisitHomeUrl:_associatekey AndAssociatevalue:_associatevalue AndAssociateauthcode:_associateauthcode];
        
    }
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [_homeWebView loadRequest:request];
    
    //    NSString *musicUrl = @"http://www.ieternal.com/upload/music/2013083111084983328.mp3";
    //    NSURL *url = [NSURL URLWithString:musicUrl];
    //    NSData *musicData = [NSData dataWithContentsOfURL:url];
    //    AVAudioPlayer *audio = [[AVAudioPlayer alloc]initWithData:musicData error:nil];
    //    audio.volume = 6;
    //    [audio play];
    //   NSString *model =  [self checkIphone];
    //    if ([model isEqualToString:@"iPhone4,1"]||[model isEqualToString:@"iPhone5,1"]||[model isEqualToString:@"iPhone5,2"] ||[model isEqualToString:@"iPad3,4"]) {
    //
    //        [self loadWebview];
    //    }else{
    //
    //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"友情提示" message:@"建议使用iphone4s或iphone5，体验更好效果" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续体验", nil];
    //        alert.tag = 100;
    //        [alert show];
    //        [alert release];
    //    }
    
    // Do any additional setup after loading the view from its nib.
}
#pragma mark--
#pragma mark--UIAlertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            
            [self loadWebview];
            
        }else{
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else if(alertView.tag == 1000){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (buttonIndex == 0) {
            BOOL isLogin = NO;
            [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
        }else{
            
            
        }
    }
}
- (void)loadRequestStyleBoadUrl:(NSDictionary *)dic
{
    //取出模板字典,并下载(重新登录有模板才会再下)
    //NSDictionary *dic = [[SavaData shareInstance] printDataDic:@"favoriteStyleDic"];
    //    if (dic.count >0 && [dic isKindOfClass:[NSDictionary class]]) {
    
    //之前判断过，这里不再做判断
    StyleSendOperation *operation = [[StyleSendOperation alloc] initWithStyleSendOperation:dic];
    operation.indexHome = 1;
    [operation main];
//    [operation release];
    
    //    }
}

- (void)beginDownloadStyleBoad:(NSDictionary *)dic
{
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *str = [NSString stringWithFormat:@"%@",request.URL];
    if ([str isEqualToString:[NSString stringWithFormat:@"%@wap/user/home",INLAND_SERVER]]) {
//        [webView setHidden:YES];
//        _addView.hidden = YES;
////        [webView stopLoading];
//        webView = nil;
//        [webView removeFromSuperview];
//        [webView release];
        [_homeWebView setHidden:YES];
        //        [_homeWebView stopLoading];
//      NSString *joinOtherHome = [[SavaData shareInstance]printDataStr:@"JoinOtherHome"];
//        if ([joinOtherHome isEqualToString:@"1"]) {
//
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    if ([str isEqualToString:[NSString stringWithFormat:@"%@home/video.js.cache",INLAND_SERVER]]) {
        MyHomeVideoListViewController *videoListController = [[MyHomeVideoListViewController alloc] init];
        //----------------------------------------------------------------------------------------------------
//#warning 永恒号+授权码获取视频列表
        if ([_visitStyle isEqualToString:@"eternalcode"]) {
            
            videoListController.eternalCode = _eterCode;
        }else{
            
//            videoListController.associatevalue = _ieternalNum;

        }
        
        //----------------------------------------------------------------------------------------------------
        [self presentViewController:videoListController animated:YES completion:nil];
        [videoListController release];
    }
    return YES;
}
- (NSString *)styleFilePath:(NSString *)boadName styleName:(NSString *)styleName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *savePath = [[[CommonData getZipFilePathManager] stringByAppendingPathComponent:boadName] stringByAppendingPathComponent:styleName];
    if ([fileManager fileExistsAtPath:savePath]) {
        return savePath;
    }else
    {
        return @"0";
    }
}

- (NSString *)strFilePathStyle:(NSInteger)index
{
    if (index ==1) {
        NSString *str = [[NSBundle mainBundle] pathForResource:@"style1" ofType:@"html"];
        return str;
    }else{
        NSString *str = [[NSBundle mainBundle] pathForResource:@"style2" ofType:@"html"];
        return str;
    }
}
-(void)addJStoWebview{
    NSString *str = @"window.videoToContinueMusic();";
    [_homeWebView stringByEvaluatingJavaScriptFromString:str];
}



//获取加载本地html的路径地址
-(NSString *)getLocalHtmlPath{
    //获取解压后的路径
    NSString *styleName = [[SavaData shareInstance] printDataStr:@"styleName"];
    NSString *specificStyle = [[SavaData shareInstance] printDataStr:@"specificStyle"];
    NSString *unzipPath = [CommonData getZipFilePathManager];
    NSString *stylePath = [NSString stringWithFormat:@"%@/%@/%@.html",unzipPath,styleName,specificStyle];
    NSURL *styleUrl = [NSURL fileURLWithPath:stylePath];
    //将url格式化
    NSString *urlStr = [NSString stringWithFormat:@"%@",styleUrl];
    //当前的url路径
    NSString *currentStr = [urlStr stringByReplacingOccurrencesOfString:@"localhost" withString:@""];
    return currentStr;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *currentURL= _homeWebView.request.URL.absoluteString;

    if (countVisit == 2) {
        [_addView setHidden:YES];
        [_mb setHidden:YES];
        [_homeWebView setHidden:NO];
    }
    
    NSString *jsStr = @"window.iosUseVideoCache=true;";
    //拼装本地的url
    // currentURL ===== file:///Users/apple/Library/Application%20Support/iPhone%20Simulator/6.1/Applications/7BEB4BB9-9B4F-40A6-B75E-CAA54FEDD07A/EternalMemory.app/style1.html
    
    ///var/mobile/Applications/D0A19CB1-42F6-403C-B334-76E0CC5667DC/Documents
    
    NSString *localUrl = [self getLocalHtmlPath];
    NSString *dataPath1 = [[NSBundle mainBundle]  pathForResource:@"style1" ofType:@"html"];
    NSString *dataPath1Str = [NSString stringWithFormat:@"file://%@",dataPath1];
    NSString *dataPath2 = [[NSBundle mainBundle]  pathForResource:@"style2" ofType:@"html"];
    NSString *dataPath2Str = [NSString stringWithFormat:@"file://%@",dataPath2];
    if ([currentURL isEqualToString:localUrl] ||[currentURL isEqualToString:dataPath1Str] || [currentURL isEqualToString:dataPath2Str]){
        //加载完成本地html向模板中注入js语句
        [_homeWebView stringByEvaluatingJavaScriptFromString:jsStr];
    }
    if ([currentURL isEqualToString:MEMORY_SUCCESS_URL]) {
        _homeWebView.hidden = YES;
//        self.titleLabel.text = @"家园";
        countVisit = countVisit +1;
        //int selectID = [[[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"%@homeStyle",USERID]]integerValue];
        NSInteger styleId ;
        if (_whichStyle == nil) {
            
            styleId = [_dictData[@"data"][@"favoriteStyle"] integerValue];
            
        }else{
            
            styleId = [_whichStyle integerValue];
        }
        
        NSDictionary *styleDic = _dictData[@"meta"][@"favoriteStyle"];
        NSString *filePath = nil;
        if ([INLAND_SERVER isEqualToString:@"http://ieternal.cn/"]) {
            if (styleId ==1 || styleId ==2) {
                filePath = [self strFilePathStyle:styleId];
            }else{
                if (styleDic.count >0 && [styleDic isKindOfClass:[NSDictionary class]]) {
                    NSString *specificStyle = [NSString stringWithFormat:@"style%d.html",styleId];
                    filePath = [self styleFilePath:styleDic[@"styleName"] styleName:specificStyle];
                    if ([filePath isEqualToString:@"0"]) {
                        //请求网络获取风格模板url
                        if (![FileModel sharedInstance].isHomeDown) {
                            [MyToast homeStyleTimeDelayText:@"本地没有保存您之前设置过的模板,需要同步后才能观看":[UIScreen mainScreen].bounds.size.height/2-60 :2.f];
                            [self loadRequestStyleBoadUrl:styleDic];
                        }
                        //下载文件同时，先显示默认的
                        filePath = [self strFilePathStyle:2];
                    }
                }else{
                    //没有信息的情况下先显示默认的
                    filePath = [self strFilePathStyle:2];
                }
            }
            
        }else{
            //国内服务器
            if (styleId ==1 || styleId ==2) {
                filePath = [self strFilePathStyle:styleId];
            }else{
                if (styleDic.count >0 && [styleDic isKindOfClass:[NSDictionary class]]) {
                    NSString *specificStyle = [NSString stringWithFormat:@"style%d.html",styleId];
                    filePath = [self styleFilePath:styleDic[@"styleName"] styleName:specificStyle];
                    if ([filePath isEqualToString:@"0"]) {
                        //请求网络获取风格模板url
                        if (![FileModel sharedInstance].isHomeDown) {
                            [MyToast homeStyleTimeDelayText:@"本地没有保存您之前设置过的模板,需要同步后才能观看":[UIScreen mainScreen].bounds.size.height/2-60 :3.f];
                            [self loadRequestStyleBoadUrl:styleDic];
                        }
                        //下载文件同时，先显示默认的
                        filePath = [self strFilePathStyle:2];
                    }
                }else{
                    //没有信息的情况下先显示默认的
                    filePath = [self strFilePathStyle:2];
                }
            }
            
        }
        
        NSURL *url = [NSURL fileURLWithPath:filePath];
        //        NSURL *url = [NSURL URLWithString:@"http://mobile.51cto.com/iphone-280323.htm"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_homeWebView loadRequest:request];
    }else if([currentURL isEqualToString:MEMORY_FAILURE_URL]){
        
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        if ([_visitStyle isEqualToString:@"eternalcode"]) {
            HUD.labelText = @"记忆码错误，请重新输入";
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
            [HUD showAnimated:YES whileExecutingBlock:^{
                sleep(2);
            } completionBlock:^{
                [HUD removeFromSuperview];
                [HUD release];
            }];
        }else{
            HUD.labelText = @"访问失败";
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]] autorelease];
            [HUD showAnimated:YES whileExecutingBlock:^{
                sleep(2);
            } completionBlock:^{
                [HUD removeFromSuperview];
                [HUD release];
            }];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
         //    [promptMB setHidden:YES];
        
    }
}

//加载webview
-(void)loadWebview{
    [_addView setHidden:NO];
    [self.view bringSubviewToFront:_addView];
    _mb = [[[MBProgressHUD alloc]initWithView:_addView]autorelease];
    [_addView addSubview:_mb];
    _mb.detailsLabelText = @"正在加载中...";
    _mb.delegate = self;
    [_mb show:YES];
    countVisit = 1;
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"友情提示" message:@"请检查网络链接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alert.tag = 1000;
    [alert show];
    [alert release];
    //    [self.navigationController popViewControllerAnimated:YES];
}

//-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//
//
//    return YES;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [_addView release];
    [_homeWebView release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addJStoWebviewsss" object:nil];
    [super dealloc];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [UIApplication sharedApplication].statusBarHidden = NO;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate
{
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

@end

