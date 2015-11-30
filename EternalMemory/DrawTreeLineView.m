//
//  DrawTreeLineView.m
//  EternalMemory
//
//  Created by kiri on 13-9-13.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "DrawTreeLineView.h"
#import "FamilyMemberButton.h"
#import "Utilities.h"
#import "UIImageView+WebCache.h"
#import "GenealogyMemberEditorViewController.h"

#define btnW                97
#define btnH                40
#define btnWith1            btnW/2
#define btnHeight1          btnH/2
#define spouseLineW         10      //配偶固定线长
#define spouseLineW1        8
#define spouseDis           20      //两个配偶上下之间的间距
#define peerLineW           247     //btnW*2+spouseLineW+spouseLineW1+35//同辈之间固定线长
#define peerLineNoSpouse    130
#define spouseUpH           30      //配偶大于1的时候，最上方的配偶距离上方线的高度
#define spouseDownH         30      //配偶大于1的时候，最下方的配偶距离下方线的高度



@implementation DrawTreeLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = frame;
        self.backgroundColor = RGBCOLOR(238, 242, 245);
        if (downPointary) {
            [downPointary release];
        }
        if (memberIdKeysAry) {
            [memberIdKeysAry release];
        }
        downPointary = [[NSMutableArray alloc] initWithCapacity:0];
        memberIdKeysAry = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
-(void)dealloc{
    
    [downPointary release];downPointary = nil;
    
    [memberIdKeysAry release];memberIdKeysAry = nil;
    
    [_familyData release];_familyData = nil;
    
    [_grandChildrenData release];_grandChildrenData = nil;
    
    [_whoFamilyDic release];_whoFamilyDic = nil;
    
    [_levelMaxSpouceCountAry release];_levelMaxSpouceCountAry = nil;
    
    [_level1LeftDisAry release];_level1LeftDisAry = nil;
    
    [_level1RightDisAry release];_level1RightDisAry = nil;
    
    _setContentOffSet = nil;
    
    [super dealloc];
}

