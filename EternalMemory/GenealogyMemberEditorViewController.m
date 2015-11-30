//
//  GenealogyModifyMemberInfoViewController.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "GenealogyMemberEditorViewController.h"
#import "GenealogyMemberDetailViewController.h"
#import "GenealogyEditorView.h"
#import "MyLifeMainViewController.h"
#import "FamliyTreeViewController2.h"
#import "GenealogyRelationEngine.h"
#import "MyFamilySQL.h"
#import "Utilities.h"
#import "RequestParams.h"
#import "GenealogyFormDataRequest.h"
#import "UIImage+UIImageExt.h"
#import "UIImageView+WebCache.h"
#import "MyToast.h"
#import "LogoMPMoviewPlayViewCtl.h"
#import "LoginViewController.h"
#import "MemberIdentityViewController.h"
#import "MBProgressHUD.h"
#import "NoActionTextField.h"

@import QuartzCore;

#define tPickHeaderActionSheet      100
#define tPickGenderActionSheet      101

#define tModifyRequest              200
#define tAdditionRequest            201
#define tDeleteRequest              202

#define tNameTextFiled              301
#define tRelationTextField          302

#define tLoginAtOtherPlaceAlert     401
#define tDeleteMemberAlert          402
#define tPopViewControllerAlert     403


@interface GenealogyMemberEditorViewController ()
{
    CGFloat                  _keyboardHeight;
    GenealogyFormDataRequest *_modifyFormRequest;
    GenealogyFormDataRequest *_additionFormRequest;
    GenealogyFormDataRequest *_modifyHeaderImageReqeust;
    NSMutableDictionary      *_saveInfoDicForAncestor;
    BOOL                     _connected;
    MBProgressHUD            *_mb;
    
    
}

@property (retain, nonatomic) IBOutlet GenealogyEditorView *editorView;
@property (retain, nonatomic) IBOutlet UIView *editHeaderView;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (retain, nonatomic) IBOutlet UIButton *deathDateBtn;
@property (retain, nonatomic) IBOutlet UIButton *birthDateBtn;
@property (retain, nonatomic) IBOutlet UIButton *genderBtn;
@property (retain, nonatomic) IBOutlet UIImageView *headerImageView;
@property (retain, nonatomic) IBOutlet NoActionTextField *nameTextField;
@property (retain, nonatomic) IBOutlet UIView *datePickerView;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet NoActionTextField *relationTextField;
@property (nonatomic, retain) IBOutlet UISwitch *birthRemind;
@property (retain, nonatomic) IBOutlet UISwitch *deathRemand;
@property (retain, nonatomic) IBOutlet UISwitch *isDeadSwitch;
@property (retain, nonatomic) IBOutlet UIView *chosingIdentityView;
@property (retain, nonatomic) IBOutlet UIView *bottomView;
@property (retain, nonatomic) IBOutlet UILabel *bottomTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *memberTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *memberIdentityLabel;
@property (retain, nonatomic) IBOutlet GenealogyEditorView *birthDateView;
@property (retain, nonatomic) IBOutlet GenealogyEditorView *deathDateView;
@property (retain, nonatomic) IBOutlet UILabel *deathTextLabel;

@property (retain, nonatomic) NSArray  *subTitleArr;

@property (assign, nonatomic) BOOL isBirthDate;
@property (assign, nonatomic) BOOL canSexBeModified;
// 封装修改请求的参数
@property (retain, nonatomic) NSMutableDictionary *attributes;

/**
 *  判断是否是我自己
 *
 *  @return BOOL
 */
- (BOOL)isMySelf;
/**
 *  设置网络请求参数默认值。
 */
- (void)setDefaultAttributes;

- (IBAction)deathDateBtnPressed:(id)sender;
- (IBAction)birthDateBtnPressed:(id)sender;
- (IBAction)genderBtnPressed:(id)sender;
- (IBAction)headerChangeBtnPressed:(id)sender;
- (IBAction)onDeleteMemberBtnClicked:(id)sender;
- (IBAction)toolBarFinashBtnPressed:(id)sender;
- (IBAction)deathStatusSwitch:(id)sender;
- (IBAction)shouldRemandBirthdate:(id)sender;
- (IBAction)shouldRemandDeathdate:(id)sender;

/**
 *  弹出DatePicker
 */
- (void)showDatePickerAnimated;
/**
 *  隐藏DatePicker
 */
- (void)dismissDatePickerAnimated;
/**
 *  获得DatePicker的时间
 *
 *  @return 时间戳字符串 JavaScript格式
 */
- (NSString *)getDateFromDatePicker;
/**
 *  获得birthDateBtn的时间
 *
 *  @return NSDate
 */
- (NSDate *)getDateFromDateButton;

/**
 *  设置试图数据
 *
 *  @param dic 封装视图数据的字典
 */
- (void)setViewDataWithDictionary:(NSMutableDictionary *)dic;

@end



@implementation GenealogyMemberEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(GenealogyEditorType)editorType
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _editorType = editorType;
    }
    
    return self;
}

