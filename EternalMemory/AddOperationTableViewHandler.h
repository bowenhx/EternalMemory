//
//  AddOperationTableViewHandler.h
//  EternalMemory
//
//  Created by Liu Zhuang on 13-9-15.
//  Copyright (c) 2013年 sun. All rights reserved.
//

static NSString * const kLabelAttributesTextColor = @"kLabelAttributesColor";
static NSString * const kLabelAttributesTextFont  = @"kLabelAttributesFont";


#import <Foundation/Foundation.h>

@interface AddOperationTableViewHandler : NSObject<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NSDictionary  *textLabelAttributes;

@end
