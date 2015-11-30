//
//  DrawTreeLineView.h
//  EternalMemory
//
//  Created by kiri on 13-9-13.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol setScrollViewOffSet <NSObject>

-(void)setTheScrollViewOffSet:(CGPoint)point;

@end
@interface DrawTreeLineView : UIView{
    
    CGRect         btnFrame;//所画第一个按钮的坐标
    CGPoint        upLevelUpPoint;//用来记录上一层上方的点;
    CGPoint        upLevelDownPoint;//用来记录上一层下方结束点的坐标；
    CGPoint        forePoint;
    CGPoint        spouseMidPoint;
    NSMutableArray *downPointary;//level = 1中轴线和右边的btn线下方的点
    NSMutableArray *memberIdKeysAry;
    CGRect         myRect;
    CGPoint        upLevelDownPoint0;

}

@property (nonatomic,retain) NSArray        *familyData;//level <= 1的家谱人员数据
@property (nonatomic,retain) NSArray        *grandChildrenData;//level > 1的家谱数据，即孙子辈的数据
@property (nonatomic,retain) NSArray        *levelMaxSpouceCountAry;//层级最大配偶个数
@property (nonatomic,retain) NSDictionary   *whoFamilyDic;//谁的家谱，“谁”的信息
@property (assign)           NSInteger      leftMaxCount;
@property (assign)           NSInteger      rightMaxCount;
@property (assign)           float          leftMaxW;
@property (assign)           float          rightMaxW;
@property (nonatomic,retain) NSMutableArray *level1RightDisAry;
@property (nonatomic,retain) NSMutableArray *level1LeftDisAry;
@property (assign)id<setScrollViewOffSet>delegate;

@property (nonatomic,copy) void (^setContentOffSet)(float width,float height);



@end