- (void)dealloc
{
    
    [_deleteMemberBtn release];
    [_editorView release];
    [_editHeaderView release];
    [_datePicker release];
    [_birthDateBtn release];
    [_genderBtn release];
    [_headerImageView release];
    [_nameTextField release];
    [_datePickerView release];
    [_toolBar release];
    [_scrollView release];
    [_attributes release];
    [_modifyHeaderImageReqeust release];
    [_tempMemberInfo release];
    [_mb release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidSelectIdentityNotification object:nil];
//    [self removeObserver:self forKeyPath:@"_connected"];
    
    if (_modifyFormRequest) {
        [_modifyFormRequest clearDelegatesAndCancel];
    }
    if (_additionFormRequest) {
        [_additionFormRequest clearDelegatesAndCancel];
    }
    if (_modifyHeaderImageReqeust) {
        [_modifyHeaderImageReqeust clearDelegatesAndCancel];
    }
    [_relationTextField release];
    [_isDeadSwitch release];
    [_chosingIdentityView release];
    [_deathDateBtn release];
    [_bottomView release];
    [_bottomTitleLabel release];
    [_memberTitleLabel release];
    [_memberIdentityLabel release];
    [_birthDateView release];
    [_deathDateView release];
    [_deathTextLabel release];
    [_deathRemand release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self addObserver:self forKeyPath:@"_connected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    self.middleBtn.hidden = YES;
    self.titleLabel.text = @"编辑";
    [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    
    if (!_memberInfoDic) {
        _memberInfoDic = [[NSMutableDictionary alloc] init];
    }
    
    if (!iPhone5) {
        _scrollView.frame = CGRectMake(0, 70, SCREEN_WIDTH, SCREEN_HEIGHT+20);
    }
    
    _isDeadSwitch.frame = (CGRect) {
        .origin.x = _deathDateView.frame.size.width - _isDeadSwitch.frame.size.width - 9,
        .origin.y = _isDeadSwitch.frame.origin.y,
        .size = _isDeadSwitch.frame.size
    };

    
    _deathRemand.frame = (CGRect){
        .origin.x = _deathDateView.frame.size.width - _deathRemand.frame.size.width - 9,
        .origin.y = _deathRemand.frame.origin.y,
        .size  = _deathRemand.frame.size
    };
    
    _birthRemind.frame = (CGRect){
        .origin.x = _birthDateView.frame.size.width - _birthRemind.frame.size.width - 9,
        .origin.y = _birthRemind.frame.origin.y,
        .size = _birthRemind.frame.size
    };
    
//    BOOL shouldWarnBirthday = [[SavaData shareInstance] printBoolData:kBirthWarned];
//    BOOL shouldWarnDeathday = [[SavaData shareInstance] printBoolData:kDeathWarnned];
//    
//    [_birthRemind setOn:shouldWarnBirthday];
//    [_deathRemand setOn:shouldWarnDeathday];
    
    if (_editorType == GenealogyEditorTypeModify) {
        [self setViewDataWithDictionary:self.memberInfoDic];
        _tempMemberInfo = [NSDictionary dictionaryWithDictionary:self.memberInfoDic];
        [_tempMemberInfo retain];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finashChoosingIdentity:) name:DidSelectIdentityNotification object:nil];
    
    BOOL isMyself = [self isMySelf];
    if (isMyself) {
        _chosingIdentityView.hidden = NO;
        _deleteMemberBtn.hidden = YES;
    }
    
    if (![_memberInfoDic[kIsDead] boolValue]) {
        _deathTextLabel.alpha = 0;
    } else {
        _deathTextLabel.alpha = 1;
    }
    NSInteger sex = [_targetMebmerInfo[kSex] integerValue];
    
    if (_editorType == GenealogyEditorTypeAdd) {
        _canSexBeModified = YES;
        _deleteMemberBtn.hidden = YES;
        
        NSDate *date = [NSDate date];
        NSTimeInterval intervel = [date timeIntervalSince1970];
        NSString *dateStr = [Utilities convertTimestempToDateWithString:[NSString stringWithFormat:@"%lld",(long long int)intervel * 1000] andDateFormat:nil];
        [_birthDateBtn setTitle:dateStr forState:UIControlStateNormal];
        [_isDeadSwitch setOn:YES];
        [self deathStatusSwitch:_isDeadSwitch];

        switch (_memberType) {
            case GenealogyAdditionTypePartner:
            {
                self.titleLabel.text = @"添加配偶";
                self.subTitleArr = @[@"现任",@"离异",@"其他"];
                CGRect frame = _bottomView.frame;
                frame.size.height = 47;
                _bottomView.frame = frame;
                _bottomTitleLabel.text = @"配偶身份";
                _memberInfoDic[kPartnerId] = _targetMebmerInfo[kMemberId];
                _memberInfoDic[kKinRelation] = @"0";
                _memberInfoDic[kLevel] = _targetMebmerInfo[kLevel];
                NSString *sexVar = @"";
                NSString *genderStr = @"";
                if (sex == 2) {
                    sexVar = @"1";
                    genderStr = @"男";

                } else {
                    sexVar = @"2";
                    genderStr = @"女";
                }
                [_genderBtn setTitle:genderStr forState:UIControlStateNormal];
                _memberInfoDic[kSex] = sexVar;
                _memberInfoDic[kDirectLine] = @"0";
                
                break;
            }
            case GenealogyAdditionTypeDaughter:
            {
                self.titleLabel.text = @"添加女儿";
                self.subTitleArr = @[@"亲生",@"领养",@"过继"];
                [_genderBtn setTitle:@"女" forState:UIControlStateNormal];
                _genderBtn.enabled = NO;
                _memberInfoDic[kParentId] = _targetMebmerInfo[kMemberId];
                _memberInfoDic[kLevel] = [NSString stringWithFormat:@"%d",([_targetMebmerInfo[kLevel] integerValue] + 1)];
                _memberInfoDic[kKinRelation] = @"1";
                _memberInfoDic[kDirectLine] = @"0";
                _memberInfoDic[kSex] = @"2";
//                _memberInfoDic[kSubTitle] = @"女儿";

                break;
            }
            case GenealogyAdditionTypeSon:
            {
                
                self.titleLabel.text = @"添加儿子";
                self.subTitleArr = @[@"亲生",@"领养",@"过继"];
                [_genderBtn setTitle:@"男" forState:UIControlStateNormal];
                _genderBtn.enabled = NO;
                _memberInfoDic[kParentId] = _targetMebmerInfo[kMemberId];
                NSString *level = [NSString stringWithFormat:@"%d",([_targetMebmerInfo[kLevel] integerValue] + 1)];
                _memberInfoDic[kLevel] = level;
                _memberInfoDic[kKinRelation] = @"1";
                _memberInfoDic[kDirectLine] = [NSString stringWithFormat:@"%d",[GenealogyRelationEngine shouldAddOnCentralAxisForLevel:_targetMebmerInfo]];
                _memberInfoDic[kSex] = @"1";
//                _memberInfoDic[kSubTitle] = @"儿子";

                break;
            }
            case GenealogyAdditionTypeAncestor:
            {
                self.titleLabel.text = @"添加父辈";
                [_genderBtn setTitle:@"男" forState:UIControlStateNormal];
                _genderBtn.enabled = NO;
                _saveInfoDicForAncestor = [_memberInfoDic mutableCopy];
                _memberInfoDic[kParentId] = @"";
                _memberInfoDic[kPartnerId] = @"";
                _memberInfoDic[kSubTitle] = @"未知";
                _memberInfoDic[kBirthDate] = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
                _memberInfoDic[kLevel] = [NSString stringWithFormat:@"%d",([_memberInfoDic[kLevel] integerValue] - 1)];
                _memberInfoDic[kDirectLine] = @"1";
                _memberInfoDic[kKinRelation] = @"1";
                _memberInfoDic[kSex] = @"1";
                _chosingIdentityView.hidden = YES;
                break;
            }
                
            default:{
                
            }
                break;
        }
    } else if(_editorType == GenealogyEditorTypeModify) {

        
        
        self.titleLabel.text = @"编辑信息";
        
        
        [_isDeadSwitch setOn:![_memberInfoDic[kIsDead] boolValue]];
        if ([_memberInfoDic[kLevel] integerValue] < 1) {
            _canSexBeModified = NO;
            
        }
        
        if ([_memberInfoDic[kPartnerId] length] != 0) {
            CGRect frame = _bottomView.frame;
            frame.size.height = 47;
            _bottomView.frame = frame;
            _bottomTitleLabel.text = @"配偶身份";
            
            CGRect btnFrame = _deleteMemberBtn.frame;
            btnFrame.origin.y = frame.origin.y + frame.size.height + 15;
            _deleteMemberBtn.frame = btnFrame;
            
            _memberTitleLabel.text = _memberInfoDic[kSubTitle];
            
        } else {
            
            
            NSString *motherName = [MyFamilySQL getMotherInfoWithMotherId:_memberInfoDic[kMotherID] andMemberId:nil][kName];
            _memberTitleLabel.text = motherName;
            
            if ([self isTop]) {
                _bottomView.hidden = YES;
                _deleteMemberBtn.frame = (CGRect){
                    .origin.x = 0,
                    .origin.y = 0,
                    .size = _deleteMemberBtn.frame.size
                };
            }
            
            if (motherName.length != 0) {
                _memberInfoDic[kMotherName] = motherName;
            }
            
            _memberIdentityLabel.text = _memberInfoDic[kSubTitle];
        }
        
    }
    
    _bottomView.layer.cornerRadius = 5;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToShowIdentityChoosingView:)];
    [_bottomView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    [self setContentSize];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"_connected"]) {
        if (!_connected) {
            [MyToast showWithText:@"网络不给力，请检查网络连接" :200];
            return;
        }
    }
}

