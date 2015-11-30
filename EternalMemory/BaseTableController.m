//
//  MoreViewCtrl.m
//  EternalMemory
//
//  Created by Guibing Li on 13-5-23.
//  Copyright (c) 2013年 sun. All rights reserved.
//


#import <CoreGraphics/CoreGraphics.h>
#import "BaseTableController.h"

@interface BaseTableController ()

@end

@implementation BaseTableController

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
    if (_myDatasArr)
    {
        [_myDatasArr release];
        self.myDatasArr = nil;
    }
    if (_myTableView)
    {
        [_myTableView release];
    }
    [super dealloc];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Utilities adjustUIForiOS7WithViews:@[self.myTableView]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
}
- (void)viewDidLoad
{
    [super viewDidLoad];


    UITableView *tmpTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-64) style:self.myTableViewStype];
//    tmpTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    tmpTable.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"public_table_line.png"]];
    self.myTableView = tmpTable;
    [tmpTable release];

    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    self.myTableView.backgroundColor = RGBCOLOR(238, 242, 245);


    if (self.myTableViewStype == UITableViewStyleGrouped)
    {
        UIView *tmpView =[[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, self.myTableView.frame.size.height)];
        self.myTableView.backgroundView = tmpView;
        [tmpView release];

        self.myTableView.backgroundView.backgroundColor = RGBCOLOR(238, 242, 245);

    }

    [self.view addSubview:self.myTableView];
    
   
    
    // Do any additional setup after loading the view.
}


#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.myDatasArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end