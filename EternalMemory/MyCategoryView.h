//
//  MyCategoryView.h
//  BookShelf
//
//  Created by SuperAdmin on 13-11-7.
//  Copyright (c) 2013年 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSBookView.h"

@protocol MycategoryViewDelegate <NSObject>

//添加新的分类
-(void)addNewCategory;
//选择分类查看内容
-(void)showCategoryInfo;
//删除分类
-(void)deleteCategoryAtIndex:(NSInteger)index;

@end

@interface MyCategoryView : UIView<UITextViewDelegate>
{
    UIButton        *deleteButton;//分类删除按钮
    UIImageView     *bgImageView;//分类背景图
    UITextView      *nameTextView;//分类名称
    UILabel         *numLabel;//分类中内容的个数
    
    id<MycategoryViewDelegate> _delegate;
    
    
}


@property (nonatomic, assign) BOOL edit;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL hideCategoryInfo;
@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, strong) id<MycategoryViewDelegate> delegate;

@end
