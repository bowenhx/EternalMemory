//
//  HomeStyleViewCtrl.m
//  EternalMemory
//
//  Created by Guibing Li on 13-5-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "HomeStyleViewCtrl.h"
#import "CommonData.h"
#import "FileModel.h"
@interface HomeStyleViewCtrl ()
{
    UIButton        *_butSelect;
    NSMutableArray  *_arrStyleText;
    NSMutableArray  *_arrStyleName;
    UIImageView     *_imageSelect;
    BOOL             isSelectBut;
    NSInteger        selectedButton;
    
    NSMutableArray  *_imageArr;
}
@end
//
//#define   FLOWVIEWY  SCREEN_HEIGHT > 500? -130:100
//#define   FLOWVIEWHEIGHT  SCREEN_HEIGHT > 500? 100:80


@implementation HomeStyleViewCtrl
@synthesize flowViewIndex;
-(void)dealloc
{
    [_arrStyleName release];
    [_arrStyleText removeAllObjects];
    [_arrStyleText release];
    [_imageSelect release];
    [_imageArr release],_imageArr = nil;
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
    self.titleLabel.text = @"美式风格";
    self.middleBtn.hidden = YES;
    self.backBtn.hidden = NO;
    self.rightBtn.hidden = NO;
    
    [self.rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.rightBtn setBackgroundImage:[UIImage imageNamed:@"nav_rightBut"] forState:UIControlStateNormal];
    
    [self initData];
    [self initLoadViewShowData];
	// Do any additional setup after loading the view.
}
- (void)initData
{
    isSelectBut = NO;
    _arrStyleText = [NSMutableArray new];
    _arrStyleName = [NSMutableArray new];
    _imageArr = [NSMutableArray new];
}
- (void)initLoadViewShowData
{
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width,SCREEN_HEIGHT-44-20)];
    //    viewBg.layer.borderWidth = 2;
    //    viewBg.layer.borderColor = [UIColor redColor].CGColor;
    viewBg.userInteractionEnabled = YES;
    AFOpenFlowView *aView = nil;
    if (SCREEN_HEIGHT > 500)
    {
        aView = [[AFOpenFlowView alloc] initWithFrame:CGRectMake(0, -130, viewBg.bounds.size.width, viewBg.bounds.size.height + 100)];
    }
    else
    {
        aView = [[AFOpenFlowView alloc] initWithFrame:CGRectMake(0, -100, viewBg.bounds.size.width, viewBg.bounds.size.height + 70)];
    }
    aView.dataSource = self;
    aView.viewDelegate = self;
    //aView.layer.borderWidth = 1;
    //aView.layer.borderColor = [UIColor greenColor].CGColor;
    _butSelect = [UIButton buttonWithType:UIButtonTypeCustom];
    _butSelect.frame = CGRectMake(100, aView.bounds.size.height-50 - 120, 120, 35);
    _butSelect.backgroundColor = [UIColor clearColor];
    _butSelect.alpha = 1;
    [_butSelect.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_butSelect setTitle:@"       bs_kt" forState:UIControlStateNormal];
    [_butSelect setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_butSelect addTarget:self action:@selector(didSelectHomeType:) forControlEvents:UIControlEventTouchUpInside];
    
    _imageSelect = [[UIImageView alloc] initWithFrame:CGRectMake(1,3, 28, 28)];
