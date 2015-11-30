//
//  GenealogyMemberDetailViewController.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "GenealogyMemberDetailViewController.h"
#import "GenealogyMemberEditorViewController.h"
#import "AddingAssoicationViewController.h"
#import "AddOperationTableViewHandler.h"
#import "GenealogyFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "MyFamilySQL.h"
#import "MyToast.h"
#import "OtherMemberHeaderDetailView.h"
#import "FamliyTreeViewController2.h"

#import <QuartzCore/QuartzCore.h>

@interface GenealogyMemberDetailViewController ()
{
    BOOL     _isMySelf;
    BOOL     _isAssociated;
    BOOL     _isAddOperation;
    
    AddOperationTableViewHandler    *handler;
    
    NSDictionary             *_savedUserInfo;
}

@property (retain, nonatomic) IBOutlet UIButton *addMemberBtn;
@property (retain, nonatomic) IBOutlet UIButton *addAssociationBtn;
@property (retain, nonatomic) IBOutlet UIButton *reviewGenealogyBtn;
@property (retain, nonatomic) IBOutlet UIImageView *headerImageView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *ageLabel;
@property (retain, nonatomic) IBOutlet UIImageView *genderImageView;

@property (retain, nonatomic) IBOutlet UILabel *birthDateLabel;
@property (retain, nonatomic) IBOutlet UILabel *relationLabel;
@property (retain, nonatomic) IBOutlet UITableView *addOperationTableView;
@property (retain, nonatomic) IBOutlet UIView *operationContainerView;
@property (retain, nonatomic) IBOutlet UILabel *isAssociatedLabel;
@property (retain, nonatomic) IBOutlet UIView *headerInfoView;

@property (assign, nonatomic) NSUInteger memberIdentity;

/**
 *	判断是否是我自己
 *
 *	@return	BOOL
 */

- (BOOL)isMySelf;
/**
 *	判断是否已关联
 *
 *	@return	BOOL
 */
- (BOOL)isAssociated;

/**
 *	添加家族成员
 *
 */
- (IBAction)onAddMemberBtnPressed:(id)sender;
/**
 *	添加关联
 *
 */
- (IBAction)onAddAssociationBtnPressed:(id)sender;
/**
 *	查看家谱
 *
 */
- (IBAction)onReviewGenealogyBtnPressed:(id)sender;

@end

@implementation GenealogyMemberDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isAssociated = NO;
        _isMySelf = NO;
        _isAddOperation = NO;
    }
    return self;
}