- (BOOL)isTop
{
    BOOL isTop = NO;
    NSInteger topLevel = [[[SavaData shareInstance] printDataStr:kMaxLevel] integerValue];
    isTop = (topLevel == [_memberInfoDic[kLevel] integerValue]);
    
    return isTop;
}

- (void)finashChoosingIdentity:(NSNotification *)notification
{
    
    NSDictionary *dic = notification.object;
    if ([_bottomTitleLabel.text isEqualToString:@"配偶身份"]) {
        _memberTitleLabel.text = dic[kIdentity];
        NSString *identity = dic[kIdentity];
        if (identity.length != 0) {
            _memberInfoDic[kSubTitle] = dic[kIdentity];
        }
        
    } else {
        
        _memberTitleLabel.text = dic[kMotherInfo][kName];
        _memberIdentityLabel.text = dic[kIdentity];
        
        NSString *identity = dic[kIdentity];
        if (identity.length != 0) {

            self.memberInfoDic[kSubTitle] = dic[kIdentity];
        }

        NSString *motherId = dic[kMotherInfo][kMotherID];
        if (motherId.length != 0) {
            self.memberInfoDic[kMotherID] = dic[kMotherInfo][kMotherID];
            self.memberInfoDic[kMotherName] = dic[kMotherInfo][kName];
        }
        
    }
}


- (void)tapToShowIdentityChoosingView:(UITapGestureRecognizer *)gesture
{
    MemberIdentityViewController *memberIdentityVC = [[MemberIdentityViewController alloc] init];
    [_bottomTitleLabel.text isEqualToString:@"配偶身份"] ? (memberIdentityVC.isPartner = YES) : (memberIdentityVC.isPartner = NO);
    memberIdentityVC.infoDic = [NSDictionary dictionaryWithDictionary:_memberInfoDic];
    [self presentViewController:memberIdentityVC animated:YES completion:nil];
    [memberIdentityVC release];
}

