//
//  FamliyTreeViewController2.m
//  EternalMemory
//
//  Created by kiri on 13-9-13.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "FamliyTreeViewController2.h"
#import "DrawTreeLineView.h"
#import "RequestParams.h"
#import "GenealogyMemberDetailViewController.h"
#import "GenealogyMetaData.h"
#import "FamilyMemberButton.h"
#import "MyFamilySQL.h"
#import "GenealogyMemberEditorViewController.h"
#import "GenealogyMemberEditorViewController.h"
#import "AddingAssoicationViewController.h"
#import "UIImageView+WebCache.h"
#import "MyToast.h"

#define btnW                97
#define btnH                40
#define btnWith1            btnW/2
#define btnHeight1          btnH/2
#define spouseLineW         10  //配偶固定线长
#define spouseLineW1        8
#define spouseDis           20  //两个配偶上下之间的间距
#define peerLineW           247 //btnW*2+spouseLineW+spouseLineW1+35//同辈之间固定线长
#define peerLineNoSpouse    130
#define spouseUpH           30  //配偶大于1的时候，最上方的配偶距离上方线的高度
#define spouseDownH         30  //配偶大于1的时候，最下方的配偶距离下方线的高度
@interface FamliyTreeViewController2 ()


@end

@implementation FamliyTreeViewController2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc{
    
    [_familyData release];_familyData = nil;
    
    [_grandChildrenData release];_grandChildrenData = nil;
    
    [tempFamilyData release];tempFamilyData = nil;
    
    [tempGrandData release];tempGrandData = nil;
    
    [levelMaxSpouceCountAry release];levelMaxSpouceCountAry = nil;
    
    [templevelMaxSpouceCountAry release];templevelMaxSpouceCountAry = nil;
    
    [level1LeftDisAry release];level1LeftDisAry = nil;
    
    [level1RightDisAry release];level1RightDisAry = nil;
    
    [tempLevel1RightDisAry release];tempLevel1RightDisAry = nil;
    
    [tempLevel1LeftDisAry release];tempLevel1LeftDisAry = nil;
    
    [_request clearDelegatesAndCancel];[_request release];
//    [drawTreeLineView release];drawTreeLineView = nil;
    
    [self removeNotifications];
    
    [_mb release];
    
    [super dealloc];
}

-(void)editMemberRefresh:(NSNotification *)notify{//只改变view，但是数据没改变，进下一级数据传输有无，所以不采用此方法
    
    NSDictionary *dic = [notify object];
    NSString *hearUrl = dic[@"headPortrait"];
    NSString *memberId = dic[kMemberId];
    NSString *name = dic[@"name"];
    NSString *birth = [Utilities convertTimestempToDateWithString2:dic[@"birthDate"]];
    NSInteger sex = [dic[@"sex"] integerValue];
    for(id obj in drawTreeLineView.subviews){
        if ([obj isKindOfClass:[FamilyMemberButton class]]) {
            FamilyMemberButton *btn = (FamilyMemberButton *)obj;
            if ([btn.memberID isEqualToString:memberId]) {
                [btn.headerImg setImageWithURL:[NSURL URLWithString:hearUrl] placeholderImage:[UIImage imageNamed:@"mrtx"]];
                [btn.nameLabel setText:name];
                [btn.birthLabel setText:birth];
                if (sex == 1) {
                    btn.backgroundColor = [UIColor colorWithRed:165/255. green:207/255. blue:255/255. alpha:1.0];
                }else if (sex == 2){
                    btn.backgroundColor = [UIColor colorWithRed:239/255. green:158/255. blue:156/255. alpha:1.0];
                }
            }
        }
    }
}

