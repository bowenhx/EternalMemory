//
//  SetPrivacyViewCtrl.m
//  EternalMemory
//
//  Created by Guibing on 13-6-3.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "SetPrivacyViewCtrl.h"
#import "NTPrivacyProblemViewCtrl.h"
#import "ForbidVisitViewController.h"
@interface SetPrivacyViewCtrl ()
{
    UISwitch *_swich;
}
@end

@implementation SetPrivacyViewCtrl

- (void)dealloc
{
    [_swich release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.myTableViewStype = UITableViewStyleGrouped;
        // Custom initialization
    }
    return self;
}
- (void)initPromptFooterView
{
    UIView *viewFoot = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    viewFoot.backgroundColor = [UIColor clearColor];
    
    UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 40)];
    labText.backgroundColor = [UIColor clearColor];
    labText.userInteractionEnabled = YES;
    labText.text = @"提示：申请封存通过后，不能修改内容，只能凭                 访问我的家园，请慎重考虑！";
    labText.font = [UIFont systemFontOfSize:12];
    labText.numberOfLines = 0;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(labText.frame.size.width-49, 3, 40, 20);
    [button setTitle:@"记忆码" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [button setTitleColor:RGBCOLOR(56, 138, 214) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didSelectMemory:) forControlEvents:UIControlEventTouchUpInside];
    [labText addSubview:button];
    [viewFoot addSubview:labText];
    [labText release];
    
    self.myTableView.tableFooterView = viewFoot;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _swich.on = YES;
    self.titleLabel.text = @"隐私设置";
    self.middleBtn.hidden = YES;
    self.rightBtn.hidden = YES;

    
//    [self initPromptFooterView];

	// Do any additional setup after loading the view.
}
- (void)didSelectMemory:(UIButton *)but
{
//    NSLog(@"记忆码");
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor =  RGBCOLOR(93.0, 102.0, 113.0);
    
    if (indexPath.row ==0) {
        cell.textLabel.text = @"密保问题";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.row ==1)
    {
        /*
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"是否公开访问";
        fd
        _swich = [[UISwitch alloc] initWithFrame:CGRectMake(320-110, 8, 60, 35)];
        _swich.onTintColor = RGBCOLOR(89, 185, 47);
        _swich.on = NO;
        [_swich addTarget:self action:@selector(touchClickSwich:) forControlEvents:UIControlEventTouchDragInside];
        [cell.contentView addSubview:_swich];

    }else
    {
        cell.textLabel.text = @"封存访问";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

         */
        cell.textLabel.text = @"封存访问";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }
        
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row ==0) {
        NTPrivacyProblemViewCtrl *privacyProblem = [NTPrivacyProblemViewCtrl new];
        [self.navigationController pushViewController:privacyProblem animated:YES];
        [privacyProblem release];
      
    }else if (indexPath.row == 2)
    {
//        NSLog(@"开始封存操作");

    }else{
        ForbidVisitViewController *forbid = [[ForbidVisitViewController alloc]init];
        [self.navigationController pushViewController:forbid animated:YES];
        [forbid release];

    }
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
  
    return @"提示:申请封存通过后,不能修改内容,只能凭记忆码访问我的家园,请慎重考虑!";
}

- (void)touchClickSwich:(UISwitch *)s
{
//    NSLog(@"s = %d",s.on);
}
- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