- (void)setMemberIdentityWhenEdit
{
    NSString *partner = _memberInfoDic[kPartnerId];
    if (partner.length == 0) {
        self.memberType = GenealogyAdditionTypePartner;
    } else {
        self.memberType = GenealogyAdditionTypeSon | GenealogyAdditionTypeDaughter;
    }
}

- (void)setContentSize
{
    CGRect bottomFram = _chosingIdentityView.frame;
    
    CGFloat contentSizeHeight = bottomFram.origin.y + bottomFram.size.height + 20;
    
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, contentSizeHeight);
}

- (void)setViewDataWithDictionary:(NSMutableDictionary *)dic
{
    NSString *name = dic[kName];
    NSString *birth = [Utilities convertTimestempToDateWithString:dic[kBirthDate]
                                                    andDateFormat:nil];
    NSString *death = [Utilities convertTimestempToDateWithString:dic[kDeathDate] andDateFormat:nil];
    
    NSString *gender = dic[kSex];
    NSString *nickName = dic[kNickName];
  
    (gender.integerValue == 2) ? (gender = @"女") : (gender = @"男");
    
    NSTimeInterval interval = [dic[kBirthDate] longLongValue] / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    [_datePicker setDate:date];
    _nameTextField.text = name;
    [_birthDateBtn setTitle:birth forState:UIControlStateNormal];
    [_birthRemind setOn:[dic[kBirthWarned] integerValue]];
    [_genderBtn setTitle:gender forState:UIControlStateNormal];
    _relationTextField.text = nickName;
    NSURL *headerUrl = dic[kHeadPortrait];
    UIImage *defaultImage = [UIImage imageNamed:@"mrtx.png"];
    [_headerImageView setImageWithURL:headerUrl placeholderImage:defaultImage];
    
    __block CGRect editorFrame = _deathDateView.frame;
    __block CGRect bottomFrame = _chosingIdentityView.frame;
    __block CGRect labelFrame = _deathTextLabel.frame;
    [_isDeadSwitch setOn:![dic[kIsDead] boolValue]];
    if (!_isDeadSwitch.isOn) {
        editorFrame.size.height = 89;
        _deathDateView.frame = editorFrame;
        
        labelFrame.origin.y = editorFrame.size.height + editorFrame.origin.y + 5;
        _deathTextLabel.frame = labelFrame;
        
        bottomFrame.origin.y = labelFrame.origin.y + labelFrame.size.height + 15;
        _chosingIdentityView.frame = bottomFrame;
        
        [_deathDateBtn setTitle:death forState:UIControlStateNormal];
    } else {
        editorFrame.size.height = 49;
        _deathDateView.frame = editorFrame;
        
        labelFrame.origin.y = editorFrame.size.height + editorFrame.origin.y + 5;
        _deathTextLabel.frame = labelFrame;
        
        bottomFrame.origin.y = labelFrame.origin.y + labelFrame.size.height + 15;
        _chosingIdentityView.frame = bottomFrame;
        [_deathDateBtn setTitle:@"" forState:UIControlStateNormal];
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.view.window == nil) {
//        for(UIViewController *controller in self.navigationController.viewControllers){
//            if ([controller isKindOfClass:[MyLifeMainViewController class]]) {
//                [self.navigationController popToViewController:controller animated:NO];
//            }
//        }
//        [self.navigationController popViewControllerAnimated:NO];
    }
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - 家谱编辑页面交互方法
- (IBAction)birthDateBtnPressed:(id)sender {
    
    _isBirthDate = YES;
    [_nameTextField resignFirstResponder];
    [self showDatePickerAnimated];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:@"0001-01-01"];
    NSDate *minDate = date;
    NSDate *maxDate = [NSDate date];
    
    _datePicker.minimumDate = minDate;
    _datePicker.maximumDate = maxDate;

}