-(void)addOrEditOrDeleteMemberRefresh:(NSNotification *)notify{
    
    [self setValuesDefault];
    [_familyData addObjectsFromArray:[MyFamilySQL getFamilyMembersWithUserId:USERID]];
    [self reHandleFamily:NO];
}
-(void)initNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addOrEditOrDeleteMemberRefresh:) name:AddingMemberSuccessNotification object:nil];//添加家谱人员
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addOrEditOrDeleteMemberRefresh:) name:ModifyMemberInfoSuccessNotification object:nil];//修改
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addOrEditOrDeleteMemberRefresh:) name:DeleteMemberSuccessNotification object:nil];//删除
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushDetail:) name:@"familyBtnPressed" object:nil];//点击家谱人员看详情
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushEditDetail:) name:@"noInfoFamilyBtnPressed" object:nil];//点击默认生成的无信息的家谱人员
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOtherPeopleFamilyData:) name:ReviewGenealogyFromAssociatedMemberNotication object:nil];//他人家谱
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:GenealogyAssociatedSuccessNotification object:nil];//关联成功
}
-(void)removeNotifications{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"familyBtnPressed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noInfoFamilyBtnPressed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AddingMemberSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ModifyMemberInfoSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DeleteMemberSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ReviewGenealogyFromAssociatedMemberNotication object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GenealogyAssociatedSuccessNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rightBtn.hidden = YES;
    self.middleBtn.hidden = YES;
    self.view.backgroundColor = RGBCOLOR(238, 242, 245);
    self.titleLabel.text = @"家谱";
    [self.rightBtn setTitle:@"我的" forState:UIControlStateNormal];
    
    [self initNotifications];
    
    _familyData = [[NSMutableArray alloc] initWithCapacity:0];
    _grandChildrenData = [[NSMutableArray alloc] initWithCapacity:0];
    levelMaxSpouceCountAry = [[NSMutableArray alloc] initWithCapacity:0];
    tempFamilyData = [[NSMutableArray alloc] initWithCapacity:0];
    tempGrandData = [[NSMutableArray alloc] initWithCapacity:0];
    templevelMaxSpouceCountAry = [[NSMutableArray alloc] initWithCapacity:0];
    level1RightDisAry = [[NSMutableArray alloc] initWithCapacity:0];
    level1LeftDisAry = [[NSMutableArray alloc] initWithCapacity:0];
    tempLevel1LeftDisAry = [[NSMutableArray alloc] initWithCapacity:0];
    tempLevel1RightDisAry = [[NSMutableArray alloc] initWithCapacity:0];
    
    tempSize = CGSizeMake(0, 0);
    
    BOOL network = [Utilities checkNetwork];
    if (!network) {
        [MyToast showWithText:@"请检查网络" :150];
    }
    
    [_familyData addObjectsFromArray:[MyFamilySQL getFamilyMembersWithUserId:USERID]];
    if (_familyData.count == 0) {
        if (network) {
            [self getFamilyTreeData];
        }
        
    }else{
        
        if (USER_IS_HANDLOGIN) {
            
            [[SavaData shareInstance] savaDataBool:NO KeyString:ISHANDLOGIN];

            [self handleFamilyData];
            [self setDrawView];
            if (network) {
                [self getFamilyTreeData];
            }
        }else{
            
            [self handleFamilyData];
            [self setDrawView];
        }
    }
    
	// Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated{
    
    contentOffSet = _scrollView.contentOffset;
}
-(void)viewWillAppear:(BOOL)animated{
    
    if (_comeFirst) {
        _comeFirst = NO;
        return;
    }
    _scrollView.contentOffset = contentOffSet;
    
}
- (void) handleFamilyData{
    
    NSArray *tempAry = [self sortFamilyDataForLevel];
    [_familyData removeAllObjects];
    
    //二级界面用到的
    NSInteger maxLevel = [tempAry[0][@"level"]integerValue];
    [[SavaData shareInstance] savaData:maxLevel KeyString:kMaxLevel];
    //
    
    for (int i = 0; i < tempAry.count; i ++ ) {
        if ([tempAry[i][@"level"] integerValue] <= 1) {
            [_familyData addObject:tempAry[i]];
        }else{
            [_grandChildrenData addObject:tempAry[i]];
            level2Count = [tempAry[i][@"members"] count];
        }
    }
    tempAry = nil;
    //计算level=2层级血亲人数
    if (_grandChildrenData.count > 0) {
        
        for(id obj in _grandChildrenData[0][@"members"]){
            
            if ([obj[@"parentId"] isEqualToString:@""]) {
                level2Count--;
            }
        }
    }
    
    for (int i = 1; i < _familyData.count; i ++ ) {
        @autoreleasepool {
            
            levelMaxSpouceCount = 0;
            NSArray *membersAry = _familyData[i][@"members"];
            NSString *level = _familyData[i][@"level"];
            NSMutableArray *newMemberAry = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray *directAry = [NSMutableArray array];
            NSMutableArray *womenAry = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray *menAry = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray *partnerAry = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableDictionary *partnerDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            for (NSDictionary *obj in membersAry){
                
                NSInteger directLine = [obj[@"directLine"] integerValue];
                NSInteger sex = [obj[@"sex"] integerValue];
                NSString  *parentId = obj[@"parentId"];
                
                if (parentId.length != 0) {//同辈血缘关系（兄弟姐妹）
                    if (directLine == 1) {
                        
                        [directAry addObject:obj];
                        
                    }else if (directLine == 0 && sex == 1){//男
                        
                        [menAry addObject:obj];
                        
                    }else if (directLine == 0 && sex == 2){//女
                        
                        [womenAry addObject:obj];
                        
                    }
                }else if (parentId.length == 0){//配偶
                    
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self findSameSpouse:obj AndDic:partnerDic]];
                    
                    [partnerDic removeAllObjects];
                    [partnerDic addEntriesFromDictionary:dic];
                    dic = nil;
                    
                }
            }
            
            //给配偶找对象
            
            NSMutableArray *tempDirectAry = [self pairHusbandAndWife:directAry AndPartner:partnerDic];//给中轴线找对象
            NSMutableArray *tempMenAry = [self pairHusbandAndWife:menAry AndPartner:partnerDic];//给男血亲找对象
            NSMutableArray *tempWomenAry = [self pairHusbandAndWife:womenAry AndPartner:partnerDic];//给女血亲找对象
            
            
            if (tempWomenAry.count > leftMaxCount) {
                leftMaxCount = tempWomenAry.count;
            }
            if (tempMenAry.count > rightMaxCount) {
                rightMaxCount = tempMenAry.count;
            }
            [levelMaxSpouceCountAry addObject:[NSNumber numberWithInt:levelMaxSpouceCount]];
            [newMemberAry addObject:tempDirectAry];
            [newMemberAry addObject:tempWomenAry];
            [newMemberAry addObject:tempMenAry];
            
            NSDictionary *newDic = @{@"level": level,@"members":newMemberAry};
            [_familyData replaceObjectAtIndex:i withObject:newDic];
            
            [newMemberAry release];
            tempMenAry = nil;
            tempWomenAry = nil;
            tempDirectAry = nil;
            directAry = nil;
            [menAry release];
            [womenAry release];
            [partnerAry release];
            [partnerDic release];
        }
        
    }