- (void)drawUnkonwBtn:(CGContextRef)context{
    
//    float x = self.leftMaxCount*peerLineW + btnWith1*3 + spouseLineW + spouseLineW1;
    btnFrame = CGRectMake(_leftMaxW - btnWith1 + 30, 40, btnW, btnH);
    
//别人的家谱里面没有默认生成的
    
    if (![WHOFAMILYID isEqualToString:USERID]) {
        return;
    }
    
    FamilyMemberButton *btnM = [FamilyMemberButton buttonWithType:UIButtonTypeCustom];
    btnM.frame = btnFrame;
    btnM.backgroundColor = [UIColor colorWithRed:165/255. green:207/255. blue:255/255. alpha:1.0];
    btnM.tag = 1001;
    [btnM.headerImg setImage:[UIImage imageNamed:@"mrtx"]];
    [self addSubview:btnM];
    
    CGContextMoveToPoint(context, btnFrame.origin.x,btnFrame.origin.y + btnHeight1);
    CGContextAddLineToPoint(context, btnFrame.origin.x - spouseLineW - spouseLineW1,btnFrame.origin.y + btnHeight1);
    
    FamilyMemberButton *motherBtn = [FamilyMemberButton buttonWithType:UIButtonTypeCustom];
    motherBtn.frame = CGRectMake(btnFrame.origin.x - spouseLineW - spouseLineW1 - btnW, btnFrame.origin.y, btnW, btnH);
    motherBtn.backgroundColor = [UIColor colorWithRed:239/255. green:158/255. blue:156/255. alpha:1.0];
    motherBtn.tag = 1002;
    [motherBtn.headerImg setImage:[UIImage imageNamed:@"mrtx"]];
    [self addSubview:motherBtn];

    if ([self.whoFamilyDic[@"memberId"] isEqualToString:self.whoFamilyDic[@"userId"]] && [WHOFAMILYID isEqualToString:USERID]) {//我的家谱，我的家谱里面所有的数据都可以点击
        [btnM addTarget:self action:@selector(noInfoBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [motherBtn addTarget:self action:@selector(noInfoBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条样式
    CGContextSetLineCap(context, kCGLineCapSquare);
    //设置线条粗细宽度
    CGContextSetLineWidth(context, 1.0);
    
    //设置颜色
    //    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:194/255. green:198/255. blue:201/255. alpha:1.0].CGColor);
    
    CGContextBeginPath(context);
    
    [self drawUnkonwBtn:context];

    
    [self beginDrawRectboard:context];

    
    
    CGContextStrokePath(context);
    

    if (_delegate && [_delegate respondsToSelector:@selector(setTheScrollViewOffSet:)]) {
        [_delegate setTheScrollViewOffSet:CGPointMake(myRect.origin.x, myRect.origin.y)];
    }
//    if (_setContentOffSet) {
//
//        _setContentOffSet(myRect.origin.x,myRect.origin.y);
//    }
    
}

- (void)beginDrawRectboard:(CGContextRef)context{
    
    if ([WHOFAMILYID isEqualToString:USERID]) {
        CGContextMoveToPoint(context, btnFrame.origin.x+btnWith1,btnFrame.origin.y+btnH);
        forePoint = CGPointMake(btnFrame.origin.x+btnWith1,btnFrame.origin.y+btnH + spouseUpH);
        CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
        upLevelDownPoint = forePoint;
    }else{
        upLevelDownPoint = CGPointMake(btnFrame.origin.x+btnWith1, btnFrame.origin.y+btnH);
    }
    
    
    for (int i = 0; i < self.familyData.count; i ++ ) {
        NSDictionary *levelDic = self.familyData[i];
        NSArray      *levelMemberAry = levelDic[@"members"];
        NSInteger  level = [levelDic[@"level"] integerValue];
        NSArray      *nextLevelMemAry = nil;
        NSInteger maxCount = [self.levelMaxSpouceCountAry[i] integerValue];//层级最大配偶数
        float y = maxCount*btnH + spouseDis*abs(maxCount - 1);
        
        if ((i+1) < self.familyData.count) {
            nextLevelMemAry = self.familyData[i+1][@"members"];
        }
        if (self.grandChildrenData.count > 0 && i == self.familyData.count - 1) {//如果孙子辈没数据，就采用这个方法，有数据，就跳出循环，采用drawLevel0方法
            [self drawLevel1:context AndIndex:i];
            return;
        }
        for (int j = 0; j < 3; j ++) {
            
            
            if (j == 0 && [levelMemberAry[j] count] != 0) {//中轴  //中轴线有可能没有数据
                
                NSArray  *spouseAry = levelMemberAry[j][0][@"spouse"];
                NSString *parentId = levelMemberAry[j][0][@"admin"][@"parentId"];
                forePoint = upLevelDownPoint;
                upLevelUpPoint = forePoint;
                
                if (![WHOFAMILYID isEqualToString:USERID] && i == 0) {//别人的家谱，最高层级btn上方的线不画
                    forePoint = upLevelDownPoint;
                    upLevelDownPoint = CGPointMake(upLevelDownPoint.x, upLevelDownPoint.y - y/2 - spouseUpH + btnHeight1);

                }else{
                    CGContextMoveToPoint(context, forePoint.x,forePoint.y);
                    forePoint = CGPointMake(forePoint.x, forePoint.y+y/2+spouseUpH-btnHeight1);
                    CGContextAddLineToPoint(context, forePoint.x,forePoint.y);//btn上方
                }
                
                [self addBtn:CGPointMake(forePoint.x - btnWith1, forePoint.y) AndDic:levelMemberAry[j][0][@"admin"] AndKinParentId:parentId AndTag:i+1 AndDirection:0 AndIndex:0 AndSpouse:NO];
                if (nextLevelMemAry.count > 0) {
                    
                    forePoint = CGPointMake(forePoint.x, forePoint.y + btnH);
                    CGContextMoveToPoint(context, forePoint.x,forePoint.y);
                    forePoint = CGPointMake(forePoint.x, forePoint.y + y/2+spouseDownH-btnHeight1);
                    CGContextAddLineToPoint(context, forePoint.x,forePoint.y);//btn下方
                    upLevelDownPoint = CGPointMake(forePoint.x, forePoint.y);
                    
                }
                [self drawMiddleContext:context AndData:spouseAry AndKinParentId:@"" AndNextLevelMember:nextLevelMemAry andMaxSpouseCount:maxCount AndTag:i+1 AndLevel:level];
                
            }
            if (j == 1 && [levelMemberAry[j] count] != 0) {//左边
                
                NSArray *leftMemberAry = levelMemberAry[j];
                NSString *parentId = leftMemberAry[0][@"admin"][@"parentId"];
                float xx = 0;
                for (int k = 0; k < leftMemberAry.count; k ++ ) {
                    float xxF = 0;
                    if (k == 0) {
                        
                        if ([levelMemberAry[0] count] != 0) {
                            forePoint = CGPointMake(upLevelUpPoint.x - xx,upLevelUpPoint.y);
                        }else{
                            forePoint = CGPointMake(upLevelDownPoint.x - xx,upLevelDownPoint.y);
                        }

                        if ((level == 0 && [[_familyData lastObject][@"level"]integerValue] < 1) || (level == 1 && [levelMemberAry[0] count] != 0)) {
                            xxF = [self spouseCount:levelMemberAry[0][0][@"spouse"]];
                        }else if (level == 1 && [levelMemberAry[0] count] == 0){
                            xxF = peerLineNoSpouse;
                        }else{
                            xxF = peerLineW;
                        }
                        xx += xxF;
                    }else{
                        xxF = [self spouseCount:leftMemberAry[k-1][@"spouse"]];
                        if ([levelMemberAry[0] count] != 0) {
                            forePoint = CGPointMake(upLevelUpPoint.x - xx,upLevelUpPoint.y);
                        }else{
                            forePoint = CGPointMake(upLevelDownPoint.x - xx,upLevelDownPoint.y);
                        }
                        xx += xxF;
                    }
                    CGContextMoveToPoint(context, forePoint.x, forePoint.y);
                    forePoint = CGPointMake(forePoint.x - xxF, forePoint.y);
                    CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                    forePoint = CGPointMake(forePoint.x, forePoint.y + y/2 + spouseUpH - btnHeight1);
                    CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                    [self addBtn:CGPointMake(forePoint.x - btnWith1, forePoint.y) AndDic:leftMemberAry[k][@"admin"] AndKinParentId:parentId AndTag:i+1 AndDirection:1 AndIndex:k AndSpouse:NO];
                    //画配偶
                    NSArray *spouseAry = leftMemberAry[k][@"spouse"];
                    
                    [self drawSpouseAry:spouseAry AndContext:context AndKinParentId:@"" AndTag:i+1 AndDirection:1 AndIndex:k];
                }
                
            }
            if (j == 2 && [levelMemberAry[j] count] != 0) {//右边
                
                NSArray *rightMemberAry = levelMemberAry[j];
                NSString *parentId = rightMemberAry[0][@"admin"][@"parentId"];
                
                float xx = 0;
                
                for (int k = 0; k < rightMemberAry.count; k ++ ) {
                    
                    float xxF = [self spouseCount:rightMemberAry[k][@"spouse"]];
                    if ([levelMemberAry[0] count] == 0) {
                        forePoint = CGPointMake(upLevelDownPoint.x + xx,upLevelDownPoint.y);
                        xx += xxF;
                    }else{
                        forePoint = CGPointMake(upLevelUpPoint.x + xx,upLevelUpPoint.y);
                        xx += xxF;
                    }
                    CGContextMoveToPoint(context, forePoint.x, forePoint.y);
                    forePoint = CGPointMake(forePoint.x + xxF, forePoint.y);
                    CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                    forePoint = CGPointMake(forePoint.x, forePoint.y + y/2 + spouseUpH - btnHeight1);
                    CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                    [self addBtn:CGPointMake(forePoint.x - btnWith1, forePoint.y) AndDic:rightMemberAry[k][@"admin"] AndKinParentId:parentId AndTag:i+1 AndDirection:2 AndIndex:k AndSpouse:NO];
                    //画配偶
                    NSArray *spouseAry = rightMemberAry[k][@"spouse"];
                    
                    [self drawSpouseAry:spouseAry AndContext:context AndKinParentId:@"" AndTag:i+1 AndDirection:2 AndIndex:k];
                }
            }
        }
    }

}
-(void)drawLevel1:(CGContextRef)context AndIndex:(NSInteger)i//采用此方法说明孙子辈有数据
{
    
    NSDictionary *levelDic = self.familyData[i];
    NSArray      *levelMemberAry = levelDic[@"members"];
    NSInteger  level = [levelDic[@"level"] integerValue];
    NSArray      *nextLevelMemAry = nil;
    NSInteger maxCount = [self.levelMaxSpouceCountAry[i] integerValue];//层级最大配偶数
    float y = maxCount*btnH + spouseDis*abs(maxCount - 1);
    nextLevelMemAry = self.grandChildrenData;//此处只是为了画配偶的时候确定坐标用，只要nextLevelMemAry.count不为0就行，数据不准确
    
    NSString *memberId = levelMemberAry[0][0][@"admin"][@"memberId"];
    NSArray  *grandAry = self.grandChildrenData[0][@"members"][memberId];//中轴线的子女
    
    for (int j = 0; j < 3; j ++) {
        
        if (j == 0 && [levelMemberAry[j] count] != 0) {
            
            NSArray  *spouseAry = levelMemberAry[j][0][@"spouse"];
            NSString *parentId = levelMemberAry[j][0][@"admin"][@"parentId"];
            
            forePoint = upLevelDownPoint;
            upLevelUpPoint = forePoint;
            CGContextMoveToPoint(context, forePoint.x,forePoint.y);
            forePoint = CGPointMake(forePoint.x, forePoint.y+y/2+spouseUpH-btnHeight1);
            CGContextAddLineToPoint(context, forePoint.x,forePoint.y);//btn上方
            
            [self addBtn:CGPointMake(forePoint.x - btnWith1, forePoint.y) AndDic:levelMemberAry[j][0][@"admin"] AndKinParentId:parentId AndTag:i+1 AndDirection:0 AndIndex:0 AndSpouse:NO];
            
            if (grandAry.count > 0) {//中轴线有孩子
                
                forePoint = CGPointMake(forePoint.x, forePoint.y + btnH);
                CGContextMoveToPoint(context, forePoint.x,forePoint.y);
                forePoint = CGPointMake(forePoint.x, forePoint.y + y/2+spouseDownH-btnHeight1);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);//btn下方
                upLevelDownPoint = CGPointMake(forePoint.x, forePoint.y);
            }
            else if (grandAry.count == 0){
                
                forePoint = CGPointMake(forePoint.x, forePoint.y + btnH);
                forePoint = CGPointMake(forePoint.x, forePoint.y + y/2+spouseDownH-btnHeight1);
                upLevelDownPoint = CGPointMake(forePoint.x, forePoint.y);
            }
            
            [self drawMiddleContext:context AndData:spouseAry AndKinParentId:@"" AndNextLevelMember:nextLevelMemAry andMaxSpouseCount:maxCount AndTag:i+1 AndLevel:level];
        }
        
        if (j == 1 && [levelMemberAry[j] count] != 0) {//左边
            
            NSArray *leftMemberAry = levelMemberAry[j];
            NSString *parentId = leftMemberAry[0][@"admin"][@"parentId"];
            float xx1 = 0;
            for (int k = 0; k < leftMemberAry.count; k ++ ) {
                
                float xxF = [self.level1LeftDisAry[k] floatValue];
                forePoint = CGPointMake(upLevelUpPoint.x - xx1,upLevelUpPoint.y);
                CGContextMoveToPoint(context, forePoint.x, forePoint.y);
                forePoint = CGPointMake(forePoint.x - xxF,forePoint.y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                xx1 += xxF;
                forePoint = CGPointMake(forePoint.x, forePoint.y + y/2 + spouseUpH - btnHeight1);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                
                [self addBtn:CGPointMake(forePoint.x - btnWith1, forePoint.y) AndDic:leftMemberAry[k][@"admin"] AndKinParentId:parentId AndTag:i+1 AndDirection:1 AndIndex:k AndSpouse:NO];
                //画配偶
                NSArray *spouseAry = leftMemberAry[k][@"spouse"];
                
                [self drawSpouseAry:spouseAry AndContext:context AndKinParentId:@"" AndTag:i+1 AndDirection:1 AndIndex:k];
                
            }
            
        }
        
        if (j == 2 && [levelMemberAry[j] count] != 0) {//右边
            
            NSArray *rightMemberAry = levelMemberAry[j];
            NSString *parentId = rightMemberAry[0][@"admin"][@"parentId"];
            float xx = 0;
            for (int k = 0; k < rightMemberAry.count; k ++ ) {
                
                forePoint = CGPointMake(upLevelUpPoint.x + xx ,upLevelUpPoint.y);
                
                CGContextMoveToPoint(context, forePoint.x, forePoint.y);
                float xxF = [self.level1RightDisAry[k] floatValue];
                forePoint = CGPointMake(forePoint.x + xxF, forePoint.y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                xx += xxF;
                forePoint = CGPointMake(forePoint.x, forePoint.y + y/2 + spouseUpH - btnHeight1);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                [self addBtn:CGPointMake(forePoint.x - btnWith1, forePoint.y) AndDic:rightMemberAry[k][@"admin"] AndKinParentId:parentId AndTag:i+1 AndDirection:2 AndIndex:k AndSpouse:NO];
                NSString *Key = rightMemberAry[k][@"admin"][@"memberId"];//自己的memberId;
                if ([self.grandChildrenData[0][@"members"][Key] count] > 0) {//有孩子，btn下方线要画
                    CGContextMoveToPoint(context, forePoint.x, forePoint.y + btnH);
                    CGContextAddLineToPoint(context, forePoint.x,upLevelDownPoint.y);
                    [downPointary addObject:[NSValue valueWithCGPoint:CGPointMake(forePoint.x, upLevelDownPoint.y)]];
                    [memberIdKeysAry addObject:Key];
                }
                //画配偶
                NSArray *spouseAry = rightMemberAry[k][@"spouse"];
                
                [self drawSpouseAry:spouseAry AndContext:context AndKinParentId:@"" AndTag:i+1 AndDirection:2 AndIndex:k];
            }
        }
    }
    [self drawGrandChildren:context];

}
-(void)drawGrandChildren:(CGContextRef)context{
    
    
    NSDictionary *levelDic = self.grandChildrenData[0];
    NSDictionary *levelMemberDic = levelDic[@"members"];
    NSInteger  level = [levelDic[@"level"] integerValue];
    NSInteger maxCount = [[self.levelMaxSpouceCountAry lastObject] integerValue];//层级最大配偶数
    float y = maxCount*btnH + spouseDis*abs(maxCount - 1);
    
    NSString *memberId = [self.familyData lastObject][@"members"][0][0][@"admin"][@"memberId"];
    NSArray  *grandAry1 = levelMemberDic[memberId];//中轴线的子女
    if (grandAry1.count > 0) {
        [downPointary insertObject:[NSValue valueWithCGPoint:upLevelDownPoint] atIndex:0];
        [memberIdKeysAry insertObject:memberId atIndex:0];
    }
    
    for (int j = 0; j < downPointary.count; j ++) {
        CGPoint downPoint = [downPointary[j] CGPointValue];
        NSString *memberId = memberIdKeysAry[j];
        NSArray *grandAry = levelMemberDic[memberId];
        NSString *parentId = memberId;
        
        for(int i = 0;i < grandAry.count; i ++ ){
            if (i == 0 &&[grandAry[0] count] !=0) {
                
                CGContextMoveToPoint(context, downPoint.x, downPoint.y);
                NSArray  *spouseAry = grandAry[0][0][@"spouse"];
                forePoint = downPoint;
                upLevelDownPoint = forePoint;
                forePoint = CGPointMake(forePoint.x, forePoint.y+y/2+spouseUpH-btnHeight1);
                
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);//btn上方
                
                [self addBtn:CGPointMake(forePoint.x - btnWith1, forePoint.y) AndDic:grandAry[0][0][@"admin"] AndKinParentId:parentId AndTag:self.familyData.count + 1 AndDirection:0 AndIndex:0 AndSpouse:NO];
                [self drawMiddleContext:context AndData:spouseAry AndKinParentId:parentId AndNextLevelMember:[NSArray array] andMaxSpouseCount:maxCount AndTag:self.familyData.count + 1 AndLevel:level];
                
            }
            if (i == 1 &&[grandAry[i] count] != 0) {
                
                NSArray *leftMemberAry = grandAry[i];
                float xx = 0;
                float xxF = 0;
                for (int k = 0; k < leftMemberAry.count; k ++ ) {
                    //有无配偶区分开
                    if (k == 0 && [grandAry[0] count] != 0) {
                        xxF = [self spouseCount:grandAry[0][0][@"spouse"]];
                        xx = [self spouseCount:grandAry[0][0][@"spouse"]];
                        forePoint = CGPointMake(downPoint.x,downPoint.y);
                    }else if (k == 0 && [grandAry[0] count] == 0){
                        xxF = peerLineNoSpouse;
                        xx = peerLineNoSpouse;
                        forePoint = CGPointMake(downPoint.x,downPoint.y);
                    }else{
                        xxF = [self spouseCount:leftMemberAry[k-1][@"spouse"]];
                        forePoint = CGPointMake(downPoint.x - xx ,downPoint.y);
                        xx = xx + xxF;
                    }
                    CGContextMoveToPoint(context, forePoint.x, forePoint.y);
                    forePoint = CGPointMake(forePoint.x - xxF, forePoint.y);
                    CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                    forePoint = CGPointMake(forePoint.x, forePoint.y + y/2 + spouseUpH - btnHeight1);
                    CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                    [self addBtn:CGPointMake(forePoint.x - btnWith1, forePoint.y) AndDic:leftMemberAry[k][@"admin"] AndKinParentId:parentId AndTag:self.familyData.count + 1 AndDirection:1 AndIndex:k AndSpouse:NO];
                    NSArray *spouseAry = leftMemberAry[k][@"spouse"];
                    
                    [self drawSpouseAry:spouseAry AndContext:context AndKinParentId:parentId AndTag:self.familyData.count + 1 AndDirection:1 AndIndex:k];
                }
            }
            if (i == 2 &&[grandAry[i] count] != 0) {
                
                NSArray *rightMemberAry = grandAry[i];
                
                float xx = 0;
                float xxF = 0;
                
                for (int k = 0; k < rightMemberAry.count; k ++ ) {
                    
                    xxF = [self spouseCount:rightMemberAry[k][@"spouse"]];
                    forePoint = CGPointMake(downPoint.x + xx ,downPoint.y);
                    xx = xx + xxF;
                    CGContextMoveToPoint(context, forePoint.x, forePoint.y);
                    forePoint = CGPointMake(forePoint.x + xxF, forePoint.y);
                    CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                    forePoint = CGPointMake(forePoint.x, forePoint.y + y/2 + spouseUpH - btnHeight1);
                    CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                    [self addBtn:CGPointMake(forePoint.x - btnWith1, forePoint.y) AndDic:rightMemberAry[k][@"admin"] AndKinParentId:parentId AndTag:self.familyData.count + 1 AndDirection:2 AndIndex:k AndSpouse:NO];
                    //画配偶
                    NSArray *spouseAry = rightMemberAry[k][@"spouse"];
                    [self drawSpouseAry:spouseAry AndContext:context AndKinParentId:parentId AndTag:self.familyData.count + 1 AndDirection:2 AndIndex:k];
                }
            }
        }
    }
    
}
-(float)spouseCount:(NSArray *)spouceAry{
    
    if (spouceAry.count == 0) {
        return peerLineNoSpouse;
    }else{
        return peerLineW;
    }
}


//中轴线的配偶
-(void)drawMiddleContext:(CGContextRef)context AndData:(NSArray *)spouseAry AndKinParentId:(NSString *)parentId AndNextLevelMember:(NSArray *)nextLevelMemAry andMaxSpouseCount:(NSInteger)count AndTag:(NSInteger)tag AndLevel:(NSInteger)level{
    

    float y = count*btnH + spouseDis*abs(count - 1);
    if (nextLevelMemAry.count > 0) {
        forePoint = CGPointMake(upLevelDownPoint.x - btnWith1, upLevelDownPoint.y-y/2-spouseDownH);
    }else{
        forePoint = CGPointMake(upLevelDownPoint.x - btnWith1, upLevelDownPoint.y + y/2 + spouseUpH);
    }
    if (spouseAry.count > 1) {
        
        CGContextMoveToPoint(context, forePoint.x,forePoint.y);
        forePoint = CGPointMake(forePoint.x - spouseLineW, forePoint.y);
        CGContextAddLineToPoint(context, forePoint.x,forePoint.y);//固定配偶线
        spouseMidPoint = forePoint;
        
        if (spouseAry.count%2 == 0) {//配偶个数为偶数
            ///画竖线
            CGContextMoveToPoint(context, spouseMidPoint.x,spouseMidPoint.y);
            float y = (spouseAry.count/2 - 1)*(btnH + spouseDis) + btnHeight1 + 0.5*spouseDis;
            forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y - y);
            CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
            ///
            for (int k = 0; k < spouseAry.count/2; k ++ ) {
                //
                float y = (spouseAry.count/2 - k - 1)*(btnH + spouseDis) + btnHeight1 + 0.5*spouseDis;
                forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y - y);
                
                CGContextMoveToPoint(context, forePoint.x,forePoint.y);
                forePoint = CGPointMake(forePoint.x - spouseLineW1, forePoint.y);
                CGContextAddLineToPoint(context, forePoint.x ,forePoint.y);
                [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:spouseAry[k] AndKinParentId:parentId AndTag:tag AndDirection:0 AndIndex:0 AndSpouse:YES];
                
            }
            CGContextMoveToPoint(context, spouseMidPoint.x,spouseMidPoint.y);
            float y1 = (spouseAry.count - 1 - spouseAry.count/2)*(btnH + spouseDis) + btnHeight1 + 0.5*spouseDis;
            forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y + y1);
            CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
            
            for (int k = spouseAry.count/2; k < spouseAry.count; k ++ ) {
                
                float y = (spouseAry.count - k - 1)*(btnH + spouseDis) + btnHeight1 + 0.5*spouseDis;
                forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y + y);
                CGContextMoveToPoint(context, forePoint.x,forePoint.y);
                forePoint = CGPointMake(forePoint.x - spouseLineW1, forePoint.y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:spouseAry[k] AndKinParentId:parentId AndTag:tag AndDirection:0 AndIndex:0 AndSpouse:YES];
                
            }
        }else if (spouseAry.count%2 == 1){
            
            CGContextMoveToPoint(context, spouseMidPoint.x,spouseMidPoint.y);
            float y = (spouseAry.count/2) * (btnH + spouseDis);
            forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y - y);
            CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
            for (int k = 0; k < spouseAry.count/2; k ++ ) {
                
                float y = (spouseAry.count/2 - k)*(btnH + spouseDis);
                forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y - y);
                CGContextMoveToPoint(context, forePoint.x, forePoint.y);
                
                forePoint = CGPointMake(forePoint.x - spouseLineW1, forePoint.y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:spouseAry[k] AndKinParentId:parentId AndTag:tag AndDirection:0 AndIndex:0 AndSpouse:YES];
            }
            CGContextMoveToPoint(context, spouseMidPoint.x,spouseMidPoint.y);
            forePoint = CGPointMake(spouseMidPoint.x - spouseLineW1, spouseMidPoint.y);
            CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
            [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:spouseAry[spouseAry.count/2] AndKinParentId:parentId AndTag:tag AndDirection:0 AndIndex:0 AndSpouse:YES];
            
            
            CGContextMoveToPoint(context, spouseMidPoint.x,spouseMidPoint.y);
            float y1 = (spouseAry.count - spouseAry.count/2 - 1)*(btnH + spouseDis);
            forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y + y1);
            CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
            
            for (int k = spouseAry.count/2 + 1; k < spouseAry.count; k ++ ) {
                
                float y = (spouseAry.count - k)*(btnH + spouseDis);
                forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y + y);
                CGContextMoveToPoint(context, forePoint.x, forePoint.y);
                
                forePoint = CGPointMake(forePoint.x - spouseLineW1, forePoint.y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:spouseAry[k] AndKinParentId:parentId AndTag:tag AndDirection:0 AndIndex:0 AndSpouse:YES];
                
            }
        }
        
    }else if (spouseAry.count == 1){
        
        CGContextMoveToPoint(context, forePoint.x,forePoint.y);
        forePoint = CGPointMake(forePoint.x - spouseLineW - spouseLineW1, forePoint.y);
        CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
        [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:spouseAry[0] AndKinParentId:parentId AndTag:tag AndDirection:0 AndIndex:0 AndSpouse:YES];
    }else if (spouseAry.count == 0 && level <= 0 && [WHOFAMILYID isEqualToString:USERID]){//中轴线上的level < 0的必须有配偶，没填就给个默认的
        
        if (level == 0 && [[_familyData lastObject][@"level"]integerValue] == 0) {
            return;
        }
        CGContextMoveToPoint(context, forePoint.x,forePoint.y);
        forePoint = CGPointMake(forePoint.x - spouseLineW - spouseLineW1, forePoint.y);
        CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
        [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:nil AndKinParentId:parentId AndTag:tag AndDirection:0 AndIndex:0 AndSpouse:YES];
    }
}