- (IBAction)genderBtnPressed:(id)sender {
    
    [_relationTextField resignFirstResponder];
    if (_datePickerView.subviews) {
        [self dismissDatePickerAnimated];
    }
    if (_nameTextField) {
        [_nameTextField resignFirstResponder];
    }
    
    if (!_canSexBeModified) {
        [MyToast showWithText:@"该成员性别不允许修改" :130];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
    actionSheet.tag = tPickGenderActionSheet;
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (IBAction)headerChangeBtnPressed:(id)sender {
    
    [_nameTextField resignFirstResponder];
    
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"选择头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取", nil];
    ac.tag = tPickHeaderActionSheet;
    [ac showInView:self.view];
    [ac release];
}

- (IBAction)onDeleteMemberBtnClicked:(id)sender {
    
    BOOL connectable = [Utilities checkNetwork];
    if (!connectable) {
        [MyToast showWithText:@"请检查网络" :150];
        return;
    }
    
    NSString *targetStr = nil;
    if ([_memberInfoDic[kLevel] integerValue] < 0) {
        targetStr = @"长辈";
    } else {
        targetStr = @"晚辈";
    }
    
    NSString *msg = [NSString stringWithFormat:@"确定把此人及配偶、%@成员都删除么？",targetStr];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = tDeleteMemberAlert;
    [alert show];
    [alert release];

}

- (IBAction)toolBarFinashBtnPressed:(id)sender {
    [self dismissDatePickerAnimated];
}

- (IBAction)deathStatusSwitch:(id)sender {
    
    
    BOOL isDead = _isDeadSwitch.isOn;
    [_relationTextField resignFirstResponder];
    _memberInfoDic[kIsDead] = [NSString stringWithFormat:@"%d",!isDead];
    __block CGRect editorFrame = _deathDateView.frame;
    __block CGRect bottomFrame = _chosingIdentityView.frame;
    __block CGRect labelFrame = _deathTextLabel.frame;
    if (isDead) {
        
        [UIView animateWithDuration:0.1 animations:^{
            editorFrame.size.height = 49;
            _deathDateView.frame = editorFrame;
            
            labelFrame.origin.y = editorFrame.origin.y + editorFrame.size.height + 5;
            _deathTextLabel.frame = labelFrame;
            _deathTextLabel.alpha = 0;
            
            bottomFrame.origin.y = labelFrame.origin.y + labelFrame.size.height+ 15;
            _chosingIdentityView.frame = bottomFrame;
            
            
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            editorFrame.size.height = 89;
            _deathDateView.frame = editorFrame;
            
            labelFrame.origin.y = editorFrame.origin.y + editorFrame.size.height + 5;
            _deathTextLabel.frame = labelFrame;
            _deathTextLabel.alpha = 1;
            bottomFrame.origin.y = labelFrame.origin.y + labelFrame.size.height + 15;
            _chosingIdentityView.frame = bottomFrame;
        }];
    }
    
    [self setContentSize];
    
}

- (IBAction)shouldRemandBirthdate:(id)sender {
    
    UISwitch *birthSwitch = (UISwitch *)sender;
    BOOL remandBirth = [birthSwitch isOn];
    _memberInfoDic[kBirthWarned] = [NSString stringWithFormat:@"%d",remandBirth];
}

- (IBAction)shouldRemandDeathdate:(id)sender {
    UISwitch *deathSwitch = (UISwitch *)sender;
    BOOL remandDeath = [deathSwitch isOn];
    _memberInfoDic[kDeathWarnned] = [NSString stringWithFormat:@"%d",remandDeath];
}

- (void)rightBtnPressed
{
    if (_nameTextField.text.length == 0 || _genderBtn.titleLabel.text.length == 0 || _relationTextField.text.length == 0) {
        [MyToast showWithText:@"请将信息填写完整" :130];
        return;
    }
    
    

    
    BOOL connectable = [Utilities checkNetwork];
//    [self setValue:@(connectable) forKey:@"_connected"];
    if (!connectable) {
        [MyToast showWithText:@"请检查网络" :150];
        return;
    }
    
    [[SavaData shareInstance] savaDataBool:[_birthRemind isOn] KeyString:kBirthWarned];
    [[SavaData shareInstance] savaDataBool:[_deathRemand isOn] KeyString:kDeathWarnned];
    
    [_nameTextField resignFirstResponder];
    [_relationTextField resignFirstResponder];
    
    BOOL network = [Utilities checkNetwork];
    
    if (network) {
        
        _mb = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:_mb];
        [_mb show:YES];
    }
    
    if (_editorType == GenealogyEditorTypeModify && network) {
        
        _mb.detailsLabelText = @"正在保存...";
        _modifyFormRequest = [[GenealogyFormDataRequest alloc] initWithURL:[[RequestParams sharedInstance] modifyMemberInfo]];
        [_modifyFormRequest setUpdateType:GenealogyUpdateTypeUpdateInfo];
        [_modifyFormRequest setModifyRequestAttributesWithDictionary:_memberInfoDic];
        _modifyFormRequest.timeOutSeconds = 30;
        _modifyFormRequest.delegate = self;
        _modifyFormRequest.userInfo = @{@"tag" : [NSNumber numberWithInteger:tModifyRequest]};
        if (!connectable) {
            return;
        }
        [_modifyFormRequest startAsynchronous];
    }
    
    if (_editorType == GenealogyEditorTypeAdd && network) {
        
        
        _mb.detailsLabelText = @"正在添加...";

        _additionFormRequest = [[GenealogyFormDataRequest alloc] initWithURL:[[RequestParams sharedInstance] addFamilyMember]];
        [_additionFormRequest setAdditionRequestAttributesWithDictionary:_memberInfoDic];
        if (_memberType == GenealogyAdditionTypeAncestor) {
            [_additionFormRequest setPostValue:@"parent" forKey:@"addtype"];
            [_additionFormRequest setPostValue:_saveInfoDicForAncestor[kMemberId] forKey:@"currentid"];
        }
        _additionFormRequest.timeOutSeconds = 30;
        _additionFormRequest.delegate = self;
        _additionFormRequest.userInfo = @{@"tag" : [NSNumber numberWithInteger:tAdditionRequest]};
        if (!connectable) {
            return;
        }
        [_additionFormRequest startAsynchronous];
    }
}

- (void)backBtnPressed
{
    NSString *originalStr = [_tempMemberInfo JSONString];
    NSString *editStr = [_memberInfoDic JSONString];
    
    if ([originalStr compare:editStr] != NSOrderedSame) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"退出之后您编辑的信息将会丢失，是否要退出？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
        alertView.tag = tPopViewControllerAlert;
        [alertView show];
        [alertView release];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    return;
    
    
}

#pragma mark - ActionSheet代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int acTag = actionSheet.tag;

    if (acTag == tPickGenderActionSheet) {
        NSString *gender = [_genderBtn.titleLabel.text copy];
        if (buttonIndex == 0) {
            
            gender = @"男";
            _memberInfoDic[kSex] = @"1";
            
        } else if(buttonIndex == 1) {
            
            gender = @"女";
            _memberInfoDic[kSex] = @"2";
            _memberInfoDic[kDirectLine] = @"0";
        }
        
        [_genderBtn setTitle:gender forState:UIControlStateNormal];
        [gender release];
    }
    
    if (acTag == tPickHeaderActionSheet) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;

        //拍照
        if (buttonIndex == 0) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.videoQuality = UIImagePickerControllerQualityType640x480;
        }
        //选照片
        if (buttonIndex == 1) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        if (buttonIndex == 2) {
            return;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
        [imagePicker release];
    }
}