- (void)dealloc
{
    
    [_memberInfoDic release];
    
    [_addMemberBtn release];
    [_addAssociationBtn release];
    [_reviewGenealogyBtn release];
    [_headerImageView release];
    [_nameLabel release];

    [_birthDateLabel release];
    [_relationLabel release];
    [_addOperationTableView release];
    [_operationContainerView release];
    [_isAssociatedLabel release];
    [_savedUserInfo release];
    [_headerInfoView release];
    [handler release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GenealogyAssociatedSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ModifyMemberInfoSuccessNotification object:nil];
    
    [_ageLabel release];
    [_genderImageView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(associatedSuccess:) name:GenealogyAssociatedSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(MemberInfoDidModified:) name:ModifyMemberInfoSuccessNotification object:nil];

    float systemVersion = [[UIDevice currentDevice] systemVersion].floatValue ;
    if (systemVersion >= 7.0) {
        CGRect frame = _headerInfoView.frame;
        frame.origin.y += 20;
        _headerInfoView.frame = frame;
        
        frame = _operationContainerView.frame;
        frame.origin.y += 20;
        _operationContainerView.frame = frame;
    }
    
    self.titleLabel.text = @"详情";
    self.middleBtn.hidden = YES;
    [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    
    handler = [[AddOperationTableViewHandler alloc] init];
    _savedUserInfo = [[SavaData parseDicFromFile:User_File] retain];
    [self setInfoData:_memberInfoDic];
    [self cornerRoundedButtons];
    
    
}

- (void)MemberInfoDidModified:(NSNotification *)notification
{
    NSDictionary *dic = notification.object;
    self.memberInfoDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [self setInfoData:self.memberInfoDic];
}

- (void)associatedSuccess:(NSNotification *)notification
{
    NSDictionary *dic = notification.object;
    NSDictionary *info = notification.userInfo;
    self.isOthersGenealogy = [info[@"isOther"] boolValue];
#if TARGET_VERSION_LITE ==1//免费版
    _addAssociationBtn.hidden = YES;
#elif TARGET_VERSION_LITE ==2//授权版
    _addAssociationBtn.hidden = NO;
#endif
    self.memberInfoDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [self setInfoData:_memberInfoDic];
}

- (void)setInfoData:(NSMutableDictionary *)dic
{
    _motherDic = [MyFamilySQL getMotherInfoWithMotherId:dic[@"motherId"] andMemberId:dic[@"memberId"]];
    
    BOOL isDead = [dic[kIsDead] boolValue];
    NSString *name = dic[kName];
    NSString *gender = (([dic[kSex] integerValue] == 2) ? (@"女") : (@"男"));
    NSString *age = [self calculateAge];
    NSString *birthDate = [Utilities convertTimestempToDateWithString:dic[kBirthDate] andDateFormat:@"yyyy.MM.dd"];
    NSString *deathDate = [Utilities convertTimestempToDateWithString:dic[kDeathDate] andDateFormat:@"yyyy.MM.dd"];
    NSString *relation = dic[kNickName];
    NSURL *headerURL = [NSURL URLWithString:dic[kHeadPortrait]];
    
    CGFloat width = [name sizeWithFont:_nameLabel.font].width;
    width > 120 ? (width = 120) : (width);
    CGRect labelFrame = _nameLabel.frame;
    labelFrame.size.width = width;
    
    UIImage *maleImage = [UIImage imageNamed:@"s_m.png"];
    UIImage *femaleImage = [UIImage imageNamed:@"s_w.png"];
    
    _nameLabel.frame = labelFrame;
    _nameLabel.textColor = (([dic[kSex] integerValue] == 2) ? ([UIColor colorWithRed:239/255. green:158/255. blue:156/255. alpha:1.0]) : ([UIColor colorWithRed:165/255. green:220/255. blue:255/255. alpha:1.0]));
        _nameLabel.text = name;
    _relationLabel.text = relation;
    _ageLabel.text = age;
    
    
    isDead ? (_birthDateLabel.text = [NSString stringWithFormat:@"%@ - %@",birthDate,deathDate]) : (_birthDateLabel.text = [NSString stringWithFormat:@"%@ - ",birthDate]);
    
    [gender isEqualToString:@"男"] ? ([_genderImageView setImage:maleImage]):([_genderImageView setImage:femaleImage]);
    
    CGRect genderIVFrame = (CGRect) {
        .origin.x = _nameLabel.frame.origin.x + _nameLabel.frame.size.width + 15,
        .origin.y = _genderImageView.frame.origin.y,
        .size = _genderImageView.frame.size
    };
    _genderImageView.frame = genderIVFrame;
   
    CGRect ageLabelFrame = (CGRect) {
        .origin.x = genderIVFrame.origin.x + genderIVFrame.size.width + 15,
        .origin.y = _ageLabel.frame.origin.y,
        .size = _ageLabel.frame.size
        
    };
    _ageLabel.frame = ageLabelFrame;
    
    
    [_headerImageView setImageWithURL:headerURL placeholderImage:[UIImage imageNamed:@"mrtx.png"]];
    
    _isMySelf = [self isMySelf];
    _isAssociated = [self isAssociated];
    
    BOOL isPartener = [_memberInfoDic[kPartnerId] length] != 0;
    
    if (_isOthersGenealogy) {
        self.rightBtn.hidden = YES;
        
        _addAssociationBtn.hidden = YES;
        _addMemberBtn.hidden = YES;
        _reviewGenealogyBtn.hidden = YES;
        
        CGRect tempFrame = _addMemberBtn.frame;
        _reviewGenealogyBtn.frame = tempFrame;
    }
    if (isPartener) {
        _addMemberBtn.hidden = YES;
        _reviewGenealogyBtn.frame = _addAssociationBtn.frame;
        _addAssociationBtn.frame = _addMemberBtn.frame;
        
        _addAssociationBtn.hidden = YES;
        
    }
    
    if (_isMySelf) {
        
        [self setOtherMemberInfoView];
        _addAssociationBtn.hidden = YES;
        _reviewGenealogyBtn.hidden = YES;
        _isAssociatedLabel.hidden = YES;
        
    } else {
        
        [self setOtherMemberInfoView];
        
        if (!_isAssociated) {
            
#if TARGET_VERSION_LITE ==1//免费版
            _addAssociationBtn.hidden = YES;
            _reviewGenealogyBtn.hidden = YES;
            _isAssociatedLabel.hidden = YES;
#elif TARGET_VERSION_LITE ==2//授权版
            _addAssociationBtn.hidden = NO;
            _reviewGenealogyBtn.hidden = YES;
            _isAssociatedLabel.hidden = YES;
#endif
        } else if(_isAssociated) {
            
#if TARGET_VERSION_LITE ==1//免费版
            _addAssociationBtn.hidden = YES;
            _reviewGenealogyBtn.hidden = YES;
            _isAssociatedLabel.hidden = YES;
#elif TARGET_VERSION_LITE ==2//授权版
            [_addAssociationBtn setTitle:@"取消关联" forState:UIControlStateNormal];
            _addAssociationBtn.hidden = NO;
            _reviewGenealogyBtn.hidden = NO;
            _isAssociatedLabel.hidden = NO;
#endif
        }
    }
}

- (void)setOtherMemberInfoView
{
    
    OtherMemberHeaderDetailView *other = [[OtherMemberHeaderDetailView alloc] initWithNib];
    CGRect otherFrame = other.frame;
    otherFrame.origin.x = 93;
    otherFrame.origin.y = 35;
    other.frame = otherFrame;
    other.backgroundColor = _headerInfoView.backgroundColor;
    [_headerInfoView addSubview:other];
    if ([_motherDic[@"sex"] integerValue] == 1) {
        [other configData:_memberInfoDic andParentType:@"父亲："];
    }else{
        [other configData:_memberInfoDic andParentType:@"母亲："];
    }
}

- (void)cornerRoundedButtons
{
    UIColor *borderColor = RGBCOLOR(212, 212, 212);
    CGFloat cornerRadius = 2;
    CGFloat borderWidth  = 0.5;
    
    _addMemberBtn.layer.cornerRadius = cornerRadius;
    _addMemberBtn.layer.borderColor  = borderColor.CGColor;
    _addMemberBtn.layer.borderWidth  = borderWidth;
    
    _reviewGenealogyBtn.layer.cornerRadius = cornerRadius;
    _reviewGenealogyBtn.layer.borderColor  = borderColor.CGColor;
    _reviewGenealogyBtn.layer.borderWidth  = borderWidth;
    
    _addAssociationBtn.layer.cornerRadius = cornerRadius;
    _addAssociationBtn.layer.borderColor  = borderColor.CGColor;
    _addAssociationBtn.layer.borderWidth  = borderWidth;
}

- (BOOL)isAssociated
{
    BOOL flag = [_memberInfoDic[kAssociated] boolValue];
    
    return flag;
}

- (BOOL)isMySelf
{
    BOOL flag = NO;
    NSString *userId = _memberInfoDic[kUserId];
    NSString *memberId = _memberInfoDic[kMemberId];
    if ([userId isEqualToString:memberId]) {
        flag = YES;
    } else {
        flag = NO;
    }
    
    return flag;
}

- (NSString *)convertTimestempToDateWithString:(NSString *)timeStemp
{
    NSTimeInterval interval = [timeStemp doubleValue] / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    return dateStr;

}

- (void)setupOperationTableView
{
    
}

- (void)setMemberInfoDic:(NSMutableDictionary *)memberInfoDic
{
    if (memberInfoDic != _memberInfoDic) {
        [_memberInfoDic release];
        _memberInfoDic = [memberInfoDic mutableCopy];
    }
}

- (IBAction)onAddMemberBtnPressed:(id)sender {
    _isAddOperation = YES;
    CGFloat tableViewWidth = 284;
    CGFloat cellHeight = 44;
    
    UIFont *textLabelFont = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    UIColor *textColor = RGBCOLOR(104, 111, 122);
    
    NSArray *items = nil;
    
    BOOL isMyself = [self isMySelf];
    BOOL isMale = ([_memberInfoDic[kSex] integerValue] == 1) && ([_memberInfoDic[kLevel] integerValue] != 0);
    if (isMyself) {
        items = @[@"添加配偶",@"添加儿子",@"添加女儿"];
    } else {
        if (isMale && [_memberInfoDic[kLevel] integerValue] < 2 && ([_memberInfoDic[kDirectLine] integerValue] == 1 || ([_memberInfoDic[kKinRelation] integerValue] == 1 && [_memberInfoDic[kLevel] integerValue] == 1 && [_memberInfoDic[kSex] integerValue] == 1))) {
            items = @[@"添加配偶",@"添加儿子",@"添加女儿"];
        } else {
            items = @[@"添加配偶"];
        }
    }
    
    handler.items = items;
    handler.textLabelAttributes = @{kLabelAttributesTextColor:textColor,kLabelAttributesTextFont:textLabelFont};

    
    NSInteger tableViewHeight = cellHeight * items.count;
    
    [_addOperationTableView setFrame:CGRectMake(SCREEN_WIDTH + 50, 186, tableViewWidth, tableViewHeight)];
    _addOperationTableView.rowHeight = cellHeight;
    _addOperationTableView.dataSource = handler;
    _addOperationTableView.delegate   = self;
    _addOperationTableView.layer.cornerRadius = 5;
    _addOperationTableView.layer.borderColor  = (RGBCOLOR(212, 212, 212)).CGColor;
    _addOperationTableView.layer.borderWidth  = 0.5;
    [self.view addSubview:_addOperationTableView];
    
    
    
    [UIView animateWithDuration:0.3 animations:^{
        _operationContainerView.frame = CGRectMake(0 - tableViewWidth, iOS7 ? 206 : 186, tableViewWidth, tableViewHeight);
        _addOperationTableView.frame = CGRectMake(16, 186, tableViewWidth, tableViewHeight);
    }];
    
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    GenealogyMemberEditorViewController *editorVC = [[GenealogyMemberEditorViewController alloc] initWithNibName: @"GenealogyMemberEditorViewController-5" bundle:nil];
    switch (row) {
        case 0:
            editorVC.memberType = GenealogyAdditionTypePartner;
            break;
        case 1:
            editorVC.memberType = GenealogyAdditionTypeSon;
            break;
        case 2:
            editorVC.memberType = GenealogyAdditionTypeDaughter;
            break;
            
        default:
            break;
    }
//    editorVC.targetMemberId = _memberInfoDic[kMemberId];
//    editorVC.level = _memberInfoDic[kLevel];
    editorVC.targetMebmerInfo = _memberInfoDic;
    [self.navigationController pushViewController:editorVC animated:YES];
    [editorVC release];
}

- (IBAction)onAddAssociationBtnPressed:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"取消关联"]) {

        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil message:@"确定要取消和此人的关联么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alerView.tag = 44;
        [alerView show];
        [alerView release];
        return;
    }
    
    AddingAssoicationViewController *vc = [[AddingAssoicationViewController alloc] init];
    vc.memberInfoDic = _memberInfoDic;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        GenealogyFormDataRequest *request = [[GenealogyFormDataRequest alloc] initWithURL:[[RequestParams sharedInstance] associateMember]];
        [request setCommentRequest];
        [request setPostValue:@"1" forKey:@"cancel"];
        [request setPostValue:_memberInfoDic[kMemberId] forKey:@"memberid"];
        [request setCompletionBlock:^{
            NSData *data = [request responseData];
            NSDictionary *responseDic = [data objectFromJSONData];
            NSInteger success = [responseDic[@"success"] integerValue];
            NSString *message = responseDic[@"message"];
            
            if (success == 1) {
                [MyFamilySQL updateMemberByMemberId:responseDic[@"data"]];
                [MyToast showWithText:message :130];
                [[NSNotificationCenter defaultCenter] postNotificationName:AddingMemberSuccessNotification object:nil userInfo:nil];
                [_addAssociationBtn setTitle:@"添加关联" forState:UIControlStateNormal];
                _reviewGenealogyBtn.hidden = YES;
            } else {
            }
        }];
        
        [request startAsynchronous];
    }
}

