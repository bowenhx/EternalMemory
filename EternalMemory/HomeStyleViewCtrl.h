//
//  HomeStyleViewCtrl.h
//  EternalMemory
//
//  Created by Guibing Li on 13-5-27.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFOpenFlowView.h"
#import "CustomNavBarController.h"
@interface HomeStyleViewCtrl : CustomNavBarController<AFOpenFlowViewDelegate,AFOpenFlowViewDataSource>

@property(nonatomic,assign)NSInteger        flowViewIndex;
@end
