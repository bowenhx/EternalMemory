//
//  MemberIdentityViewController.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-17.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "MemberIdentityViewController.h"
#import "MemberIdentityCell.h"
#import "GenealogyMetaData.h"
#import <QuartzCore/QuartzCore.h>
#import "MyFamilySQL.h"
#import "MyToast.h"

#define CELL_IDENTIFER          @"memberCell"

@interface MemberIdentityViewController ()
{
    CGRect      _originFrameForInputView;
    CGFloat     _totalHeightOfKeyboardAndToolbar;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSIndexPath *lastIndexPathSecOne;
@property (nonatomic, retain) NSIndexPath *lastIndexPathSecTwo;
@property (nonatomic, retain) NSMutableDictionary *tableDataDic;
@property (nonatomic, retain) NSMutableDictionary *requiredData;
@property (nonatomic, retain) UITextField *inputView;
@property (nonatomic, retain) UIToolbar   *toolBar;

@property (nonatomic, retain) NSMutableArray     *itemsArr;

@end

@implementation MemberIdentityViewController

- (void)dealloc
{
    [_itemsArr release];
    [_lastIndexPathSecTwo release];
    [_lastIndexPathSecOne release];
    [_tableView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = @"身份关系";
    [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    self.middleBtn.hidden = YES;
    
    _requiredData = [NSMutableDictionary new];
    _itemsArr = [NSMutableArray new];
    
    [self setupTableView];
    [self setupToolBar];
    
    if (!_isPartner) {
        
        NSArray *identityArr = [[MyFamilySQL getAllMothersForAMember:_infoDic] retain];
        NSArray *titleArr = @[@"亲生",@"领养",@"过继",@"其他"];
        
        [_itemsArr addObjectsFromArray:titleArr];
        _tableDataDic = [@{@"identity": identityArr, @"title" : titleArr} mutableCopy];
        [identityArr release];
        
        
        
    } else {
        
        NSArray *identityArr = @[@"现任",@"前任",@"其他"];
        [_itemsArr addObjectsFromArray:identityArr];
        _tableDataDic = [@{@"identity" : identityArr} mutableCopy];
        
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _originFrameForInputView = [_inputView convertRect:_inputView.frame toView:self.view];
    
}

- (void)setupTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, iOS7 ? 60 : 44, SCREEN_WIDTH, SCREEN_HEIGHT - 60) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundView = nil;
    _tableView.bounces = NO;
    [_tableView registerClass:[MemberIdentityCell class] forCellReuseIdentifier:CELL_IDENTIFER];
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
}

- (void)setupToolBar
{
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    }
    
    UIBarButtonItem *finashBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finashInputting:)];
    UIBarButtonItem *flexableSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [_toolBar setItems:@[flexableSpace, finashBtn]];
    _toolBar.alpha = 0;
    [self.view addSubview:_toolBar];
    [_toolBar release];
    [finashBtn release];
    [flexableSpace release];
    
}

- (void)finashInputting:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        _toolBar.alpha = 0;
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [_inputView resignFirstResponder];
}

