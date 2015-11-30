//
//  SelectListCategoriesViewController.m
//  EternalMemory
//
//  Created by sun on 13-5-31.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "SelectListCategoriesViewController.h"
#import "EditCategoriesViewController.h"
#import "DiaryGroupsModel.h"
#import "DiaryGroupsSQL.h"
#import "FileModel.h"
#import "Utilities.h"
#import "MyToast.h"
#define CELL_HEIGHT 50
#define TEXTTYPE @"0"

@interface SelectListCategoriesViewController ()
{
    ASIFormDataRequest *formDataRequest;
    NSInteger comeInTime;
}
@property (nonatomic, retain)  UITableView *tableview;
@property (retain, nonatomic)  UITextField *editGroupTextField;
@property (retain, nonatomic)  UIView *lineView;
@property (nonatomic, retain)  NSArray *categoriesArray;

-(UIView *)configureFooterView;

@end

@implementation SelectListCategoriesViewController
@synthesize tableview = _tableview;
@synthesize currentIndex = _currentIndex;
@synthesize categoriesArray = _categoriesArray;
@synthesize selectListCategoriesDelegate = _selectListCategoriesDelegate;
#pragma mark - object lifecycle
- (void)dealloc
{
    if (formDataRequest)
    {
        [formDataRequest clearDelegatesAndCancel];
        formDataRequest = nil;
    }
    RELEASE_SAFELY(_tableview);
    [_editGroupTextField release];
    [_lineView release];
    [super dealloc];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate
{
    return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _currentIndex = 0;
        comeInTime = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setViewData];
    self.categoriesArray = [DiaryGroupsSQL getDiaryGroups:TEXTTYPE AndUserId:USERID] ;
    CGFloat tableView_origin_y = iOS7 ? 64.0f:44.0f;
    CGFloat tableView_height = iOS7? (SCREEN_HEIGHT - tableView_origin_y):(SCREEN_HEIGHT - tableView_origin_y - 20);
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, tableView_origin_y, 320, tableView_height) style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [_tableview setTableFooterView:[self configureFooterView]];
    [self.view addSubview:_tableview];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![Utilities checkNetwork])
    {
        [MyToast showWithText:@"网络连接失败，请检查网络，更新您最新的日记分组" :200];
    }
    else
    {
        if (comeInTime == 1)
        {
            NSURL *registerUrl = [[RequestParams sharedInstance] manageGroup];
            formDataRequest = [ASIFormDataRequest requestWithURL:registerUrl];
            [formDataRequest setPostValue:@"list" forKey:@"operation"];
            [formDataRequest setPostValue:@"0" forKey:@"type"];
            formDataRequest.delegate = self;
            [formDataRequest setShouldAttemptPersistentConnection:NO];
            [RequestParams setRequestCommonData:formDataRequest];
            [formDataRequest startAsynchronous];
            comeInTime = 2;
        }
    }
}
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    
    int success =[[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]] intValue];
    if (success == 1)
    {
        NSMutableArray *dataArray = [NSMutableArray array];
        [dataArray setArray:[resultDictionary objectForKey:@"data"]];
        [DiaryGroupsSQL  refershDiaryGroups:dataArray WithUserID:USERID];
    }
    self.categoriesArray = [DiaryGroupsSQL getDiaryGroups:TEXTTYPE AndUserId:USERID] ;
    [self.tableview reloadData];
    formDataRequest = nil;
}


-(UIView *)configureFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UILabel *editLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 213, 30)];
    editLabel.text = @"编辑分组";
    editLabel.textAlignment = NSTextAlignmentLeft;
    editLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGetsure = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEditBtnClicked:)];
    [editLabel addGestureRecognizer:tapGetsure];
    [tapGetsure release];
    [footerView addSubview:editLabel];
    [editLabel release];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, 310, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:220.0/ 255.0 green:220.0/ 255.0 blue:220.0/ 255.0 alpha:1.0f];
    [footerView addSubview:lineView];
    [lineView release];
    if (iOS7)
    {
//        lineView.hidden = YES;
        lineView.frame = CGRectMake(15, 0, 320, 1);
    }
    return [footerView autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - private methods
- (void)backBtnPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setViewData
{
    self.rightBtn.hidden = YES;
    [self.titleLabel setText:@"书籍"];
    self.middleBtn.enabled = NO;
    
}
#pragma mark - ibaction
- (void)onEditBtnClicked:(id)sender{
    if ([Utilities checkNetwork]) {
        [_selectListCategoriesDelegate EditCategories:YES selectedGroup:nil  selectedIndex:(NSInteger)nil];
        [self backBtnPressed];
    }
    else
    {
        [MyToast showWithText:@"请检查网络" :140];
    }
}
#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [FileModel sharedInstance].editSort = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_currentIndex
                                                   inSection:0];
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UIColor *selectedColor = RGBCOLOR(46,154,222);
        newCell.textLabel.textColor = selectedColor;
        newCell.accessoryView.hidden = NO;
    }
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        UIColor *defulColor = RGBCOLOR(118,131,141);
        oldCell.textLabel.textColor = defulColor;
        oldCell.accessoryView.hidden = YES;
    }
    [self.titleLabel setText:newCell.textLabel.text];
    _currentIndex = indexPath.row;
    if (_currentIndex == 0) {
        [_selectListCategoriesDelegate EditCategories:NO selectedGroup:nil selectedIndex:_currentIndex];
    }
    else
    {
        DiaryGroupsModel *model = [self.categoriesArray objectAtIndex:_currentIndex - 1];
        [_selectListCategoriesDelegate EditCategories:NO selectedGroup:model  selectedIndex:_currentIndex];
    }
    [self backBtnPressed];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_categoriesArray count] + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SelectListCategoriesCellIdentifier = @"SelectListCategoriesCellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:SelectListCategoriesCellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] init] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
         cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fl_xz.png"]] autorelease];
    }
    
    if ([indexPath row] == 0 )
    {
        [cell.textLabel setText:@"书籍"];
    }
    else
    {
        DiaryGroupsModel *model = [self.categoriesArray objectAtIndex:indexPath.row - 1];
        [cell.textLabel setText:[NSString stringWithFormat:@"%@  (共%@篇)",model.title,model.blogcount]];
    }
    if(indexPath.row == _currentIndex){
        UIColor *selectedColor = RGBCOLOR(46,154,222);
        cell.textLabel.textColor = selectedColor;
        cell.accessoryView.hidden = NO;
    }
    else
    {
        UIColor *defulColor = RGBCOLOR(118,131,141);
        cell.textLabel.textColor = defulColor;
        cell.accessoryView.hidden = YES;
    }
    return cell;
}


@end