/**
 *	画配偶
 */
-(void)drawSpouseAry:(NSArray *)spouseAry AndContext:(CGContextRef)context AndKinParentId:(NSString *)parentId AndTag:(NSInteger)tag AndDirection:(NSInteger)direction AndIndex:(NSInteger)index
{
    
    if (spouseAry.count >= 1) {
        
        forePoint = CGPointMake(forePoint.x - btnWith1, forePoint.y + btnHeight1);
        CGContextMoveToPoint(context, forePoint.x, forePoint.y);
        spouseMidPoint = CGPointMake(forePoint.x - spouseLineW, forePoint.y);
        forePoint =spouseMidPoint;
        CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
//#warning 线画重
        if (spouseAry.count%2 == 0) {//配偶个数为偶数
            for (int m = 0; m < spouseAry.count/2; m ++ ) {
                
                CGContextMoveToPoint(context, spouseMidPoint.x,spouseMidPoint.y);
                float y = (spouseAry.count/2 - m - 1)*(btnH + spouseDis) + btnHeight1 + 0.5*spouseDis;
                forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y - y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                forePoint = CGPointMake(forePoint.x - spouseLineW1, forePoint.y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:spouseAry[m] AndKinParentId:parentId AndTag:tag AndDirection:direction AndIndex:index AndSpouse:YES];
                
            }
            for (int m = spouseAry.count/2; m < spouseAry.count; m ++ ) {
                
                CGContextMoveToPoint(context, spouseMidPoint.x,spouseMidPoint.y);
                float y = (spouseAry.count - m - 1)*(btnH + spouseDis) + btnHeight1 + 0.5*spouseDis;
                forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y + y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                forePoint = CGPointMake(forePoint.x - spouseLineW1, forePoint.y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:spouseAry[m] AndKinParentId:parentId AndTag:tag AndDirection:direction AndIndex:index AndSpouse:YES];
                
            }
            
        }else if (spouseAry.count%2 == 1){//配偶个数为奇数
            
            for (int m = 0; m < spouseAry.count/2; m ++ ) {
                
                CGContextMoveToPoint(context, spouseMidPoint.x,spouseMidPoint.y);
                float y = (spouseAry.count/2 - m)*(btnH + spouseDis);
                
                forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y - y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                forePoint = CGPointMake(forePoint.x - spouseLineW1, forePoint.y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:spouseAry[m] AndKinParentId:parentId AndTag:tag AndDirection:direction AndIndex:index AndSpouse:YES];
            }
            CGContextMoveToPoint(context, spouseMidPoint.x,spouseMidPoint.y);
            forePoint = CGPointMake(spouseMidPoint.x - spouseLineW1, spouseMidPoint.y);
            CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
            [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:spouseAry[spouseAry.count/2] AndKinParentId:parentId AndTag:tag AndDirection:direction AndIndex:index AndSpouse:YES];
            
            for (int m = spouseAry.count/2 + 1; m < spouseAry.count; m ++ ) {
                
                CGContextMoveToPoint(context, spouseMidPoint.x,spouseMidPoint.y);
                float y = (spouseAry.count - m)*(btnH + spouseDis);
                forePoint = CGPointMake(spouseMidPoint.x, spouseMidPoint.y + y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                forePoint = CGPointMake(forePoint.x - spouseLineW1, forePoint.y);
                CGContextAddLineToPoint(context, forePoint.x,forePoint.y);
                [self addBtn:CGPointMake(forePoint.x - btnW, forePoint.y - btnHeight1) AndDic:spouseAry[m] AndKinParentId:parentId AndTag:tag AndDirection:direction AndIndex:index AndSpouse:YES];
            }
        }
    }

}
-(void)addBtn:(CGPoint)point AndDic:(NSDictionary *)dic AndKinParentId:(NSString *)parentId AndTag:(NSInteger)tag AndDirection:(NSInteger)direction AndIndex:(NSInteger)index AndSpouse:(BOOL)spouse{
    
    FamilyMemberButton *familyBtn = [FamilyMemberButton buttonWithType:UIButtonTypeCustom];
    familyBtn.frame = CGRectMake(point.x, point.y, btnW, btnH);
    
    [self addSubview:familyBtn];
    
    
    if (dic == nil && spouse && [WHOFAMILYID isEqualToString:USERID]) {
        
        [familyBtn setBackgroundColor:[UIColor colorWithRed:239/255. green:158/255. blue:156/255. alpha:1.0]];
        [familyBtn.headerImg setImage:[UIImage imageNamed:@"mrtx"]];
        familyBtn.tag = tag;
        familyBtn.isSpouse = spouse;
        [familyBtn addTarget:self action:@selector(noInfoBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        return;
    }
    if ([dic[@"sex"] integerValue] == 1) {
        [familyBtn setBackgroundColor:[UIColor colorWithRed:165/255. green:207/255. blue:255/255. alpha:1.0]];
        
    }else if ([dic[@"sex"] integerValue] == 2){
        [familyBtn setBackgroundColor:[UIColor colorWithRed:239/255. green:158/255. blue:156/255. alpha:1.0]];
    }else if ([dic[@"sex"] integerValue] == 0){
        [familyBtn setBackgroundColor:[UIColor greenColor]];
    }
    if ([self.whoFamilyDic[@"memberId"] isEqualToString:dic[@"memberId"]]) {
        [familyBtn setBackgroundColor:[UIColor colorWithRed:177/255. green:202/255. blue:84/255. alpha:1.0]];
    }
    if ([dic[@"nickName"] isEqualToString:@"本人"]) {
    }
    if ([dic[@"associated"] integerValue] == 0) {
        
        NSString *userId = self.whoFamilyDic[@"userId"];
        userId = [userId stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if ([userId isEqualToString:USERID]) {//我的家谱，我的家谱里面所有的数据都可以点击
            [familyBtn addTarget:self action:@selector(familyBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }else if ([dic[@"associated"] integerValue] == 1){
        
        if (![dic[@"memberId"] isEqualToString:dic[@"userId"]]) {
            [familyBtn addGuanlian];
        }
        [familyBtn addTarget:self action:@selector(familyBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    if ([dic[@"headPortrait"] isEqualToString:@""]) {
        
        [familyBtn.headerImg setImage:[UIImage imageNamed:@"mrtx"]];
        
    }else{
        
        [familyBtn.headerImg setImageWithURL:[NSURL URLWithString:dic[@"headPortrait"]] placeholderImage:[UIImage imageNamed:@"mrtx"]];
    }
    familyBtn.nameLabel.text = dic[@"name"];
    NSString *birth = [Utilities convertTimestempToDateWithString2:dic[@"birthDate"]];
    familyBtn.birthLabel.text = birth;
    familyBtn.level = [dic[@"level"] integerValue];
    familyBtn.direction = direction;
    familyBtn.index = index;
    familyBtn.tag = tag;
    familyBtn.isSpouse = spouse;
    familyBtn.memberID = dic[@"memberId"];
    //
    familyBtn.parentId = parentId;//此处，孙子辈配偶的父亲id为空，把admin的父亲id当作配偶的id，是为了方便后续找到对应的配偶信息；其他层级parentId正常

    //
    
    if ([dic[@"level"] integerValue] == 0 && [dic[@"memberId"] isEqualToString:_whoFamilyDic[@"memberId"]]) {
        myRect = familyBtn.frame;
    }
    
}

-(void)familyBtnPressed:(FamilyMemberButton *)btn{
    
    NSDictionary *infoDic = nil;
    NSArray *ary = nil;
    
    if (btn.tag == self.familyData.count + 1) {
        ary = self.grandChildrenData[0][@"members"][btn.parentId][btn.direction];
    }else{
        ary = self.familyData[btn.tag-1][@"members"][btn.direction];
    }

    NSDictionary *dic = ary[btn.index];
    if (btn.isSpouse) {
        NSArray *spouseAry = dic[@"spouse"];
        for(id obj in spouseAry){
            NSString *memberId = obj[@"memberId"];
            if ([btn.memberID isEqualToString:memberId]) {
                infoDic = obj;
                break;
            }
        }
    }else{
        infoDic = dic[@"admin"];
    }
    NSString *userId = self.whoFamilyDic[@"userId"];
    userId = [userId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    BOOL isOther = YES;
    if ([userId isEqualToString:USERID]) {
        
        isOther = NO;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:infoDic,@"info",[NSNumber numberWithBool:isOther],@"isOther", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"familyBtnPressed" object:dict];
}
-(void)noInfoBtnPressed:(FamilyMemberButton *)btn{
    
    if (btn.tag == 1002) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请先完善其配偶信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }else if(btn.tag == 1001){
        NSDictionary *dic = self.familyData[0][@"members"][0][0][@"admin"];
        NSMutableDictionary *dic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:dic,@"infoDic",[NSNumber numberWithInt:btn.tag],@"tag", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noInfoFamilyBtnPressed" object:dic2];
        
    }else{
        NSDictionary *dic1 = self.familyData[btn.tag - 1][@"members"][0][0][@"admin"];
        NSMutableDictionary *dic3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:dic1,@"infoDic",[NSNumber numberWithInt:btn.tag],@"tag", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noInfoFamilyBtnPressed" object:dic3];

    }
   

}
@end