- (void)backBtnPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBtnPressed
{
    [_inputView resignFirstResponder];
    
    if (_inputView.text.length != 0) {
        _requiredData[kIdentity]  = _inputView.text;
    }
    
    if ([_requiredData[kIdentity] length] == 0) {
        NSString *message = @"";
        NSInteger section = [_tableView numberOfSections];
        if (section == 1) {
            message = @"请选择父母";
        } else if (section == 2) {
            message = @"请选择关系";
        }
        
        [MyToast showWithText:message :130];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DidSelectIdentityNotification object:self.requiredData userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger count = [_tableDataDic count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSInteger count = [_tableDataDic[@"identity"] count];
        return count;
    }
    if (section == 1) {
        return [_tableDataDic[@"title"] count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MemberIdentityCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFER];

    if (_isPartner) {
        cell.textLabel.text = _tableDataDic[@"identity"][indexPath.row];
        if ([cell.textLabel.text isEqualToString:_infoDic[kSubTitle]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.lastIndexPathSecOne = indexPath;
            _requiredData[kIdentity] = cell.textLabel.text;
        } else {
            
        }
    } else {
        if (indexPath.section == 0) {
            cell.textLabel.text = _tableDataDic[@"identity"][indexPath.row][kName];
            if ([cell.textLabel.text isEqualToString:_infoDic[kMotherName]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.lastIndexPathSecOne = indexPath;
                if (_isPartner) {
                    _requiredData[kIdentity] = cell.textLabel.text;
                } else {
                    _requiredData[kMotherInfo] = _tableDataDic[@"identity"][indexPath.row];
                }
            } else {
                
            }
        }
        if (indexPath.section == 1) {
            cell.textLabel.text = _tableDataDic[@"title"][indexPath.row];
            if ([cell.textLabel.text isEqualToString:_infoDic[kSubTitle]]  && ![cell.textLabel.text isEqualToString:@"其他"]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.lastIndexPathSecTwo = indexPath;
                _requiredData[kIdentity] = cell.textLabel.text;
                
            } else {

            }
        }
    }
    
    
    NSInteger numberOfSections = [tableView numberOfSections];
    if ((numberOfSections == 2 && (indexPath.section == 1 && indexPath.row == 3)) || (numberOfSections == 1 && (indexPath.section == 0 && indexPath.row == 2))) {
//    if ([cell.textLabel.text isEqualToString:@"其他"]) {
        
        if (!_inputView) {
            _inputView = [[UITextField alloc] initWithFrame:CGRectMake(70, iOS7 ? 6 : 11, 200, 30)];
            _inputView.delegate = self;
            _inputView.font = [UIFont systemFontOfSize:15];
            _inputView.placeholder = @"请输入";
            _inputView.backgroundColor = [UIColor clearColor];
            _inputView.borderStyle = UITextBorderStyleNone;
            [cell.contentView addSubview:_inputView];
            [_inputView release];
            
        }
        
        
        NSString *subTitle = [_infoDic[kSubTitle] copy];
        
        if (![_itemsArr containsObject:subTitle]) {
            _inputView.text = subTitle;
            
            [subTitle release];
        }
    } else {
        _inputView = nil;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_isPartner) {
        return @"配偶身份";
    } else {
        if (section == 0) {
            if ([_tableDataDic[@"identity"] count] == 0) {
                return nil;
            }
            return @"选择父母";
        }
        if (section == 1) {
            return @"亲子关系";
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        MemberIdentityCell *lastCell = (MemberIdentityCell *)[tableView cellForRowAtIndexPath:_lastIndexPathSecOne];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
        
        MemberIdentityCell *cell = (MemberIdentityCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ([cell.textLabel.text isEqualToString:@"其他"]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [_inputView becomeFirstResponder];
            return;
        } else {
            _toolBar.alpha = 0;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
            [_inputView resignFirstResponder];
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (tableView.numberOfSections == 1) {
            _inputView.text = @"";
        }
        
        self.lastIndexPathSecOne = indexPath;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (_isPartner) {
            _requiredData[kIdentity] = cell.textLabel.text;
            
        } else {
            _requiredData[kMotherInfo] = _tableDataDic[@"identity"][indexPath.row];
            
        }
    }
    
    if (section == 1) {
        MemberIdentityCell *lastCell = (MemberIdentityCell *)[tableView cellForRowAtIndexPath:_lastIndexPathSecTwo];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
        
        MemberIdentityCell *cell = (MemberIdentityCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ([cell.textLabel.text isEqualToString:@"其他"]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [_inputView becomeFirstResponder];
            return;
        } else {
            _toolBar.alpha = 0;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
            [_inputView resignFirstResponder];
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _inputView.text = @"";
        
        self.lastIndexPathSecTwo = indexPath;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        _requiredData[kIdentity] = cell.textLabel.text;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_tableView.numberOfSections == 2) {
        MemberIdentityCell *lastCell = (MemberIdentityCell *)[_tableView cellForRowAtIndexPath:_lastIndexPathSecTwo];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (_tableView.numberOfSections == 1) {
        MemberIdentityCell *lastCell = (MemberIdentityCell *)[_tableView cellForRowAtIndexPath:_lastIndexPathSecOne];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoarDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _tableView.contentOffset = CGPointMake(0, 0);
    _tableView.contentSize = CGSizeMake(SCREEN_WIDTH, _tableView.frame.size.height);
    _requiredData[kIdentity] = textField.text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    
    return YES;
}

- (void)keyBoardDidHide:(NSNotification *)notification
{

    [UIView animateWithDuration:0.1 animations:^{
        _toolBar.alpha = 0;
        _tableView.contentOffset = CGPointMake(0, 0);
        _tableView.bounces = YES;
    }];
    

}

- (void)keyBoarDidShow:(NSNotification *)notification
{
    CGPoint toolBarPosition = [self getKeyboardToolbarYAxisWithKeyboardNotification:notification];
    [UIView animateWithDuration:0.1 animations:^{
        _toolBar.frame = (CGRect){
            .origin = toolBarPosition,
            .size.width  = SCREEN_WIDTH,
            .size.height = 44
        };
        _toolBar.alpha = 1;
    }];
    
    [self resetTableviewContentOffset];
    
}

- (void)keyboardFrameChanged:(NSNotification *)notification
{
    CGPoint toolBarPoint = [self getKeyboardToolbarYAxisWithKeyboardNotification:notification];
    
    [UIView animateWithDuration:0.1 animations:^{
        _toolBar.frame = (CGRect){
            .origin = toolBarPoint,
            .size.width  = SCREEN_WIDTH,
            .size.height = 44
        };
    }];
    
    _totalHeightOfKeyboardAndToolbar = _toolBar.frame.origin.y;
    
    [self resetTableviewContentOffset];
}

- (CGPoint)getKeyboardToolbarYAxisWithKeyboardNotification:(NSNotification *)notification
{
    NSValue *keyboardValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [keyboardValue CGRectValue].size;
    CGFloat toolBar_y = SCREEN_HEIGHT - keyboardSize.height - (iOS7 ? 44 : 64);
    CGFloat toolBar_x = 0;
    
    return CGPointMake(toolBar_x, toolBar_y);
}


- (void)resetTableviewContentOffset
{
    CGFloat offset_y = _originFrameForInputView.origin.y + _originFrameForInputView.size.height - _totalHeightOfKeyboardAndToolbar;
    
    if (offset_y < 0) {
        offset_y = 0;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _tableView.contentOffset = CGPointMake(0, offset_y);
    }];
}

- (BOOL)shouldAutorotate
{
    return NO;
}
@end
