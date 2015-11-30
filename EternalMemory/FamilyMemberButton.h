//
//  FamilyMemberButton.h
//  EternalMemory
//
//  Created by kiri on 13-9-16.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FamilyMemberButton : UIButton


@property (nonatomic,retain) UIImageView *headerImg;
@property (nonatomic,retain) UILabel     *nameLabel;
@property (nonatomic,retain) UILabel     *birthLabel;

//一下属性用于标记btn，查看详情时查找对应数据，传递到二级界面
@property (assign)           NSInteger   level;//层级
@property (assign)           NSInteger   direction;//1:左边  0：中轴  2：右边
@property (assign)           NSInteger   index;//左边第几个，右边第几个
@property (assign)           NSInteger   isSpouse;//是否是配偶，0不是，1是
@property (nonatomic,retain) NSString    *memberID;//唯一的
@property (nonatomic,retain) NSString    *parentId;//父亲id，孙子辈用的
-(void)addGuanlian;
@end
