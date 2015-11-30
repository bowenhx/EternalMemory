//
//  FamliyTreeViewController2.h
//  EternalMemory
//
//  Created by kiri on 13-9-13.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavBarController.h"
#import "MBProgressHUD.h"
#import "DrawTreeLineView.h"
#import <QuartzCore/QuartzCore.h>

@interface FamliyTreeViewController2 : CustomNavBarController<
    ASIHTTPRequestDelegate,
    NavBarDelegate,
    UIScrollViewDelegate,
    UIAlertViewDelegate,
    setScrollViewOffSet>{
        
        ASIFormDataRequest      *_request;
        UIScrollView            *_scrollView;
        DrawTreeLineView        *drawTreeLineView;
        NSMutableArray          *_familyData;//level <= 1的家谱人员数据
        NSMutableArray          *_grandChildrenData;//level > 1的家谱数据，即孙子辈的数据
        NSInteger               leftMaxCount;//level <= 1中轴线左边最大血亲人数；用于计算画布宽度
        NSInteger               rightMaxCount;//level <= 1//中轴线右边最大血亲人数；用于计算画布宽度
        NSMutableArray          *levelMaxSpouceCountAry;//层级最大配偶个数，用于计算画布高度
        NSInteger               levelMaxSpouceCount;
        NSInteger               leftCount2;//level=2层级左边最大血亲数目
        NSInteger               rightCount2;//level=2层级右边最大血亲数目
        NSInteger               level2Count;
        MBProgressHUD           *_mb;
        float                   leftMaxW;
        float                   rightMAxW;
        
        NSMutableArray          *tempFamilyData;
        NSMutableArray          *tempGrandData;
        NSMutableArray          *templevelMaxSpouceCountAry;
        NSInteger               tempLeftMaxCount;
        NSInteger               tempRightMaxCount;
        float                   tempLeftMaxW;
        float                   tempRightMaxW;
        NSMutableArray          *tempLevel1RightDisAry;
        NSMutableArray          *tempLevel1LeftDisAry;
        CGSize                  tempSize;
        
        CGPoint                 contentOffSet;
        
        NSMutableArray          *level1RightDisAry;
        NSMutableArray          *level1LeftDisAry;
        
        float                   leftMaxW1;//level<0的左边画布最大长度
        float                   rightmaxW1;
        

    
}
@property (assign)BOOL   comeFirst;

@end