//最高一层的parentId为空，单独处理
    
    NSArray *highlevelAry = _familyData[0][@"members"];
    NSDictionary *adminDic = [NSDictionary dictionary];
    NSMutableArray *firstSpouseAry = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i <highlevelAry.count ; i ++ ) {
        NSDictionary *dic = highlevelAry[i];
        if ([dic[@"directLine"] integerValue] == 1) {
            adminDic = dic;
        } else {
            [firstSpouseAry addObject:dic];
        }
    }
    NSDictionary *membersDic = @{@"admin": adminDic,@"spouse":firstSpouseAry};
    NSArray *leftAry = [NSArray array];
    NSArray *rightAry = [NSArray array];
    NSArray   *membersAry = [NSArray arrayWithObjects:[NSArray arrayWithObject:membersDic],leftAry,rightAry,nil];
    NSDictionary *firstDic = @{@"level": _familyData[0][@"level"],@"members":membersAry};
    [levelMaxSpouceCountAry insertObject:[NSNumber numberWithInt:firstSpouseAry.count] atIndex:0];
    [_familyData replaceObjectAtIndex:0 withObject:firstDic];
    [firstSpouseAry release];
    
    
    [self handleGrandChildrenData];

}

-(void)handleGrandChildrenData{
    
    for (int i = 0; i < _grandChildrenData.count; i ++ ) {
        
        levelMaxSpouceCount = 0;

        NSArray *membersAry = _grandChildrenData[i][@"members"];
        NSInteger level = [_grandChildrenData[i][@"level"]integerValue];
        NSMutableDictionary *grandDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSMutableDictionary *partnerDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        for(NSDictionary *dic in membersAry){
            NSString *parentId = dic[@"parentId"];

            if ([parentId isEqualToString:@""]) {//孙子辈的配偶们集合
                
                NSMutableDictionary *dic1 = [NSMutableDictionary dictionaryWithDictionary:[self findSameSpouse:dic AndDic:partnerDic]];
                [partnerDic removeAllObjects];
                [partnerDic addEntriesFromDictionary:dic1];
                
            }else{//同一个父亲的孙子分类
                
                NSArray *allKeys = [grandDic allKeys];
                BOOL a = NO;
                for(int k = 0;k < allKeys.count; k ++ ){
                    if ([allKeys[k] isEqualToString:parentId]) {
                        a = YES;
                        NSMutableArray *ary = grandDic[allKeys[k]];
                        [ary addObject:dic];
                        [grandDic setObject:ary forKey:allKeys[k]];
                        break;
                    }
                }
                if (!a) {
                    
                    NSMutableArray *ary = [NSMutableArray arrayWithObject:dic];
                    [grandDic setObject:ary forKey:parentId];
                }
            }
        }
        //同一父亲下的孩子再分男女
        NSArray *allKeys = [grandDic allKeys];
        for (int m = 0; m < allKeys.count; m ++ ) {
            
            @autoreleasepool {
                NSString *key = allKeys[m];
                NSArray *sameParentAry = grandDic[key];
                NSMutableArray *womenAry = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableArray *menAry = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableArray *middleAry = [[NSMutableArray alloc] initWithCapacity:0];
                for (int j = 0; j < sameParentAry.count; j ++) {
                    NSDictionary *infoDic = sameParentAry[j];
                    if ([infoDic[@"sex"] integerValue] == 2) {//孙女
                        [womenAry addObject:infoDic];
                    }else if ([infoDic[@"sex"] integerValue] == 1 && [infoDic[@"directLine"] integerValue] == 1){//中轴
                        [middleAry addObject:infoDic];
                    }else if ([infoDic[@"sex"] integerValue] == 1){//孙子
                        [menAry addObject:infoDic];
                    }
                }
                if (middleAry.count == 0 && menAry.count > 0) {
                    
                    [middleAry addObject:menAry[0]];
                    [menAry removeObjectAtIndex:0];
                }
                //给孙子孙女们找对象

                NSMutableArray *newAry = [[NSMutableArray alloc] initWithCapacity:0];
                
                NSMutableArray *tempMiddleAry = [self pairHusbandAndWife:middleAry AndPartner:partnerDic];//给中轴线找对象
                NSMutableArray *tempMenAry = [self pairHusbandAndWife:menAry AndPartner:partnerDic];//给男血亲找对象
                NSMutableArray *tempWomenAry = [self pairHusbandAndWife:womenAry AndPartner:partnerDic];//给女血亲找对象
                
                
                [newAry addObject:tempMiddleAry];
                [newAry addObject:tempWomenAry];
                [newAry addObject:tempMenAry];
                
                
                [grandDic setObject:newAry forKey:key];
                
                [newAry release];
                
                tempMenAry = nil;
                tempMiddleAry = nil;
                tempWomenAry = nil;
                [menAry release];
                [middleAry release];
                [womenAry release];
            }
        }
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:level],@"level",grandDic,@"members",nil];
        [_grandChildrenData replaceObjectAtIndex:i withObject:dict];
        [levelMaxSpouceCountAry addObject:[NSNumber numberWithInt:levelMaxSpouceCount]];
        [grandDic release];
        [partnerDic release];

    }
}

//夫妻配对
- (NSMutableArray *)pairHusbandAndWife:(NSMutableArray *)ary AndPartner:(NSMutableDictionary *)partnerDic{
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *allKeys = [partnerDic allKeys];
    float wx = 0;
    for (int i = 0; i < ary.count; i ++ ) {
        
        NSDictionary *dic = ary[i];
        NSString *memberId = dic[@"memberId"];
        BOOL a = NO;
        for(id obj in allKeys){
            if ([memberId isEqualToString:obj]) {
                NSDictionary *infoDic = @{@"admin": dic,@"spouse":partnerDic[memberId]};
                [array addObject:infoDic];
                wx += peerLineW;
                a = YES;
                if ([partnerDic[memberId] count] > levelMaxSpouceCount) {
                    levelMaxSpouceCount = [partnerDic[memberId] count];
                }
                break;
            }
        }
        if(!a){
            NSDictionary *infoDic = @{@"admin": dic,@"spouse":[NSDictionary dictionary]};
            [array addObject:infoDic];
            wx += peerLineNoSpouse;
        }
    }
    if (ary.count != 0) {
        if ([ary[0][@"sex"] integerValue] == 1) {
            if (rightmaxW1 < wx) {
                rightmaxW1 = wx + btnWith1;
            }
        }else{
            wx = wx + btnWith1*3 + spouseLineW1 + spouseLineW;
            if (wx >= leftMaxW1) {
                leftMaxW1 = wx;
            }
        }
    }
    
    return [array autorelease];
}

