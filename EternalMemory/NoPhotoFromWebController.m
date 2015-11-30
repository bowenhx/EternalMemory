//
//  NoPhotoFromWebController.m
//  EternalMemory
//
//  Created by xiaoxiao on 3/24/14.
//  Copyright (c) 2014 sun. All rights reserved.
//

#import "NoPhotoFromWebController.h"

@interface NoPhotoFromWebController ()
{
    //web进入时导航栏显示的控件
    UIButton        *_memoryButton;
    UIButton        *_allButton;
    UIButton        *_closeButton;
    UIImageView     *_backgroupImageView;
    UILabel         *_warningLabel;
}
@end

@implementation NoPhotoFromWebController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _backgroupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(90, (SCREEN_HEIGHT - 105 - 30)/2, 140, 105)];
    _backgroupImageView.image = [UIImage imageNamed:@"no_photo_home"];
    [self.view addSubview:_backgroupImageView];
    [_backgroupImageView release];

    _warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, (_backgroupImageView.frame.size.height + _backgroupImageView.frame.origin.y + 10), 220, 40)];
    _warningLabel.text = @"您还没照片，请先上传照片";
    _warningLabel.textColor = [UIColor grayColor];
    _warningLabel.backgroundColor = [UIColor clearColor];
    _warningLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_warningLabel];
    [_warningLabel release];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"photo"]];
    [self createNavgationBarFromWeb];
    // Do any additional setup after loading the view.
}
-(void)createNavgationBarFromWeb
{
    _memoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _memoryButton.frame = CGRectMake(10, 10, 75, 30);
    _memoryButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_memoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_memoryButton setTitle:@"时光记忆" forState:UIControlStateNormal];
    [_memoryButton setTitleColor:[UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1] forState:UIControlStateNormal];

    [_memoryButton setBackgroundImage:[UIImage imageNamed:@"life_memory_photo"] forState:UIControlStateNormal];
    
    [_memoryButton addTarget:self action:@selector(showMemoryPhoto) forControlEvents:UIControlEventTouchUpInside];
    _memoryButton.userInteractionEnabled = YES;
    [_memoryButton setHighlighted:NO];
    [self.view addSubview:_memoryButton];
    
    _allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allButton.frame = CGRectMake(85, 10, 75, 30);
    _allButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_allButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_allButton setTitle:@"其他图片" forState:UIControlStateNormal];
    [_allButton setTitleColor:[UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1] forState:UIControlStateNormal];
    [_allButton setBackgroundImage:[UIImage imageNamed:@"all_photo_selected"] forState:UIControlStateNormal];
    [_allButton setBackgroundImage:[UIImage imageNamed:@"all_photo_selected"] forState:UIControlStateHighlighted];
    [self.view addSubview:_allButton];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = CGRectMake(280, 10, 30, 30);
    [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(backToHomeWeb) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    
}

-(void)showMemoryPhoto
{
    [self dismissViewControllerAnimated:NO completion:NULL];
}
-(void)backToHomeWeb
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backToHomeWeb" object:nil];

}
#pragma mark - View controller rotation methods

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setNavBarOriention:toInterfaceOrientation];
}
-(void)setNavBarOriention:(UIInterfaceOrientation)orientation
{
    
    if (orientation == UIInterfaceOrientationPortrait)
    {
        _memoryButton.frame = CGRectMake(10, 10, 75, 30);
        _allButton.frame = CGRectMake(85, 10, 75, 30);
        _closeButton.frame = CGRectMake(280, 10, 30, 30);
        _backgroupImageView.frame = CGRectMake(90, (SCREEN_HEIGHT - 105 - 30)/2, 140, 105);
        _warningLabel.frame = CGRectMake(50, ( _backgroupImageView.frame.size.height + _backgroupImageView.frame.origin.y + 10), 220, 40);
    }
    else
    {
        CGFloat width = (iPhone5)? 568 : 480;
        _memoryButton.frame = CGRectMake(20, 10, 75, 30);
        _allButton.frame = CGRectMake(95, 10, 75, 30);
        _closeButton.frame = CGRectMake(width - 40, 10, 30, 30);
        _backgroupImageView.frame = CGRectMake((width - 140)/ 2, 90, 140, 105);
        _warningLabel.frame = CGRectMake((width - 220)/2,210 , 220, 40);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