#pragma mark - UIAlertView代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = alertView.tag;
    if (tag == tDeleteMemberAlert) {
        if (buttonIndex == 1) {
            
            GenealogyFormDataRequest *request = [GenealogyFormDataRequest requestWithURL:[[RequestParams sharedInstance] deleteMember]];
            [request setupDeleteMemberRequestWithMemberid:_memberInfoDic[kMemberId]];
            request.userInfo = @{@"tag":@(tDeleteRequest)};
            request.delegate = self;
            [request startAsynchronous];
           
            
        }
        
    } else if(tag == tLoginAtOtherPlaceAlert) {
        if (buttonIndex == 1) {
            BOOL isLogin = NO;
            [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
            [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
        }
    } else if (tag == tPopViewControllerAlert) {
        if (buttonIndex == 0) {
            return;
        }
        
        if (buttonIndex == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}

#pragma mark - UITextField代理方法

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_datePicker.superview) {
        [self dismissDatePickerAnimated];
    }
    
    if (textField == _relationTextField) {
        [UIView animateWithDuration:0.3 animations:^{
            _scrollView.contentOffset = CGPointMake(0, iPhone5 ? 40 : 120);
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    if (tag == tNameTextFiled) {
        _memberInfoDic[kName] = textField.text;
            }
    
    if (tag == tRelationTextField) {
        _memberInfoDic[kNickName] = textField.text;
        
    }
    [_nameTextField resignFirstResponder];
    [_relationTextField resignFirstResponder];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    if (tag == tNameTextFiled) {
        _memberInfoDic[kName] = textField.text;
        [_nameTextField resignFirstResponder];
    }
    
    if (tag == tRelationTextField) {
        _memberInfoDic[kNickName] = textField.text;
        [_relationTextField resignFirstResponder];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.contentOffset = CGPointMake(0, 0);
    }];
}
#pragma mark - UIImagePicker代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [_headerImageView setImage:image];
    
    image = [image imageByScalingAndCroppingForSize:CGSizeMake(600, 600)];
    image = [image fixOrientation];
    _modifyHeaderImageReqeust = [[GenealogyFormDataRequest alloc] initWithURL:[[RequestParams sharedInstance] addHeaderImage]];
    [_modifyHeaderImageReqeust setupModifyMemberHeaderRequestWithHeaderImage:image andMemberId:_memberInfoDic[kMemberId]];
    
    [_modifyHeaderImageReqeust setBytesSentBlock:^(unsigned long long size, unsigned long long total) {
    }];
    
    [_modifyHeaderImageReqeust setCompletionBlock:^{

        NSData *data = [_modifyHeaderImageReqeust responseData];
        NSDictionary *responseDic = [data objectFromJSONData];
        NSInteger succcess = [responseDic[@"success"] integerValue];
        NSString *message = responseDic[@"message"];
        if (succcess == 1) {
            self.memberInfoDic = [NSMutableDictionary dictionaryWithDictionary:responseDic[@"data"]];
            [MyFamilySQL updateMemberByMemberId:_memberInfoDic];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ModifyMemberInfoSuccessNotification object:_memberInfoDic userInfo:nil];
            
        } else {
        }
        
    }];
    
    [_modifyHeaderImageReqeust setFailedBlock:^{
    }];
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ASIHTTPRequest代理方法
- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    [_mb show:NO];
    [_mb setHidden:YES];
    NSInteger tag = [request.userInfo[@"tag"] integerValue];
    NSData *data = [request responseData];
    NSDictionary *responseDic = [data objectFromJSONData];
//    NSString *message = responseDic[@"message"];
    NSInteger success = [responseDic[@"success"] integerValue];
    NSString *error = responseDic[@"errorcode"];
    if ([error isEqualToString:@"1005"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的账号在异地登录，请重新登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = tLoginAtOtherPlaceAlert;
        [alert show];
        [alert release];
    }
    
    // 修改成员信息的请求
    if (tag == tModifyRequest) {

        if (success == 1) {
            if ([responseDic[@"data"][@"birthWarned"]integerValue] != [_tempMemberInfo[@"birthWarned"]integerValue] || [responseDic[@"data"][@"birthDate"]longLongValue ] != [_tempMemberInfo[@"birthDate"]longLongValue] || [responseDic[@"data"][@"deathDate"] longLongValue] != [_tempMemberInfo[@"deathDate"]longLongValue] || [responseDic[@"data"][@"deathWarned"] integerValue] != [_tempMemberInfo[@"deathWarned"]integerValue]) {
                
                [self localRemind:responseDic[@"data"] andType:@"modify"];
            }
            [MyToast showWithText:@"修改成功" :130];
            _memberInfoDic[kSubTitle] = responseDic[@"data"][kSubTitle];
            _memberInfoDic[kName] = responseDic[@"data"][kName];
            
            [MyFamilySQL updateMemberByMemberId:_memberInfoDic];
            
            if (_modifyHeaderImageReqeust) {
                [_modifyHeaderImageReqeust setPostValue:responseDic[@"data"][kMemberId] forKey:@"memberid"];
                [_modifyHeaderImageReqeust startAsynchronous];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ModifyMemberInfoSuccessNotification object:_memberInfoDic userInfo:nil];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [MyToast showWithText:@"修改失败" :130];
        }
    }
    
    // 添加成员信息的请求
    if (tag == tAdditionRequest) {

        if (success == 1) {
            
            NSDictionary *dic = responseDic[@"data"];
            
            [self localRemind:dic andType:@"add"];
            [MyFamilySQL addFamilyMembers:@[dic] AndType:nil WithUserID:USERID];
            if (_memberType == GenealogyAdditionTypeAncestor) {
                _saveInfoDicForAncestor[kParentId] = dic[kMemberId];
                [MyFamilySQL updateMemberByMemberId:_saveInfoDicForAncestor];
            }
            
            if (_modifyHeaderImageReqeust) {
                [_modifyHeaderImageReqeust setPostValue:responseDic[@"data"][kMemberId] forKey:@"memberid"];
                [_modifyHeaderImageReqeust startAsynchronous];
            }
            
            [MyToast showWithText:@"添加成功" :130];
            [[NSNotificationCenter defaultCenter] postNotificationName:AddingMemberSuccessNotification object:responseDic[@"data"] userInfo:nil];
            
            for(UIViewController *controller in self.navigationController.viewControllers){
                if ([controller isKindOfClass:[FamliyTreeViewController2 class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }

        } else {

            [MyToast showWithText:@"添加失败" :130];
        }
    }
    
    // 删除成员
    if (tag == tDeleteRequest) {
        if (success == 1) {

            NSArray *memberId = responseDic[@"data"][0];
            //删除成员，同时删除本地这个人的生日、忌日提醒
            for(UILocalNotification *localNotify in [[UIApplication sharedApplication] scheduledLocalNotifications]){
                if ([localNotify.userInfo[@"memberId"] isEqualToString:memberId[0]]) {
                    [[UIApplication sharedApplication] cancelLocalNotification:localNotify];
                }
            }
            ///////////
            NSArray *movedMemberId = responseDic[@"data"][1];
            [MyFamilySQL deleteMembers:memberId andMoveMemberToCentralAxis:movedMemberId];
            [[NSNotificationCenter defaultCenter] postNotificationName:DeleteMemberSuccessNotification object:nil userInfo:Nil];
            for(UIViewController *controller in self.navigationController.viewControllers){
                if ([controller isKindOfClass:[FamliyTreeViewController2 class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }
            [MyToast showWithText:@"删除成功" :130];
            
        } else {

            [MyToast showWithText:@"删除失败" :130];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSInteger tag = [request.userInfo[@"tag"] integerValue];
    [_mb show:NO];
    [_mb setHidden:YES];
    // 修改成员信息的请求
    if (tag == tModifyRequest) {
        
    }
    
    // 添加成员信息的请求
    if (tag == tAdditionRequest) {
        
    }
    
    // 删除成员
    if (tag == tDeleteRequest) {
        
    }
}
#pragma mark - 私有方法

- (void)setMemberInfoDic:(NSMutableDictionary *)memberInfoDic
{
    if (memberInfoDic != _memberInfoDic) {
        [_memberInfoDic release];
        _memberInfoDic = [memberInfoDic mutableCopy];
    }
}

- (void)setDefaultAttributes
{
    _attributes[kName] = _memberInfoDic[kName];
    _attributes[kBirthDate] = _memberInfoDic[kBirthDate];
    _attributes[kSex] = _memberInfoDic[kSex];
}
-(void)settingLocalRemind:(NSDate *)date andType:(NSString *)type andMemberId:(NSString *)memberId andName:(NSString *)name andTime:(NSString *)time{
    
    UILocalNotification *newNotification = [[UILocalNotification alloc] init];
    if (newNotification) {
        
        //时区
        
        newNotification.timeZone=[NSTimeZone defaultTimeZone];
        
        //推送事件---10秒后
        ///测试用
//        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//        [dateFormatter setDateFormat:@"yyyy.MM.dd"];
//        NSString *str = [dateFormatter stringFromDate:date];
//        
//        NSDateFormatter *dateFormatter1 = [[[NSDateFormatter alloc] init] autorelease];
//        [dateFormatter1 setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
//        NSString *str2 = [dateFormatter1 stringFromDate:[NSDate date]];
//        str = [NSString stringWithFormat:@"%@ %@",str,[str2 substringFromIndex:11]];
//        
//        date = [dateFormatter1 dateFromString:str];
        ///
        newNotification.fireDate=date;//[date dateByAddingTimeInterval:120];
        
        //推送内容
        
        newNotification.alertBody = [NSString stringWithFormat:@"永恒记忆提醒您：\n%@是%@的%@",time,name,type];
        
        //应用右上角红色图标数字
        //        newNotification.applicationIconBadgeNumber = 1;
        
        newNotification.soundName = UILocalNotificationDefaultSoundName;
        
        //设置按钮
        
        newNotification.alertAction = @"关闭";
        
        //判断重复与否
        
        newNotification.repeatInterval = NSYearCalendarUnit;
        newNotification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:memberId,@"memberId",type,@"type",time,@"time",nil];
        [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
        [newNotification release];
        
    }
}
-(void)localRemind:(NSDictionary *)dict andType:(NSString *)type{
    NSString *memberId = dict[@"memberId"];
    if ([type isEqualToString:@"modify"]) {
        
        for(UILocalNotification *localNotify in [[UIApplication sharedApplication] scheduledLocalNotifications]){
            if ([localNotify.userInfo[@"memberId"] isEqualToString:memberId]) {
                [[UIApplication sharedApplication] cancelLocalNotification:localNotify];
            }
        }
    }
    if ([dict[@"birthWarned"] integerValue] == 1) {
        NSString *dateStr = [NSString stringWithFormat:@"%@ 09:00:00",[Utilities convertTimestempToDateWithString2:dict[@"birthDate"]]];
        NSDate *date = [Utilities transformDateStrToDate:dateStr];
        [self settingLocalRemind:date andType:@"生日" andMemberId:memberId andName:dict[@"name"] andTime:@"今天"];
        NSInteger duration = 24*60*60;
        date = [date dateByAddingTimeInterval:-duration];
        [self settingLocalRemind:date andType:@"生日" andMemberId:memberId andName:dict[@"name"] andTime:@"明天"];

    }
    if ([dict[@"deathWarned"] integerValue] == 1) {
        NSString *dateStr = [NSString stringWithFormat:@"%@ 09:00:00",[Utilities convertTimestempToDateWithString2:dict[@"deathDate"]]];
        NSDate *date = [Utilities transformDateStrToDate:dateStr];
        [self settingLocalRemind:date andType:@"忌日" andMemberId:memberId andName:dict[@"name"] andTime:@"今天"];

        NSInteger duration = 24*60*60;
        date = [date dateByAddingTimeInterval:-duration];
        [self settingLocalRemind:date andType:@"忌日" andMemberId:memberId andName:dict[@"name"] andTime:@"明天"];
    }
    
}
- (IBAction)deathDateBtnPressed:(id)sender {
    
    _isBirthDate = NO;
    [self showDatePickerAnimated];
    NSDate *birthDate = [NSDate dateWithTimeIntervalSince1970:[_memberInfoDic[kBirthDate] doubleValue]/1000];
    NSDate *deathDate = [NSDate dateWithTimeIntervalSince1970:[_memberInfoDic[kDeathDate] doubleValue]/1000];
    NSDate *maxDate = [NSDate date];
    _datePicker.minimumDate = birthDate;
    _datePicker.maximumDate = maxDate;
    [_datePicker setDate:deathDate];
    
}

- (void)showDatePickerAnimated
{
    [_relationTextField resignFirstResponder];
    
    CGRect rect = _datePickerView.frame;
    rect.origin.x = 0;
    rect.origin.y = SCREEN_HEIGHT;
    _datePickerView.frame = rect;
    if (!_datePickerView.superview) {
        [self.view addSubview:_datePickerView];
    }
    
    if (_birthDateBtn.titleLabel.text.length != 0) {
        [_datePicker setDate:[self getDateFromDateButton]];
    }

    [UIView animateWithDuration:0.3 animations:^{
        
        CGFloat offset_y = 0;
        if (iPhone5) {
            offset_y = 179;
        } else {
            offset_y = 300;
        }
        CGRect frame = _datePickerView.frame;
        frame.origin.x = 0;
        frame.origin.y = SCREEN_HEIGHT - _datePickerView.frame.size.height;
        _datePickerView.frame = frame;
        _scrollView.contentOffset = CGPointMake(0, offset_y);
        
    }];
}

- (void)popToGenealogyViewController
{
    LogoMPMoviewPlayViewCtl *logoVC = [[LogoMPMoviewPlayViewCtl alloc] init];
    LoginViewController *logVC = [[LoginViewController alloc] init];
    MyLifeMainViewController *lifeVC = [[MyLifeMainViewController alloc] initWithNibName:iPhone5 ? @"MyLifeMainViewController-5" : @"MyLifeMainViewController" bundle:nil];
    FamliyTreeViewController2 *familyVC = [[FamliyTreeViewController2 alloc] init];
    
    [self.navigationController setViewControllers:@[logoVC,logVC,lifeVC,familyVC] animated:YES];
    
    [lifeVC release];
    [familyVC release];
    [logVC release];
    [logoVC release];
}

- (void)dismissDatePickerAnimated
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _datePickerView.frame;
        rect.origin.x = 0;
        rect.origin.y = SCREEN_HEIGHT;
        _datePickerView.frame = rect;
        
        _scrollView.contentOffset = CGPointMake(0, 0);
        
    } completion:^(BOOL finished) {
        [_datePickerView removeFromSuperview];
    }];
    

    if (_isBirthDate) {
        [_birthDateBtn setTitle:[self getDateFromDatePicker] forState:UIControlStateNormal];
    } else {
        [_deathDateBtn setTitle:[self getDateFromDatePicker] forState:UIControlStateNormal];
    }

}

- (NSString *)getDateFromDatePicker
{
    NSDate *date = [_datePicker date];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateStr = [formatter stringFromDate:date];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateToPost = [formatter stringFromDate:date];
    
    NSTimeInterval interval = [date timeIntervalSince1970] * 1000;
    NSString *time = [NSString stringWithFormat:@"%lld",(long long int)interval];
    if (_isBirthDate) {
        _memberInfoDic[kBirthDate] = time;
    } else {
        _memberInfoDic[kDeathDate] = time;
    }
    
    return dateStr;
}

- (NSDate *)getDateFromDateButton
{
    NSString *dateStr = [_birthDateBtn titleLabel].text;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *date = [dateFormatter dateFromString:dateStr];

    return date;
}

- (BOOL)isMySelf
{
    NSString *memberId = self.memberInfoDic[kMemberId];
    NSString *userId   = self.memberInfoDic[kUserId];
    
    BOOL isMySelf = NO;
    if ([memberId isEqualToString:userId]) {
        isMySelf = YES;
    } else {
        isMySelf = NO;
    }
    
    return isMySelf;
}

- (void)keyBoardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = userInfo[UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    _keyboardHeight = keyboardSize.height;
    
}

- (void)getDataFromUIKit {
    
}

- (void)viewDidUnload {
    [self setDeleteMemberBtn:nil];
    [self setEditorView:nil];
    [self setEditHeaderView:nil];
    [self setDatePicker:nil];
    [self setBirthDateBtn:nil];
    [self setGenderBtn:nil];
    [self setHeaderImageView:nil];
    [self setNameTextField:nil];
    [self setDatePickerView:nil];
    [self setToolBar:nil];
    [self setScrollView:nil];
    [self setRelationTextField:nil];
    [super viewDidUnload];
}

@end