- (NSMutableDictionary *)findSameSpouse:(NSDictionary *)obj AndDic:(NSMutableDictionary *)partnerDic{

    NSArray *allKeys = [partnerDic allKeys];
    NSString *partnerId = obj[@"partnerId"];
    for(id key in allKeys){
        if ([partnerId isEqualToString:key]) {
            @autoreleasepool {
                NSMutableArray *ary = [NSMutableArray arrayWithArray:partnerDic[partnerId]];
                [ary addObject:obj];
                [partnerDic setObject:ary forKey:partnerId];
                
                return partnerDic;
            }
        }
    }
    [partnerDic setObject:[NSArray arrayWithObject:obj] forKey:partnerId];

    return partnerDic;
}

//按照level大小排序
- (NSArray *)sortFamilyDataForLevel{
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"level" ascending:YES];
    NSArray *tempArray = [_familyData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    return tempArray;
}

//计算画布大小
-(CGSize)calculateDrawView{
  
    if (leftMaxW1 < 160) {
        leftMaxW1 = 160;
    }
    if (rightmaxW1 < 160) {
        rightmaxW1 = 160;
    }
    leftMaxW = leftMaxW1;
    rightMAxW = rightmaxW1;
    
    if (_grandChildrenData.count != 0) {//level = 2 层级有数据
        
        NSString *memberId = [_familyData lastObject][@"members"][0][0][@"admin"][@"memberId"];//level = 1 中轴的memberId
        //level = 2层的宽度
        float lW = 0;
        NSArray *leftMAry = [_familyData lastObject][@"members"][1];
        for (int i = 0; i < leftMAry.count; i ++) {
            float dis = 0;
            NSArray *lAry = nil;
            NSArray *mAry = nil;
            if (i == 0) {
                if ([[_familyData lastObject][@"members"][0][0][@"spouse"] count] == 0) {
                    dis += peerLineNoSpouse;
                }else{
                    dis += peerLineW;
                }
                [level1LeftDisAry addObject:[NSNumber numberWithFloat:dis]];
                lAry = _grandChildrenData[0][@"members"][memberId][1];
                mAry = _grandChildrenData[0][@"members"][memberId][0];
                dis = 0;
                for (int k = 0; k < lAry.count; k ++) {
                    if (k == 0 && mAry.count != 0) {
                        float xx = [self calSpouseCountDis:mAry[0][@"spouse"]];
                        dis += xx;
                        
                    }else if (k == 0 && mAry.count == 0){
                        dis += peerLineNoSpouse;
                    }else{
                        
                        float xx = [self calSpouseCountDis:lAry[k-1][@"spouse"]];
                        dis += xx;
                    }
                }
                lW += dis + btnWith1*3 + spouseLineW1 + spouseLineW;
            }else{
                if ([leftMAry[i-1][@"spouse"] count] == 0) {
                    [level1LeftDisAry addObject:[NSNumber numberWithFloat:peerLineNoSpouse]];
                }else{
                    [level1LeftDisAry addObject:[NSNumber numberWithFloat:peerLineW]];
                }
            }
        }
        
        
        float rW = 0;
        NSArray *rightMAry = [_familyData lastObject][@"members"][2];
        for (int i = 0; i < rightMAry.count; i ++) {
            float dis = 0;
            NSArray *rAry = nil;
            NSArray *lAry = nil;
            NSArray *mAry = nil;
            if (i == 0) {
                NSString *key = [_familyData lastObject][@"members"][0][0][@"admin"][@"memberId"];//level = 1 中轴的memberId
                rAry = _grandChildrenData[0][@"members"][key][2];//中轴的右边儿子
                NSString *key1  = rightMAry[i][@"admin"][@"memberId"];
                lAry = _grandChildrenData[0][@"members"][key1][1];
                mAry = _grandChildrenData[0][@"members"][key1][0];
                
            }else{
                NSString *keyL = rightMAry[i-1][@"admin"][@"memberId"];
                NSString *key  = rightMAry[i][@"admin"][@"memberId"];
                rAry = _grandChildrenData[0][@"members"][keyL][2];
                lAry = _grandChildrenData[0][@"members"][key][1];
                mAry = _grandChildrenData[0][@"members"][key][0];
            }
            for (int k = 0; k < rAry.count; k ++) {
                    float xx = [self calSpouseCountDis:rAry[k][@"spouse"]];
                    dis += xx;
            }
            for (int k = 0; k < lAry.count; k ++) {
                
                if (k == 0 && mAry.count != 0) {
                    float xx = [self calSpouseCountDis:mAry[0][@"spouse"]];
                    dis += xx;
                }else if (k == 0 && mAry.count == 0){
                    dis += peerLineNoSpouse;
                }else{
                    float xx = [self calSpouseCountDis:lAry[k-1][@"spouse"]];
                    dis += xx;
                }
                if (k == lAry.count - 1) {
                    NSInteger sCount = [lAry[k][@"spouse"] count];
                    if (sCount != 0) {
                        dis += btnWith1*3 + spouseLineW + spouseLineW1;
                    }else{
                        dis += btnWith1;
                    }
                }
            }
            if (lAry.count == 0 && mAry.count != 0 && rAry.count != 0) {
                if ([mAry[0][@"spouse"]count] != 0) {
                    dis += btnWith1*4 + 35 + spouseLineW + spouseLineW1;
                }else{
                    dis += btnWith1*2 + 35;
                }
            }else if (lAry.count == 0 && mAry.count == 0 && rAry.count == 0){
                float xx = [self calSpouseCountDis:rightMAry[i][@"spouse"]];
                dis += xx;
            }else if (lAry.count == 0 && rAry.count == 0 && mAry.count != 0){
                float xx = [self calSpouseCountDis:mAry[0][@"spouse"]];
                float xx1 = [self calSpouseCountDis:rightMAry[i][@"spouse"]];
                xx < xx1 ? xx = xx1 : xx;
                dis += xx;
            }else if (rAry.count != 0 && mAry.count == 0 && lAry.count == 0){
                float xx = [self calSpouseCountDis:rightMAry[i][@"spouse"]];
                dis += xx - peerLineNoSpouse;
            }else if(lAry.count != 0){
                dis += btnWith1;
                dis += 35;
            }
            
            [level1RightDisAry addObject:[NSNumber numberWithFloat:dis]];
            rW += dis;
            if (i == rightMAry.count - 1) {
                NSString *key1  = rightMAry[i][@"admin"][@"memberId"];
                NSInteger count = [_grandChildrenData[0][@"members"][key1][2]count];
                for (int j = 0; j < count; j ++) {
                    float xx = [self calSpouseCountDis:_grandChildrenData[0][@"members"][key1][2][j][@"spouse"]];
                    rW += xx;
                }
                rW += btnWith1;
            }
        }
        if (rW > rightMAxW) {
            rightMAxW = rW;
        }
        if (lW > leftMaxW) {
            leftMaxW = lW;
        }
        
        
        //level = 1层的宽度
        float lW1 = 0;
        for (int i = 0; i < level1LeftDisAry.count; i ++) {
            lW1 += [level1LeftDisAry[i] floatValue];
        }
        lW1 += btnWith1*3 + spouseLineW + spouseLineW1;
        float rW1 = 0;
        for (int i = 0 ; i < level1RightDisAry.count; i ++) {
            rW1 += [level1RightDisAry[i] floatValue];
        }
        rW1 += btnWith1;
        if (lW1 > leftMaxW) {
            leftMaxW = lW1;
        }
        if (rW1 > rightMAxW) {
            rightMAxW = rW1;
        }
    }
    leftMaxW += 30;
    rightMAxW += 30;
    //总得宽度
    float width = leftMaxW + rightMAxW;
    
    //    float x = leftMaxCount*peerLineW+btnWith1*3+spouseLineW+spouseLineW1;
    //计算画布高度
    float height = 0;
    for (int i = 0; i < levelMaxSpouceCountAry.count; i ++ ) {
        NSInteger count = [levelMaxSpouceCountAry[i] integerValue];
        if (count > 0) {
            height += btnH*count+spouseDis*(count-1)+spouseUpH+spouseDownH;
        }else{
            height += btnH+spouseDownH+spouseUpH;
        }
    }
    width += 60;
    height += 100;
    
    if (width < 320) {
        width = 320;
    }
    if (height < self.view.frame.size.height) {
        height = self.view.frame.size.height;
    }
    CGSize size = CGSizeMake(width, height);
    if (!tempSize.width) {
        tempSize = size;
    }
    return size;
}
-(float)calSpouseCountDis:(NSArray *)ary{
    
    if (ary.count != 0) {
        return peerLineW;
    }else{
        return peerLineNoSpouse;
    }
}
-(void)reHandleFamily:(BOOL)other{
    
    [self handleFamilyData];
    
    CGSize size = [self calculateDrawView];
    _scrollView.contentSize = CGSizeMake(size.width, size.height);
    
    drawTreeLineView = [[DrawTreeLineView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    drawTreeLineView.delegate = self;
    
    [self setDrawViewData];
    
    if (other) {
        CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [basic setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [basic setFromValue:[NSNumber numberWithFloat:0.1]];
        [basic setToValue:[NSNumber numberWithInt:1]];
        [basic setDuration:1.2];
        [drawTreeLineView.layer addAnimation:basic forKey:@"animationKey"];
        [_scrollView addSubview:drawTreeLineView];
        [drawTreeLineView release];
    }else{
        [_scrollView addSubview:drawTreeLineView];
        [drawTreeLineView release];
    }
    
}

//绘制画布
- (void)setDrawView{
    
    CGSize size = [self calculateDrawView];
    
    _scrollView = [[UIScrollView alloc] init];
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        _scrollView.frame = CGRectMake(0, 44, 320, self.view.frame.size.height - 44);
    }else{
        _scrollView.frame = CGRectMake(0, 64, 320, self.view.frame.size.height - 64);
    }
    _scrollView.minimumZoomScale = 0.4;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = RGBCOLOR(238, 242, 245);
    _scrollView.contentSize = CGSizeMake(size.width, size.height);
    _scrollView.scrollEnabled = YES;
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    drawTreeLineView = [[DrawTreeLineView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    drawTreeLineView.delegate = self;
    [self setDrawViewData];
    [_scrollView addSubview:drawTreeLineView];
    [drawTreeLineView release];
    
    UIButton *saveBtn = [[UIButton alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        saveBtn.frame = CGRectMake(10, SCREEN_HEIGHT - 52, 86, 42);
    }else{
        saveBtn.frame = CGRectMake(10, SCREEN_HEIGHT - 72, 86, 42);
    }
    saveBtn.showsTouchWhenHighlighted = YES;
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"family_save"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveImg) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 56, 42)];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.text = @"保存家谱";
    aLabel.textColor = [UIColor whiteColor];
    aLabel.font = [UIFont systemFontOfSize:12.0f];
    [saveBtn addSubview:aLabel];
    [aLabel release];
    
    
/*    __block typeof(self) bself = self;
//    __block UIScrollView *s = _scrollView;
    
    drawTreeLineView.setContentOffSet = ^(float width,float height){
        
//        s.contentOffset = CGPointMake(width - 175 + btnWith1, height - (bself.view.frame.size.height - 44)/2);
        [bself asd:CGPointMake(width, height)];
    };*/
    
}

-(void)setDrawViewData{
    
    drawTreeLineView.familyData = _familyData;
    drawTreeLineView.grandChildrenData = _grandChildrenData;
    drawTreeLineView.levelMaxSpouceCountAry = levelMaxSpouceCountAry;
    drawTreeLineView.leftMaxCount = leftMaxCount;
    drawTreeLineView.leftMaxW = leftMaxW;
    drawTreeLineView.rightMaxW = rightMAxW;
    drawTreeLineView.rightMaxCount = rightMaxCount;
    drawTreeLineView.level1LeftDisAry = level1LeftDisAry;
    drawTreeLineView.level1RightDisAry = level1RightDisAry;
    NSArray *levelsAry = [_familyData valueForKey:@"level"];
    
    for(int i = 0;i < levelsAry.count; i ++ ){
        if ([levelsAry[i] integerValue] == 0) {
            
            drawTreeLineView.whoFamilyDic = _familyData[i][@"members"][0][0][@"admin"];
            NSString *userId = _familyData[i][@"members"][0][0][@"admin"][@"memberId"];
            userId = [userId stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [[SavaData shareInstance] savadataStr:userId KeyString:WHOFAMILY];
            if ([userId isEqualToString:USERID]) {
                self.titleLabel.text = @"我的家谱";
            }else{
                self.titleLabel.text = [NSString stringWithFormat:@"%@的家谱",_familyData[i][@"members"][0][0][@"admin"][@"name"]];
            }
            break;
        }
    }

}

-(void)setTheScrollViewOffSet:(CGPoint)point{
    
    _scrollView.contentOffset = CGPointMake(point.x - 175 + btnWith1, point.y - (self.view.frame.size.height - 44)/2);
    
}
-(void)asd:(CGPoint)point{
    _scrollView.contentOffset = CGPointMake(point.x - 175 + btnWith1, point.y - (self.view.frame.size.height - 44)/2);

}

-(void)pushDetail:(NSNotification *)notify{
    
    NSDictionary *dic = [notify object];
    GenealogyMemberDetailViewController *vc = [[GenealogyMemberDetailViewController alloc] initWithNibName:iPhone5 ? @"GenealogyMemberDetailViewController-5" : @"GenealogyMemberDetailViewController" bundle:nil];
    if ([dic[@"isOther"] boolValue]) {
        vc.isOthersGenealogy = YES;
    }else{
        vc.isOthersGenealogy = NO;
    }
    vc.memberInfoDic = [NSMutableDictionary dictionaryWithDictionary:dic[@"info"]];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

-(void)pushEditDetail:(NSNotification *)notify{
    
    NSDictionary *dic = [notify object];
    NSInteger tag = [dic[@"tag"] integerValue];
    GenealogyMemberEditorViewController *editVC = [[GenealogyMemberEditorViewController alloc] initWithNibName:@"GenealogyMemberEditorViewController-5" bundle:nil type:GenealogyEditorTypeAdd];
    if (tag == 1001) {
        editVC.memberType = GenealogyAdditionTypeAncestor;
        editVC.memberInfoDic = [NSMutableDictionary dictionaryWithDictionary:dic[@"infoDic"]];
    }else{
        editVC.memberType = GenealogyAdditionTypePartner;
        editVC.targetMebmerInfo = [NSMutableDictionary dictionaryWithDictionary:dic[@"infoDic"]];
    }

    [self.navigationController pushViewController:editVC animated:YES];
    [editVC release];
    
}

- (void)getFamilyTreeData{
    
    _mb = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:_mb];
    _mb.detailsLabelText = @"加载中...";
    [_mb show:YES];
    
    NSURL *url = [[RequestParams sharedInstance] newFamilyTree];
    
    _request = [[ASIFormDataRequest alloc] initWithURL:url];
    [_request setRequestMethod:@"POST"];
    [_request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_request setPostValue:@"level" forKey:@"struct"];
    [_request setTimeOutSeconds:20];
    [_request setDelegate:self];
    [_request setShouldAttemptPersistentConnection:NO];
    [_request startAsynchronous];
}


- (void)requestFinished:(ASIHTTPRequest *)request{
    
    [_mb show:NO];
    [_mb removeFromSuperview];
    
    NSData *data = [request responseData];
    NSDictionary *dic = [data objectFromJSONData];
    NSString *message = dic[@"message"];
    if ([dic[@"success"] intValue] == 1)
    {
        [self setValuesDefault];
        [_familyData addObjectsFromArray:dic[@"data"]];
    //TODO:缓存
        [MyFamilySQL addFamilyMembers:_familyData AndType:@"reAdd" WithUserID:USERID];

        if (_familyData.count) {
            
            [[SavaData shareInstance] savaDataBool:NO KeyString:ISHANDLOGIN];
            [self handleFamilyData];
            [self setDrawView];
            
        }
    }else if ([dic[@"errorcode"] integerValue] == 1005)
    {
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        
    }else if ([dic[@"errorcode"] intValue] ==9000)
    {
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        
    }else{
        
        [self networkPromptMessage:message];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    
    [_mb show:NO];
    [_mb removeFromSuperview];
    
    [self networkPromptMessage:@"网络连接异常"];

}

-(void)refreshView:(NSNotification *)notify{
    
    NSDictionary *dic = [notify object];
    [_familyData removeAllObjects];
    [_grandChildrenData removeAllObjects];
    
    [_familyData addObjectsFromArray:[MyFamilySQL getFamilyMembersWithUserId:USERID]];
    [self handleFamilyData];
    drawTreeLineView.familyData = _familyData;
    drawTreeLineView.grandChildrenData = _grandChildrenData;
    for(id obj in drawTreeLineView.subviews){
        if ([obj isKindOfClass:[FamilyMemberButton class]]) {
            FamilyMemberButton *btn = (FamilyMemberButton *)obj;
            if ([btn.memberID isEqualToString:dic[@"memberId"]]) {
                [btn addGuanlian];
                btn.nameLabel.text = dic[@"name"];
                NSString *birth = [Utilities convertTimestempToDateWithString2:dic[@"birthDate"]];
                btn.birthLabel.text = birth;
                if (![dic[@"headPortrait"] isEqualToString:@""]) {
                    [btn.headerImg setImageWithURL:[NSURL URLWithString:dic[@"headPortrait"]] placeholderImage:[UIImage imageNamed:@"mrtx"]];
                }
            }
        }
    }
}

-(void)getOtherPeopleFamilyData:(NSNotification *)notify{
    
    
    NSDictionary *dic = [notify object];
    
    NSString *associatekey = dic[@"associateKey"];
    NSString *associatevalue = dic[@"associateValue"];
    NSString *associateauthcode = dic[@"associateAuthCode"];
    NSString *eternalnum = dic[@"eternalnum"];
    NSString *eternalCode = dic[@"eternalCode"];
    NSString *associateuserid = dic[@"associateUserId"];
    
    if (_request) {
        [_request release];
    }
    NSURL *url = [[RequestParams sharedInstance] newFamilyTree];
    _request = [[ASIFormDataRequest alloc] initWithURL:url];
    [_request setRequestMethod:@"POST"];
    [_request setPostValue:USER_TOKEN_GETOUT forKey:@"clienttoken"];
    [_request setPostValue:USER_AUTH_GETOUT forKey:@"serverauth"];
    [_request setPostValue:@"level" forKey:@"struct"];
    [_request setPostValue:@"associate" forKey:@"type"];
    [_request setPostValue:associatekey forKey:@"associatekey"];
    [_request setPostValue:associatevalue forKey:@"associatevalue"];
    [_request setPostValue:associateuserid forKey:@"associateuserid"];
    [_request setPostValue:associateauthcode forKey:@"associateauthcode"];
    [_request setPostValue:eternalCode forKey:@"eternalcode"];
    [_request setPostValue:eternalnum forKey:@"eternalnum"];
    [_request setTimeOutSeconds:20];
    [_request setShouldAttemptPersistentConnection:NO];
    __block typeof(self) bself = self;
    [_request setCompletionBlock:^{
        [bself requestSuccess:_request];
    }];
    [_request setFailedBlock:^{
        [bself requestFail:_request];
    }];
    [_request startAsynchronous];
}

-(void)requestSuccess:(ASIFormDataRequest *)request{
    
    self.rightBtn.hidden = NO;
    NSData *data = [request responseData];
    NSDictionary *dic = [data objectFromJSONData];
    NSString *message = dic[@"message"];
    NSInteger success = [dic[@"success"] integerValue];
    if (success == 1) {
        
        [self drawOtherFamily];

        [_familyData addObjectsFromArray:dic[@"data"]];
        if (_familyData.count) {
            
            [self reHandleFamily:YES];
            
        }
    }else if ([dic[@"errorcode"] integerValue] ==1005)
    {
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:AUTO_RELOGIN delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        
    }else if ([dic[@"errorcode"] intValue] ==9000)
    {
        [[[[UIAlertView alloc] initWithTitle:ALERT_TITLE message:POINT_OUTMES delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease] show];
        
    }else{
        
        [self networkPromptMessage:message];
    }
    
}

-(void)requestFail:(ASIFormDataRequest *)request{
    
    [self networkPromptMessage:@"网络不给力"];
}

-(void)setValuesDefault{
    
    [_familyData removeAllObjects];
    [_grandChildrenData removeAllObjects];
    [levelMaxSpouceCountAry removeAllObjects];
    [level1LeftDisAry removeAllObjects];
    [level1RightDisAry removeAllObjects];
    
    leftMaxCount = 0;
    rightMaxCount = 0;
    
    levelMaxSpouceCount = 0;
    level2Count = 0;
    leftCount2 = 0;
    rightCount2 = 0;
    leftMaxW = 0;
    rightMAxW = 0;
    leftMaxW1 = 0;
    rightmaxW1 = 0;
    
//    drawTreeLineView.familyData = nil;
//    drawTreeLineView.grandChildrenData = nil;
//    drawTreeLineView.levelMaxSpouceCountAry = nil;
//    drawTreeLineView.leftMaxCount = 0;
//    drawTreeLineView.leftMaxW = 0;
//    drawTreeLineView.rightMaxCount = 0;
//    drawTreeLineView.rightMaxW = 0;
//    drawTreeLineView.level1LeftDisAry = nil;
//    drawTreeLineView.level1RightDisAry = nil;
    
    [drawTreeLineView removeFromSuperview];
    drawTreeLineView = nil;
}

-(void)drawOtherFamily{
    
    if (tempFamilyData.count == 0) {
        
        [tempFamilyData addObjectsFromArray:_familyData];
        [tempGrandData addObjectsFromArray:_grandChildrenData];
        [templevelMaxSpouceCountAry addObjectsFromArray:levelMaxSpouceCountAry];
        tempLeftMaxCount = leftMaxCount;
        tempRightMaxCount = rightMaxCount;
        tempLeftMaxW = leftMaxW;
        tempRightMaxW = rightMAxW;
        [tempLevel1LeftDisAry addObjectsFromArray:level1LeftDisAry];
        [tempLevel1RightDisAry addObjectsFromArray:level1RightDisAry];

    }
    
    [self setValuesDefault];

    
}
-(void)saveImg{
    
    float zoomScale = 1.0 / [_scrollView zoomScale];
	CGRect rect;
	rect.origin.x = drawTreeLineView.frame.origin.x * zoomScale;
	rect.origin.y = drawTreeLineView.frame.origin.y * zoomScale;
	rect.size.width = drawTreeLineView.frame.size.width * zoomScale;
	rect.size.height = drawTreeLineView.frame.size.height * zoomScale;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextTranslateCTM(context, 0, self.view.frame.size.height);
    //    CGContextScaleCTM(context, 1, -1);
    //    CGContextDrawImage(context, CGRectMake(rect.origin.x, rect.origin.y, drawTreeLineView.frame.size.width, drawTreeLineView.frame.size.height), drawTreeLineView.);
    //    CGContextClipToRect(context, rect);
    
    [drawTreeLineView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithCGImage:[img CGImage]],nil,nil,nil);
    [MyToast showWithText:@"已成功保存到相册" :300];
}
-(void)rightBtnPressed{
    
    [_familyData removeAllObjects];
    [_grandChildrenData removeAllObjects];
    [levelMaxSpouceCountAry removeAllObjects];
    [level1RightDisAry removeAllObjects];
    [level1LeftDisAry removeAllObjects];
    
    [_familyData addObjectsFromArray:tempFamilyData];
    [_grandChildrenData addObjectsFromArray:tempGrandData];
    [levelMaxSpouceCountAry addObjectsFromArray:templevelMaxSpouceCountAry];
    leftMaxCount = tempLeftMaxCount;
    rightMaxCount = tempRightMaxCount;
    
    [level1LeftDisAry addObjectsFromArray:tempLevel1LeftDisAry];
    [level1RightDisAry addObjectsFromArray:tempLevel1RightDisAry];
    leftMaxW = tempLeftMaxW;
    rightMAxW = tempRightMaxW;
    
    [tempFamilyData removeAllObjects];
    [tempGrandData removeAllObjects];
    [templevelMaxSpouceCountAry removeAllObjects];
    
    [drawTreeLineView removeFromSuperview];
    
    
    _scrollView.contentSize = CGSizeMake(tempSize.width,tempSize.height);

    drawTreeLineView = [[DrawTreeLineView alloc] initWithFrame:CGRectMake(0, 0, tempSize.width, tempSize.height)];
    drawTreeLineView.delegate = self;
    [self setDrawViewData];
    [_scrollView addSubview:drawTreeLineView];
    [drawTreeLineView release];
    self.rightBtn.hidden = YES;
    self.rightBtn.titleLabel.text = @"我的家谱";
}

-(void)backBtnPressed{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return drawTreeLineView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView

{
    //缩放操作中被调用
    if (drawTreeLineView.frame.size.height < _scrollView.frame.size.height && drawTreeLineView.frame.size.width < _scrollView.frame.size.height) {
        drawTreeLineView.center = _scrollView.center;
    }else{
        drawTreeLineView.frame = CGRectMake(0, 0, drawTreeLineView.frame.size.width, drawTreeLineView.frame.size.height);
    }

    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale

{
    //缩放结束后被调用
    if (drawTreeLineView.frame.size.height < _scrollView.frame.size.height && drawTreeLineView.frame.size.width < _scrollView.frame.size.width) {
        drawTreeLineView.center = _scrollView.center;
    }else if (drawTreeLineView.frame.size.height < _scrollView.frame.size.height && drawTreeLineView.frame.size.width > _scrollView.frame.size.width){
        drawTreeLineView.frame = CGRectMake(0, (self.view.frame.size.height - 44 - drawTreeLineView.frame.size.height)/2, drawTreeLineView.frame.size.width, drawTreeLineView.frame.size.height);
    }else if (drawTreeLineView.frame.size.height > _scrollView.frame.size.height && drawTreeLineView.frame.size.width < _scrollView.frame.size.width){
        drawTreeLineView.frame = CGRectMake((self.view.frame.size.width - drawTreeLineView.frame.size.width)/2, 0, drawTreeLineView.frame.size.width, drawTreeLineView.frame.size.height);
    }else{
        drawTreeLineView.frame = CGRectMake(0, 0, drawTreeLineView.frame.size.width, drawTreeLineView.frame.size.height);
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
        BOOL isLogin = NO;
        [[SavaData shareInstance]savaDataBool:isLogin KeyString:ISLOGIN];
        [(EternalMemoryAppDelegate*)([UIApplication sharedApplication].delegate)showLoginVC];
}
- (BOOL)shouldAutorotate
{
    return YES;
} 
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskAll;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        //zuo
        self.view.frame = CGRectMake(0, 44, self.view.frame.size.height - 44, self.view.frame.size.width);
        _scrollView.frame = CGRectMake(0, 44, 320, self.view.frame.size.height - 44);

    }
    if (interfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        //you
        self.view.frame = CGRectMake(0, 44, self.view.frame.size.height - 44, self.view.frame.size.width);
    }
    if (interfaceOrientation==UIInterfaceOrientationPortrait) {
        //shang
        self.view.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44);

    }
    if (interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
        //xia
        self.view.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44);

    }
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    // Dispose of any resources that can be recreated.
}
//计算字节，一个汉字3个字节，一个字母一个字节
/*- (int)calc_charsetNum:(NSString*)_str
{
    unsigned result = 0;
    const char *tchar=[_str UTF8String];
    if (NULL == tchar) {
        return result;
    }
    result = strlen(tchar);
    return result;
}*/


@end