//    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:selectedButton] forKey:[NSString stringWithFormat:@"%@homeStyle",USERID]];

    flowViewIndex = [[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@homeStyle",USERID]] intValue];
    selectedButton = flowViewIndex;
//    if (flowViewIndex == 1)
//    {
//        flowViewIndex = 1;
//        selectedButton = 1;
//        _imageSelect.image = [UIImage imageNamed:@"public_noselect_but.png"];
//    }
//    else
//    {
//        flowViewIndex = 0;
//        selectedButton = 0;
//        _imageSelect.image = [UIImage imageNamed:@"public_select_but.png"];
//    }
    if (selectedButton == 0)
    {
        _imageSelect.image = [UIImage imageNamed:@"public_select_but.png"];
    }
    else
    {
        _imageSelect.image = [UIImage imageNamed:@"public_noselect_but.png"];
    }
    [_butSelect addSubview:_imageSelect];
    [aView addSubview:_butSelect];
    [viewBg addSubview:aView];
    [self.view addSubview:viewBg];
    
    [aView release];
    [viewBg release];
    [_arrStyleName addObject:@"美式风格"];
    [_arrStyleName addObject:@"欧式风格"];
    [_arrStyleText addObject:@"bs_kt"];
    [_arrStyleText addObject:@"ox_kt"];
    
    
    //默认的风格模板
    [self acquiesceTwoStyle];
    
    //TODO: 便利下载风格模板数量数组 //需要风格图片和模板名字一致
  
    NSMutableArray *arr = [[SavaData shareInstance] printDataAry:@"styleFile"];
    if (arr.count>0) {
        for (NSDictionary *dic in arr) {
            
            NSString *name = dic[@"styleName"];
            //取出图片路径地址
            NSString *styleId = [self styleFilePath:name imageName:dic[@"imageName"]];
           // NSString *styleId = [self styleFilePath:name imageName:@"style3.png"];
            [_arrStyleName addObject:dic[@"styleName"]];
            
            UIImage *image1 = [UIImage imageWithContentsOfFile:styleId];
//            NSLog(@"image1=  %@",image1);
            if ([image1 isKindOfClass:[UIImage class]]) {
                NSString *imageName = dic[@"imageName"];
                imageName = [imageName substringToIndex:imageName.length - 4];
                [_arrStyleText addObject:imageName];
                [_imageArr addObject:image1];
            }
        }
    }    
    
    
    int i= 0;
    for (UIImage *img in _imageArr)
    {
        [aView setImage:img forIndex:i];
        i++;
    }
    
	//设置图片轮寻的数量
	[aView setNumberOfImages:_imageArr.count];
}
//默认风格
- (void)acquiesceTwoStyle
{
   
    NSString *strImg1 = [[NSBundle mainBundle] pathForResource:@"0" ofType:@"jpg"];
    NSString *strImg2 = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"];
    UIImage *image1 = [UIImage imageWithContentsOfFile:strImg1];
    UIImage *image2 = [UIImage imageWithContentsOfFile:strImg2];
    if ([image1 isKindOfClass:[UIImage class]] &&[image2 isKindOfClass:[UIImage class]]) {
        [_imageArr addObject:image1];
        [_imageArr addObject:image2];
    }    
//    NSLog(@"image2 = %@",image2);
//    NSLog(@"image1 = %@",image1);

}
- (NSString *)styleFilePath:(NSString *)styleName imageName:(NSString *)str
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *savePath = [[[CommonData getZipFilePathManager] stringByAppendingPathComponent:styleName] stringByAppendingPathComponent:str];
    if (![fileManager fileExistsAtPath:savePath]) {
//        [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
//        NSLog(@"没有下载文件");
        return @"";
    }else
    {
        
        return savePath;
    }
}


- (void)didSelectHomeType:(UIButton *)but
{
    //    if (!isSelectBut){
    //        _imageSelect.image = [UIImage imageNamed:@"public_select_but"];
    //        selectedButton = flowViewIndex;
    //    } else
    //    {
    //        _imageSelect.image = [UIImage imageNamed:@"public_noselect_but"];
    //        selectedButton = -1;
    //    }
    //     isSelectBut = !isSelectBut;i
    if (_imageSelect.tag == selectedButton)
    {
        _imageSelect.image = [UIImage imageNamed:@"public_noselect_but"];
        selectedButton = -1;
    }
    else
    {
        _imageSelect.image = [UIImage imageNamed:@"public_select_but"];
        selectedButton = _imageSelect.tag;
    }
}
#pragma mark AFOpenFlowViewDataSource

- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index
{
//    NSLog(@"---- %d",index);
    
}
- (UIImage *)defaultImage
{
    return [UIImage imageNamed:@"default.png"];
}
#pragma mark delegate
- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index
{
    _imageSelect.tag = index;
    flowViewIndex = index;
    if (selectedButton == flowViewIndex)
    {
        _imageSelect.image = [UIImage imageNamed:@"public_select_but"];
    }
    else
    {
        _imageSelect.image = [UIImage imageNamed:@"public_noselect_but"];
    }
    if (_arrStyleText.count>0) {
        
        [_butSelect setTitle:[NSString stringWithFormat:@"      %@",_arrStyleText[index]] forState:UIControlStateNormal];
    }
    self.titleLabel.text = _arrStyleName[index];
    
    //	NSLog(@"Cover Flow selection did change to %d", index);
}
-(void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
    //保存家园风格的键值
}
-(void)rightBtnPressed
{
//    [self.navigationController popViewControllerAnimated:YES];
    //保存家园风格的键值
    [self networkPromptMessage:@"风格保存成功"];
    [[SavaData shareInstance] savadataStr:_arrStyleName[selectedButton] KeyString:@"homeStyle"];
     [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:selectedButton] forKey:[NSString stringWithFormat:@"%@homeStyle",USERID]];
    if (selectedButton > 1)
    {
        [[SavaData shareInstance] savadataStr:_arrStyleName[selectedButton] KeyString:@"styleName"];
        [[SavaData shareInstance] savadataStr:_arrStyleText[selectedButton] KeyString:@"specificStyle"];
    }
    else
    {
        [[SavaData shareInstance] savadataStr:nil KeyString:@"styleName"];
        [[SavaData shareInstance] savadataStr:nil KeyString:@"specificStyle"];
    }
    [self.navigationController popViewControllerAnimated:YES];
//    if (selectedButton == 1)
//    {
//        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:selectedButton] forKey:[NSString stringWithFormat:@"%@homeStyle",USERID]];
//    }
//    else if (selectedButton ==0)
//    {
//        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:selectedButton] forKey:[NSString stringWithFormat:@"%@homeStyle",USERID]];
//    }else{
//         [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:selectedButton] forKey:[NSString stringWithFormat:@"%@homeStyle",USERID]];
//    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
