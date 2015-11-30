//
//  PhotoCategoryFlowLayout.m
//  EternalMemory
//
//  Created by FFF on 14-3-4.
//  Copyright (c) 2014年 sun. All rights reserved.
//

#import "PhotoCategoryFlowLayout.h"

@implementation PhotoCategoryFlowLayout

- (instancetype) init {
    if (self = [super init]) {
        self.minimumLineSpacing = 10;
        self.minimumInteritemSpacing = 5;
        self.itemSize = CGSizeMake(90, 90);
        self.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    return self;
}

@end