- (IBAction)onReviewGenealogyBtnPressed:(id)sender {

    
    [[NSNotificationCenter defaultCenter] postNotificationName:ReviewGenealogyFromAssociatedMemberNotication object:_memberInfoDic userInfo:nil];
    for(UIViewController *controller in self.navigationController.viewControllers){
        if ([controller isKindOfClass:[FamliyTreeViewController2 class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

- (void)rightBtnPressed
{
    GenealogyMemberEditorViewController *vc = [[GenealogyMemberEditorViewController alloc] initWithNibName:@"GenealogyMemberEditorViewController-5"bundle:nil];
    vc.editorType = GenealogyEditorTypeModify;
    vc.memberInfoDic = self.memberInfoDic;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    
}

- (NSString *)calculateAge
{
    
    BOOL isDead = [_memberInfoDic[kIsDead] boolValue];
    double aYear = 31556926;  // 1 * 60 * 60 *24 * 365 
    NSUInteger age = 0;
    NSUInteger ageSeconds = 0;

    double birthDate = [_memberInfoDic[kBirthDate] doubleValue] / 1000;
    double deathDate = [_memberInfoDic[kDeathDate] doubleValue] / 1000;
    double currentDate = [[[[NSDate alloc] init] autorelease] timeIntervalSince1970];
    NSString *returnValue = nil;
    if (isDead) {
        ageSeconds = deathDate - birthDate;
        age = ceil(ageSeconds/aYear);
        returnValue = [NSString stringWithFormat:@"享年%d岁",age];
    } else {
        ageSeconds = (NSUInteger)currentDate - birthDate;
        age = ageSeconds/aYear;
        returnValue = [NSString stringWithFormat:@"%d岁",age];
    }
    
    return returnValue;
}

- (void)switchTableViewAnimated:(BOOL)animated
{
//#warning 切换试图
    _isAddOperation = NO;
    NSInteger tableViewHeight = _addOperationTableView.frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        _addOperationTableView.frame = CGRectMake(SCREEN_WIDTH , 186, 284, tableViewHeight);
        _operationContainerView.frame = CGRectMake(16, iOS7 ? 206 : 186, 284, 185);
    } completion:^(BOOL finished) {
        [_addOperationTableView removeFromSuperview];
    }];
}

- (void)backBtnPressed
{
    
    if (_isAddOperation) {
        //
        [self switchTableViewAnimated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    [self setAddMemberBtn:nil];
    [self setAddMemberBtn:nil];
    [self setAddAssociationBtn:nil];
    [self setReviewGenealogyBtn:nil];
    [self setHeaderImageView:nil];
    [self setNameLabel:nil];
    [self setBirthDateLabel:nil];
    [self setRelationLabel:nil];
    [self setAddOperationTableView:nil];
    [self setOperationContainerView:nil];
    [self setIsAssociatedLabel:nil];
    [self setHeaderInfoView:nil];
    [super viewDidUnload];
}
@end
